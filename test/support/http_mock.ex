defmodule Payrails.HTTP.Mock do
  @moduledoc """
  Mock HTTP adapter for testing.

  Looks up the response to return from the calling process dictionary
  under the `:payrails_mock_response` key. This allows each test to
  configure its own response without shared state.

  ## Usage in tests

      mock_response(%{status: 200, headers: [], body: ~s({"id": "123"})})
      {:ok, body} = Payrails.Client.request(client, :get, "/test")

  Use `mock_response/1` for single requests or `mock_responses/1` for
  sequential requests that need different responses.
  """

  @behaviour Payrails.HTTP.Behaviour

  @impl true
  def request(_method, _url, _headers, _body, _opts \\ []) do
    case Process.get(:payrails_mock_responses) do
      [response | rest] ->
        Process.put(:payrails_mock_responses, rest)
        response

      _ ->
        case Process.get(:payrails_mock_response) do
          nil -> {:error, :no_mock_configured}
          response -> response
        end
    end
  end

  @doc """
  Sets the mock response for the current test process.
  """
  def mock_response(response) do
    Process.put(:payrails_mock_response, {:ok, response})
  end

  @doc """
  Sets the mock to return an error.
  """
  def mock_error(reason) do
    Process.put(:payrails_mock_response, {:error, reason})
  end

  @doc """
  Sets a queue of mock responses to be returned in order.
  """
  def mock_responses(responses) do
    Process.put(:payrails_mock_responses, responses)
  end
end
