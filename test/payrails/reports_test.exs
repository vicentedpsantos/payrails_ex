defmodule Payrails.ReportsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Reports}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists reports", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Reports.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/reports"
    end
  end

  describe "get/3" do
    test "gets a report", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "rpt-1"})})
      assert {:ok, _} = Reports.get(client, "rpt-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/reports/rpt-1"
    end
  end

  describe "list_runs/3" do
    test "lists runs for a report", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Reports.list_runs(client, "rpt-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/reports/rpt-1/runs"
    end
  end

  describe "create_run/4" do
    test "creates a run", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "run-1"})})
      assert {:ok, _} = Reports.create_run(client, "rpt-1", %{})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/merchant/reports/rpt-1/runs"
    end
  end

  describe "get_run/4" do
    test "gets a specific run", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "run-1"})})
      assert {:ok, _} = Reports.get_run(client, "rpt-1", "run-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/reports/rpt-1/runs/run-1"
    end
  end
end
