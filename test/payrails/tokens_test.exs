defmodule Payrails.TokensTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Tokens}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/3" do
    test "lists tokens for an instrument", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, _} = Tokens.list(client, "instr-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/instruments/instr-1/tokens"
    end
  end

  describe "create/4" do
    test "creates a token", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "tok-1"})})

      assert {:ok, %{"id" => "tok-1"}} = Tokens.create(client, "instr-1", %{provider: "stripe"})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/payment/instruments/instr-1/tokens"
    end
  end

  describe "get/4" do
    test "gets a token", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "tok-1"})})

      assert {:ok, _} = Tokens.get(client, "instr-1", "tok-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/instruments/instr-1/tokens/tok-1"
    end
  end

  describe "delete/4" do
    test "deletes a token", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})

      assert {:ok, nil} = Tokens.delete(client, "instr-1", "tok-1")

      {method, _, _, _, _} = Mock.last_request()
      assert method == :delete
    end
  end

  describe "get_from_provider/4" do
    test "gets token by provider ID", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "tok-p"})})

      assert {:ok, _} = Tokens.get_from_provider(client, "instr-1", "prov-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/payment/instruments/instr-1/tokens/provider/prov-1"
    end
  end

  describe "delete_from_provider/4" do
    test "deletes token by provider ID", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})

      assert {:ok, nil} = Tokens.delete_from_provider(client, "instr-1", "prov-1")

      {method, url, _, _, _} = Mock.last_request()
      assert method == :delete
      assert url =~ "/tokens/provider/prov-1"
    end
  end
end
