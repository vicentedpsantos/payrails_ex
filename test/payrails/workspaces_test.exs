defmodule Payrails.WorkspacesTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Workspaces}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists workspaces", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Workspaces.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/workspaces"
    end
  end

  describe "create/3" do
    test "creates a workspace", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "ws-1"})})
      assert {:ok, _} = Workspaces.create(client, %{name: "test"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :post
    end
  end

  describe "get/3" do
    test "gets a workspace", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "ws-1"})})
      assert {:ok, _} = Workspaces.get(client, "ws-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/workspaces/ws-1"
    end
  end

  describe "create_batch/3" do
    test "creates workspaces in batch", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"created": 2})})
      assert {:ok, _} = Workspaces.create_batch(client, %{workspaces: [%{}, %{}]})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/merchant/workspaces/batch"
    end
  end
end
