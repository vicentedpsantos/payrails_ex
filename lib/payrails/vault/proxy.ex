defmodule Payrails.Vault.Proxy do
  @moduledoc """
  Vault proxy and outbound connection invocation.
  """

  alias Payrails.{Client, Error}

  @doc """
  Proxies a request through a provider.
  """
  @spec proxy(Client.t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def proxy(%Client{} = client, provider_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "/payment/providers/#{provider_id}/proxy",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Invokes an outbound vault connection.
  """
  @spec invoke_outbound(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def invoke_outbound(%Client{} = client, connection_id, body, opts \\ []) do
    opts = Keyword.put_new(opts, :base_url, client.config.vault_url)

    Client.request(
      client,
      :post,
      "/vault/connections/#{connection_id}/invoke",
      Keyword.put(opts, :body, body)
    )
  end
end
