defmodule Payrails.Response do
  @moduledoc """
  Wraps an HTTP response from the Payrails API.

  Most SDK functions return `{:ok, body}` directly. Use this struct
  when you need access to HTTP status codes or response headers.

  ## Fields

    * `:status` - HTTP status code
    * `:body` - Decoded JSON response body
    * `:headers` - Response headers as a list of `{name, value}` tuples
  """

  defstruct [:status, :body, :headers]

  @type t :: %__MODULE__{
          status: integer(),
          body: map() | list() | nil,
          headers: [{String.t(), String.t()}]
        }
end
