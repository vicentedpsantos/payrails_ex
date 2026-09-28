defmodule Payrails.Webhook do
  @moduledoc """
  Webhook signature verification using HMAC-SHA256.

  Payrails signs webhook payloads so you can verify they are authentic.
  Use `verify/3` to check a signature, or `construct_event/3` to verify
  and decode the payload in one step.

  ## Example

      case Payrails.Webhook.construct_event(raw_body, signature_header, webhook_secret) do
        {:ok, event} -> handle_event(event)
        {:error, :invalid_signature} -> send_resp(conn, 401, "Invalid signature")
      end
  """

  @doc """
  Verifies a webhook payload signature.

  Computes HMAC-SHA256 of the `payload` using `secret` and compares it
  to the provided `signature` using constant-time comparison.

  Returns `:ok` if the signature is valid, `{:error, :invalid_signature}` otherwise.
  """
  @spec verify(binary(), binary(), binary()) :: :ok | {:error, :invalid_signature}
  def verify(payload, signature, secret)
      when is_binary(payload) and is_binary(signature) and is_binary(secret) do
    expected = compute_signature(payload, secret)

    if secure_compare(expected, normalize_signature(signature)) do
      :ok
    else
      {:error, :invalid_signature}
    end
  end

  @doc """
  Verifies the signature and decodes the webhook payload.

  Returns `{:ok, decoded_event}` if the signature is valid and the payload
  is valid JSON, or `{:error, reason}` otherwise.
  """
  @spec construct_event(binary(), binary(), binary()) :: {:ok, map()} | {:error, term()}
  def construct_event(payload, signature, secret)
      when is_binary(payload) and is_binary(signature) and is_binary(secret) do
    case verify(payload, signature, secret) do
      :ok ->
        case JSON.decode(payload) do
          {:ok, event} -> {:ok, event}
          {:error, reason} -> {:error, {:json_decode_error, reason}}
        end

      error ->
        error
    end
  end

  @doc """
  Computes the HMAC-SHA256 signature for a payload.

  Returns the hex-encoded signature string.
  """
  @spec compute_signature(binary(), binary()) :: binary()
  def compute_signature(payload, secret) do
    :crypto.mac(:hmac, :sha256, secret, payload)
    |> Base.encode16(case: :lower)
  end

  # Strips any algorithm prefix (e.g. "sha256=") from the signature header
  defp normalize_signature(signature) do
    case String.split(signature, "=", parts: 2) do
      [_algo, hex] -> String.downcase(hex)
      [hex] -> String.downcase(hex)
    end
  end

  defp secure_compare(a, b) when is_binary(a) and is_binary(b) do
    if byte_size(a) == byte_size(b) do
      :crypto.hash_equals(a, b)
    else
      false
    end
  end
end
