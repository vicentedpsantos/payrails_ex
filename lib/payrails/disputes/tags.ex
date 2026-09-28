defmodule Payrails.Disputes.Tags do
  @moduledoc """
  Tag CRUD and attach/detach/bulk operations on disputes.
  """

  alias Payrails.{Client, Error}

  @tags_path "/dispute/tags"
  @disputes_path "/dispute/disputes"

  # --- Tag CRUD ---

  @doc """
  Lists tags.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @tags_path, opts)
  end

  @doc """
  Creates a tag.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @tags_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Updates a tag.
  """
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def update(%Client{} = client, tag_id, body, opts \\ []) do
    Client.request(client, :put, "#{@tags_path}/#{tag_id}", Keyword.put(opts, :body, body))
  end

  @doc """
  Deletes a tag.
  """
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map() | nil} | {:error, Error.t()}
  def delete(%Client{} = client, tag_id, opts \\ []) do
    Client.request(client, :delete, "#{@tags_path}/#{tag_id}", opts)
  end

  # --- Attach / Detach ---

  @doc """
  Attaches a tag to a dispute.
  """
  @spec attach(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def attach(%Client{} = client, dispute_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@disputes_path}/#{dispute_id}/tags",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Detaches a tag from a dispute.
  """
  @spec detach(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, Error.t()}
  def detach(%Client{} = client, dispute_id, tag_id, opts \\ []) do
    Client.request(client, :delete, "#{@disputes_path}/#{dispute_id}/tags/#{tag_id}", opts)
  end

  # --- Bulk operations ---

  @doc """
  Bulk attaches tags to disputes.
  """
  @spec bulk_attach(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def bulk_attach(%Client{} = client, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@disputes_path}/tags/bulk",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Bulk replaces tags by type across disputes.
  """
  @spec bulk_replace_by_type(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def bulk_replace_by_type(%Client{} = client, body, opts \\ []) do
    Client.request(
      client,
      :put,
      "#{@disputes_path}/tags/bulk/type",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Replaces tags by type on a specific dispute.
  """
  @spec replace_by_type(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def replace_by_type(%Client{} = client, dispute_id, body, opts \\ []) do
    Client.request(
      client,
      :put,
      "#{@disputes_path}/#{dispute_id}/tags/type",
      Keyword.put(opts, :body, body)
    )
  end
end
