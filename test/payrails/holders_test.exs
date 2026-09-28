defmodule Payrails.HoldersTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Error, Holders}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists holders", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": [{"id": "h1"}]})})

      assert {:ok, %{"results" => [%{"id" => "h1"}]}} = Holders.list(client)
    end
  end

  describe "create/3" do
    test "creates a holder", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "h-new"})})

      assert {:ok, %{"id" => "h-new"}} = Holders.create(client, %{reference: "cust-1"})

      {method, url, _headers, body, _opts} = Mock.last_request()
      assert method == :post
      assert url =~ "/merchant/holders"
      assert body =~ "cust-1"
    end
  end

  describe "get/3" do
    test "gets a holder by ID", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "h-123"})})

      assert {:ok, %{"id" => "h-123"}} = Holders.get(client, "h-123")

      {_method, url, _headers, _body, _opts} = Mock.last_request()
      assert url =~ "/merchant/holders/h-123"
    end

    test "returns error for not found", %{client: client} do
      Mock.mock_response(%{
        status: 404,
        headers: [],
        body: ~s({"code": "not_found", "detail": "Holder not found"})
      })

      assert {:error, %Error{code: "not_found", status: 404}} = Holders.get(client, "bad-id")
    end
  end
end
