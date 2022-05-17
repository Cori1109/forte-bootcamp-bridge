defmodule NftBridgeWeb.DepositControllerTest do
  use NftBridgeWeb.ConnCase

  test "POST /api/deposit with valid data", %{conn: conn} do
    conn = post(conn, "/api/deposit", data: %{
      chain_id: 1,
      owner_address: "BrjiWKs4PyViL9o7CSsy8a78ZDKDgSUDQXrJt24eVq9A",
      recipient_address: "0xc354a878bcD24eBd597732CBEf7a4fc925653c9B",
      token_id: "6forqAKXSXyvTYL8aLB1chnBGF35qAnmyBYezrR7CbXe"
    })
    assert %{
      "custodial_wallet_address" => "Dph3pc4ip7HnGYB9dB5hjYqqaQhzWqwGePBqsMA1BXzH",
    } = json_response(conn, 200)["data"]
  end

  test "POST /api/deposit with empty body", %{conn: conn} do
    conn = post(conn, "/api/deposit", data: %{
    })
    assert %{
      "error" => "Error processing request",
    } = json_response(conn, 200)["data"]
  end
end
