defmodule Payrails.Tokens do
  @moduledoc """
  CRUD operations on payment tokens.

  Tokens are provider-specific representations of a payment instrument,
  nested under an instrument.
  """

  alias Payrails.{Client, Error}

  @doc """
  Lists tokens for a payment instrument.
  """
  @spec list(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, instrument_id, opts \\ []) do
    Client.request(client, :get, base_path(instrument_id), opts)
  end

  @doc """
  Creates a new token for a payment instrument.
  """
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, instrument_id, body, opts \\ []) do
    Client.request(client, :post, base_path(instrument_id), Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a token by ID.
  """
  @spec get(Client.t(), String.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, instrument_id, token_id, opts \\ []) do
    Client.request(client, :get, "#{base_path(instrument_id)}/#{token_id}", opts)
  end

  @doc """
  Deletes a token by ID.
  """
  @spec delete(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, Error.t()}
  def delete(%Client{} = client, instrument_id, token_id, opts \\ []) do
    Client.request(client, :delete, "#{base_path(instrument_id)}/#{token_id}", opts)
  end

  @doc """
  Retrieves a token by provider ID.
  """
  @spec get_from_provider(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_from_provider(%Client{} = client, instrument_id, provider_id, opts \\ []) do
    Client.request(
      client,
      :get,
      "#{base_path(instrument_id)}/provider/#{provider_id}",
      opts
    )
  end

  @doc """
  Deletes a token by provider ID.
  """
  @spec delete_from_provider(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, Error.t()}
  def delete_from_provider(%Client{} = client, instrument_id, provider_id, opts \\ []) do
    Client.request(
      client,
      :delete,
      "#{base_path(instrument_id)}/provider/#{provider_id}",
      opts
    )
  end

  defp base_path(instrument_id) do
    "/payment/instruments/#{instrument_id}/tokens"
  end
end
