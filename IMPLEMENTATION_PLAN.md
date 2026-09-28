# PayrailsEx — Implementation Plan

An Elixir SDK for the [Payrails API](https://docs.payrails.com/reference/getoauthtoken).

## Goals

- Cover **all** public Payrails API endpoints (merchant, payment, vault, dispute)
- Target **Elixir 1.19.5** (OTP 27+)
- **Zero external dependencies** by default — use Elixir/Erlang stdlib only:
  - `JSON` module (built-in since Elixir 1.18) for encoding/decoding
  - Erlang `:httpc` (from `inets`) as the default HTTP adapter
  - Erlang `:crypto` for HMAC-SHA256 webhook signature verification
  - Erlang `:ssl` with certificate store from `:public_key` / CAStore
- Provide a pluggable **HTTP client behaviour** so users can swap in Req, Finch, etc.
- Idiomatic Elixir: structs for config, `{:ok, result} | {:error, reason}` returns, no exceptions for API errors

---

## 1. Project Structure

```
payrails_ex/
├── lib/
│   ├── payrails.ex                        # Top-level convenience / facade
│   ├── payrails/
│   │   ├── client.ex                      # Client struct, request execution, token management
│   │   ├── config.ex                      # Configuration struct & validation
│   │   ├── error.ex                       # Error struct (maps API error format)
│   │   ├── response.ex                    # Response struct wrapping status + body + headers
│   │   ├── paginator.ex                   # Lazy cursor-based pagination via Stream
│   │   ├── webhook.ex                     # Signature verification (HMAC-SHA256)
│   │   │
│   │   ├── http/
│   │   │   ├── behaviour.ex              # HTTP client behaviour (request/1 callback)
│   │   │   └── default.ex                # Default adapter using Erlang :httpc
│   │   │
│   │   ├── auth/
│   │   │   ├── auth.ex                   # OAuth token + vault access token endpoints
│   │   │   └── token_store.ex            # In-memory token cache with auto-refresh
│   │   │
│   │   ├── client_init/
│   │   │   └── client_init.ex            # SDK client init, vault client init, vault public info
│   │   │
│   │   ├── workflows/
│   │   │   └── workflows.ex              # Workflow configuration CRUD + versioning
│   │   │
│   │   ├── executions/
│   │   │   └── executions.ex             # Create / list / get executions, history, actions
│   │   │
│   │   ├── actions/
│   │   │   └── actions.ex                # Payment actions: authorize, capture, cancel,
│   │   │                                 # refund, confirm, payout, fraud_update,
│   │   │                                 # lookup, start_payment_session
│   │   │                                 # + list/get action records
│   │   │
│   │   ├── payments/
│   │   │   └── payments.ex               # List / get payments, operations, operation logs
│   │   │
│   │   ├── instruments/
│   │   │   └── instruments.ex            # CRUD on payment instruments
│   │   │
│   │   ├── tokens/
│   │   │   └── tokens.ex                 # CRUD on tokens + provider token ops
│   │   │
│   │   ├── network_tokens/
│   │   │   └── network_tokens.ex         # Provision network token, generate cryptogram
│   │   │
│   │   ├── card_info/
│   │   │   └── card_info.ex              # BIN lookup
│   │   │
│   │   ├── providers/
│   │   │   └── providers.ex              # List / get providers, provider config CRUD,
│   │   │                                 # authenticated configs, onboarding URL
│   │   │
│   │   ├── rulesets/
│   │   │   └── rulesets.ex               # CRUD on rulesets
│   │   │
│   │   ├── holders/
│   │   │   └── holders.ex               # List / create / get holders
│   │   │
│   │   ├── workspaces/
│   │   │   └── workspaces.ex             # Create / list / get workspaces
│   │   │
│   │   ├── dropin_links/
│   │   │   └── dropin_links.ex           # CRUD on drop-in payment links
│   │   │
│   │   ├── files/
│   │   │   └── files.ex                  # Upload / get files
│   │   │
│   │   ├── reports/
│   │   │   └── reports.ex                # Reports + report runs
│   │   │
│   │   ├── fraud/
│   │   │   └── fraud.ex                  # Fraud checks, operations, operation logs
│   │   │
│   │   ├── three_ds/
│   │   │   └── three_ds.ex              # 3DS records, operations, operation logs
│   │   │
│   │   ├── reconciliation/
│   │   │   └── reconciliation.ex         # Bulk manual reconciliation
│   │   │
│   │   ├── audit_logs/
│   │   │   └── audit_logs.ex             # API logs listing + event retrieval
│   │   │
│   │   ├── sso/
│   │   │   └── sso.ex                    # SSO connection CRUD + SAML configs
│   │   │
│   │   ├── vault/
│   │   │   ├── proxy.ex                  # Vault proxy + outbound connection invocation
│   │   │   ├── connections.ex            # Vault connection CRUD + versioning
│   │   │   └── records.ex               # Records, fields, tokenize / detokenize
│   │   │
│   │   └── disputes/
│   │       ├── disputes.ex               # List / get disputes, activities, documents
│   │       ├── defense.ex                # Defend, accept, evidence upload/submit/list/download
│   │       ├── representment.ex          # Generate/regenerate plan, submit evidence,
│   │       │                             # generate PDF, edit sections, download bundle
│   │       ├── tags.ex                   # Tag CRUD, attach/detach/bulk operations
│   │       ├── runs.ex                   # Dispute service runs
│   │       └── alerts.ex                 # Alert enrollment, alert CRUD, descriptors,
│   │                                     # events, match payment, refund alert
│   │
├── test/
│   ├── test_helper.exs
│   ├── payrails/
│   │   ├── client_test.exs
│   │   ├── config_test.exs
│   │   ├── webhook_test.exs
│   │   ├── paginator_test.exs
│   │   ├── http/
│   │   │   └── default_test.exs
│   │   └── ...                           # Mirror of lib/ structure
│   └── support/
│       └── http_mock.ex                  # Mock HTTP adapter for tests
│
├── mix.exs
├── .formatter.exs
├── .gitignore
├── IMPLEMENTATION_PLAN.md
├── README.md
├── LICENSE
└── CHANGELOG.md
```

---

## 2. Core Infrastructure

### 2.1 Configuration (`Payrails.Config`)

```elixir
%Payrails.Config{
  base_url: "https://api.payrails.io",       # or staging URL
  vault_url: "https://api.vault.payrails.io", # vault-specific base URL
  client_id: "...",
  api_key: "...",
  http_client: Payrails.HTTP.Default,         # pluggable
  http_options: [],                            # adapter-specific options (timeouts, etc.)
  webhook_secret: nil                          # optional, for signature verification
}
```

- Validated at construction time; raises on missing required fields.
- `base_url` defaults to production; user overrides for staging/sandbox.

### 2.2 HTTP Client Behaviour (`Payrails.HTTP.Behaviour`)

```elixir
@callback request(method, url, headers, body, opts) ::
  {:ok, %{status: integer, headers: list, body: binary}} |
  {:error, term}
```

- **Default adapter** (`Payrails.HTTP.Default`): wraps Erlang `:httpc`.
  - Handles SSL configuration automatically (using OTP certificate verification).
  - Supports configurable timeouts.
- Users can implement the behaviour to plug in Req, Finch, Mint, etc.

### 2.3 Client (`Payrails.Client`)

Responsible for:
- Holding config + current bearer token state.
- Executing requests: builds URL, sets headers (`Authorization`, `x-idempotency-key`, `Content-Type`), encodes body with `JSON`, calls HTTP adapter, decodes response.
- Auto-generating `x-idempotency-key` UUIDs for mutating requests (POST/PUT/PATCH/DELETE) when not explicitly provided.
- Automatic token acquisition and refresh via `Payrails.Auth`.
- Returning `{:ok, decoded_body}` or `{:error, %Payrails.Error{}}`.

### 2.4 Error Handling (`Payrails.Error`)

Maps the Payrails error format:

```elixir
%Payrails.Error{
  id: "uuid",
  code: "error_code",
  detail: "Human-readable message",
  doc_url: "https://...",
  reason: %{},
  status: 401           # HTTP status code
}
```

- Network / adapter errors wrapped as `%Payrails.Error{code: "network_error", ...}`.
- JSON decode failures wrapped similarly.

### 2.5 Response (`Payrails.Response`)

```elixir
%Payrails.Response{
  status: 200,
  body: %{...},          # decoded JSON
  headers: [...]
}
```

Functions return `{:ok, body}` for direct use; `Payrails.Response` available for users who need headers/status.

### 2.6 Pagination (`Payrails.Paginator`)

- All `list*` endpoints use cursor-based pagination (`page[cursor]`, `page[size]`).
- Response includes `links.next` URL for the next page.
- `Paginator.stream/3` returns a `Stream` that lazily fetches pages.
- Each page yields its `results` list; the stream auto-follows `links.next` until exhausted.

### 2.7 Webhook Verification (`Payrails.Webhook`)

```elixir
Payrails.Webhook.verify(payload, signature, secret) :: :ok | {:error, :invalid_signature}
Payrails.Webhook.construct_event(payload, signature, secret) :: {:ok, map} | {:error, term}
```

- Uses `:crypto.mac/4` for HMAC-SHA256.
- Constant-time comparison via `:crypto.hash_equals/2` (available in OTP 27).

---

## 3. API Modules — Endpoint Coverage

Below is every endpoint grouped by module. Each function maps to one API call.

### 3.1 Auth (`Payrails.Auth`)

| Function | Method | Path |
|----------|--------|------|
| `get_token/2` | POST | `/auth/token/{clientId}` |
| `get_vault_access_token/1` | POST | `/token/auth` |

### 3.2 Client Init (`Payrails.ClientInit`)

| Function | Method | Path |
|----------|--------|------|
| `init/2` | POST | `/merchant/client/init` |
| `vault_init/2` | POST | `/merchant/vault/client/init` |
| `vault_public_info/1` | GET | `/merchant/vault/public-info` |

### 3.3 Workflow Configurations (`Payrails.Workflows`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/merchant/workflows` |
| `create/2` | POST | `/merchant/workflows` |
| `get_version/3` | GET | `/merchant/workflows/{code}/versions/{version}` |
| `update_version/4` | PATCH | `/merchant/workflows/{code}/versions/{version}` |
| `get_default_version/2` | GET | `/merchant/workflows/{code}/default` |
| `set_default_version/3` | PUT | `/merchant/workflows/{code}/default` |

### 3.4 Executions (`Payrails.Executions`)

| Function | Method | Path |
|----------|--------|------|
| `list/3` | GET | `/merchant/workflows/{workflowCode}/executions` |
| `create/3` | POST | `/merchant/workflows/{workflowCode}/executions` |
| `get/3` | GET | `/merchant/workflows/{workflowCode}/executions/{executionId}` |
| `get_history/3` | GET | `/merchant/workflows/{workflowCode}/executions/{executionId}/history` |
| `get_actions/3` | GET | `/merchant/workflows/{workflowCode}/executions/{executionId}/actions` |

### 3.5 Payment Actions (`Payrails.Actions`)

| Function | Method | Path |
|----------|--------|------|
| `lookup/3` | POST | `.../executions/{executionId}/lookup` |
| `start_payment_session/3` | POST | `.../executions/{executionId}/startPaymentSession` |
| `authorize/3` | POST | `.../executions/{executionId}/authorize` |
| `confirm/3` | POST | `.../executions/{executionId}/confirm` |
| `cancel/3` | POST | `.../executions/{executionId}/cancel` |
| `capture/3` | POST | `.../executions/{executionId}/capture` |
| `refund/3` | POST | `.../executions/{executionId}/refund` |
| `payout/3` | POST | `.../executions/{executionId}/payout` |
| `fraud_update/3` | POST | `.../executions/{executionId}/fraudUpdate` |
| `list/2` | GET | `/merchant/actions` |
| `get/2` | GET | `/merchant/actions/{actionId}` |

All action paths are nested under `/merchant/workflows/{workflowCode}/executions/{executionId}/`.

### 3.6 Payments (`Payrails.Payments`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/payment/payments` |
| `get/2` | GET | `/payment/payments/{paymentId}` |
| `get_operations/2` | GET | `/payment/payments/{paymentId}/operations` |
| `get_operation_logs/3` | GET | `/payment/payments/{paymentId}/operations/{operationId}/logs` |

### 3.7 Instruments (`Payrails.Instruments`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/payment/instruments` |
| `create/2` | POST | `/payment/instruments` |
| `get/2` | GET | `/payment/instruments/{instrumentId}` |
| `update/3` | PUT | `/payment/instruments/{instrumentId}` |
| `delete/2` | DELETE | `/payment/instruments/{instrumentId}` |

### 3.8 Tokens (`Payrails.Tokens`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/payment/instruments/{instrumentId}/tokens` |
| `create/3` | POST | `/payment/instruments/{instrumentId}/tokens` |
| `get/3` | GET | `/payment/instruments/{instrumentId}/tokens/{tokenId}` |
| `delete/3` | DELETE | `/payment/instruments/{instrumentId}/tokens/{tokenId}` |
| `get_from_provider/3` | GET | `/payment/instruments/{instrumentId}/tokens/provider/{providerId}` |
| `delete_from_provider/3` | DELETE | `/payment/instruments/{instrumentId}/tokens/provider/{providerId}` |

### 3.9 Network Tokens (`Payrails.NetworkTokens`)

| Function | Method | Path |
|----------|--------|------|
| `provision/3` | POST | `/payment/instruments/{instrumentId}/network-tokens` |
| `generate_cryptogram/3` | POST | `/payment/instruments/{instrumentId}/network-tokens/{tokenId}/cryptogram` |

### 3.10 Card Info (`Payrails.CardInfo`)

| Function | Method | Path |
|----------|--------|------|
| `bin_lookup/2` | GET | `/payment/card-info/bin/{bin}` |

### 3.11 Providers (`Payrails.Providers`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/payment/providers` |
| `get/2` | GET | `/payment/providers/{providerId}` |
| `list_active_configs/2` | GET | `/payment/providers/configs/active` |
| `create_config/2` | POST | `/payment/providers/configs` |
| `list_configs/2` | GET | `/payment/providers/configs` |
| `update_config/3` | PUT | `/payment/providers/configs/{configId}` |
| `get_config/2` | GET | `/payment/providers/configs/{configId}` |
| `patch_config/3` | PATCH | `/payment/providers/configs/{configId}` |
| `create_authenticated_config/2` | POST | `/payment/providers/configs/authenticated` |
| `update_authenticated_config/3` | PUT | `/payment/providers/configs/authenticated/{configId}` |
| `create_onboarding_url/3` | POST | `/payment/providers/configs/{configId}/onboarding-url` |

### 3.12 Rulesets (`Payrails.Rulesets`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/merchant/rulesets` |
| `create/2` | POST | `/merchant/rulesets` |
| `get/2` | GET | `/merchant/rulesets/{rulesetId}` |
| `update/3` | PUT | `/merchant/rulesets/{rulesetId}` |

### 3.13 Holders (`Payrails.Holders`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/merchant/holders` |
| `create/2` | POST | `/merchant/holders` |
| `get/2` | GET | `/merchant/holders/{holderId}` |

### 3.14 Workspaces (`Payrails.Workspaces`)

| Function | Method | Path |
|----------|--------|------|
| `list/1` | GET | `/merchant/workspaces` |
| `create/2` | POST | `/merchant/workspaces` |
| `get/2` | GET | `/merchant/workspaces/{workspaceId}` |
| `create_batch/2` | POST | `/merchant/workspaces/batch` |

### 3.15 Drop-in Links (`Payrails.DropinLinks`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/merchant/dropin-links` |
| `create/2` | POST | `/merchant/dropin-links` |
| `get/2` | GET | `/merchant/dropin-links/{linkId}` |
| `delete/2` | DELETE | `/merchant/dropin-links/{linkId}` |

### 3.16 Files (`Payrails.Files`)

| Function | Method | Path |
|----------|--------|------|
| `get/2` | GET | `/merchant/files/{fileId}` |
| `upload/2` | POST | `/merchant/files` |

### 3.17 Reports (`Payrails.Reports`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/merchant/reports` |
| `get/2` | GET | `/merchant/reports/{reportId}` |
| `list_runs/3` | GET | `/merchant/reports/{reportId}/runs` |
| `create_run/3` | POST | `/merchant/reports/{reportId}/runs` |
| `get_run/3` | GET | `/merchant/reports/{reportId}/runs/{runId}` |

### 3.18 Fraud (`Payrails.Fraud`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/payment/fraud` |
| `get/2` | GET | `/payment/fraud/{fraudId}` |
| `get_operations/2` | GET | `/payment/fraud/{fraudId}/operations` |
| `get_operation_logs/3` | GET | `/payment/fraud/{fraudId}/operations/{operationId}/logs` |

### 3.19 3D Secure (`Payrails.ThreeDS`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/payment/threeds` |
| `get/2` | GET | `/payment/threeds/{threedsId}` |
| `get_operations/2` | GET | `/payment/threeds/{threedsId}/operations` |
| `get_operation_logs/3` | GET | `/payment/threeds/{threedsId}/operations/{operationId}/logs` |

### 3.20 Reconciliation (`Payrails.Reconciliation`)

| Function | Method | Path |
|----------|--------|------|
| `bulk_manual_reconcile/2` | POST | `/payment/reconciliation/manual` |

### 3.21 Audit Logs (`Payrails.AuditLogs`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/merchant/audit-logs` |
| `list_events/2` | GET | `/merchant/audit-logs/events` |
| `get_event/2` | GET | `/merchant/audit-logs/events/{eventId}` |

### 3.22 SSO (`Payrails.SSO`)

| Function | Method | Path |
|----------|--------|------|
| `create_connection/2` | POST | `/merchant/sso/connections` |
| `list_connections/2` | GET | `/merchant/sso/connections` |
| `get_connection/2` | GET | `/merchant/sso/connections/{connectionId}` |
| `update_connection/3` | PATCH | `/merchant/sso/connections/{connectionId}` |
| `list_saml_configs/2` | GET | `/merchant/sso/saml/configs` |

### 3.23 Vault Proxy (`Payrails.Vault.Proxy`)

| Function | Method | Path |
|----------|--------|------|
| `proxy/3` | POST | `/payment/providers/{providerId}/proxy` |
| `invoke_outbound/3` | POST | `/vault/connections/{connectionId}/invoke` |

### 3.24 Vault Connections (`Payrails.Vault.Connections`)

| Function | Method | Path |
|----------|--------|------|
| `create/2` | POST | `/vault/connections` |
| `list/2` | GET | `/vault/connections` |
| `get/2` | GET | `/vault/connections/{connectionId}` |
| `update/3` | PUT | `/vault/connections/{connectionId}` |
| `delete/2` | DELETE | `/vault/connections/{connectionId}` |
| `create_version/3` | POST | `/vault/connections/{connectionId}/versions` |
| `set_live_version/3` | PUT | `/vault/connections/{connectionId}/versions/{versionId}/live` |
| `get_version/3` | GET | `/vault/connections/{connectionId}/versions/{versionId}` |
| `list_versions/3` | GET | `/vault/connections/{connectionId}/versions` |

### 3.25 Vault Records (`Payrails.Vault.Records`)

| Function | Method | Path |
|----------|--------|------|
| `tokenize/2` | POST | `/records/tokenize` (vault host) |
| `detokenize/2` | POST | `/records/detokenize` (vault host) |
| `get/2` | GET | `/records/{recordId}` |
| `get_by_alias/2` | GET | `/records/alias/{alias}` |
| `delete/2` | DELETE | `/records/{recordId}` |
| `delete_by_alias/2` | DELETE | `/records/alias/{alias}` |
| `list_for_instrument/2` | GET | `/records/instruments/{instrumentId}` |
| `get_field_by_alias/2` | GET | `/records/fields/alias/{alias}` |
| `get_fields_info/2` | POST | `/records/fields/info` |
| `delete_field_by_alias/2` | DELETE | `/records/fields/alias/{alias}` |
| `delete_field/3` | DELETE | `/records/{recordId}/fields/{fieldType}` |

### 3.26 Disputes (`Payrails.Disputes`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/dispute/disputes` |
| `get/2` | GET | `/dispute/disputes/{disputeId}` |
| `get_activities/2` | GET | `/dispute/disputes/{disputeId}/activities` |
| `get_documents/2` | GET | `/dispute/disputes/{disputeId}/documents` |
| `defend/3` | POST | `/dispute/disputes/{disputeId}/defend` |
| `accept/2` | POST | `/dispute/disputes/{disputeId}/accept` |
| `upload_evidence/3` | POST | `/dispute/disputes/{disputeId}/evidences` |
| `submit_evidence/2` | POST | `/dispute/disputes/{disputeId}/evidences/submit` |
| `list_evidences/2` | GET | `/dispute/disputes/{disputeId}/evidences` |
| `download_evidence/3` | GET | `/dispute/disputes/{disputeId}/evidences/{evidenceId}/download` |

### 3.27 Dispute Representment (`Payrails.Disputes.Representment`)

| Function | Method | Path |
|----------|--------|------|
| `generate_plan/2` | POST | `.../disputes/{disputeId}/representment/plan` |
| `regenerate_plan/2` | POST | `.../disputes/{disputeId}/representment/plan/regenerate` |
| `submit_evidences/3` | POST | `.../disputes/{disputeId}/representment/plan/evidences` |
| `generate_pdf/2` | POST | `.../disputes/{disputeId}/representment/pdf` |
| `edit_sections/3` | PATCH | `.../disputes/{disputeId}/representment/sections` |
| `download_bundle/2` | GET | `.../disputes/{disputeId}/representment/bundle` |

### 3.28 Dispute Tags (`Payrails.Disputes.Tags`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/dispute/tags` |
| `create/2` | POST | `/dispute/tags` |
| `update/3` | PUT | `/dispute/tags/{tagId}` |
| `delete/2` | DELETE | `/dispute/tags/{tagId}` |
| `attach/3` | POST | `/dispute/disputes/{disputeId}/tags` |
| `detach/3` | DELETE | `/dispute/disputes/{disputeId}/tags/{tagId}` |
| `bulk_attach/2` | POST | `/dispute/disputes/tags/bulk` |
| `bulk_replace_by_type/2` | PUT | `/dispute/disputes/tags/bulk/type` |
| `replace_by_type/3` | PUT | `/dispute/disputes/{disputeId}/tags/type` |

### 3.29 Dispute Runs (`Payrails.Disputes.Runs`)

| Function | Method | Path |
|----------|--------|------|
| `list/2` | GET | `/dispute/runs` |
| `get/2` | GET | `/dispute/runs/{runId}` |

### 3.30 Dispute Alerts (`Payrails.Disputes.Alerts`)

| Function | Method | Path |
|----------|--------|------|
| `list_enrollments/2` | GET | `/dispute/alerts/enrollments` |
| `enroll/2` | POST | `/dispute/alerts/enrollments` |
| `list/2` | GET | `/dispute/alerts` |
| `get/2` | GET | `/dispute/alerts/{alertId}` |
| `action/3` | POST | `/dispute/alerts/{alertId}/action` |
| `match_payment/3` | POST | `/dispute/alerts/{alertId}/match-payment` |
| `refund/2` | POST | `/dispute/alerts/{alertId}/refund` |
| `list_descriptors/2` | GET | `/dispute/alerts/enrollments/{enrollmentId}/descriptors` |
| `add_descriptors/3` | POST | `/dispute/alerts/enrollments/{enrollmentId}/descriptors` |
| `unenroll_descriptor/3` | DELETE | `/dispute/alerts/enrollments/{enrollmentId}/descriptors/{descriptorId}` |
| `list_enrollment_events/2` | GET | `/dispute/alerts/enrollments/{enrollmentId}/events` |
| `list_alert_events/2` | GET | `/dispute/alerts/{alertId}/events` |

---

## 4. Cross-Cutting Concerns

### 4.1 Authentication & Token Management

- `Payrails.Auth.get_token/2` fetches a bearer token using `client_id` + `api_key`.
- `Payrails.Auth.TokenStore` (optional GenServer or ETS-backed) caches the token and auto-refreshes before `expires_in` elapses.
- For simple/stateless usage, `Payrails.Client` can fetch a fresh token per-request or accept a pre-fetched token.
- Vault endpoints on `api.vault.payrails.io` use a separate vault access token obtained via `get_vault_access_token/1`.

### 4.2 Idempotency

- All mutating requests (POST/PUT/PATCH/DELETE) that require `x-idempotency-key` auto-generate a UUID v4 if not provided by the caller.
- Users can pass `idempotency_key: "..."` in the options to control this.

### 4.3 Pagination

- Every `list` function accepts `opts` with `page_size`, `cursor`, `after`, `before` keys.
- `Payrails.Paginator.stream(client, &list_fn/2, opts)` returns a `Stream.resource` that auto-pages.

### 4.4 Request/Response Pipeline

```
caller → build_url → set_headers → encode_body (JSON) → HTTP adapter
                                                              ↓
caller ← decode_body (JSON) ← wrap result ← HTTP adapter response
```

### 4.5 Telemetry (Future / Optional)

- Emit `:telemetry` events for request start/stop/exception if `:telemetry` is available.
- Not a hard dependency; guarded with `Code.ensure_loaded?/1`.

---

## 5. Dependencies

### Required (zero external)

| Dependency | Source | Purpose |
|------------|--------|---------|
| `JSON` | Elixir 1.18+ stdlib | JSON encode/decode |
| `:httpc` | Erlang `inets` app | HTTP client (default adapter) |
| `:crypto` | Erlang stdlib | HMAC-SHA256 for webhooks |
| `:ssl` | Erlang stdlib | TLS for HTTPS |
| `:public_key` | Erlang stdlib | Certificate verification |

### Optional (user-provided)

| Dependency | Purpose |
|------------|---------|
| `req` / `finch` | Alternative HTTP adapters (user implements behaviour) |
| `castore` | Mozilla CA certificate bundle (recommended for production; `:httpc` can use system certs) |

---

## 6. Implementation Order

Phases are ordered by dependency — each phase builds on the previous.

### Phase 1 — Project Bootstrap
- [ ] `mix new payrails_ex` with Elixir 1.19.5, OTP 27
- [ ] `mix.exs` configuration (zero deps, project metadata)
- [ ] `.formatter.exs`, `.gitignore`

### Phase 2 — Core Infrastructure
- [ ] `Payrails.Config` — struct + validation
- [ ] `Payrails.Error` — error struct
- [ ] `Payrails.Response` — response struct
- [ ] `Payrails.HTTP.Behaviour` — HTTP client behaviour
- [ ] `Payrails.HTTP.Default` — `:httpc` adapter
- [ ] `Payrails.Client` — request builder + executor

### Phase 3 — Auth & Token Management
- [ ] `Payrails.Auth` — `get_token/2`, `get_vault_access_token/1`
- [ ] `Payrails.Auth.TokenStore` — in-memory cache with TTL-based refresh

### Phase 4 — Core Payment APIs
- [ ] `Payrails.Holders`
- [ ] `Payrails.Instruments`
- [ ] `Payrails.Tokens`
- [ ] `Payrails.Workflows`
- [ ] `Payrails.Executions`
- [ ] `Payrails.Actions`
- [ ] `Payrails.Payments`
- [ ] `Payrails.Paginator`

### Phase 5 — Supporting APIs
- [ ] `Payrails.ClientInit`
- [ ] `Payrails.Providers`
- [ ] `Payrails.Rulesets`
- [ ] `Payrails.CardInfo`
- [ ] `Payrails.NetworkTokens`
- [ ] `Payrails.Workspaces`
- [ ] `Payrails.DropinLinks`
- [ ] `Payrails.Files`
- [ ] `Payrails.Reports`

### Phase 6 — Observability & Security APIs
- [ ] `Payrails.Fraud`
- [ ] `Payrails.ThreeDS`
- [ ] `Payrails.AuditLogs`
- [ ] `Payrails.SSO`
- [ ] `Payrails.Reconciliation`

### Phase 7 — Vault APIs
- [ ] `Payrails.Vault.Records`
- [ ] `Payrails.Vault.Connections`
- [ ] `Payrails.Vault.Proxy`

### Phase 8 — Disputes
- [ ] `Payrails.Disputes`
- [ ] `Payrails.Disputes.Representment`
- [ ] `Payrails.Disputes.Tags`
- [ ] `Payrails.Disputes.Runs`
- [ ] `Payrails.Disputes.Alerts`

### Phase 9 — Webhook & Top-Level Facade
- [ ] `Payrails.Webhook` — signature verification + event construction
- [ ] `Payrails` — top-level module with `@moduledoc`, convenience delegates

### Phase 10 — Tests & Documentation
- [ ] Unit tests for each module (using mock HTTP adapter)
- [ ] Integration test harness (opt-in, requires real credentials)
- [ ] `@moduledoc` / `@doc` on all public functions
- [ ] README with quick-start, usage examples, configuration guide

---

## 7. Usage Example (Target API)

```elixir
# Configure
config = Payrails.Config.new!(
  client_id: "my-client-id",
  api_key: "my-api-key",
  base_url: "https://api.staging.payrails.io"
)

# Create a client (fetches token automatically)
client = Payrails.Client.new(config)

# Create a holder
{:ok, holder} = Payrails.Holders.create(client, %{
  reference: "customer-123",
  type: "Customer"
})

# Create a payment instrument
{:ok, instrument} = Payrails.Instruments.create(client, %{
  holder_id: holder["id"],
  payment_method: "card",
  data: %{
    network: "visa",
    bin: "411111",
    suffix: "1111",
    expiry_month: "12",
    expiry_year: "2027"
  }
})

# Create an execution and authorize
{:ok, execution} = Payrails.Executions.create(client, "payment-acceptance", %{
  merchant_reference: "order-456",
  holder_reference: "customer-123"
})

{:ok, result} = Payrails.Actions.authorize(client, "payment-acceptance", execution["id"], %{
  amount: %{value: "99.99", currency: "EUR"},
  payment_composition: [%{
    payment_instrument_id: instrument["id"],
    amount: %{value: "99.99", currency: "EUR"}
  }]
})

# Paginate through payments
client
|> Payrails.Payments.stream(filter: [status: "Captured"])
|> Stream.each(&IO.inspect/1)
|> Stream.run()

# Verify a webhook
:ok = Payrails.Webhook.verify(raw_body, signature_header, webhook_secret)
```

---

## 8. Design Decisions

| Decision | Rationale |
|----------|-----------|
| Zero external deps by default | Minimizes version conflicts; Elixir 1.19 + OTP 27 provides JSON, HTTP, crypto natively |
| Pluggable HTTP adapter | Users in production likely already have Finch/Req; adapter pattern avoids forcing a choice |
| Maps (not structs) for API payloads | Payrails API is large and evolving; maps are forward-compatible without code changes |
| Structs for Config/Error/Response | These are SDK-internal and benefit from compile-time checks |
| `x-idempotency-key` auto-generation | Prevents accidental duplicate operations; user can override |
| Lazy pagination streams | Memory-efficient for large result sets; idiomatic Elixir |
| No GenServer requirement for basic use | `Client` is a plain struct; `TokenStore` GenServer is opt-in for long-lived processes |
| Keys sent as camelCase to API | Payrails API uses camelCase; SDK accepts maps with string or atom keys, converts internally |
