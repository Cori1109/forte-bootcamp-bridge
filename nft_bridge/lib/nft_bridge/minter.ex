defmodule NftBridge.Minter do
  alias NftBridge.Metaplex
  alias NftBridge.Metadata

  def mint(payer, metadata) do
    mint = Solana.keypair()
    token = Solana.keypair()

    tx_reqs = [
      Solana.RPC.Request.get_minimum_balance_for_rent_exemption(Solana.SPL.Token.Mint.byte_size(),
        commitment: "confirmed"
      ),
      Solana.RPC.Request.get_minimum_balance_for_rent_exemption(Solana.SPL.Token.byte_size(),
        commitment: "confirmed"
      ),
      Solana.RPC.Request.get_recent_blockhash(commitment: "confirmed")
    ]

    solana_network = Application.get_env(:nft_bridge, NftBridgeWeb.Endpoint)[:solana_network]
    client = Solana.RPC.client(network: solana_network)
    {:ok, tracker} = Solana.RPC.Tracker.start_link(network: solana_network, t: 100)

    pda = B58.encode58(Metadata.get_pda_from_public_key(Solana.pubkey!(mint)))

    [{:ok, mint_balance}, {:ok, token_balance}, {:ok, %{"blockhash" => blockhash}}] = Solana.RPC.send(client, tx_reqs)

    {:ok, associated_token} = Solana.SPL.AssociatedToken.find_address(Solana.pubkey!(mint), Solana.pubkey!(payer))

    tx = %Solana.Transaction{
      instructions: [
        Solana.SPL.Token.Mint.init(
          balance: mint_balance,
          payer: Solana.pubkey!(payer),
          authority: Solana.pubkey!(payer),
          new: Solana.pubkey!(mint),
          decimals: 0
        ),
        Solana.SPL.Token.init(
          balance: token_balance,
          payer: Solana.pubkey!(payer),
          mint: Solana.pubkey!(mint),
          owner: Solana.pubkey!(payer),
          new: Solana.pubkey!(token)
        ),
        Solana.SPL.AssociatedToken.create_account(
            payer: Solana.pubkey!(payer),
            owner: Solana.pubkey!(payer),
            new: associated_token,
            mint: Solana.pubkey!(mint)
        ),
        Metaplex.create_metadata(
            payer: Solana.pubkey!(payer),
            metadata: Solana.pubkey!(pda),
            mintAuthority: Solana.pubkey!(payer),
            mint: Solana.pubkey!(mint),
            updateAuthority: Solana.pubkey!(payer),
            data: metadata
        ),
        Solana.SPL.Token.mint_to(
          token: Solana.pubkey!(token),
          mint: Solana.pubkey!(mint),
          authority: Solana.pubkey!(payer),
          amount: 1
        )
      ],
      signers: [payer, mint, token],
      blockhash: blockhash,
      payer: Solana.pubkey!(payer)
    }

    {:ok, signature} =
      Solana.RPC.send_and_confirm(client, tracker, tx,
        commitment: "confirmed",
        timeout: 10_000
      )

    [head | _] = signature
    head
  end
end
