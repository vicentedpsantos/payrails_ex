defmodule Payrails.Disputes.RunsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config}
  alias Payrails.Disputes.Runs
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "list/2" do
    test "lists runs", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Runs.list(client)
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/runs"
    end
  end

  describe "get/3" do
    test "gets a run", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "run-1"})})
      assert {:ok, _} = Runs.get(client, "run-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/dispute/runs/run-1"
    end
  end
end
