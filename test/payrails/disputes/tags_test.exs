defmodule Payrails.Disputes.TagsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config}
  alias Payrails.Disputes.Tags
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists tags", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Tags.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/tags"
    end
  end

  describe "create/3" do
    test "creates a tag", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "tag-1"})})
      assert {:ok, _} = Tags.create(client, %{name: "fraud"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :post
    end
  end

  describe "update/4" do
    test "updates a tag", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "tag-1"})})
      assert {:ok, _} = Tags.update(client, "tag-1", %{name: "updated"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :put
    end
  end

  describe "delete/3" do
    test "deletes a tag", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Tags.delete(client, "tag-1")
      {method, _, _, _, _} = Mock.last_request()
      assert method == :delete
    end
  end

  describe "attach/4" do
    test "attaches a tag to a dispute", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})
      assert {:ok, _} = Tags.attach(client, "d-1", %{tag_id: "tag-1"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/disputes/d-1/tags"
    end
  end

  describe "detach/4" do
    test "detaches a tag from a dispute", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Tags.detach(client, "d-1", "tag-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :delete
      assert url =~ "/dispute/disputes/d-1/tags/tag-1"
    end
  end

  describe "bulk_attach/3" do
    test "bulk attaches tags", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})
      assert {:ok, _} = Tags.bulk_attach(client, %{disputes: ["d-1"], tags: ["tag-1"]})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/dispute/disputes/tags/bulk"
    end
  end

  describe "bulk_replace_by_type/3" do
    test "bulk replaces tags by type", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})
      assert {:ok, _} = Tags.bulk_replace_by_type(client, %{type: "priority", tags: ["high"]})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :put
      assert url =~ "/dispute/disputes/tags/bulk/type"
    end
  end

  describe "replace_by_type/4" do
    test "replaces tags by type on a dispute", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"status": "ok"})})
      assert {:ok, _} = Tags.replace_by_type(client, "d-1", %{type: "priority", tags: ["low"]})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :put
      assert url =~ "/dispute/disputes/d-1/tags/type"
    end
  end
end
