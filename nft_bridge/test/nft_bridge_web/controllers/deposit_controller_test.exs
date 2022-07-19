defmodule NftBridgeWeb.DepositControllerTest do
  use NftBridgeWeb.ConnCase

  test "POST /api/deposit with valid data", %{conn: conn} do
    conn = post(conn, "/api/deposit", data: %{
      chain_id: 1,
      owner_address: "BrjiWKs4PyViL9o7CSsy8a78ZDKDgSUDQXrJt24eVq9A",
      recipient_address: "0xd136EB70B571cEf8Db36FAd5be07cB4F76905B64",
      token_id: "81sr2GMGtRuLsu5deVseZLa9LcGudVKRcwjQCrAMWLt4"
    })
    assert %{
      "custodial_wallet_address" => "G9GKqWfKr78jWagsTYiacEj1L6dX3E8JLU832HMBSaKC",
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
