defmodule Payrails.NetworkTokensTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, NetworkTokens}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "provision/4" do
    test "provisions a network token", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "nt-1"})})

      assert {:ok, _} = NetworkTokens.provision(client, "instr-1", %{network: "visa"})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/payment/instruments/instr-1/network-tokens"
    end
  end

  describe "generate_cryptogram/5" do
    test "generates a cryptogram", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"cryptogram": "abc123"})})

      assert {:ok, _} = NetworkTokens.generate_cryptogram(client, "instr-1", "nt-1")

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/payment/instruments/instr-1/network-tokens/nt-1/cryptogram"
    end
  end
end
