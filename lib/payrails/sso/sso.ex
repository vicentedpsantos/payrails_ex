defmodule Payrails.SSO do
  @moduledoc """
  SSO connection CRUD and SAML configurations.
  """

  alias Payrails.{Client, Error}

  @connections_path "/merchant/sso/connections"

  @doc """
  Lists SSO connections.
  """
  @spec list_connections(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_connections(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @connections_path, opts)
  end

  @doc """
  Creates an SSO connection.
  """
  @spec create_connection(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create_connection(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @connections_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves an SSO connection by ID.
  """
  @spec get_connection(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_connection(%Client{} = client, connection_id, opts \\ []) do
    Client.request(client, :get, "#{@connections_path}/#{connection_id}", opts)
  end

  @doc """
  Updates an SSO connection.
  """
  @spec update_connection(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def update_connection(%Client{} = client, connection_id, body, opts \\ []) do
    Client.request(
      client,
      :patch,
      "#{@connections_path}/#{connection_id}",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Lists SAML configurations.
  """
  @spec list_saml_configs(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_saml_configs(%Client{} = client, opts \\ []) do
    Client.request(client, :get, "/merchant/sso/saml/configs", opts)
  end
end
