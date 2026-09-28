defmodule Payrails.DisputesTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Disputes}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists disputes", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Disputes.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/disputes"
    end
  end

  describe "get/3" do
    test "gets a dispute", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "d-1"})})
      assert {:ok, _} = Disputes.get(client, "d-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/disputes/d-1"
    end
  end

  describe "get_activities/3" do
    test "gets activities", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"activities": []})})
      assert {:ok, _} = Disputes.get_activities(client, "d-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/disputes/d-1/activities"
    end
  end

  describe "get_documents/3" do
    test "gets documents", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"documents": []})})
      assert {:ok, _} = Disputes.get_documents(client, "d-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/disputes/d-1/documents"
    end
  end

  describe "defend/4" do
    test "defends a dispute", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "defended"})})
      assert {:ok, _} = Disputes.defend(client, "d-1", %{reason: "fraud"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/disputes/d-1/defend"
    end
  end

  describe "accept/3" do
    test "accepts a dispute", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "accepted"})})
      assert {:ok, _} = Disputes.accept(client, "d-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/disputes/d-1/accept"
    end
  end

  describe "upload_evidence/4" do
    test "uploads evidence", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "ev-1"})})
      assert {:ok, _} = Disputes.upload_evidence(client, "d-1", %{file: "base64data"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/disputes/d-1/evidences"
    end
  end

  describe "submit_evidence/3" do
    test "submits evidence", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "submitted"})})
      assert {:ok, _} = Disputes.submit_evidence(client, "d-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/disputes/d-1/evidences/submit"
    end
  end

  describe "list_evidences/3" do
    test "lists evidences", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"evidences": []})})
      assert {:ok, _} = Disputes.list_evidences(client, "d-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :get
      assert url =~ "/dispute/disputes/d-1/evidences"
    end
  end

  describe "download_evidence/4" do
    test "downloads evidence", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"url": "https://download.test"})})
      assert {:ok, _} = Disputes.download_evidence(client, "d-1", "ev-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/disputes/d-1/evidences/ev-1/download"
    end
  end
end
