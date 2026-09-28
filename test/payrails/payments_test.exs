defmodule Payrails.PaymentsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Payments}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists payments", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, _} = Payments.list(client)

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/payments"
    end
  end

  describe "get/3" do
    test "gets a payment", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "pay-1"})})

      assert {:ok, %{"id" => "pay-1"}} = Payments.get(client, "pay-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/payments/pay-1"
    end
  end

  describe "get_operations/3" do
    test "gets operations for a payment", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"operations": []})})

      assert {:ok, _} = Payments.get_operations(client, "pay-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/payments/pay-1/operations"
    end
  end

  describe "get_operation_logs/4" do
    test "gets logs for a specific operation", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"logs": []})})

      assert {:ok, _} = Payments.get_operation_logs(client, "pay-1", "op-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/payments/pay-1/operations/op-1/logs"
    end
  end
end
