defmodule Payrails.Executions do
  @moduledoc """
  Operations on workflow executions.

  Executions represent a single run of a workflow, tracking state
  through the payment lifecycle.
  """

  alias Payrails.{Client, Error}

  @doc """
  Lists executions for a workflow.
  """
  @spec list(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, workflow_code, opts \\ []) do
    Client.request(client, :get, base_path(workflow_code), opts)
  end

  @doc """
  Creates a new execution for a workflow.
  """
  @spec create(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, workflow_code, body, opts \\ []) do
    Client.request(client, :post, base_path(workflow_code), Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves an execution by ID.
  """
  @spec get(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, workflow_code, execution_id, opts \\ []) do
    Client.request(client, :get, "#{base_path(workflow_code)}/#{execution_id}", opts)
  end

  @doc """
  Retrieves the history of an execution.
  """
  @spec get_history(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_history(%Client{} = client, workflow_code, execution_id, opts \\ []) do
    Client.request(client, :get, "#{base_path(workflow_code)}/#{execution_id}/history", opts)
  end

  @doc """
  Retrieves the actions performed within an execution.
  """
  @spec get_actions(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_actions(%Client{} = client, workflow_code, execution_id, opts \\ []) do
    Client.request(client, :get, "#{base_path(workflow_code)}/#{execution_id}/actions", opts)
  end

  defp base_path(workflow_code) do
    "/merchant/workflows/#{workflow_code}/executions"
  end
end
