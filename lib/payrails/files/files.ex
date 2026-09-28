defmodule Payrails.Files do
  @moduledoc """
  File upload and retrieval.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/files"

  @doc """
  Retrieves a file by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, file_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{file_id}", opts)
  end

  @doc """
  Uploads a file.
  """
  @spec upload(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def upload(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end
end
