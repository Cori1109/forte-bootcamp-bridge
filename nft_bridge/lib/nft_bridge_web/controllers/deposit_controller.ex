defmodule NftBridgeWeb.DepositController do
  use NftBridgeWeb, :controller
  alias NftBridge.Tokens

  def deposit(conn, %{"data" => params }) do
    valid_attrs = %{
      owner_address: params["owner_address"],
      receipt_address: params["recipient_address"],
      status: "pending",
      token_id: params["token_id"],
      chain_id: params["chain_id"]
    }

    case Tokens.create_token(valid_attrs) do
      {:ok, _} ->
        custodial_wallet_address = Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:solana_custodial_wallet_address]
        json(conn, %{ data: %{ custodial_wallet_address: custodial_wallet_address }})
      {:error, _} ->
        json(conn, %{ data: %{ error: "Error processing request"}})
    end
  end
end
