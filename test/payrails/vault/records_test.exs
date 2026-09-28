defmodule Payrails.Vault.RecordsTest do
  use ExUnit.Case, async: true

  alias Payrails.{Client, Config}
  alias Payrails.Vault.Records
  alias Payrails.HTTP.Mock

  setup do
    config =
      Config.new!(
        client_id: "test-id",
        api_key: "test-key",
        http_client: Mock,
        vault_url: "https://api.vault.payrails.io"
      )

    client = Client.new(config) |> Client.put_token("tok")
    %{client: client}
  end

  describe "tokenize/3" do
    test "tokenizes data", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"token": "tok-1"})})
      assert {:ok, _} = Records.tokenize(client, %{data: "4111111111111111"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "api.vault.payrails.io/records/tokenize"
    end
  end

  describe "detokenize/3" do
    test "detokenizes data", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"data": "4111111111111111"})})
      assert {:ok, _} = Records.detokenize(client, %{token: "tok-1"})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/records/detokenize"
    end
  end

  describe "get/3" do
    test "gets a record by ID", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "rec-1"})})
      assert {:ok, _} = Records.get(client, "rec-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/records/rec-1"
    end
  end

  describe "get_by_alias/3" do
    test "gets a record by alias", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"id": "rec-1"})})
      assert {:ok, _} = Records.get_by_alias(client, "my-alias")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/records/alias/my-alias"
    end
  end

  describe "delete/3" do
    test "deletes a record by ID", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Records.delete(client, "rec-1")
      {method, _, _, _, _} = Mock.last_request()
      assert method == :delete
    end
  end

  describe "delete_by_alias/3" do
    test "deletes a record by alias", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Records.delete_by_alias(client, "my-alias")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/records/alias/my-alias"
    end
  end

  describe "list_for_instrument/3" do
    test "lists records for an instrument", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"results": []})})
      assert {:ok, _} = Records.list_for_instrument(client, "instr-1")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/records/instruments/instr-1"
    end
  end

  describe "get_field_by_alias/3" do
    test "gets a field by alias", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"value": "test"})})
      assert {:ok, _} = Records.get_field_by_alias(client, "field-alias")
      {_, url, _, _, _} = Mock.last_request()
      assert url =~ "/records/fields/alias/field-alias"
    end
  end

  describe "get_fields_info/3" do
    test "gets fields info", %{client: client} do
      Mock.mock_response(%{status: 200, headers: [], body: ~s({"fields": []})})
      assert {:ok, _} = Records.get_fields_info(client, %{record_ids: ["rec-1"]})
      {method, url, _, _, _} = Mock.last_request()
      assert method == :post
      assert url =~ "/records/fields/info"
    end
  end

  describe "delete_field_by_alias/3" do
    test "deletes a field by alias", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Records.delete_field_by_alias(client, "field-alias")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :delete
      assert url =~ "/records/fields/alias/field-alias"
    end
  end

  describe "delete_field/4" do
    test "deletes a specific field from a record", %{client: client} do
      Mock.mock_response(%{status: 204, headers: [], body: ""})
      assert {:ok, nil} = Records.delete_field(client, "rec-1", "pan")
      {method, url, _, _, _} = Mock.last_request()
      assert method == :delete
      assert url =~ "/records/rec-1/fields/pan"
    end
  end
end
