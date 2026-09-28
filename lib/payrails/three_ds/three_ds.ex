defmodule Payrails.ThreeDS do
  @moduledoc """
  3D Secure records, operations, and operation logs.
  """

  alias Payrails.{Client, Error}

  @base_path "/payment/threeds"

  @doc """
  Lists 3DS records.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Retrieves a 3DS record by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, threeds_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{threeds_id}", opts)
  end

  @doc """
  Lists operations for a 3DS record.
  """
  @spec get_operations(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_operations(%Client{} = client, threeds_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{threeds_id}/operations", opts)
  end

  @doc """
  Retrieves operation logs for a specific operation on a 3DS record.
  """
  @spec get_operation_logs(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_operation_logs(%Client{} = client, threeds_id, operation_id, opts \\ []) do
    Client.request(
      client,
      :get,
      "#{@base_path}/#{threeds_id}/operations/#{operation_id}/logs",
      opts
    )
  end
end
