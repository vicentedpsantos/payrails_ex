defmodule Payrails.ErrorTest do
  use ExUnit.Case, async: true

  alias Payrails.Error

  describe "from_response/2" do
    test "builds error from API error body" do
      body = %{
        "id" => "err-123",
        "code" => "unauthorized",
        "detail" => "Invalid credentials",
        "docUrl" => "https://docs.payrails.com/errors/unauthorized",
        "reason" => %{"field" => "api_key"}
      }

      error = Error.from_response(body, 401)

      assert %Error{} = error
      assert error.id == "err-123"
      assert error.code == "unauthorized"
      assert error.detail == "Invalid credentials"
      assert error.doc_url == "https://docs.payrails.com/errors/unauthorized"
      assert error.reason == %{"field" => "api_key"}
      assert error.status == 401
    end

    test "defaults code to api_error when not present" do
      error = Error.from_response(%{}, 500)

      assert error.code == "api_error"
    end

    test "falls back to message field for detail" do
      error = Error.from_response(%{"message" => "Something went wrong"}, 400)

      assert error.detail == "Something went wrong"
    end
  end

  describe "network_error/1" do
    test "wraps a reason atom" do
      error = Error.network_error(:timeout)

      assert error.code == "network_error"
      assert error.detail == "timeout"
      assert error.status == nil
    end

    test "wraps a reason string" do
      error = Error.network_error("connection refused")

      assert error.code == "network_error"
      assert error.detail == "connection refused"
    end

    test "wraps a complex reason" do
      error = Error.network_error({:tls_alert, :handshake_failure})

      assert error.code == "network_error"
      assert error.detail =~ "tls_alert"
    end
  end

  describe "json_decode_error/2" do
    test "wraps a JSON decode failure" do
      error = Error.json_decode_error("unexpected token", 200)

      assert error.code == "json_decode_error"
      assert error.detail =~ "Failed to decode response body"
      assert error.detail =~ "unexpected token"
      assert error.status == 200
    end
  end
end
