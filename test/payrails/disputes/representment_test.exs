defmodule Payrails.Disputes.RepresentmentTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config}
  alias Payrails.Disputes.Representment
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "generate_plan/3" do
    test "generates a plan", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"plan": {}})})
      assert {:ok, _} = Representment.generate_plan(client, "d-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/disputes/d-1/representment/plan"
    end
  end

  describe "regenerate_plan/3" do
    test "regenerates a plan", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"plan": {}})})
      assert {:ok, _} = Representment.regenerate_plan(client, "d-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/representment/plan/regenerate"
    end
  end

  describe "submit_evidences/4" do
    test "submits evidences", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})
      assert {:ok, _} = Representment.submit_evidences(client, "d-1", %{evidence_ids: ["e1"]})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/representment/plan/evidences"
    end
  end

  describe "generate_pdf/3" do
    test "generates a PDF", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"url": "https://pdf.test"})})
      assert {:ok, _} = Representment.generate_pdf(client, "d-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/representment/pdf"
    end
  end

  describe "edit_sections/4" do
    test "edits sections", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"sections": []})})
      assert {:ok, _} = Representment.edit_sections(client, "d-1", %{title: "Updated"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :patch
    end
  end

  describe "download_bundle/3" do
    test "downloads bundle", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"url": "https://bundle.test"})})
      assert {:ok, _} = Representment.download_bundle(client, "d-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :get
      assert url =~ "/representment/bundle"
    end
  end
end
