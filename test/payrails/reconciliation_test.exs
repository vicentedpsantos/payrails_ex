defmodule Payrails.ReconciliationTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Reconciliation}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "bulk_manual_reconcile/3" do
    test "posts to reconciliation endpoint", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"reconciled": 5})})

      assert {:ok, %{"reconciled" => 5}} =
               Reconciliation.bulk_manual_reconcile(client, %{payment_ids: ["p1", "p2"]})

      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/payment/reconciliation/manual"
    end
  end
end
