defmodule Payrails.ResponseTest do
  use ExUnit.Case, async: true

  alias Payrails.Response

  test "struct has expected fields" do
    response = %Response{
      status: 200,
      body: %{"id" => "123"},
      headers: [{"content-type", "application/json"}]
    }

    assert response.status == 200
    assert response.body == %{"id" => "123"}
    assert response.headers == [{"content-type", "application/json"}]
  end

  test "defaults to nil" do
    response = %Response{}

    assert response.status == nil
    assert response.body == nil
    assert response.headers == nil
  end
end
