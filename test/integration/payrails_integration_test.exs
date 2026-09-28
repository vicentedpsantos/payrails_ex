defmodule Payrails.IntegrationTest do
  @moduledoc """
  Integration tests that run against the real Payrails API.

  These tests are excluded by default. To run them, set the required
  environment variables and include the `:integration` tag:

      PAYRAILS_CLIENT_ID=your-id \\
      PAYRAILS_API_KEY=your-key \\
      PAYRAILS_BASE_URL=https://api.staging.payrails.io \\
      mix test --include integration

  Optional environment variables:
    - PAYRAILS_VAULT_URL — Vault API base URL
    - PAYRAILS_WEBHOOK_SECRET — Webhook signing secret (for webhook tests)
  """

  use ExUnit.Case

  @moduletag :integration

  setup_all do
    client_id = System.fetch_env!("PAYRAILS_CLIENT_ID")
    api_key = System.fetch_env!("PAYRAILS_API_KEY")

    config_opts = [
      client_id: client_id,
      api_key: api_key
    ]

    config_opts =
      case System.get_env("PAYRAILS_BASE_URL") do
        nil -> config_opts
        url -> Keyword.put(config_opts, :base_url, url)
      end

    config_opts =
      case System.get_env("PAYRAILS_VAULT_URL") do
        nil -> config_opts
        url -> Keyword.put(config_opts, :vault_url, url)
      end

    config = Payrails.Config.new!(config_opts)
    client = Payrails.Client.new(config)

    %{config: config, client: client}
  end

  describe "authentication" do
    test "obtains a bearer token", %{client: client} do
      assert {:ok, token_data} = Payrails.Auth.get_token(client)
      assert is_binary(token_data["access_token"])
      assert is_integer(token_data["expires_in"])
    end

    test "token store fetches and caches tokens", %{config: config} do
      {:ok, pid} = Payrails.Auth.TokenStore.start_link(config: config)

      assert {:ok, token} = Payrails.Auth.TokenStore.get_token(pid)
      assert is_binary(token)

      # Second call should return the cached token
      assert {:ok, ^token} = Payrails.Auth.TokenStore.get_token(pid)

      GenServer.stop(pid)
    end
  end

  describe "holders" do
    setup %{client: client} do
      {:ok, token_data} = Payrails.Auth.get_token(client)
      client = Payrails.Client.put_token(client, token_data["access_token"])
      %{client: client}
    end

    test "lists holders", %{client: client} do
      assert {:ok, body} = Payrails.Holders.list(client)
      assert is_map(body)
    end

    test "creates and retrieves a holder", %{client: client} do
      ref = "integration-test-#{System.unique_integer([:positive])}"

      assert {:ok, holder} =
               Payrails.Holders.create(client, %{reference: ref, type: "Customer"})

      assert holder["reference"] == ref

      assert {:ok, fetched} = Payrails.Holders.get(client, holder["id"])
      assert fetched["id"] == holder["id"]
    end
  end

  describe "payments" do
    setup %{client: client} do
      {:ok, token_data} = Payrails.Auth.get_token(client)
      client = Payrails.Client.put_token(client, token_data["access_token"])
      %{client: client}
    end

    test "lists payments", %{client: client} do
      assert {:ok, body} = Payrails.Payments.list(client)
      assert is_map(body)
    end
  end

  describe "webhook verification" do
    @tag :webhook
    test "round-trip sign and verify" do
      secret = System.get_env("PAYRAILS_WEBHOOK_SECRET", "test-secret-for-round-trip")
      payload = ~s({"event":"test","data":{}})

      signature = Payrails.Webhook.compute_signature(payload, secret)
      assert :ok = Payrails.Webhook.verify(payload, signature, secret)

      assert {:ok, event} = Payrails.Webhook.construct_event(payload, signature, secret)
      assert event["event"] == "test"
    end
  end
end
