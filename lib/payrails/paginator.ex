defmodule Payrails.Paginator do
  @moduledoc """
  Lazy cursor-based pagination via `Stream`.

  Wraps any list endpoint into a `Stream` that automatically follows
  `links.next` until all pages are exhausted.

  ## Usage

      # Stream all holders, 50 per page
      Payrails.Paginator.stream(client, &Payrails.Holders.list/2, params: [page_size: 50])
      |> Stream.each(&IO.inspect/1)
      |> Stream.run()

  Each element emitted by the stream is a single item from the `results`
  list in the paginated response.
  """

  alias Payrails.Client

  @doc """
  Returns a `Stream` that lazily fetches pages from a list endpoint.

  ## Parameters

    * `client` - A `%Payrails.Client{}` with a valid token
    * `list_fn` - A function with arity 2: `(client, opts) -> {:ok, body} | {:error, reason}`.
      Typically a reference like `&Payrails.Holders.list/2`.
    * `opts` - Options passed to the list function. Supports:
      * `:params` - Query params (e.g. `page_size`, filters)
      * Any other options accepted by the list function

  ## Return

  A `Stream` of individual items from the paginated results.
  """
  @spec stream(Client.t(), (Client.t(), keyword() -> {:ok, map()} | {:error, term()}), keyword()) ::
          Enumerable.t()
  def stream(%Client{} = client, list_fn, opts \\ []) when is_function(list_fn, 2) do
    Stream.resource(
      fn -> {:first, opts} end,
      &fetch_next(&1, client, list_fn),
      fn _acc -> :ok end
    )
  end

  defp fetch_next(:done, _client, _list_fn) do
    {:halt, :done}
  end

  defp fetch_next({:first, opts}, client, list_fn) do
    case list_fn.(client, opts) do
      {:ok, body} ->
        emit_page(body)

      {:error, _reason} ->
        {:halt, :done}
    end
  end

  defp fetch_next({:next, url}, client, _list_fn) do
    # For subsequent pages, we fetch the next URL directly.
    # Strip the base URL to get just the path + query.
    {path, query} = parse_next_url(url, client.config.base_url)
    params = if query, do: [params: URI.decode_query(query)], else: []

    case Client.request(client, :get, path, params) do
      {:ok, body} ->
        emit_page(body)

      {:error, _reason} ->
        {:halt, :done}
    end
  end

  defp emit_page(body) when is_map(body) do
    results = Map.get(body, "results", [])
    next = get_in(body, ["links", "next"])

    continuation =
      if next && next != "" do
        {:next, next}
      else
        :done
      end

    {results, continuation}
  end

  defp emit_page(_body), do: {[], :done}

  defp parse_next_url(url, base_url) do
    path = String.replace_prefix(url, base_url, "")
    uri = URI.parse(path)
    {uri.path, uri.query}
  end
end
