defmodule Payrails.Vault.ProxyTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config}
  alias Payrails.Vault.Proxy
  alias Payrails.HTTP.Mock

  setup do
    config =
      Config.new!(
        client_id: "test-id",
        api_key: "test-key",
        http_client: Mock,
        vault_url: "https://api.vault.payrails.io"
      )

    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "proxy/4" do
    test "posts to provider proxy endpoint", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"result": "ok"})})

      assert {:ok, _} = Proxy.proxy(client, "prov-1", %{data: "test"})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/payment/providers/prov-1/proxy"
    end
  end

  describe "invoke_outbound/4" do
    test "posts to vault connection invoke endpoint", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"result": "ok"})})

      assert {:ok, _} = Proxy.invoke_outbound(client, "conn-1", %{payload: "test"})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "api.vault.payrails.io/vault/connections/conn-1/invoke"
    end
  end
end
