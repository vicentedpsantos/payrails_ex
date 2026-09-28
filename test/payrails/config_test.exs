defmodule Payrails.ConfigTest do
  use ExUnit.Case, async: true

  alias Payrails.Config

  describe "new!/1" do
    test "creates config with required fields" do
      config = Config.new!(client_id: "test-id", api_key: "test-key")

      assert %Config{} = config
      assert config.client_id == "test-id"
      assert config.api_key == "test-key"
    end

    test "applies default values" do
      config = Config.new!(client_id: "test-id", api_key: "test-key")

      assert config.base_url == "https://api.payrails.io"
      assert config.vault_url == "https://api.vault.payrails.io"
      assert config.http_client == Payrails.HTTP.Default
      assert config.http_options == []
      assert config.webhook_secret == nil
    end

    test "allows overriding defaults" do
      config =
        Config.new!(
          client_id: "test-id",
          api_key: "test-key",
          base_url: "https://api.staging.payrails.io",
          vault_url: "https://api.vault.staging.payrails.io",
          http_client: Payrails.HTTP.Mock,
          http_options: [timeout: 60_000],
          webhook_secret: "whsec_test"
        )

      assert config.base_url == "https://api.staging.payrails.io"
      assert config.vault_url == "https://api.vault.staging.payrails.io"
      assert config.http_client == Payrails.HTTP.Mock
      assert config.http_options == [timeout: 60_000]
      assert config.webhook_secret == "whsec_test"
    end

    test "raises when client_id is missing" do
      assert_raise ArgumentError, ~r/client_id is required/, fn ->
        Config.new!(api_key: "test-key")
      end
    end

    test "raises when api_key is missing" do
      assert_raise ArgumentError, ~r/api_key is required/, fn ->
        Config.new!(client_id: "test-id")
      end
    end

    test "raises when client_id is nil" do
      assert_raise ArgumentError, ~r/client_id cannot be nil or empty/, fn ->
        Config.new!(client_id: nil, api_key: "test-key")
      end
    end

    test "raises when client_id is empty string" do
      assert_raise ArgumentError, ~r/client_id cannot be nil or empty/, fn ->
        Config.new!(client_id: "", api_key: "test-key")
      end
    end

    test "raises when api_key is not a string" do
      assert_raise ArgumentError, ~r/api_key must be a string/, fn ->
        Config.new!(client_id: "test-id", api_key: 12345)
      end
    end

    test "raises for invalid base_url" do
      assert_raise ArgumentError, ~r/base_url must be a valid HTTP/, fn ->
        Config.new!(client_id: "test-id", api_key: "test-key", base_url: "not-a-url")
      end
    end

    test "raises for non-string base_url" do
      assert_raise ArgumentError, ~r/base_url must be a string/, fn ->
        Config.new!(client_id: "test-id", api_key: "test-key", base_url: 123)
      end
    end
  end
end
