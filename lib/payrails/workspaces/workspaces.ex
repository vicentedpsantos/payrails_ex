defmodule Payrails.Workspaces do
  @moduledoc """
  Operations on workspaces.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/workspaces"

  @doc """
  Lists workspaces.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Creates a new workspace.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a workspace by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, workspace_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{workspace_id}", opts)
  end

  @doc """
  Creates multiple workspaces in a batch.
  """
  @spec create_batch(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create_batch(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, "#{@base_path}/batch", Keyword.put(opts, :body, body))
  end
end
