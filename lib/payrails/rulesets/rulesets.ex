defmodule Payrails.Rulesets do
  @moduledoc """
  CRUD operations on rulesets.
  """

  alias Payrails.{Client, Error}

  @base_path "/merchant/rulesets"

  @doc """
  Lists rulesets.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Creates a new ruleset.
  """
  @spec create(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @base_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a ruleset by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, ruleset_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{ruleset_id}", opts)
  end

  @doc """
  Updates a ruleset.
  """
  @spec update(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def update(%Client{} = client, ruleset_id, body, opts \\ []) do
    Client.request(
      client,
      :put,
      "#{@base_path}/#{ruleset_id}",
      Keyword.put(opts, :body, body)
    )
  end
end
