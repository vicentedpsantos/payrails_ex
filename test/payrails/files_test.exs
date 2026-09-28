defmodule Payrails.FilesTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Files}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "get/3" do
    test "gets a file", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "f-1", "name": "report.csv"})})
      assert {:ok, %{"id" => "f-1"}} = Files.get(client, "f-1")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :get
      assert url =~ "/merchant/files/f-1"
    end
  end

  describe "upload/3" do
    test "uploads a file", %{client: client} do
      Mock.mock_response(%{status: 201, headers: [], body: ~s({"id": "f-2"})})
      assert {:ok, _} = Files.upload(client, %{name: "data.csv", content: "base64data"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/merchant/files"
    end
  end
end
