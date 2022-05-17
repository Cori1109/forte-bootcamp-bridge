# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :nft_bridge,
  ecto_repos: [NftBridge.Repo]

# Configures the endpoint
config :nft_bridge, NftBridgeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "X5ZEwFGR4Z02vG2QRTDQt7hY+Tp6Shn1G+XeBROkjI4Fvbv0GHwgbpAVFamDMibo",
  render_errors: [view: NftBridgeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: NftBridge.PubSub,
  live_view: [signing_salt: "FOp0MFcl"],
  custodial_wallet_address: "Dph3pc4ip7HnGYB9dB5hjYqqaQhzWqwGePBqsMA1BXzH"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
