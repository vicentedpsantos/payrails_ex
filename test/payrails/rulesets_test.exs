defmodule Payrails.RulesetsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Rulesets}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists rulesets", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Rulesets.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/rulesets"
    end
  end

  describe "create/3" do
    test "creates a ruleset", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "rs-1"})})
      assert {:ok, _} = Rulesets.create(client, %{name: "test"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :post
    end
  end

  describe "get/3" do
    test "gets a ruleset", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "rs-1"})})
      assert {:ok, _} = Rulesets.get(client, "rs-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/merchant/rulesets/rs-1"
    end
  end

  describe "update/4" do
    test "updates a ruleset", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "rs-1"})})
      assert {:ok, _} = Rulesets.update(client, "rs-1", %{name: "updated"})
      {method, _, _, _, _} = Mock.last_request()
      assert method == :put
    end
  end
end
