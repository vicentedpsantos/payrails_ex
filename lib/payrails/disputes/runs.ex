defmodule Payrails.Disputes.Runs do
  @moduledoc """
  Dispute service runs.
  """

  alias Payrails.{Client, Error}

  @base_path "/dispute/runs"

  @doc """
  Lists dispute runs.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Retrieves a dispute run by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, run_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{run_id}", opts)
  end
end
