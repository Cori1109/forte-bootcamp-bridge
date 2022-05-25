defmodule BridgeWeb.SolanaClient do
  use WebSockex
  require Logger

  @url "wss://api.devnet.solana.com"

  def get_connection() do
    WebSockex.Conn.new(@url)
  end

  def start_link(state \\ %{accounts: []}) do
   connection = WebSockex.Conn.new(@url)
   WebSockex.start_link(connection, __MODULE__, state, name: SolanaClient)
  end

  def handle_connect(_conn, state) do
    Logger.info("Connected! State:: #{inspect(state)}")
    Logger.info("Re-subscribing to any pending accounts...")

    Enum.map(state.accounts, fn account -> account_subscribe(account) end)

    {:ok, state}
  end

  def handle_frame({:text, msg}, state) do
    handle_msg(Jason.decode!(msg), state)
  end

  # def handle_cast({:account, {custodial_wallet, token_id} = data}, state) do
  #   Logger.info("****handle_cast()
  #      #### msg:: #{inspect(msg)}
  #      #### state:: #{inspect(state)}")

  #   subscription_msg = Jason.decode!(msg)
  #   account_id = List.first(subscription_msg["params"])
  #   updated_accounts = MapSet.new(state.accounts) |> MapSet.put(account_id)
  #   new_state = Map.put(state, :accounts, updated_accounts)

  #   {:reply, frame, new_state}
  # end

  def handle_cast({:send, {_type, msg} = frame}, state) do
    Logger.info("****handle_cast()
       #### msg:: #{inspect(msg)}
       #### state:: #{inspect(state)}")

    subscription_msg = Jason.decode!(msg)
    account_id = List.first(subscription_msg["params"])
    updated_accounts = MapSet.new(state.accounts) |> MapSet.put(account_id)
    new_state = Map.put(state, :accounts, updated_accounts)

    {:reply, frame, new_state}
  end

  defp handle_disconnect(_conn, state) do
    Logger.info("Disconnected! State:: #{inspect(state)}")
    {:reconnect, state}
  end

  def account_subscribe(account_id) do
    Logger.info("Subscribing to account:: #{account_id}")
    account_subscribe(SolanaClient, account_id)
  end

  def get_custodial_token_account_address(owner_address, mint_address) do
    body = Poison.encode!(%{
      jsonrpc: "2.0",
      id: 1,
      method: "getTokenAccountsByOwner",
      params: [
        owner_address,
        %{
          mint: mint_address
        }
      ]
    })

    headers = [{"Content-type", "application/json"}]

    result = HTTPoison.post!("https://api.devnet.solana.com", body, headers, [])

    req = Poison.decode!(result.body)

    #TODO: Add conditional statement to check if the account exists based on the data returned.

    resp = req["result"]["value"]
    |>Enum.at(0)
    resp["pubkey"]
  end

  #################################################################################
  #
  # Private Helper Functions
  #
  #################################################################################


  defp handle_msg(data, state) do
    #TODO: Inspect returned data and determine if the token has been recieved. If
    #  so, begin the next part of the transfer.

    #TODO: If beginning next part of transfer, need to remove the associated
    #  account_id from the current state too.

    Logger.info("****handle_msg()
       #### data:: #{inspect(data)}
       #### state:: #{inspect(state)}")

    {:ok, state}
  end

  defp account_subscribe(pid, account_id) do
    subscription_msg = %{
      jsonrpc: "2.0",
      id: 1,
      method: "accountSubscribe",
      params:  [
        account_id,
        %{
          encoding: "jsonParsed",
          commitment: "finalized"
        }
      ]
    }|> Jason.encode!()
    WebSockex.cast(pid, {:send, {:text, subscription_msg}})
  end

  defp get_custodial_token_account_address(pid, owner_address, mint_address) do
    body = Poison.encode!(%{
      jsonrpc: "2.0",
      id: 1,
      method: "getTokenAccountsByOwner",
      params: [
        owner_address,
        %{
          mint: mint_address
        }
      ]
    })

    headers = [{"Content-type", "application/json"}]

    result = HTTPoison.post!("https://api.devnet.solana.com", body, headers, [])

    req = Poison.decode!(result.body)

    #TODO: Add conditional statement to check if the account exists based on the data returned.

    resp = req["result"]["value"]
    |>Enum.at(0)
    resp["pubkey"]
  end
end
