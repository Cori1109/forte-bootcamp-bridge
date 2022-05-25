defmodule NftBridgeWeb.DepositController do
  use NftBridgeWeb, :controller
  require Logger
  alias NftBridge.Deposits
  alias NftBridge.Deposits.Record
  alias NftBridgeWeb.RecordController
  alias NftBridgeWeb.SolanaClient
  alias NftBridgeWeb.Registry

  @custodial_wallet "Dph3pc4ip7HnGYB9dB5hjYqqaQhzWqwGePBqsMA1BXzH"

  def deposit(conn, %{"data" => params }) do
    if (params === nil or not hasData(params)) do
      conn
      |> put_status(404)
      |> render("error.json")
    else
      account_address = SolanaClient.get_custodial_token_account_address(@custodial_wallet, params["token_id"])
      SolanaClient.account_subscribe(account_address)

      case Deposits.create_records(convertToRecord(params)) do
        {:ok, _} ->
          conn
          |> put_status(200)
          |> render("custodial_wallet_address.json", custodian_address: @custodial_wallet)

        {:error, res} ->
          conn
          |> put_status(500)
          |> render("error.json", res.errors)
      end
    end
  end

  defp hasData(data) do
    Map.has_key?(data, "chain_id")
      and Map.has_key?(data, "owner_address")
      and Map.has_key?(data, "recipient_address")
      and Map.has_key?(data, "token_id")
  end

  defp convertToRecord(data) do
    %{
      "owner_address" => data["owner_address"],
      "recipient_address" => data["recipient_address"],
      "token_id" => data["token_id"],
      "status" => "in_progress"
    }
  end
end
