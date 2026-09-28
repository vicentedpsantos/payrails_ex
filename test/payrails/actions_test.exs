defmodule Payrails.ActionsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Actions, Client, Config}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  @workflow "payment-acceptance"
  @exec_id "exec-123"

  describe "execution-level actions" do
    for action <- ~w(authorize capture cancel refund confirm payout lookup)a do
      test "#{action}/5 posts to correct path", %{client: client} do
        Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})

        action_fn = unquote(action)
        assert {:ok, _} = apply(Actions, action_fn, [client, @workflow, @exec_id, %{amount: 100}])

        {method, url, _, _, _} = Mock.last_request()
        assert method == :post
        assert url =~ "/merchant/workflows/#{@workflow}/executions/#{@exec_id}/#{expected_path(action_fn)}"
      end
    end

    test "start_payment_session/5 posts to correct path", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"session": "s1"})})

      assert {:ok, _} = Actions.start_payment_session(client, @workflow, @exec_id, %{})

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/executions/#{@exec_id}/startPaymentSession"
    end

    test "fraud_update/5 posts to correct path", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})

      assert {:ok, _} = Actions.fraud_update(client, @workflow, @exec_id, %{})

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/executions/#{@exec_id}/fraudUpdate"
    end
  end

  describe "action records" do
    test "list/2 lists actions", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})

      assert {:ok, _} = Actions.list(client)

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/actions"
    end

    test "get/3 gets an action by ID", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "act-1"})})

      assert {:ok, %{"id" => "act-1"}} = Actions.get(client, "act-1")

      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/actions/act-1"
    end
  end

  defp expected_path(:authorize), do: "authorize"
  defp expected_path(:capture), do: "capture"
  defp expected_path(:cancel), do: "cancel"
  defp expected_path(:refund), do: "refund"
  defp expected_path(:confirm), do: "confirm"
  defp expected_path(:payout), do: "payout"
  defp expected_path(:lookup), do: "lookup"
end
