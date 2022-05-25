defmodule NftBridge.TokenServer do
  require Logger
  use GenServer
  alias NftBridge.Tokens
  alias NftBridge.Metadata

  @contract_address Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:contract_address]

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
    ExW3.Contract.start_link
  end

  @impl true
  def init(_) do
    json_path = Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:json_abi_path]
    {:ok, json} = get_json(json_path)
    token_abi = reformat_abi(json["abi"])

    # Schedule work to be performed on start
    schedule_work()

    {:ok, token_abi}
  end

  @impl true
  def handle_info(:work, abi) do
    Logger.info("Starting...")

    ExW3.Contract.register(:Nft, abi: abi)
    ExW3.Contract.at(:Nft, @contract_address)

    solana_network = Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:solana_network]
    client = Solana.RPC.client(network: solana_network)

    custodial_wallet_address = Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:solana_custodial_wallet_address]

    eth_custodial_wallet_address = Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:ethereum_custodial_wallet]

    tokens = Tokens.get_pending_tokens()

    Enum.map(tokens, fn x ->
      # TODO Allow token id duplication, owner address validaiton.
      # This version only validates the token id for bootcamp (DO NOT USE IN PRODUCTION)
      # the actual implementation has some flaws
      case token_in_wallet?(client, custodial_wallet_address, x.token_id) do
        {:ok, info} ->
          case Enum.empty?(info) do
            true ->
              Logger.warn("Not found")
            false ->
              Logger.info("Found")
              # TODO split the solana validation and the mint process
              # Tokens.update_status!(x.id, "received")

              token_id = get_token_id_from_mint(x.token_id);
              if minted?(abi, token_id) == false do
                Logger.info("Token not minted in the eth network")

                metadata = get_metadata(client, x.token_id)
                url = metadata.data.uri

                case mint_token(abi, token_id, url, eth_custodial_wallet_address) do
                  {:ok, tx} ->
                    Logger.info("Token minted in tx " <> tx)
                  {:error, err} ->
                    Logger.error(err)
                end
              else
                Logger.info("Token already minted in the eth network")
              end

              # TODO validate the actual owner of the token before the transfer
              case transfer(abi, token_id, eth_custodial_wallet_address, x.receipt_address) do
                {:ok, _} ->
                  Logger.info("Token transferred to " <> x.receipt_address)
                  Tokens.update_status!(x.id, "done")
                {:error, err} ->
                  Logger.error(err)
              end
          end
      end
    end)

    # Reschedule once more
    schedule_work()

    {:noreply, abi}
  end

  defp token_in_wallet?(client, wallet, token_id) do
    req = {"getTokenAccountsByOwner", [wallet, %{"mint" => token_id}, %{"encoding" => "jsonParsed"}]}
    Solana.RPC.send(client, req)
  end

  defp get_token_id_from_mint(mint) do
    temp = B58.decode58!(mint) |> Base.encode16()
    {:ok, token} = ExW3.Utils.hex_to_integer("0x" <> temp)
    token
  end

  defp minted?(abi, id) do
    case eth_call_helper(abi, "ownerOf", [id]) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp mint_token(abi, id, url, to) do
    encoded_data = get_encoded_data(abi, "safeMint", [encode_address(to), id, url])

    ExW3.Rpc.eth_send([
      %{
        to: ExW3.Contract.address(:Nft),
        data: encoded_data,
        gas: "0x30c75",
        from: to
      }
    ])
  end

  defp transfer(abi, id, from, to) do
    #TODO check ABI to avoid force the last param
    encoded_data = get_encoded_data(abi, "safeTransferFrom", [encode_address(from), encode_address(to), id, ""])

    ExW3.Rpc.eth_send([
      %{
        to: ExW3.Contract.address(:Nft),
        data: encoded_data,
        gas: "0x30c75",
        from: from
      }
    ])
  end

  defp eth_call_helper(abi, method_name, args) do
    result =
      ExW3.Rpc.eth_call([
        %{
          to: ExW3.Contract.address(:Nft),
          data: "0x#{ExW3.Abi.encode_method_call(abi, method_name, args)}"
        }
      ])

    case result do
      {:ok, data} ->
        ([:ok] ++ ExW3.Abi.decode_output(abi, method_name, data)) |> List.to_tuple()

      {:error, err} ->
        {:error, err}
    end
  end

  defp get_encoded_data(abi, name, args) do
    data = ABI.encode(get_signature(abi, name), args)
    "0x" <> (data |> Base.encode16(case: :lower))
  end

  defp get_signature(abi, name) do
    "#{name}#{ExW3.Abi.types_signature(abi, name)}"
  end

  defp encode_address(address) do
    address |> String.slice(2..-1) |> Base.decode16!(case: :mixed)
  end

  defp reformat_abi(abi) do
    abi
    |> Enum.map(&map_abi/1)
    |> Map.new()
  end

  defp map_abi(x) do
    case {x["name"], x["type"]} do
      {nil, "constructor"} -> {:constructor, x}
      {nil, "fallback"} -> {:fallback, x}
      {name, _} -> {name, x}
    end
  end

  defp get_json(filename) do
    with {:ok, body} <- File.read(filename),
         {:ok, json} <- Jason.decode(body), do: {:ok, json}
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
