defmodule Payrails do
  @moduledoc """
  Elixir SDK for the [Payrails API](https://docs.payrails.com).

  ## Quick Start

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

      {:ok, instrument} = Payrails.Instruments.create(client, %{
        holder_id: holder["id"],
        payment_method: "card"
      })

  ## Token Management

  For long-lived processes, use `Payrails.Auth.TokenStore` to automatically
  cache and refresh tokens:

      {:ok, _pid} = Payrails.Auth.TokenStore.start_link(
        config: config,
        name: MyApp.PayrailsTokens
      )

      {:ok, token} = Payrails.Auth.TokenStore.get_token(MyApp.PayrailsTokens)

  ## Pagination

  All list endpoints support lazy pagination via `Payrails.Paginator`:

      client
      |> Payrails.Paginator.stream(&Payrails.Payments.list/2, params: [page_size: 50])
      |> Stream.each(&process_payment/1)
      |> Stream.run()

  ## Webhook Verification

      :ok = Payrails.Webhook.verify(raw_body, signature_header, webhook_secret)

  ## Custom HTTP Client

  The SDK uses Erlang's `:httpc` by default. Implement `Payrails.HTTP.Behaviour`
  to use Req, Finch, or any other HTTP client:

      config = Payrails.Config.new!(
        client_id: "...",
        api_key: "...",
        http_client: MyApp.FinchAdapter
      )

  ## API Modules

  - `Payrails.Auth` — OAuth token acquisition
  - `Payrails.ClientInit` — SDK client initialization
  - `Payrails.Holders` — Payment holders
  - `Payrails.Instruments` — Payment instruments
  - `Payrails.Tokens` — Provider tokens
  - `Payrails.NetworkTokens` — Network token provisioning
  - `Payrails.Workflows` — Workflow configurations
  - `Payrails.Executions` — Workflow executions
  - `Payrails.Actions` — Payment actions (authorize, capture, refund, etc.)
  - `Payrails.Payments` — Payment records and operations
  - `Payrails.Providers` — Provider configurations
  - `Payrails.Rulesets` — Rulesets
  - `Payrails.CardInfo` — BIN lookup
  - `Payrails.Workspaces` — Workspaces
  - `Payrails.DropinLinks` — Drop-in payment links
  - `Payrails.Files` — File management
  - `Payrails.Reports` — Reports and runs
  - `Payrails.Fraud` — Fraud checks
  - `Payrails.ThreeDS` — 3D Secure
  - `Payrails.Reconciliation` — Manual reconciliation
  - `Payrails.AuditLogs` — Audit logs
  - `Payrails.SSO` — SSO connections
  - `Payrails.Vault.Records` — Vault tokenize/detokenize
  - `Payrails.Vault.Connections` — Vault connections
  - `Payrails.Vault.Proxy` — Vault proxy
  - `Payrails.Disputes` — Dispute management
  - `Payrails.Disputes.Representment` — Representment plans
  - `Payrails.Disputes.Tags` — Dispute tags
  - `Payrails.Disputes.Runs` — Dispute runs
  - `Payrails.Disputes.Alerts` — Dispute alerts
  - `Payrails.Webhook` — Webhook signature verification
  - `Payrails.Paginator` — Lazy cursor-based pagination
  """
end
