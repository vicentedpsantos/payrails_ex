defmodule Payrails.HTTP.Behaviour do
  @moduledoc """
  Behaviour for pluggable HTTP clients.

  Implement this behaviour to use a custom HTTP client (e.g. Req, Finch)
  instead of the default `:httpc` adapter.

  ## Example

      defmodule MyApp.ReqAdapter do
        @behaviour Payrails.HTTP.Behaviour

        @impl true
        def request(method, url, headers, body, opts) do
          response = Req.request!(method: method, url: url, headers: headers, body: body)
          {:ok, %{status: response.status, headers: response.headers, body: response.body}}
        end
      end

  Then configure:

      Payrails.Config.new!(
        client_id: "...",
        api_key: "...",
        http_client: MyApp.ReqAdapter
      )
  """

  @type method :: :get | :post | :put | :patch | :delete
  @type url :: String.t()
  @type headers :: [{String.t(), String.t()}]
  @type body :: binary() | nil
  @type opts :: keyword()

  @type response :: %{
          status: integer(),
          headers: [{String.t(), String.t()}],
          body: binary()
        }

  @callback request(method(), url(), headers(), body(), opts()) ::
              {:ok, response()} | {:error, term()}
end
