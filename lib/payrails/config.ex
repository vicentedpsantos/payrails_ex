defmodule Payrails.Config do
  @moduledoc """
  Configuration struct for the Payrails SDK.

  ## Fields

    * `:base_url` - Base URL for the Payrails API (default: `"https://api.payrails.io"`)
    * `:vault_url` - Base URL for the Vault API (default: `"https://api.vault.payrails.io"`)
    * `:client_id` - OAuth client ID (required)
    * `:api_key` - API key / client secret (required)
    * `:http_client` - Module implementing `Payrails.HTTP.Behaviour` (default: `Payrails.HTTP.Default`)
    * `:http_options` - Adapter-specific options such as timeouts (default: `[]`)
    * `:webhook_secret` - Secret for webhook signature verification (optional)

  ## Example

      config = Payrails.Config.new!(
        client_id: "my-client-id",
        api_key: "my-api-key"
      )
  """

  @default_base_url "https://api.payrails.io"
  @default_vault_url "https://api.vault.payrails.io"

  @enforce_keys [:client_id, :api_key]
  defstruct [
    :client_id,
    :api_key,
    :webhook_secret,
    base_url: @default_base_url,
    vault_url: @default_vault_url,
    http_client: Payrails.HTTP.Default,
    http_options: []
  ]

  @type t :: %__MODULE__{
          base_url: String.t(),
          vault_url: String.t(),
          client_id: String.t(),
          api_key: String.t(),
          http_client: module(),
          http_options: keyword(),
          webhook_secret: String.t() | nil
        }

  @doc """
  Creates a new `%Payrails.Config{}` from the given keyword list.

  Raises `ArgumentError` if required fields (`:client_id`, `:api_key`) are missing
  or if any provided value is invalid.

  ## Options

  See module documentation for the full list of fields.
  """
  @spec new!(keyword()) :: t()
  def new!(opts) when is_list(opts) do
    opts
    |> validate_required!([:client_id, :api_key])
    |> validate_strings!([:client_id, :api_key])
    |> validate_urls!()
    |> then(&struct!(__MODULE__, &1))
  end

  defp validate_required!(opts, keys) do
    Enum.each(keys, fn key ->
      case Keyword.fetch(opts, key) do
        {:ok, value} when value in [nil, ""] ->
          raise ArgumentError, "#{key} cannot be nil or empty"

        :error ->
          raise ArgumentError, "#{key} is required"

        _ ->
          :ok
      end
    end)

    opts
  end

  defp validate_strings!(opts, keys) do
    Enum.each(keys, fn key ->
      case Keyword.fetch(opts, key) do
        {:ok, value} when is_binary(value) -> :ok
        {:ok, _} -> raise ArgumentError, "#{key} must be a string"
        :error -> :ok
      end
    end)

    opts
  end

  defp validate_urls!(opts) do
    Enum.each([:base_url, :vault_url], fn key ->
      case Keyword.fetch(opts, key) do
        {:ok, url} when is_binary(url) ->
          uri = URI.parse(url)

          unless uri.scheme in ["http", "https"] and is_binary(uri.host) do
            raise ArgumentError, "#{key} must be a valid HTTP(S) URL, got: #{inspect(url)}"
          end

        {:ok, _} ->
          raise ArgumentError, "#{key} must be a string"

        :error ->
          :ok
      end
    end)

    opts
  end
end
