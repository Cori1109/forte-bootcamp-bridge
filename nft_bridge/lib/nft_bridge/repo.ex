defmodule NftBridge.Repo do
  use Ecto.Repo,
    otp_app: :nft_bridge,
    adapter: Ecto.Adapters.Postgres
end
