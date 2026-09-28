defmodule Payrails.Disputes.Alerts do
  @moduledoc """
  Alert enrollment, alert CRUD, descriptors, events, match payment, and refund.
  """

  alias Payrails.{Client, Error}

  @alerts_path "/dispute/alerts"
  @enrollments_path "#{@alerts_path}/enrollments"

  # --- Enrollments ---

  @doc """
  Lists alert enrollments.
  """
  @spec list_enrollments(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_enrollments(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @enrollments_path, opts)
  end

  @doc """
  Creates an alert enrollment.
  """
  @spec enroll(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def enroll(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @enrollments_path, Keyword.put(opts, :body, body))
  end

  # --- Alerts ---

  @doc """
  Lists alerts.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @alerts_path, opts)
  end

  @doc """
  Retrieves an alert by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, alert_id, opts \\ []) do
    Client.request(client, :get, "#{@alerts_path}/#{alert_id}", opts)
  end

  @doc """
  Performs an action on an alert.
  """
  @spec action(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def action(%Client{} = client, alert_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@alerts_path}/#{alert_id}/action",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Matches a payment to an alert.
  """
  @spec match_payment(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def match_payment(%Client{} = client, alert_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@alerts_path}/#{alert_id}/match-payment",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Refunds an alert.
  """
  @spec refund(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def refund(%Client{} = client, alert_id, opts \\ []) do
    Client.request(client, :post, "#{@alerts_path}/#{alert_id}/refund", opts)
  end

  # --- Descriptors ---

  @doc """
  Lists descriptors for an enrollment.
  """
  @spec list_descriptors(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def list_descriptors(%Client{} = client, enrollment_id, opts \\ []) do
    Client.request(client, :get, "#{@enrollments_path}/#{enrollment_id}/descriptors", opts)
  end

  @doc """
  Adds descriptors to an enrollment.
  """
  @spec add_descriptors(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def add_descriptors(%Client{} = client, enrollment_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@enrollments_path}/#{enrollment_id}/descriptors",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Unenrolls a descriptor from an enrollment.
  """
  @spec unenroll_descriptor(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, Error.t()}
  def unenroll_descriptor(%Client{} = client, enrollment_id, descriptor_id, opts \\ []) do
    Client.request(
      client,
      :delete,
      "#{@enrollments_path}/#{enrollment_id}/descriptors/#{descriptor_id}",
      opts
    )
  end

  # --- Events ---

  @doc """
  Lists events for an enrollment.
  """
  @spec list_enrollment_events(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def list_enrollment_events(%Client{} = client, enrollment_id, opts \\ []) do
    Client.request(client, :get, "#{@enrollments_path}/#{enrollment_id}/events", opts)
  end

  @doc """
  Lists events for an alert.
  """
  @spec list_alert_events(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def list_alert_events(%Client{} = client, alert_id, opts \\ []) do
    Client.request(client, :get, "#{@alerts_path}/#{alert_id}/events", opts)
  end
end
