defmodule Payrails.NetworkTokens do
  @moduledoc """
  Network token provisioning and cryptogram generation.
  """

  alias Payrails.{Client, Error}

  @doc """
  Provisions a network token for a payment instrument.
  """
  @spec provision(Client.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def provision(%Client{} = client, instrument_id, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "/payment/instruments/#{instrument_id}/network-tokens",
      Keyword.put(opts, :body, body)
    )
  end

  @doc """
  Generates a cryptogram for a network token.
  """
  @spec generate_cryptogram(Client.t(), String.t(), String.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def generate_cryptogram(%Client{} = client, instrument_id, token_id, body \\ %{}, opts \\ []) do
    Client.request(
      client,
      :post,
      "/payment/instruments/#{instrument_id}/network-tokens/#{token_id}/cryptogram",
      Keyword.put(opts, :body, body)
    )
  end
end
