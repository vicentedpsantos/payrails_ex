defmodule Payrails.AuditLogs do
  @moduledoc """
  API logs listing and event retrieval.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/audit-logs"

  @doc """
  Lists audit logs.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Lists audit log events.
  """
  @spec list_events(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_events(%Client{} = client, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/events", opts)
  end

  @doc """
  Retrieves a specific audit log event by ID.
  """
  @spec get_event(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_event(%Client{} = client, event_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/events/#{event_id}", opts)
  end
end
