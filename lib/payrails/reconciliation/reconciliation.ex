defmodule Payrails.Reconciliation do
  @moduledoc """
  Bulk manual reconciliation.
  """

  alias Payrails.{Client, Error}

  @doc """
  Performs bulk manual reconciliation.
  """
  @spec bulk_manual_reconcile(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, Error.t()}
  def bulk_manual_reconcile(%Client{} = client, body, opts \\ []) do
    Client.request(
      client,
      :post,
      "/payment/reconciliation/manual",
      Keyword.put(opts, :body, body)
    )
  end
end
