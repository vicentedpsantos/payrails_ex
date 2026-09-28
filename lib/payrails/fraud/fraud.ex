defmodule Payrails.Fraud do
  @moduledoc """
  Fraud checks, operations, and operation logs.
  """

  alias Payrails.{Client, Error}

  @base_path "/payment/fraud"

  @doc """
  Lists fraud records.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Retrieves a fraud record by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, fraud_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{fraud_id}", opts)
  end

  @doc """
  Lists operations for a fraud record.
  """
  @spec get_operations(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_operations(%Client{} = client, fraud_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{fraud_id}/operations", opts)
  end

  @doc """
  Retrieves operation logs for a specific operation on a fraud record.
  """
  @spec get_operation_logs(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_operation_logs(%Client{} = client, fraud_id, operation_id, opts \\ []) do
    Client.request(
      client,
      :get,
      "#{@base_path}/#{fraud_id}/operations/#{operation_id}/logs",
      opts
    )
  end
end
