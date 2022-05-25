defmodule NftBridgeWeb.DepositView do
  use NftBridgeWeb, :view

  def render("index.json", _) do
    %{
      "data": %{
        "custodial_wallet_address": "testaddress"
      }
    }
  end

  def render("error.json", _) do
    %{
      "error": "404",
      "message": "not found"
    }
  end
end
