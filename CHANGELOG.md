# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-09-28

### Added

- Core infrastructure: `Config`, `Client`, `Error`, `Response` structs
- Pluggable HTTP client behaviour (`Payrails.HTTP.Behaviour`) with default `:httpc` adapter
- OAuth authentication (`Payrails.Auth`) with automatic token store (`Payrails.Auth.TokenStore`)
- Auto-generated `x-idempotency-key` for mutating requests
- Lazy cursor-based pagination via `Payrails.Paginator.stream/3`
- Webhook signature verification (`Payrails.Webhook`) using HMAC-SHA256 with constant-time comparison
- Full API coverage:
  - Client initialization (`Payrails.ClientInit`)
  - Holders (`Payrails.Holders`)
  - Payment instruments (`Payrails.Instruments`)
  - Provider tokens (`Payrails.Tokens`)
  - Network tokens (`Payrails.NetworkTokens`)
  - Workflows (`Payrails.Workflows`)
  - Executions (`Payrails.Executions`)
  - Actions (`Payrails.Actions`) — authorize, capture, cancel, refund, confirm, payout, lookup, etc.
  - Payments (`Payrails.Payments`)
  - Providers (`Payrails.Providers`)
  - Rulesets (`Payrails.Rulesets`)
  - Card info / BIN lookup (`Payrails.CardInfo`)
  - Workspaces (`Payrails.Workspaces`)
  - Drop-in links (`Payrails.DropinLinks`)
  - Files (`Payrails.Files`)
  - Reports (`Payrails.Reports`)
  - Fraud checks (`Payrails.Fraud`)
  - 3D Secure (`Payrails.ThreeDS`)
  - Reconciliation (`Payrails.Reconciliation`)
  - Audit logs (`Payrails.AuditLogs`)
  - SSO connections (`Payrails.SSO`)
  - Vault records, connections, and proxy (`Payrails.Vault.Records`, `Payrails.Vault.Connections`, `Payrails.Vault.Proxy`)
  - Disputes, representment, tags, runs, and alerts (`Payrails.Disputes.*`)
