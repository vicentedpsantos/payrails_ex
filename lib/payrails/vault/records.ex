defmodule Payrails.Vault.Records do
  @moduledoc """
  Vault records, fields, tokenize and detokenize operations.

  All endpoints in this module use the vault host (`vault_url`) by default.
  """

  alias Payrails.{Client, Error}

  @base_path "/records"

  # --- Tokenize / Detokenize ---

  @doc """
  Tokenizes data into vault records.
  """
  @spec tokenize(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def tokenize(%Client{} = client, body, opts \\ []) do
    request(client, :post, "#{@base_path}/tokenize", Keyword.put(opts, :body, body))
  end

  @doc """
  Detokenizes vault records back to plaintext.
  """
  @spec detokenize(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def detokenize(%Client{} = client, body, opts \\ []) do
    request(client, :post, "#{@base_path}/detokenize", Keyword.put(opts, :body, body))
  end

  # --- Records ---

  @doc """
  Retrieves a vault record by ID.
  """
  @spec get(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get(%Client{} = client, record_id, opts \\ []) do
    request(client, :get, "#{@base_path}/#{record_id}", opts)
  end

  @doc """
  Retrieves a vault record by alias.
  """
  @spec get_by_alias(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_by_alias(%Client{} = client, record_alias, opts \\ []) do
    request(client, :get, "#{@base_path}/alias/#{record_alias}", opts)
  end

  @doc """
  Deletes a vault record by ID.
  """
  @spec delete(Client.t(), String.t(), keyword()) :: {:ok, map() | nil} | {:error, Error.t()}
  def delete(%Client{} = client, record_id, opts \\ []) do
    request(client, :delete, "#{@base_path}/#{record_id}", opts)
  end

  @doc """
  Deletes a vault record by alias.
  """
  @spec delete_by_alias(Client.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, Error.t()}
  def delete_by_alias(%Client{} = client, record_alias, opts \\ []) do
    request(client, :delete, "#{@base_path}/alias/#{record_alias}", opts)
  end

  @doc """
  Lists vault records for a payment instrument.
  """
  @spec list_for_instrument(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def list_for_instrument(%Client{} = client, instrument_id, opts \\ []) do
    request(client, :get, "#{@base_path}/instruments/#{instrument_id}", opts)
  end

  # --- Fields ---

  @doc """
  Retrieves a vault field by alias.
  """
  @spec get_field_by_alias(Client.t(), String.t(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def get_field_by_alias(%Client{} = client, field_alias, opts \\ []) do
    request(client, :get, "#{@base_path}/fields/alias/#{field_alias}", opts)
  end

  @doc """
  Retrieves information about vault fields.
  """
  @spec get_fields_info(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_fields_info(%Client{} = client, body, opts \\ []) do
    request(client, :post, "#{@base_path}/fields/info", Keyword.put(opts, :body, body))
  end

  @doc """
  Deletes a vault field by alias.
  """
  @spec delete_field_by_alias(Client.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, Error.t()}
  def delete_field_by_alias(%Client{} = client, field_alias, opts \\ []) do
    request(client, :delete, "#{@base_path}/fields/alias/#{field_alias}", opts)
  end

  @doc """
  Deletes a specific field from a vault record.
  """
  @spec delete_field(Client.t(), String.t(), String.t(), keyword()) ::
          {:ok, map() | nil} | {:error, Error.t()}
  def delete_field(%Client{} = client, record_id, field_type, opts \\ []) do
    request(client, :delete, "#{@base_path}/#{record_id}/fields/#{field_type}", opts)
  end

  defp request(client, method, path, opts) do
    opts = Keyword.put_new(opts, :base_url, client.config.vault_url)
    Client.request(client, method, path, opts)
  end
end
