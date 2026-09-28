defmodule Payrails.WebhookTest do
  use ExUnit.Case, async: true

  alias Payrails.Webhook

  @secret "whsec_test_secret_key"
  @payload ~s({"event":"payment.captured","data":{"id":"pay-123"}})

  describe "verify/3" do
    test "returns :ok for valid signature" do
      signature = Webhook.compute_signature(@payload, @secret)

      assert :ok = Webhook.verify(@payload, signature, @secret)
    end

    test "returns error for invalid signature" do
      assert {:error, :invalid_signature} =
               Webhook.verify(@payload, "invalid_hex_signature_value", @secret)
    end

    test "handles sha256= prefixed signatures" do
      signature = Webhook.compute_signature(@payload, @secret)
      prefixed = "sha256=#{signature}"

      assert :ok = Webhook.verify(@payload, prefixed, @secret)
    end

    test "is case-insensitive for hex signatures" do
      signature = Webhook.compute_signature(@payload, @secret)
      upper = String.upcase(signature)

      assert :ok = Webhook.verify(@payload, upper, @secret)
    end

    test "rejects tampered payload" do
      signature = Webhook.compute_signature(@payload, @secret)
      tampered = String.replace(@payload, "pay-123", "pay-evil")

      assert {:error, :invalid_signature} = Webhook.verify(tampered, signature, @secret)
    end

    test "rejects wrong secret" do
      signature = Webhook.compute_signature(@payload, @secret)

      assert {:error, :invalid_signature} = Webhook.verify(@payload, signature, "wrong_secret")
    end
  end

  describe "construct_event/3" do
    test "returns decoded event on valid signature" do
      signature = Webhook.compute_signature(@payload, @secret)

      assert {:ok, event} = Webhook.construct_event(@payload, signature, @secret)
      assert event["event"] == "payment.captured"
      assert event["data"]["id"] == "pay-123"
    end

    test "returns error for invalid signature" do
      assert {:error, :invalid_signature} =
               Webhook.construct_event(@payload, "bad_sig", @secret)
    end

    test "returns error for invalid JSON with valid signature" do
      bad_json = "not json"
      signature = Webhook.compute_signature(bad_json, @secret)

      assert {:error, {:json_decode_error, _}} =
               Webhook.construct_event(bad_json, signature, @secret)
    end
  end

  describe "compute_signature/2" do
    test "produces consistent hex-encoded HMAC-SHA256" do
      sig1 = Webhook.compute_signature("hello", "secret")
      sig2 = Webhook.compute_signature("hello", "secret")

      assert sig1 == sig2
      assert byte_size(sig1) == 64
      assert sig1 =~ ~r/^[0-9a-f]{64}$/
    end

    test "different payloads produce different signatures" do
      sig1 = Webhook.compute_signature("payload_a", @secret)
      sig2 = Webhook.compute_signature("payload_b", @secret)

      assert sig1 != sig2
    end
  end
end
