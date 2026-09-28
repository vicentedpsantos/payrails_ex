defmodule Payrails.Workflows do
  @moduledoc """
  Workflow configuration CRUD and versioning.

  Workflows define the payment processing logic and can be versioned.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/workflows"

  @doc """
  Lists workflow configurations.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Creates a new workflow configuration.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a specific version of a workflow.
  """
  @spec get_version(Client.t(), String.t(), String.t() | integer(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_version(%Client{} = client, code, version, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{code}/versions/#{version}", opts)
  end

  @doc """
  Updates a specific version of a workflow.
  """
  @spec update_version(Client.t(), String.t(), String.t() | integer(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def update_version(%Client{} = client, code, version, body, opts \\ []) do
    Client.request(
      client,
      :patch,
      "#{@base_path}/#{code}/versions/#{version}",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Retrieves the default version of a workflow.
  """
  @spec get_default_version(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_default_version(%Client{} = client, code, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{code}/default", opts)
  end

  @doc """
  Sets the default version for a workflow.
  """
  @spec set_default_version(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def set_default_version(%Client{} = client, code, body, opts \\ []) do
    Client.request(
      client,
      :put,
      "#{@base_path}/#{code}/default",
      Keyword.put(opts, :body, body)
    )
  end
end
