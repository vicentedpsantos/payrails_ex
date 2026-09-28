defmodule Payrails.PaginatorTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config, Paginator}
  alias Payrails.HTTP.Mock

  setup do
    config =
      Config.new!(
        client_id: "test-id",
        api_key: "test-key",
        http_client: Mock,
        base_url: "https://api.payrails.io"
      )

    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "stream/3" do
    test "streams items from a single page", %{client: client} do
      Mock.mock_response(%{
        status: 200,
        headers: [],
        body:
          JSON.encode!(%{
            "results" => [%{"id" => "1"}, %{"id" => "2"}],
            "links" => %{}
          })
      })

      items =
        Paginator.stream(client, &mock_list/2)
        |> Enum.to_list()

      assert items == [%{"id" => "1"}, %{"id" => "2"}]
    end

    test "streams across multiple pages", %{client: client} do
      Mock.mock_responses([
        {:ok,
         %{
           status: 200,
           headers: [],
           body:
             JSON.encode!(%{
               "results" => [%{"id" => "1"}],
               "links" => %{"next" => "https://api.payrails.io/test?cursor=abc"}
             })
         }},
        {:ok,
         %{
           status: 200,
           headers: [],
           body:
             JSON.encode!(%{
               "results" => [%{"id" => "2"}],
               "links" => %{"next" => "https://api.payrails.io/test?cursor=def"}
             })
         }},
        {:ok,
         %{
           status: 200,
           headers: [],
           body:
             JSON.encode!(%{
               "results" => [%{"id" => "3"}],
               "links" => %{}
             })
         }}
      ])

      items =
        Paginator.stream(client, &mock_list/2)
        |> Enum.to_list()

      assert items == [%{"id" => "1"}, %{"id" => "2"}, %{"id" => "3"}]
    end

    test "handles empty results", %{client: client} do
      Mock.mock_response(%{
        status: 200,
        headers: [],
        body: JSON.encode!(%{"results" => [], "links" => %{}})
      })

      items =
        Paginator.stream(client, &mock_list/2)
        |> Enum.to_list()

      assert items == []
    end

    test "stops on error", %{client: client} do
      Mock.mock_error(:timeout)

      items =
        Paginator.stream(client, &mock_list/2)
        |> Enum.to_list()

      assert items == []
    end

    test "can be composed with Stream functions", %{client: client} do
      Mock.mock_response(%{
        status: 200,
        headers: [],
        body:
          JSON.encode!(%{
            "results" => [%{"id" => "1"}, %{"id" => "2"}, %{"id" => "3"}],
            "links" => %{}
          })
      })

      items =
        Paginator.stream(client, &mock_list/2)
        |> Stream.filter(fn item -> item["id"] != "2" end)
        |> Enum.to_list()

      assert items == [%{"id" => "1"}, %{"id" => "3"}]
    end
  end

  # A simple list function that delegates to Client.request
  defp mock_list(client, opts) do
    Client.request(client, :get, "/test", opts)
  end
end
