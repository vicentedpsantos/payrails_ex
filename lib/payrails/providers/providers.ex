defmodule Payrails.Providers do
  @moduledoc """
  Operations on payment providers and their configurations.
  """

  alias Payrails.{Client, Error}

  @base_path "/payment/providers"
  @configs_path "#{@base_path}/configs"

  # --- Providers ---

  @doc """
  Lists available providers.
  """
  @spec list(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @base_path, opts)
  end

  @doc """
  Retrieves a provider by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, provider_id, opts \\ []) do
    Client.request(client, :get, "#{@base_path}/#{provider_id}", opts)
  end

  # --- Provider Configs ---

  @doc """
  Lists active provider configurations.
  """
  @spec list_active_configs(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_active_configs(%Client{} = client, opts \\ []) do
    Client.request(client, :get, "#{@configs_path}/active", opts)
  end

  @doc """
  Lists all provider configurations.
  """
  @spec list_configs(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def list_configs(%Client{} = client, opts \\ []) do
    Client.request(client, :get, @configs_path, opts)
  end

  @doc """
  Creates a provider configuration.
  """
  @spec create_config(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def create_config(%Client{} = client, body, opts \\ []) do
    Client.request(client, :post, @configs_path, Keyword.put(opts, :body, body))
  end

  @doc """
  Retrieves a provider configuration by ID.
  """
  @spec get_config(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_config(%Client{} = client, config_id, opts \\ []) do
    Client.request(client, :get, "#{@configs_path}/#{config_id}", opts)
  end

  @doc """
  Replaces a provider configuration.
  """
  @spec update_config(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def update_config(%Client{} = client, config_id, body, opts \\ []) do
    Client.request(client, :put, "#{@configs_path}/#{config_id}", Keyword.put(opts, :body, body))
  end

  @doc """
  Partially updates a provider configuration.
  """
  @spec patch_config(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def patch_config(%Client{} = client, config_id, body, opts \\ []) do
    Client.request(
      client,
      :patch,
      "#{@configs_path}/#{config_id}",
      Keyword.put(opts, :body, body)
    )
  end

  # --- Authenticated Configs ---

  @doc """
  Creates an authenticated provider configuration.
  """
  @spec create_authenticated_config(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def create_authenticated_config(%Client{} = client, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@configs_path}/authenticated",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Updates an authenticated provider configuration.
  """
  @spec update_authenticated_config(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def update_authenticated_config(%Client{} = client, config_id, body, opts \\ []) do
    Client.request(
      client,
      :put,
      "#{@configs_path}/authenticated/#{config_id}",
      Keyword.put(opts, :body, body)
    )
  end

  # --- Onboarding ---

  @doc """
  Creates an onboarding URL for a provider configuration.
  """
  @spec create_onboarding_url(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def create_onboarding_url(%Client{} = client, config_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "#{@configs_path}/#{config_id}/onboarding-url",
      Keyword.put(opts, :body, body)
    )
  end
end
