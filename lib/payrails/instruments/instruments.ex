defmodule Payrails.Instruments do
  @moduledoc """
  CRUD operations on payment instruments.

  Payment instruments represent stored payment methods (cards, bank accounts, etc.)
  associated with a holder.
  """

  alias Payrails.{Client, Error}

  @base_path "/payment/instruments"

  @doc """
  Lists payment instruments.

  ## Options

  Accepts pagination and filter options passed as query params.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Creates a new payment instrument.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a payment instrument by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, instrument_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{instrument_id}", opts)
  end

  @doc """
  Updates a payment instrument.
  """
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def update(%Client{} = client, instrument_id, body, opts \\ []) do
    Client.request(client, :put, "#{@base_path}/#{instrument_id}", Keyword.put(opts, :body, body))
  end

  @doc """
  Deletes a payment instrument.
  """
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map() | nil} | {:error, Error.t()}
  def delete(%Client{} = client, instrument_id, opts \\ []) do
    Client.request(client, :delete, "#{@base_path}/#{instrument_id}", opts)
  end
end
