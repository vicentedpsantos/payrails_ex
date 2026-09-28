defmodule Payrails.Auth.TokenStore do
  @moduledoc """
  Optional GenServer that caches bearer tokens and auto-refreshes before expiry.

  Use this for long-lived processes that make many API calls. For simple
  scripting or short-lived usage, manually calling `Payrails.Auth.get_token/2`
  and `Payrails.Client.put_token/2` is sufficient.

  ## Usage

      config = Payrails.Config.new!(client_id: "...", api_key: "...")

      {:ok, pid} = Payrails.Auth.TokenStore.start_link(config: config)
      {:ok, token} = Payrails.Auth.TokenStore.get_token(pid)

  ## Supervision

  Add to your supervision tree:

      children = [
        {Payrails.Auth.TokenStore, config: config, name: MyApp.PayrailsTokenStore}
      ]

  Then retrieve tokens by name:

      {:ok, token} = Payrails.Auth.TokenStore.get_token(MyApp.PayrailsTokenStore)
  """

  use GenServer

  alias Payrails.{Auth, Client, Config}

  @refresh_buffer_seconds 60

  @doc """
  Starts the token store.

  ## Options

    * `:config` (required) - A `%Payrails.Config{}` struct
    * `:name` - Optional GenServer name for registration
    * `:refresh_buffer` - Seconds before expiry to trigger refresh (default: #{@refresh_buffer_seconds})
  """
  def start_link(opts) do
    {config, opts} = Keyword.pop!(opts, :config)
    {refresh_buffer, opts} = Keyword.pop(opts, :refresh_buffer, @refresh_buffer_seconds)

    GenServer.start_link(__MODULE__, {config, refresh_buffer}, opts)
  end

  @doc """
  Returns a valid bearer token, fetching or refreshing as needed.

  Returns `{:ok, token_string}` or `{:error, reason}`.
  """
  @spec get_token(GenServer.server()) :: {:ok, String.t()} | {:error, term()}
  def get_token(server) do
    GenServer.call(server, :get_token)
  end

  @doc """
  Forces a token refresh, discarding any cached token.

  Returns `{:ok, token_string}` or `{:error, reason}`.
  """
  @spec refresh_token(GenServer.server()) :: {:ok, String.t()} | {:error, term()}
  def refresh_token(server) do
    GenServer.call(server, :refresh_token)
  end

  # Server callbacks

  @impl true
  def init({%Config{} = config, refresh_buffer}) do
    state = %{
      config: config,
      client: Client.new(config),
      token: nil,
      expires_at: nil,
      refresh_buffer: refresh_buffer,
      refresh_timer: nil
    }

    {:ok, state}
  end

  @impl true
  def handle_call(:get_token, _from, state) do
    if token_valid?(state) do
      {:reply, {:ok, state.token}, state}
    else
      case fetch_token(state) do
        {:ok, new_state} -> {:reply, {:ok, new_state.token}, new_state}
        {:error, reason} -> {:reply, {:error, reason}, state}
      end
    end
  end

  def handle_call(:refresh_token, _from, state) do
    state = cancel_refresh_timer(state)

    case fetch_token(state) do
      {:ok, new_state} -> {:reply, {:ok, new_state.token}, new_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_info(:refresh, state) do
    case fetch_token(state) do
      {:ok, new_state} -> {:noreply, new_state}
      {:error, _reason} -> {:noreply, %{state | token: nil, expires_at: nil}}
    end
  end

  defp token_valid?(%{token: nil}), do: false

  defp token_valid?(%{expires_at: expires_at}) do
    System.monotonic_time(:second) < expires_at
  end

  defp fetch_token(state) do
    case Auth.get_token(state.client) do
      {:ok, %{"access_token" => token, "expires_in" => expires_in}} ->
        state = cancel_refresh_timer(state)

        now = System.monotonic_time(:second)
        expires_at = now + expires_in
        refresh_in = max(expires_in - state.refresh_buffer, 1)
        timer = Process.send_after(self(), :refresh, refresh_in * 1_000)

        {:ok,
         %{
           state
           | token: token,
             expires_at: expires_at,
             refresh_timer: timer
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp cancel_refresh_timer(%{refresh_timer: nil} = state), do: state

  defp cancel_refresh_timer(%{refresh_timer: timer} = state) do
    Process.cancel_timer(timer)
    %{state | refresh_timer: nil}
  end
end
