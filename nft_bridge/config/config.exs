# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :nft_bridge,
  ecto_repos: [NftBridge.Repo]

# Configures the endpoint
config :nft_bridge, NftBridgeWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: NftBridgeWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: NftBridge.PubSub,
  live_view: [signing_salt: "DImld3/Y"],
  solana_custodial_wallet_address: "G9GKqWfKr78jWagsTYiacEj1L6dX3E8JLU832HMBSaKC",
  solana_custodial_wallet_file: "/home/dante/.config/solana/custodial_wallet.json",
  solana_network: "devnet",
  contract_address: "0xCfEB869F69431e42cdB54A4F4f105C19C080A601",
  json_abi_path: "../nft_contract/build/contracts/NftBridgeToken.json",
  ethereum_custodial_wallet: "0x9D16ea37330985dBe038fEc7fc12Ed3176a3F523"

config :ethereumex,
  client_type: :http,
  url: "http://localhost:8545"

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :nft_bridge, NftBridge.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
