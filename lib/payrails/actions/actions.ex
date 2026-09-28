defmodule Payrails.Actions do
  @moduledoc """
  Payment actions on workflow executions.

  Provides operations like authorize, capture, cancel, refund, etc.
  on a specific execution within a workflow. Also supports listing
  and retrieving action records.
  """

  alias Payrails.{Client, Error}

  # --- Execution-level actions ---

  @doc """
  Performs a payment lookup on an execution.
  """
  @spec lookup(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def lookup(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "lookup", body, opts)
  end

  @doc """
  Starts a payment session on an execution.
  """
  @spec start_payment_session(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def start_payment_session(
        %Client{} = client,
        workflow_code,
        execution_id,
        body \\ %{},
        opts \\ []
      ) do
    post_action(client, workflow_code, execution_id, "startPaymentSession", body, opts)
  end

  @doc """
  Authorizes a payment on an execution.
  """
  @spec authorize(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def authorize(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "authorize", body, opts)
  end

  @doc """
  Confirms a payment on an execution.
  """
  @spec confirm(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def confirm(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "confirm", body, opts)
  end

  @doc """
  Cancels a payment on an execution.
  """
  @spec cancel(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def cancel(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "cancel", body, opts)
  end

  @doc """
  Captures a payment on an execution.
  """
  @spec capture(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def capture(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "capture", body, opts)
  end

  @doc """
  Refunds a payment on an execution.
  """
  @spec refund(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def refund(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "refund", body, opts)
  end

  @doc """
  Initiates a payout on an execution.
  """
  @spec payout(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def payout(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "payout", body, opts)
  end

  @doc """
  Sends a fraud update on an execution.
  """
  @spec fraud_update(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def fraud_update(%Client{} = client, workflow_code, execution_id, body \\ %{}, opts \\ []) do
    post_action(client, workflow_code, execution_id, "fraudUpdate", body, opts)
  end

  # --- Action records ---

  @doc """
  Lists action records.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, "/merchant/actions", opts)
  end

  @doc """
  Retrieves an action record by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, action_id, opts \\ []) do
    Client.request(client, :get, "/merchant/actions/#{action_id}", opts)
  end

  defp post_action(client, workflow_code, execution_id, action, body, opts) do
    path =
      "/merchant/workflows/#{workflow_code}/executions/#{execution_id}/#{action}"

    Client.request(client, :post, path, Keyword.put(opts, :body, body))
  end
end
