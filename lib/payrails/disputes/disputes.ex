defmodule Payrails.Disputes do
  @moduledoc """
  Dispute operations: listing, defense, evidence management.
  """

  alias Payrails.{Client, Error}

  @base_path "/dispute/disputes"

  @doc """
  Lists disputes.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Retrieves a dispute by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{dispute_id}", opts)
  end

  @doc """
  Retrieves activities for a dispute.
  """
  @spec get_activities(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_activities(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{dispute_id}/activities", opts)
  end

  @doc """
  Retrieves documents for a dispute.
  """
  @spec get_documents(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_documents(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{dispute_id}/documents", opts)
  end

  @doc """
  Defends a dispute.
  """
  @spec defend(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def defend(%Client{} = client, dispute_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@base_path}/#{dispute_id}/defend",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Accepts a dispute.
  """
  @spec accept(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def accept(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :post, "#{@base_path}/#{dispute_id}/accept", opts)
  end

  @doc """
  Uploads evidence for a dispute.
  """
  @spec upload_evidence(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def upload_evidence(%Client{} = client, dispute_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@base_path}/#{dispute_id}/evidences",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Submits evidence for a dispute.
  """
  @spec submit_evidence(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def submit_evidence(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :post, "#{@base_path}/#{dispute_id}/evidences/submit", opts)
  end

  @doc """
  Lists evidence for a dispute.
  """
  @spec list_evidences(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_evidences(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{dispute_id}/evidences", opts)
  end

  @doc """
  Downloads evidence for a dispute.
  """
  @spec download_evidence(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def download_evidence(%Client{} = client, dispute_id, evidence_id, opts \\ []) do
    Client.request(
      client,
      :get,
      "#{@base_path}/#{dispute_id}/evidences/#{evidence_id}/download",
      opts
    )
  end
end
