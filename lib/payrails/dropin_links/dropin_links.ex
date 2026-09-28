defmodule Payrails.DropinLinks do
  @moduledoc """
  CRUD operations on drop-in payment links.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/dropin-links"

  @doc """
  Lists drop-in links.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Creates a new drop-in link.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a drop-in link by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, link_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{link_id}", opts)
  end

  @doc """
  Deletes a drop-in link.
  """
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map() | nil} | {:error, Error.t()}
  def delete(%Client{} = client, link_id, opts \\ []) do
    Client.request(client, :delete, "#{@base_path}/#{link_id}", opts)
  end
end
