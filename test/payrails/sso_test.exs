defmodule Payrails.SSOTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, SSO}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list_connections/2" do
    test "lists SSO connections", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = SSO.list_connections(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/sso/connections"
    end
  end

  describe "create_connection/3" do
    test "creates an SSO connection", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "conn-1"})})
      assert {:ok, _} = SSO.create_connection(client, %{provider: "okta"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :post
    end
  end

  describe "get_connection/3" do
    test "gets an SSO connection", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "conn-1"})})
      assert {:ok, _} = SSO.get_connection(client, "conn-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/sso/connections/conn-1"
    end
  end

  describe "update_connection/4" do
    test "patches an SSO connection", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "conn-1"})})
      assert {:ok, _} = SSO.update_connection(client, "conn-1", %{enabled: true})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :patch
    end
  end

  describe "list_saml_configs/2" do
    test "lists SAML configs", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = SSO.list_saml_configs(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/sso/saml/configs"
    end
  end
end
