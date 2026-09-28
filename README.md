# PayrailsEx

Elixir SDK for the [Payrails API](https://docs.payrails.com).

- **Zero external dependencies** — uses Elixir/Erlang stdlib only (JSON, `:httpc`, `:crypto`, `:ssl`)
- **Pluggable HTTP client** — swap in Req, Finch, or any adapter
- **Full API coverage** — payments, holders, instruments, vault, disputes, webhooks, and more
- **Lazy pagination** — `Stream`-based cursor pagination for large result sets
- **Automatic token management** — optional GenServer-based token cache with auto-refresh

Requires **Elixir 1.19+** (OTP 27+).

## Installation

Add `payrails_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:payrails_ex, "~> 0.1.0"}
  ]
end
```

## Quick Start

```elixir
# 1. Configure
config = Payrails.Config.new!(
  client_id: "my-client-id",
  api_key: "my-api-key"
)

# 2. Create a client and authenticate
client = Payrails.Client.new(config)
{:ok, token_data} = Payrails.Auth.get_token(client)
client = Payrails.Client.put_token(client, token_data["access_token"])

# 3. Make API calls
{:ok, holder} = Payrails.Holders.create(client, %{
  reference: "customer-123",
  type: "Customer"
})
```

## Configuration

`Payrails.Config.new!/1` accepts the following options:

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `:client_id` | Yes | — | OAuth client ID |
| `:api_key` | Yes | — | API key / client secret |
| `:base_url` | No | `https://api.payrails.io` | API base URL |
| `:vault_url` | No | `https://api.vault.payrails.io` | Vault API base URL |
| `:http_client` | No | `Payrails.HTTP.Default` | Module implementing `Payrails.HTTP.Behaviour` |
| `:http_options` | No | `[]` | Adapter-specific options (timeouts, etc.) |
| `:webhook_secret` | No | `nil` | Secret for webhook signature verification |

```elixir
config = Payrails.Config.new!(
  client_id: "my-client-id",
  api_key: "my-api-key",
  base_url: "https://api.staging.payrails.io"
)
```

## Authentication

### Manual Token Management

Suitable for scripts or short-lived processes:

```elixir
config = Payrails.Config.new!(client_id: "...", api_key: "...")
client = Payrails.Client.new(config)

{:ok, token_data} = Payrails.Auth.get_token(client)
client = Payrails.Client.put_token(client, token_data["access_token"])

# client is now authenticated for API calls
```

### Automatic Token Store

For long-lived processes (e.g. Phoenix applications), use the GenServer-based token store that automatically refreshes tokens before they expire:

```elixir
# In your supervision tree
children = [
  {Payrails.Auth.TokenStore, config: config, name: MyApp.PayrailsTokens}
]

# Retrieve tokens anywhere in your app
{:ok, token} = Payrails.Auth.TokenStore.get_token(MyApp.PayrailsTokens)
client = Payrails.Client.put_token(client, token)
```

## API Usage

All API modules follow the same pattern, returning `{:ok, result}` or `{:error, %Payrails.Error{}}`:

### Holders

```elixir
{:ok, holders} = Payrails.Holders.list(client)
{:ok, holder} = Payrails.Holders.create(client, %{reference: "cust-1", type: "Customer"})
{:ok, holder} = Payrails.Holders.get(client, holder["id"])
```

### Payment Instruments

```elixir
{:ok, instrument} = Payrails.Instruments.create(client, %{
  holder_id: holder["id"],
  payment_method: "card"
})

{:ok, _} = Payrails.Instruments.delete(client, instrument["id"])
```

### Executions & Actions

```elixir
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

{:ok, _} = Payrails.Actions.capture(client, "payment-acceptance", execution["id"], %{
  amount: %{value: "99.99", currency: "EUR"}
})
```

### Payments

```elixir
{:ok, payments} = Payrails.Payments.list(client)
{:ok, payment} = Payrails.Payments.get(client, "pay-id")
{:ok, ops} = Payrails.Payments.get_operations(client, "pay-id")
```

## Pagination

All list endpoints support lazy cursor-based pagination via `Payrails.Paginator.stream/3`:

```elixir
client
|> Payrails.Paginator.stream(&Payrails.Payments.list/2, params: [page_size: 50])
|> Stream.filter(fn payment -> payment["status"] == "Captured" end)
|> Stream.each(&process_payment/1)
|> Stream.run()
```

Each element emitted by the stream is a single item from the `results` list in the paginated response. The stream automatically follows `links.next` until all pages are exhausted.

## Webhook Verification

Verify incoming webhook signatures using HMAC-SHA256:

```elixir
# Verify only
case Payrails.Webhook.verify(raw_body, signature_header, webhook_secret) do
  :ok -> handle_webhook(raw_body)
  {:error, :invalid_signature} -> send_resp(conn, 401, "Invalid signature")
end

# Verify and decode in one step
case Payrails.Webhook.construct_event(raw_body, signature_header, webhook_secret) do
  {:ok, event} -> handle_event(event)
  {:error, :invalid_signature} -> send_resp(conn, 401, "Invalid signature")
  {:error, {:json_decode_error, _}} -> send_resp(conn, 400, "Invalid payload")
end
```

Signatures can include a `sha256=` prefix and are compared case-insensitively using constant-time comparison.

## Custom HTTP Client

The SDK uses Erlang's `:httpc` by default. To use a different HTTP client, implement the `Payrails.HTTP.Behaviour` callback:

```elixir
defmodule MyApp.FinchAdapter do
  @behaviour Payrails.HTTP.Behaviour

  @impl true
  def request(method, url, headers, body, _opts) do
    req = Finch.build(method, url, headers, body)

    case Finch.request(req, MyApp.Finch) do
      {:ok, %Finch.Response{status: status, headers: headers, body: body}} ->
        {:ok, %{status: status, headers: headers, body: body}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end

config = Payrails.Config.new!(
  client_id: "...",
  api_key: "...",
  http_client: MyApp.FinchAdapter
)
```

## Vault Operations

Vault endpoints automatically use the `:vault_url` from your config:

```elixir
# Tokenize sensitive data
{:ok, record} = Payrails.Vault.Records.tokenize(client, %{data: "4111111111111111"})

# Detokenize
{:ok, data} = Payrails.Vault.Records.detokenize(client, record["id"])

# Vault connections
{:ok, connections} = Payrails.Vault.Connections.list(client)
```

## Error Handling

All API calls return `{:ok, result}` or `{:error, %Payrails.Error{}}`:

```elixir
case Payrails.Holders.create(client, params) do
  {:ok, holder} ->
    IO.puts("Created holder: #{holder["id"]}")

  {:error, %Payrails.Error{code: code, detail: detail, status: status}} ->
    IO.puts("API error #{status}: [#{code}] #{detail}")
end
```

The `Payrails.Error` struct contains:

| Field | Description |
|-------|-------------|
| `:status` | HTTP status code |
| `:code` | Error code from API response |
| `:detail` | Human-readable error message |
| `:reason` | Raw error reason (for network errors) |

## API Modules

| Module | Description |
|--------|-------------|
| `Payrails.Auth` | OAuth token acquisition |
| `Payrails.Auth.TokenStore` | Automatic token cache with refresh |
| `Payrails.ClientInit` | SDK client initialization |
| `Payrails.Holders` | Payment holders |
| `Payrails.Instruments` | Payment instruments |
| `Payrails.Tokens` | Provider tokens |
| `Payrails.NetworkTokens` | Network token provisioning |
| `Payrails.Workflows` | Workflow configurations |
| `Payrails.Executions` | Workflow executions |
| `Payrails.Actions` | Payment actions (authorize, capture, refund, etc.) |
| `Payrails.Payments` | Payment records and operations |
| `Payrails.Providers` | Provider configurations |
| `Payrails.Rulesets` | Rulesets |
| `Payrails.CardInfo` | BIN lookup |
| `Payrails.Workspaces` | Workspaces |
| `Payrails.DropinLinks` | Drop-in payment links |
| `Payrails.Files` | File management |
| `Payrails.Reports` | Reports and runs |
| `Payrails.Fraud` | Fraud checks |
| `Payrails.ThreeDS` | 3D Secure |
| `Payrails.Reconciliation` | Manual reconciliation |
| `Payrails.AuditLogs` | Audit logs |
| `Payrails.SSO` | SSO connections |
| `Payrails.Vault.Records` | Vault tokenize/detokenize |
| `Payrails.Vault.Connections` | Vault connections |
| `Payrails.Vault.Proxy` | Vault proxy |
| `Payrails.Disputes` | Dispute management |
| `Payrails.Disputes.Representment` | Representment plans |
| `Payrails.Disputes.Tags` | Dispute tags |
| `Payrails.Disputes.Runs` | Dispute runs |
| `Payrails.Disputes.Alerts` | Dispute alerts |
| `Payrails.Webhook` | Webhook signature verification |
| `Payrails.Paginator` | Lazy cursor-based pagination |

## License

MIT
