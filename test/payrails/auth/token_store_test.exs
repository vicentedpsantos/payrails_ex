defmodule Payrails.Auth.TokenStoreTest do
  use ExUnit.Case, async: true

  alias Payrails.Auth.TokenStore
  alias Payrails.{Config, Error}
  alias Payrails.HTTP.Mock

  setup do
    config =
      Config.new!(
        client_id: "test-client-id",
        api_key: "test-api-key",
        http_client: Mock
      )

    %{config: config}
  end

  defp token_response(token, expires_in \\ 3600) do
    {:ok,
     %{
       status: 200,
       headers: [],
       body:
         JSON.encode!(%{
           "access_token" => token,
           "token_type" => "Bearer",
           "expires_in" => expires_in
         })
     }}
  end

  describe "start_link/1" do
    test "starts the token store", %{config: config} do
      Mock.mock_response(%{
        status: 200,
        headers: [],
        body: JSON.encode!(%{"access_token" => "t", "token_type" => "Bearer", "expires_in" => 3600})
      })

      assert {:ok, pid} = TokenStore.start_link(config: config)
      assert Process.alive?(pid)
      GenServer.stop(pid)
    end

    test "accepts a name option", %{config: config} do
      name = :"test_store_#{System.unique_integer([:positive])}"

      assert {:ok, pid} = TokenStore.start_link(config: config, name: name)
      assert Process.whereis(name) == pid
      GenServer.stop(pid)
    end
  end

  describe "get_token/1" do
    test "fetches token on first call", %{config: config} do
      Mock.mock_response(%{
        status: 200,
        headers: [],
        body:
          JSON.encode!(%{
            "access_token" => "fresh-token",
            "token_type" => "Bearer",
            "expires_in" => 3600
          })
      })

      {:ok, pid} = TokenStore.start_link(config: config)

      assert {:ok, "fresh-token"} = TokenStore.get_token(pid)
      GenServer.stop(pid)
    end

    test "returns cached token on subsequent calls", %{config: config} do
      # First call fetches, second should use cache
      Mock.mock_responses([
        token_response("first-token"),
        token_response("second-token")
      ])

      {:ok, pid} = TokenStore.start_link(config: config)

      assert {:ok, "first-token"} = TokenStore.get_token(pid)
      assert {:ok, "first-token"} = TokenStore.get_token(pid)
      GenServer.stop(pid)
    end

    test "returns error when token fetch fails", %{config: config} do
      Mock.mock_response(%{
        status: 401,
        headers: [],
        body: JSON.encode!(%{"code" => "unauthorized", "detail" => "Bad credentials"})
      })

      {:ok, pid} = TokenStore.start_link(config: config)

      assert {:error, %Error{code: "unauthorized"}} = TokenStore.get_token(pid)
      GenServer.stop(pid)
    end
  end

  describe "refresh_token/1" do
    test "forces a new token fetch", %{config: config} do
      Mock.mock_responses([
        token_response("original-token"),
        token_response("refreshed-token")
      ])

      {:ok, pid} = TokenStore.start_link(config: config)

      assert {:ok, "original-token"} = TokenStore.get_token(pid)
      assert {:ok, "refreshed-token"} = TokenStore.refresh_token(pid)
      GenServer.stop(pid)
    end
  end

  describe "auto-refresh" do
    test "schedules refresh before expiry", %{config: config} do
      # Token expires in 2 seconds, refresh buffer is 1 second,
      # so refresh should fire after ~1 second
      Mock.mock_responses([
        token_response("short-lived-token", 2),
        token_response("auto-refreshed-token", 3600)
      ])

      {:ok, pid} = TokenStore.start_link(config: config, refresh_buffer: 1)

      assert {:ok, "short-lived-token"} = TokenStore.get_token(pid)

      # Wait for auto-refresh
      Process.sleep(1_500)

      assert {:ok, "auto-refreshed-token"} = TokenStore.get_token(pid)
      GenServer.stop(pid)
    end
  end
end
