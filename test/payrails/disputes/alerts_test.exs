defmodule Payrails.Disputes.AlertsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config}
  alias Payrails.Disputes.Alerts
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list_enrollments/2" do
    test "lists enrollments", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Alerts.list_enrollments(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/alerts/enrollments"
    end
  end

  describe "enroll/3" do
    test "creates an enrollment", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "enr-1"})})
      assert {:ok, _} = Alerts.enroll(client, %{network: "visa"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :post
    end
  end

  describe "list/2" do
    test "lists alerts", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Alerts.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/alerts"
    end
  end

  describe "get/3" do
    test "gets an alert", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "alt-1"})})
      assert {:ok, _} = Alerts.get(client, "alt-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/alerts/alt-1"
    end
  end

  describe "action/4" do
    test "performs an action on an alert", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})
      assert {:ok, _} = Alerts.action(client, "alt-1", %{action: "resolve"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/alerts/alt-1/action"
    end
  end

  describe "match_payment/4" do
    test "matches a payment to an alert", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "matched"})})
      assert {:ok, _} = Alerts.match_payment(client, "alt-1", %{payment_id: "pay-1"})
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/alerts/alt-1/match-payment"
    end
  end

  describe "refund/3" do
    test "refunds an alert", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "refunded"})})
      assert {:ok, _} = Alerts.refund(client, "alt-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/alerts/alt-1/refund"
    end
  end

  describe "list_descriptors/3" do
    test "lists descriptors", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Alerts.list_descriptors(client, "enr-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/alerts/enrollments/enr-1/descriptors"
    end
  end

  describe "add_descriptors/4" do
    test "adds descriptors", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"status": "ok"})})
      assert {:ok, _} = Alerts.add_descriptors(client, "enr-1", %{descriptors: ["d1"]})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/enrollments/enr-1/descriptors"
    end
  end

  describe "unenroll_descriptor/4" do
    test "unenrolls a descriptor", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Alerts.unenroll_descriptor(client, "enr-1", "desc-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :delete
      assert url =~ "/enrollments/enr-1/descriptors/desc-1"
    end
  end

  describe "list_enrollment_events/3" do
    test "lists enrollment events", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"events": []})})
      assert {:ok, _} = Alerts.list_enrollment_events(client, "enr-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/enrollments/enr-1/events"
    end
  end

  describe "list_alert_events/3" do
    test "lists alert events", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"events": []})})
      assert {:ok, _} = Alerts.list_alert_events(client, "alt-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/alerts/alt-1/events"
    end
  end
end
