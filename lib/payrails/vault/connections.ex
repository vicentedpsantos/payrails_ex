defmodule Payrails.Vault.Connections do
  @moduledoc """
  Vault connection CRUD and versioning.
  """

  alias Payrails.{Client, Error}

  @base_path "/vault/connections"

  @doc """
  Lists vault connections.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    request(client, :get, @base_path, opts)
  end

  @doc """
  Creates a new vault connection.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a vault connection by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, connection_id, opts \\ []) do
    request(client, :get, "#{@base_path}/#{connection_id}", opts)
  end

  @doc """
  Updates a vault connection.
  """
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def update(%Client{} = client, connection_id, body, opts \\ []) do
    request(client, :put, "#{@base_path}/#{connection_id}", Keyword.put(opts, :body, body))
  end

  @doc """
  Deletes a vault connection.
  """
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map() | nil} | {:error, Error.t()}
  def delete(%Client{} = client, connection_id, opts \\ []) do
    request(client, :delete, "#{@base_path}/#{connection_id}", opts)
  end

  # --- Versioning ---

  @doc """
  Lists versions for a vault connection.
  """
  @spec list_versions(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_versions(%Client{} = client, connection_id, opts \\ []) do
    request(client, :get, "#{@base_path}/#{connection_id}/versions", opts)
  end

  @doc """
  Creates a new version for a vault connection.
  """
  @spec create_version(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def create_version(%Client{} = client, connection_id, body, opts \\ []) do
    request(
      client,
      :post,
      "#{@base_path}/#{connection_id}/versions",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Retrieves a specific version of a vault connection.
  """
  @spec get_version(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_version(%Client{} = client, connection_id, version_id, opts \\ []) do
    request(client, :get, "#{@base_path}/#{connection_id}/versions/#{version_id}", opts)
  end

  @doc """
  Sets a version as the live version for a vault connection.
  """
  @spec set_live_version(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def set_live_version(%Client{} = client, connection_id, version_id, opts \\ []) do
    request(client, :put, "#{@base_path}/#{connection_id}/versions/#{version_id}/live", opts)
  end

  defp request(client, method, path, opts) do
    opts = Keyword.put_new(opts, :base_url, client.config.vault_url)
    Client.request(client, method, path, opts)
  end
end
