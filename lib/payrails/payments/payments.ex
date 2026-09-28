defmodule Payrails.Payments do
  @moduledoc """
  Operations on payments and their operations/logs.
  """

  alias Payrails.{Client, Error}

  @base_path "/payment/payments"

  @doc """
  Lists payments.

  ## Options

  Accepts pagination and filter options passed as query params.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Retrieves a payment by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, payment_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{payment_id}", opts)
  end

  @doc """
  Lists operations for a payment.
  """
  @spec get_operations(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_operations(%Client{} = client, payment_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{payment_id}/operations", opts)
  end

  @doc """
  Retrieves operation logs for a specific operation on a payment.
  """
  @spec get_operation_logs(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_operation_logs(%Client{} = client, payment_id, operation_id, opts \\ []) do
    Client.request(
      client,
      :get,
      "#{@base_path}/#{payment_id}/operations/#{operation_id}/logs",
      opts
    )
  end
end
