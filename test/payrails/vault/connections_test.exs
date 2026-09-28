defmodule Payrails.Vault.ConnectionsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config}
  alias Payrails.Vault.Connections
  alias Payrails.HTTP.Mock

  setup do
    config =
      Config.new!(
        client_id: "test-id",
        api_key: "test-key",
        http_client: Mock,
        vault_url: "https://api.vault.payrails.io"
      )

    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists connections", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Connections.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "api.vault.payrails.io/vault/connections"
    end
  end

  describe "create/3" do
    test "creates a connection", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "conn-1"})})
      assert {:ok, _} = Connections.create(client, %{name: "test"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :post
    end
  end

  describe "get/3" do
    test "gets a connection", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "conn-1"})})
      assert {:ok, _} = Connections.get(client, "conn-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/vault/connections/conn-1"
    end
  end

  describe "update/4" do
    test "updates a connection", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "conn-1"})})
      assert {:ok, _} = Connections.update(client, "conn-1", %{name: "updated"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :put
    end
  end

  describe "delete/3" do
    test "deletes a connection", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Connections.delete(client, "conn-1")
      {method, _, _, _, _} = Mock.last_request()
      assert method == :delete
    end
  end

  describe "list_versions/3" do
    test "lists versions", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Connections.list_versions(client, "conn-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/vault/connections/conn-1/versions"
    end
  end

  describe "create_version/4" do
    test "creates a version", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "v-1"})})
      assert {:ok, _} = Connections.create_version(client, "conn-1", %{config: %{}})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/vault/connections/conn-1/versions"
    end
  end

  describe "get_version/4" do
    test "gets a version", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "v-1"})})
      assert {:ok, _} = Connections.get_version(client, "conn-1", "v-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/vault/connections/conn-1/versions/v-1"
    end
  end

  describe "set_live_version/4" do
    test "sets the live version", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "v-1"})})
      assert {:ok, _} = Connections.set_live_version(client, "conn-1", "v-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :put
      assert url =~ "/vault/connections/conn-1/versions/v-1/live"
    end
  end
end
