defmodule Payrails.Disputes.Representment do
  @moduledoc """
  Dispute representment: plan generation, evidence submission, PDF generation,
  section editing, and bundle download.
  """

  alias Payrails.{Client, Error}

  @doc """
  Generates a representment plan for a dispute.
  """
  @spec generate_plan(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def generate_plan(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :post, base_path(dispute_id, "/plan"), opts)
  end

  @doc """
  Regenerates a representment plan for a dispute.
  """
  @spec regenerate_plan(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def regenerate_plan(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :post, base_path(dispute_id, "/plan/regenerate"), opts)
  end

  @doc """
  Submits evidences for a representment plan.
  """
  @spec submit_evidences(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def submit_evidences(%Client{} = client, dispute_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      base_path(dispute_id, "/plan/evidences"),
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Generates a representment PDF for a dispute.
  """
  @spec generate_pdf(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def generate_pdf(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :post, base_path(dispute_id, "/pdf"), opts)
  end

  @doc """
  Edits representment sections for a dispute.
  """
  @spec edit_sections(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def edit_sections(%Client{} = client, dispute_id, body, opts \\ []) do
    Client.request(
      client,
      :patch,
      base_path(dispute_id, "/sections"),
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Downloads the representment bundle for a dispute.
  """
  @spec download_bundle(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def download_bundle(%Client{} = client, dispute_id, opts \\ []) do
    Client.request(client, :get, base_path(dispute_id, "/bundle"), opts)
  end

  defp base_path(dispute_id, suffix) do
    "/dispute/disputes/#{dispute_id}/representment#{suffix}"
  end
end
