defmodule Payrails.DropinLinksTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, DropinLinks}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists drop-in links", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = DropinLinks.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/dropin-links"
    end
  end

  describe "create/3" do
    test "creates a drop-in link", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "dl-1"})})
      assert {:ok, _} = DropinLinks.create(client, %{amount: 100})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :post
    end
  end

  describe "get/3" do
    test "gets a drop-in link", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "dl-1"})})
      assert {:ok, _} = DropinLinks.get(client, "dl-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/dropin-links/dl-1"
    end
  end

  describe "delete/3" do
    test "deletes a drop-in link", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = DropinLinks.delete(client, "dl-1")
      {method, _, _, _, _} = Mock.last_request()
      assert method == :delete
    end
  end
end
