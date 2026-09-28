defmodule Payrails.ClientInit do
  @moduledoc """
  SDK client initialization and vault public info.
  """

  alias Payrails.{Client, Error}

  @doc """
  Initializes an SDK client session.
  """
  @spec init(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def init(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, "/merchant/client/init", Keyword.put(opts, :body, body))
  end

  @doc """
  Initializes a vault client session.
  """
  @spec vault_init(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def vault_init(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, "/merchant/vault/client/init", Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves vault public information (e.g. public key for card encryption).
  """
  @spec vault_public_info(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def vault_public_info(%Client{} = client, opts \\ []) do
    Client.request(client, :get, "/merchant/vault/public-info", opts)
  end
end
