defmodule Payrails.Reports do
  @moduledoc """
  Reports and report runs.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/reports"

  @doc """
  Lists reports.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Retrieves a report by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, report_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{report_id}", opts)
  end

  @doc """
  Lists runs for a report.
  """
  @spec list_runs(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_runs(%Client{} = client, report_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{report_id}/runs", opts)
  end

  @doc """
  Creates a new run for a report.
  """
  @spec create_run(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def create_run(%Client{} = client, report_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@base_path}/#{report_id}/runs",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Retrieves a specific run for a report.
  """
  @spec get_run(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_run(%Client{} = client, report_id, run_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{report_id}/runs/#{run_id}", opts)
  end
end
