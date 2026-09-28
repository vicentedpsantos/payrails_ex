defmodule Payrails.HTTP.Default do
  @moduledoc """
  Default HTTP adapter using Erlang's `:httpc`.

  Handles SSL/TLS configuration automatically using OTP's built-in
  certificate verification. Supports configurable timeouts via
  the `:http_options` config key.

  ## Options (via `http_options`)

    * `:timeout` - Request timeout in milliseconds (default: `30_000`)
    * `:connect_timeout` - Connection timeout in milliseconds (default: `10_000`)
  """

  @behaviour Payrails.HTTP.Behaviour

  @default_timeout 30_000
  @default_connect_timeout 10_000

  @impl true
  def request(method, url, headers, body, opts \\ []) do
    :ok = ensure_inets_started()

    http_opts = build_http_options(url, opts)
    request = build_request(method, url, headers, body)

    case :httpc.request(method, request, http_opts, body_format: :binary) do
      {:ok, {{_http_version, status, _reason}, resp_headers, resp_body}} ->
        {:ok,
         %{
           status: status,
           headers: normalize_headers(resp_headers),
           body: resp_body
         }}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp ensure_inets_started do
    case :inets.start() do
      :ok -> :ok
      {:error, {:already_started, :inets}} -> :ok
    end
  end

  defp build_request(:get, url, headers, _body) do
    {to_charlist(url), encode_headers(headers)}
  end

  defp build_request(:delete, url, headers, nil) do
    {to_charlist(url), encode_headers(headers)}
  end

  defp build_request(_method, url, headers, body) do
    content_type =
      headers
      |> Enum.find_value(~c"application/json", fn {k, v} ->
        if String.downcase(k) == "content-type", do: to_charlist(v)
      end)

    {to_charlist(url), encode_headers(headers), content_type, body || ""}
  end

  defp build_http_options(url, opts) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    connect_timeout = Keyword.get(opts, :connect_timeout, @default_connect_timeout)

    base = [timeout: timeout, connect_timeout: connect_timeout]

    if String.starts_with?(url, "https") do
      base ++ [ssl: ssl_options(url)]
    else
      base
    end
  end

  defp ssl_options(url) do
    %{host: host} = URI.parse(url)

    [
      verify: :verify_peer,
      depth: 3,
      server_name_indication: to_charlist(host),
      cacerts: :public_key.cacerts_get(),
      customize_hostname_check: [
        match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      ]
    ]
  end

  defp encode_headers(headers) do
    Enum.map(headers, fn {k, v} -> {to_charlist(k), to_charlist(v)} end)
  end

  defp normalize_headers(headers) do
    Enum.map(headers, fn {k, v} -> {to_string(k), to_string(v)} end)
  end
end
