defmodule Payrails.WorkflowsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Workflows}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists workflows", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, _} = Workflows.list(client)
    end
  end

  describe "create/3" do
    test "creates a workflow", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"code": "payment-acceptance"})})

      assert {:ok, %{"code" => "payment-acceptance"}} =
               Workflows.create(client, %{code: "payment-acceptance"})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/merchant/workflows"
    end
  end

  describe "get_version/4" do
    test "gets a specific version", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"version": 1})})

      assert {:ok, _} = Workflows.get_version(client, "payment-acceptance", 1)

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/workflows/payment-acceptance/versions/1"
    end
  end

  describe "update_version/5" do
    test "patches a version", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"version": 1})})

      assert {:ok, _} = Workflows.update_version(client, "pa", 1, %{enabled: true})

      {method, _, _, _, _} = Mock.last_request()
      assert method == :patch
    end
  end

  describe "get_default_version/3" do
    test "gets the default version", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"version": 2})})

      assert {:ok, _} = Workflows.get_default_version(client, "pa")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/workflows/pa/default"
    end
  end

  describe "set_default_version/4" do
    test "sets the default version", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"version": 3})})

      assert {:ok, _} = Workflows.set_default_version(client, "pa", %{version: 3})

      {method, _, _, _, _} = Mock.last_request()
      assert method == :put
    end
  end
end
