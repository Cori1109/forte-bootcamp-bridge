defmodule NftBridge.Metaplex do
  alias Solana.{Instruction, Account, SystemProgram}
  alias NftBridge.Metadata
  import Solana.Helpers

  def id(), do: Solana.pubkey!("metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s")

  @create_metadata_schema [
    payer: [
      type: {:custom, Solana.Key, :check, []},
      required: true,
      doc: ""
    ],
    metadata: [
      type: {:custom, Solana.Key, :check, []},
      required: true,
      doc: ""
    ],
    mintAuthority: [
      type: {:custom, Solana.Key, :check, []},
      required: true,
      doc: ""
    ],
    mint: [
      type: {:custom, Solana.Key, :check, []},
      required: true,
      doc: ""
    ],
    updateAuthority: [
      type: {:custom, Solana.Key, :check, []},
      required: true,
      doc: ""
    ],
    data: [
      required: true,
      doc: ""
    ]
  ]


  @doc """
  ## Options
  #{NimbleOptions.docs(@create_metadata_schema)}
  """
  def create_metadata(opts) do
    case validate(opts, @create_metadata_schema) do
      {:ok, params} ->
        %Instruction{
          program: id(),
          accounts: [
            %Account{key: params.metadata, writable?: true, signer?: false},
            %Account{key: params.mint, writable?: false, signer?: false},
            %Account{key: params.mintAuthority, writable?: false, signer?: true},
            %Account{key: params.payer, writable?: false, signer?: true},
            %Account{key: params.updateAuthority, writable?: false, signer?: false},
            %Account{key: SystemProgram.id(), writable?: false, signer?: false},
            %Account{key: Solana.rent(), writable?: false, signer?: false}
          ],
          data: Metadata.encode_data([{0, 8}, Metadata.encode(params.data), true])
        }
      error ->
        error
    end
  end
end
