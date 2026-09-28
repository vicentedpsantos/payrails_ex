defmodule Payrails.ThreeDSTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, ThreeDS}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists 3DS records", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = ThreeDS.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/threeds"
    end
  end

  describe "get/3" do
    test "gets a 3DS record", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "3ds-1"})})
      assert {:ok, _} = ThreeDS.get(client, "3ds-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/threeds/3ds-1"
    end
  end

  describe "get_operations/3" do
    test "gets operations", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"operations": []})})
      assert {:ok, _} = ThreeDS.get_operations(client, "3ds-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/threeds/3ds-1/operations"
    end
  end

  describe "get_operation_logs/4" do
    test "gets operation logs", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"logs": []})})
      assert {:ok, _} = ThreeDS.get_operation_logs(client, "3ds-1", "op-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/threeds/3ds-1/operations/op-1/logs"
    end
  end
end
