defmodule Payrails.InstrumentsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Instruments}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists instruments", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, %{"results" => []}} = Instruments.list(client)
    end
  end

  describe "create/3" do
    test "creates an instrument", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "instr-1"})})

      assert {:ok, %{"id" => "instr-1"}} =
               Instruments.create(client, %{payment_method: "card"})

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/instruments"
    end
  end

  describe "get/3" do
    test "gets an instrument", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "instr-1"})})

      assert {:ok, %{"id" => "instr-1"}} = Instruments.get(client, "instr-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/instruments/instr-1"
    end
  end

  describe "update/4" do
    test "updates an instrument", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "instr-1"})})

      assert {:ok, _} = Instruments.update(client, "instr-1", %{status: "active"})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :put
      assert url =~ "/payment/instruments/instr-1"
    end
  end

  describe "delete/3" do
    test "deletes an instrument", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})

      assert {:ok, nil} = Instruments.delete(client, "instr-1")

      {method, url, _, _, _} = Mock.last_request()
      assert method == :delete
      assert url =~ "/payment/instruments/instr-1"
    end
  end
end
