defmodule Payrails.HTTP.Mock do
  @moduledoc """
  Mock HTTP adapter for testing.

  Uses an ETS table for response storage, allowing cross-process usage
  (e.g. when a GenServer makes HTTP calls on behalf of a test).

  ## Usage in tests

      mock_response(%{status: 200, headers: [], body: ~s({"id": "123"})})
      {:ok, body} = Payrails.Client.request(client, :get, "/test")

  Use `mock_response/1` for single requests or `mock_responses/1` for
  sequential requests that need different responses.
  """

  @behaviour Payrails.HTTP.Behaviour
  @table __MODULE__

  @doc """
  Creates the ETS table. Call once from test_helper.exs.
  """
  def setup! do
    :ets.new(@table, [:named_table, :public, :set])
    :ok
  end

  @impl true
  def request(_method, _url, _headers, _body, _opts \\ []) do
    owner = find_owner()

    case :ets.lookup(@table, {owner, :responses}) do
      [{_, [response | rest]}] ->
        :ets.insert(@table, {{owner, :responses}, rest})
        response

      _ ->
        case :ets.lookup(@table, {owner, :response}) do
          [{_, response}] -> response
          [] -> {:error, :no_mock_configured}
        end
    end
  end

  @doc """
  Sets the mock response for the current test process.
  """
  def mock_response(response) do
    :ets.insert(@table, {{self(), :response}, {:ok, response}})
  end

  @doc """
  Sets the mock to return an error.
  """
  def mock_error(reason) do
    :ets.insert(@table, {{self(), :response}, {:error, reason}})
  end

  @doc """
  Sets a queue of mock responses to be returned in order.
  """
  def mock_responses(responses) do
    :ets.insert(@table, {{self(), :responses}, responses})
  end

  # Finds the owning test process. If the calling process is not
  # the one that set up the mock (e.g. a GenServer), we walk up
  # the ancestor chain via $ancestors to find the test process.
  defp find_owner do
    pid = self()

    case :ets.whereis(@table) do
      :undefined ->
        pid

      _ ->
        if :ets.lookup(@table, {pid, :response}) != [] or
             :ets.lookup(@table, {pid, :responses}) != [] do
          pid
        else
          find_ancestor_owner(pid)
        end
    end
  end

  defp find_ancestor_owner(pid) do
    case Process.info(pid, :dictionary) do
      {:dictionary, dict} ->
        ancestors = Keyword.get(dict, :"$ancestors", [])
        Enum.find(ancestors, self(), &has_mock?/1)

      nil ->
        self()
    end
  end

  defp has_mock?(pid) when is_pid(pid) do
    :ets.lookup(@table, {pid, :response}) != [] or
      :ets.lookup(@table, {pid, :responses}) != []
  end

  defp has_mock?(_), do: false
end
