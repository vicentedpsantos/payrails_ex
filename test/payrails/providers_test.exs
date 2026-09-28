defmodule Payrails.ProvidersTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Providers}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists providers", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Providers.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/providers"
    end
  end

  describe "get/3" do
    test "gets a provider", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "prov-1"})})
      assert {:ok, _} = Providers.get(client, "prov-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/providers/prov-1"
    end
  end

  describe "list_active_configs/2" do
    test "lists active configs", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Providers.list_active_configs(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/providers/configs/active"
    end
  end

  describe "create_config/3" do
    test "creates a config", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "cfg-1"})})
      assert {:ok, _} = Providers.create_config(client, %{provider: "stripe"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/payment/providers/configs"
    end
  end

  describe "get_config/3" do
    test "gets a config", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "cfg-1"})})
      assert {:ok, _} = Providers.get_config(client, "cfg-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/providers/configs/cfg-1"
    end
  end

  describe "update_config/4" do
    test "replaces a config", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "cfg-1"})})
      assert {:ok, _} = Providers.update_config(client, "cfg-1", %{enabled: true})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :put
    end
  end

  describe "patch_config/4" do
    test "patches a config", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "cfg-1"})})
      assert {:ok, _} = Providers.patch_config(client, "cfg-1", %{enabled: false})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :patch
    end
  end

  describe "create_authenticated_config/3" do
    test "creates an authenticated config", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "acfg-1"})})
      assert {:ok, _} = Providers.create_authenticated_config(client, %{})
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/providers/configs/authenticated"
    end
  end

  describe "update_authenticated_config/4" do
    test "updates an authenticated config", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "acfg-1"})})
      assert {:ok, _} = Providers.update_authenticated_config(client, "acfg-1", %{})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :put
      assert url =~ "/payment/providers/configs/authenticated/acfg-1"
    end
  end

  describe "create_onboarding_url/4" do
    test "creates an onboarding URL", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"url": "https://onboard.test"})})
      assert {:ok, _} = Providers.create_onboarding_url(client, "cfg-1", %{return_url: "https://app.test"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/payment/providers/configs/cfg-1/onboarding-url"
    end
  end
end
