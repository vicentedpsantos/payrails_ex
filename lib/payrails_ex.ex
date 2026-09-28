defmodule Payrails do
  @moduledoc """
  Elixir SDK for the Payrails API.

  ## Quick Start

      config = Payrails.Config.new!(
        client_id: "my-client-id",
        api_key: "my-api-key"
      )

      client = Payrails.Client.new(config)

      {:ok, holder} = Payrails.Holders.create(client, %{
        reference: "customer-123"
      })
  """
end
