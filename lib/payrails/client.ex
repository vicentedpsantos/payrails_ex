defmodule Payrails.Client do
  @moduledoc """
  HTTP client for executing requests against the Payrails API.

  Holds configuration and an optional bearer token. Builds URLs, sets
  required headers, encodes/decodes JSON, and delegates to the configured
  HTTP adapter.

  ## Usage

      config = Payrails.Config.new!(client_id: "...", api_key: "...")
      client = Payrails.Client.new(config)

      # After obtaining a token (see Payrails.Auth):
      client = Payrails.Client.put_token(client, "bearer-token-here")

      {:ok, body} = Payrails.Client.request(client, :get, "/merchant/holders")
  """

  alias Payrails.{Config, Error, Response}

  defstruct [:config, :token]

  @type t :: %__MODULE__{
          config: Config.t(),
          token: String.t() | nil
        }

  @mutating_methods [:post, :put, :patch, :delete]

  @doc """
  Creates a new client from the given config.
  """
  @spec new(Config.t()) :: t()
  def new(%Config{} = config) do
    %__MODULE__{config: config}
  end

  @doc """
  Sets the bearer token on the client.
  """
  @spec put_token(t(), String.t()) :: t()
  def put_token(%__MODULE__{} = client, token) when is_binary(token) do
    %{client | token: token}
  end

  @doc """
  Executes an HTTP request against the Payrails API.

  Returns `{:ok, body}` with the decoded JSON response body on success (2xx),
  or `{:error, %Payrails.Error{}}` on failure.

  ## Options

    * `:body` - Request body (will be JSON-encoded)
    * `:params` - Query parameters as a keyword list or map
    * `:idempotency_key` - Custom idempotency key for mutating requests
    * `:base_url` - Override the base URL (e.g. for vault endpoints)
    * `:headers` - Additional headers to merge
  """
  @spec request(t(), atom(), String.t(), keyword()) ::
          {:ok, map() | list() | binary()} | {:error, Error.t()}
  def request(%__MODULE__{} = client, method, path, opts \\ []) do
    base_url = Keyword.get(opts, :base_url, client.config.base_url)
    url = build_url(base_url, path, Keyword.get(opts, :params))
    headers = build_headers(client, method, opts)
    body = encode_body(Keyword.get(opts, :body))

    case client.config.http_client.request(method, url, headers, body, client.config.http_options) do
      {:ok, %{status: status, body: resp_body, headers: resp_headers}} ->
        handle_response(status, resp_body, resp_headers)

      {:error, reason} ->
        {:error, Error.network_error(reason)}
    end
  end

  @doc """
  Same as `request/4` but returns a `%Payrails.Response{}` struct on success
  instead of just the body, giving access to status code and headers.
  """
  @spec request_full(t(), atom(), String.t(), keyword()) ::
          {:ok, Response.t()} | {:error, Error.t()}
  def request_full(%__MODULE__{} = client, method, path, opts \\ []) do
    base_url = Keyword.get(opts, :base_url, client.config.base_url)
    url = build_url(base_url, path, Keyword.get(opts, :params))
    headers = build_headers(client, method, opts)
    body = encode_body(Keyword.get(opts, :body))

    case client.config.http_client.request(method, url, headers, body, client.config.http_options) do
      {:ok, %{status: status, body: resp_body, headers: resp_headers}} ->
        handle_full_response(status, resp_body, resp_headers)

      {:error, reason} ->
        {:error, Error.network_error(reason)}
    end
  end

  defp build_url(base_url, path, nil), do: base_url <> path

  defp build_url(base_url, path, params) when is_list(params) or is_map(params) do
    query =
      params
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> URI.encode_query()

    case query do
      "" -> base_url <> path
      q -> base_url <> path <> "?" <> q
    end
  end

  defp build_headers(client, method, opts) do
    extra_headers = Keyword.get(opts, :headers, [])

    base = [
      {"accept", "application/json"},
      {"content-type", "application/json"}
    ]

    base
    |> maybe_add_auth(client.token)
    |> maybe_add_idempotency_key(method, opts)
    |> Kernel.++(extra_headers)
  end

  defp maybe_add_auth(headers, nil), do: headers

  defp maybe_add_auth(headers, token) do
    [{"authorization", "Bearer #{token}"} | headers]
  end

  defp maybe_add_idempotency_key(headers, method, opts) when method in @mutating_methods do
    key = Keyword.get_lazy(opts, :idempotency_key, &generate_idempotency_key/0)
    [{"x-idempotency-key", key} | headers]
  end

  defp maybe_add_idempotency_key(headers, _method, _opts), do: headers

  defp generate_idempotency_key do
    <<a::32, b::16, c::16, d::16, e::48>> = :crypto.strong_rand_bytes(16)

    [
      Base.encode16(<<a::32>>, case: :lower),
      Base.encode16(<<b::16>>, case: :lower),
      Base.encode16(<<c::16>>, case: :lower),
      Base.encode16(<<d::16>>, case: :lower),
      Base.encode16(<<e::48>>, case: :lower)
    ]
    |> Enum.join("-")
  end

  defp encode_body(nil), do: nil
  defp encode_body(body) when is_map(body) or is_list(body), do: JSON.encode!(body)
  defp encode_body(body) when is_binary(body), do: body

  defp handle_response(status, resp_body, _resp_headers) when status in 200..299 do
    decode_body(resp_body)
  end

  defp handle_response(status, resp_body, _resp_headers) do
    case decode_body_raw(resp_body) do
      {:ok, body} when is_map(body) ->
        {:error, Error.from_response(body, status)}

      _ ->
        {:error, %Error{code: "api_error", detail: resp_body, status: status}}
    end
  end

  defp handle_full_response(status, resp_body, resp_headers) when status in 200..299 do
    case decode_body(resp_body) do
      {:ok, body} ->
        {:ok, %Response{status: status, body: body, headers: resp_headers}}

      {:error, _} = error ->
        error
    end
  end

  defp handle_full_response(status, resp_body, _resp_headers) do
    case decode_body_raw(resp_body) do
      {:ok, body} when is_map(body) ->
        {:error, Error.from_response(body, status)}

      _ ->
        {:error, %Error{code: "api_error", detail: resp_body, status: status}}
    end
  end

  defp decode_body(""), do: {:ok, nil}
  defp decode_body(nil), do: {:ok, nil}

  defp decode_body(body) when is_binary(body) do
    case JSON.decode(body) do
      {:ok, decoded} -> {:ok, decoded}
      {:error, reason} -> {:error, Error.json_decode_error(reason, nil)}
    end
  end

  defp decode_body_raw(""), do: {:ok, nil}
  defp decode_body_raw(nil), do: {:ok, nil}

  defp decode_body_raw(body) when is_binary(body) do
    JSON.decode(body)
  end
end
