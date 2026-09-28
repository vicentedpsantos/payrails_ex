defmodule Payrails.Auth do
  @moduledoc """
  OAuth token acquisition for the Payrails API.

  Provides functions to obtain bearer tokens for authenticating API requests
  and vault access tokens for vault-specific operations.

  ## Usage

      config = Payrails.Config.new!(client_id: "my-id", api_key: "my-key")
      client = Payrails.Client.new(config)

      {:ok, token_data} = Payrails.Auth.get_token(client)
      client = Payrails.Client.put_token(client, token_data["access_token"])

  For automatic token management, see `Payrails.Auth.TokenStore`.
  """

  alias Payrails.{Client, Error}

  @doc """
  Fetches an OAuth bearer token using the client's credentials.

  Calls `POST /auth/token/{clientId}` with the API key in the `x-api-key` header.

  Returns `{:ok, token_data}` where `token_data` contains:
    * `"access_token"` - The bearer token string
    * `"token_type"` - Token type (typically `"Bearer"`)
    * `"expires_in"` - Token lifetime in seconds

  ## Options

  Accepts the same options as `Payrails.Client.request/4`.
  """
  @spec get_token(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_token(%Client{} = client, opts \\ []) do
    path = "/auth/token/#{client.config.client_id}"

    headers = [{"x-api-key", client.config.api_key}]
    opts = Keyword.update(opts, :headers, headers, &(headers ++ &1))

    Client.request(client, :post, path, opts)
  end

  @doc """
  Fetches a vault access token for vault-specific operations.

  Calls `POST /token/auth` on the vault URL. Requires an existing
  bearer token on the client (obtained via `get_token/2`).

  Returns `{:ok, token_data}` with the vault access token details.

  ## Options

  Accepts the same options as `Payrails.Client.request/4`.
  """
  @spec get_vault_access_token(Client.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def get_vault_access_token(%Client{} = client, opts \\ []) do
    opts = Keyword.put_new(opts, :base_url, client.config.vault_url)

    Client.request(client, :post, "/token/auth", opts)
  end
end
