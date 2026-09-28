defmodule Payrails.CardInfoTest do
  use ExUnit.Case, async: true

  alias Payrails.{CardInfo, Client, Config}
  alias Payrails.HTTP.Mock

  setup do
    config = Config.new!(client_id: "test-id", api_key: "test-key", http_client: Mock)
    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "bin_lookup/3" do
    test "looks up card info by BIN", %{client: client} do
      Mock.mock_response(%{
        status: 200,
        headers: [],
        body: ~s({"brand": "visa", "type": "credit", "country": "US"})
      })

      assert {:ok, %{"brand" => "visa"}} = CardInfo.bin_lookup(client, "411111")

      {method, url, _, _, _} = Mock.last_request()
      assert method == :get
      assert url =~ "/payment/card-info/bin/411111"
    end
  end
end
