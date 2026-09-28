defmodule Payrails.AuthTest do
  use ExUnit.Case, async: true

  alias Payrails.{Auth, Client, Config, Error}
  alias Payrails.HTTP.Mock

  setup do
    config =
      Config.new!(
        client_id: "test-client-id",
        api_key: "test-api-key",
        http_client: Mock,
        vault_url: "https://api.vault.payrails.io"
      )

    client = Client.new(config)

    %{client: client}
  end

  describe "get_token/2" do
    test "returns token data on success", %{client: client} do
      Mock.mock_response(%{
        status: 200,
        headers: [],
        body:
          JSON.encode!(%{
            "access_token" => "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.test",
            "token_type" => "Bearer",
            "expires_in" => 3600
          })
      })

      assert {:ok, token_data} = Auth.get_token(client)
      assert token_data["access_token"] == "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.test"
      assert token_data["token_type"] == "Bearer"
      assert token_data["expires_in"] == 3600
    end

    test "returns error on invalid credentials", %{client: client} do
      Mock.mock_response(%{
        status: 401,
        headers: [],
        body:
          JSON.encode!(%{
            "code" => "unauthorized",
            "detail" => "Invalid API key"
          })
      })

      assert {:error, %Error{} = error} = Auth.get_token(client)
      assert error.code == "unauthorized"
      assert error.status == 401
    end

    test "returns error on network failure", %{client: client} do
      Mock.mock_error(:timeout)

      assert {:error, %Error{code: "network_error"}} = Auth.get_token(client)
    end
  end

  describe "get_vault_access_token/2" do
    test "returns vault token data on success", %{client: client} do
      client = Client.put_token(client, "bearer-token")

      Mock.mock_response(%{
        status: 200,
        headers: [],
        body:
          JSON.encode!(%{
            "access_token" => "vault-token-123",
            "token_type" => "Bearer",
            "expires_in" => 1800
          })
      })

      assert {:ok, token_data} = Auth.get_vault_access_token(client)
      assert token_data["access_token"] == "vault-token-123"
    end

    test "returns error when not authenticated", %{client: client} do
      Mock.mock_response(%{
        status: 401,
        headers: [],
        body: JSON.encode!(%{"code" => "unauthorized", "detail" => "Missing token"})
      })

      assert {:error, %Error{code: "unauthorized"}} = Auth.get_vault_access_token(client)
    end
  end
end
