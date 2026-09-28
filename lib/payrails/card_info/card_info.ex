defmodule Payrails.CardInfo do
  @moduledoc """
  BIN lookup for card information.
  """

  alias Payrails.{Client, Error}

  @doc """
  Looks up card information by BIN (Bank Identification Number).

  The BIN is typically the first 6-8 digits of a card number.
  """
  @spec bin_lookup(Client.t(), String.t(), keyword()) :: {:ok, map()} | {:error, Error.t()}
  def bin_lookup(%Client{} = client, bin, opts \\ []) do
    Client.request(client, :get, "/payment/card-info/bin/#{bin}", opts)
  end
end
