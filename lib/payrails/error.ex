defmodule Payrails.Error do
  @moduledoc """
  Represents an error returned by the Payrails API or encountered during a request.

  ## Fields

    * `:id` - Error identifier from the API
    * `:code` - Machine-readable error code (e.g. `"unauthorized"`, `"network_error"`)
    * `:detail` - Human-readable error description
    * `:doc_url` - Link to API documentation for this error
    * `:reason` - Additional context map from the API
    * `:status` - HTTP status code (nil for non-HTTP errors)
  """

  defstruct [:id, :code, :detail, :doc_url, :reason, :status]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          code: String.t(),
          detail: String.t() | nil,
          doc_url: String.t() | nil,
          reason: map() | nil,
          status: integer() | nil
        }

  @doc """
  Builds an error struct from a decoded API error response body and HTTP status.
  """
  @spec from_response(map(), integer()) :: t()
  def from_response(body, status) when is_map(body) do
    %__MODULE__{
      id: body["id"],
      code: body["code"] || "api_error",
      detail: body["detail"] || body["message"],
      doc_url: body["docUrl"],
      reason: body["reason"],
      status: status
    }
  end

  @doc """
  Builds an error struct for network/transport failures.
  """
  @spec network_error(term()) :: t()
  def network_error(reason) do
    %__MODULE__{
      code: "network_error",
      detail: format_reason(reason)
    }
  end

  @doc """
  Builds an error struct for JSON decoding failures.
  """
  @spec json_decode_error(term(), integer()) :: t()
  def json_decode_error(reason, status) do
    %__MODULE__{
      code: "json_decode_error",
      detail: "Failed to decode response body: #{format_reason(reason)}",
      status: status
    }
  end

  defp format_reason(reason) when is_binary(reason), do: reason
  defp format_reason(reason) when is_atom(reason), do: Atom.to_string(reason)
  defp format_reason(reason), do: inspect(reason)
end
