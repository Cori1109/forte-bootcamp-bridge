defmodule NftBridge.TokenServer do
  require Logger
  use GenServer
  alias NftBridge.Tokens
  alias NftBridge.Metadata

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    # Do the desired work here
    # ...
    Logger.info("Starting...")

    client = Solana.RPC.client(network: "devnet")
    tokens = Tokens.get_pending_tokens()

    custodial_wallet_address = Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:custodial_wallet_address]

    Enum.map(tokens, fn x ->
      # TODO Allow token id duplication, owner address validation.
      # This version only validates the token id for bootcamp (DO NOT USE IN PRODUCTION)

      req = {"getTokenAccountsByOwner", [custodial_wallet_address, %{"mint" => x.token_id} , %{"encoding" => "jsonParsed"}]}

      # TODO token process
      case Solana.RPC.send(client, req) do
        {:ok, info} ->
          IO.inspect(info)
          case Enum.empty?(info) do
            true ->
              Logger.warn("Not found")
            false ->
              Logger.info("Found")
              Tokens.update_status!(x.id, "received")

              metadata = get_metadata(client, x.token_id)
              IO.inspect(metadata)
          end
      end
    end)

    # Reschedule once more
    schedule_work()

    {:noreply, state}
  end

  defp get_metadata(client, token_id) do
    pda = Metadata.get_pda(token_id)

    req = {"getAccountInfo", [pda, %{"encoding" => "base64"}]}

    case Solana.RPC.send(client, req) do
      {:ok, info} ->
        IO.inspect(info)
        [head, _tail] = Map.get(info, "data")
        raw = Base.decode64!(head)
        Metadata.parse(raw)
      {:error, err} ->
        Logger.error(err)
    end
  end

  defp schedule_work do
    Process.send_after(self(), :work, 30 * 1000)
  end
end
