defmodule Payrails.Holders do
  @moduledoc """
  Operations on payment holders.

  Holders represent customers or entities that own payment instruments.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/holders"

  @doc """
  Lists holders.

  ## Options

  Accepts pagination and filter options passed as query params.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Creates a new holder.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a holder by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, holder_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{holder_id}", opts)
  end
end
