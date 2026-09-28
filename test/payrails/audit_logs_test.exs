defmodule Payrails.AuditLogsTest do
  use ExUnit.Case, async: true

  alias Payrails.{AuditLogs, Client, Config}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists audit logs", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = AuditLogs.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/audit-logs"
    end
  end

  describe "list_events/2" do
    test "lists events", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = AuditLogs.list_events(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/audit-logs/events"
    end
  end

  describe "get_event/3" do
    test "gets an event", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "evt-1"})})
      assert {:ok, _} = AuditLogs.get_event(client, "evt-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/audit-logs/events/evt-1"
    end
  end
end
