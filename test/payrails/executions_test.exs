defmodule Payrails.ExecutionsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Executions}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/3" do
    test "lists executions for a workflow", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, _} = Executions.list(client, "payment-acceptance")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/workflows/payment-acceptance/executions"
    end
  end

  describe "create/4" do
    test "creates an execution", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "exec-1"})})

      assert {:ok, %{"id" => "exec-1"}} =
               Executions.create(client, "payment-acceptance", %{
                 merchant_reference: "order-1"
               })

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/merchant/workflows/payment-acceptance/executions"
    end
  end

  describe "get/4" do
    test "gets an execution", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "exec-1"})})

      assert {:ok, _} = Executions.get(client, "payment-acceptance", "exec-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/workflows/payment-acceptance/executions/exec-1"
    end
  end

  describe "get_history/4" do
    test "gets execution history", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"history": []})})

      assert {:ok, _} = Executions.get_history(client, "pa", "exec-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/executions/exec-1/history"
    end
  end

  describe "get_actions/4" do
    test "gets execution actions", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"actions": []})})

      assert {:ok, _} = Executions.get_actions(client, "pa", "exec-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/executions/exec-1/actions"
    end
  end
end
