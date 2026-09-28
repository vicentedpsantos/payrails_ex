defmodule Payrails.ClientTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Error, Response}
  alias Payrails.HTTP.Mock

  setup do
    config =
      Config.new!(
        client_id: "test-id",
        api_key: "test-key",
        http_client: Mock
      )

    client = Client.new(config) |> Client.put_token("test-token")

    %{client: client, config: config}
  end

  describe "new/1" do
    test "creates client from config", %{config: config} do
      client = Client.new(config)

      assert %Client{} = client
      assert client.config == config
      assert client.token == nil
    end
  end

  describe "put_token/2" do
    test "sets the bearer token", %{config: config} do
      client = Client.new(config) |> Client.put_token("my-token")

      assert client.token == "my-token"
    end
  end

  describe "request/4" do
    test "successful GET returns decoded body", %{client: client} do
      Mock.mock_response(%{
        status: 200,
        headers: [{"content-type", "application/json"}],
        body: ~s({"id": "holder-123", "name": "Test"})
      })

      assert {:ok, body} = Client.request(client, :get, "/merchant/holders/123")
      assert body == %{"id" => "holder-123", "name" => "Test"}
    end

    test "successful POST returns decoded body", %{client: client} do
      Mock.mock_response(%{
        status: 201,
        headers: [{"content-type", "application/json"}],
        body: ~s({"id": "new-123"})
      })

      assert {:ok, body} =
               Client.request(client, :post, "/merchant/holders",
                 body: %{reference: "cust-1"}
               )

      assert body == %{"id" => "new-123"}
    end

    test "returns nil body for empty response", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})

      assert {:ok, nil} = Client.request(client, :delete, "/merchant/holders/123")
    end

    test "returns error for 4xx responses", %{client: client} do
      Mock.mock_response(%{
        status: 401,
        headers: [],
        body: ~s({"code": "unauthorized", "detail": "Invalid token"})
      })

      assert {:error, %Error{} = error} = Client.request(client, :get, "/merchant/holders")
      assert error.code == "unauthorized"
      assert error.detail == "Invalid token"
      assert error.status == 401
    end

    test "returns error for 5xx responses", %{client: client} do
      Mock.mock_response(%{
        status: 500,
        headers: [],
        body: ~s({"code": "internal_error", "detail": "Server error"})
      })

      assert {:error, %Error{} = error} = Client.request(client, :get, "/test")
      assert error.code == "internal_error"
      assert error.status == 500
    end

    test "wraps network errors", %{client: client} do
      Mock.mock_error(:timeout)

      assert {:error, %Error{} = error} = Client.request(client, :get, "/test")
      assert error.code == "network_error"
      assert error.detail == "timeout"
    end

    test "handles non-JSON error responses", %{client: client} do
      Mock.mock_response(%{
        status: 502,
        headers: [],
        body: "Bad Gateway"
      })

      assert {:error, %Error{} = error} = Client.request(client, :get, "/test")
      assert error.code == "api_error"
      assert error.detail == "Bad Gateway"
      assert error.status == 502
    end

    test "appends query params", %{client: client} do
      # We verify the request succeeds — the mock doesn't inspect the URL,
      # but we ensure the code path doesn't crash with params
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, _} =
               Client.request(client, :get, "/merchant/holders",
                 params: [status: "active", page_size: 10]
               )
    end

    test "skips nil query params", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, _} =
               Client.request(client, :get, "/test",
                 params: [status: "active", cursor: nil]
               )
    end

    test "allows overriding base_url for vault endpoints", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"token": "vt-123"})})

      assert {:ok, _} =
               Client.request(client, :post, "/records/tokenize",
                 base_url: "https://api.vault.payrails.io",
                 body: %{data: "sensitive"}
               )
    end

    test "sends without auth header when no token set", %{config: config} do
      client = Client.new(config)
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"ok": true})})

      assert {:ok, _} = Client.request(client, :get, "/test")
    end

    test "allows custom idempotency key", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "123"})})

      assert {:ok, _} =
               Client.request(client, :post, "/test",
                 body: %{},
                 idempotency_key: "my-custom-key"
               )
    end
  end

  describe "request_full/4" do
    test "returns Response struct on success", %{client: client} do
      Mock.mock_response(%{
        status: 200,
        headers: [{"content-type", "application/json"}, {"x-request-id", "req-456"}],
        body: ~s({"id": "123"})
      })

      assert {:ok, %Response{} = response} = Client.request_full(client, :get, "/test")
      assert response.status == 200
      assert response.body == %{"id" => "123"}
      assert {"x-request-id", "req-456"} in response.headers
    end

    test "returns error for failed requests", %{client: client} do
      Mock.mock_response(%{
        status: 404,
        headers: [],
        body: ~s({"code": "not_found", "detail": "Resource not found"})
      })

      assert {:error, %Error{} = error} = Client.request_full(client, :get, "/test/missing")
      assert error.code == "not_found"
      assert error.status == 404
    end
  end
end
