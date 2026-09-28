defmodule Payrails.FraudTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Fraud}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists fraud records", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Fraud.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/fraud"
    end
  end

  describe "get/3" do
    test "gets a fraud record", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "fr-1"})})
      assert {:ok, _} = Fraud.get(client, "fr-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/fraud/fr-1"
    end
  end

  describe "get_operations/3" do
    test "gets operations", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"operations": []})})
      assert {:ok, _} = Fraud.get_operations(client, "fr-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/fraud/fr-1/operations"
    end
  end

  describe "get_operation_logs/4" do
    test "gets operation logs", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"logs": []})})
      assert {:ok, _} = Fraud.get_operation_logs(client, "fr-1", "op-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/fraud/fr-1/operations/op-1/logs"
    end
  end
end
