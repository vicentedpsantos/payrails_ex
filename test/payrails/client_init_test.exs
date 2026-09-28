defmodule Payrails.ClientInitTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, ClientInit, Config}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "init/3" do
    test "posts to /merchant/client/init", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"sessionId": "s1"})})

      assert {:ok, %{"sessionId" => "s1"}} = ClientInit.init(client, %{holder: "h1"})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/merchant/client/init"
    end
  end

  describe "vault_init/3" do
    test "posts to /merchant/vault/client/init", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"vaultSession": "vs1"})})

      assert {:ok, _} = ClientInit.vault_init(client, %{})

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/vault/client/init"
    end
  end

  describe "vault_public_info/2" do
    test "gets vault public info", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"publicKey": "pk_test"})})

      assert {:ok, %{"publicKey" => "pk_test"}} = ClientInit.vault_public_info(client)

      {method, url, _, _, _} = Mock.last_request()
      assert method == :get
      assert url =~ "/merchant/vault/public-info"
    end
  end
end
