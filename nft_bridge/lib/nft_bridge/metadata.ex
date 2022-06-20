defmodule NftBridge.Metadata do

  # Metaplex metadata parser and encoder
  # based on
  # https://github.com/michaelhly/solana-py/issues/48#issuecomment-1073077165
  # and
  # https://github.com/metaplex-foundation/metaplex-program-library/blob/master/token-metadata/program/src/state.rs


  defstruct [:key, :update_authority, :mint, :primary_sale_happened, :is_mutable, :editionNonce, :tokenStandard, :collection, :uses,
   data: { :name, :symbol, :uri, :seller_fee_basis_points, :creators }]

  @metadata_program_id "metaqbxxUerdq28cj1RbAWkYQm3ybzjb6a8bt518x1s"


  def encode(metadata) do
    {:ok, update_authority_enc} = B58.decode58(metadata.update_authority)
    {:ok, mint_enc} = B58.decode58(metadata.mint)

    encode_value({metadata.key, 8})
    <> update_authority_enc
    <> mint_enc
    <> encode_value({metadata.data.name, "borsh"})
    <> encode_value({metadata.data.symbol, "borsh"})
    <> encode_value({metadata.data.uri, "borsh"})
    <> encode_value({metadata.data.seller_fee_basis_points, 16})
    <> encode_value(false) #has_creators
    <> encode_value({metadata.primary_sale_happened, 8})
    <> encode_value({metadata.is_mutable, 8})
    <> encode_value(true)
    <> encode_value({metadata.editionNonce, 8})
    <> encode_value(true)
    <> encode_value({metadata.tokenStandard, 8})
    <> encode_value(false) #has_collections
    <> encode_value(false) #has_uses
  end

  defp encode_value({value, "borsh"}) when is_binary(value) do
    <<byte_size(value)::little-size(32), value::binary>>
  end

  defp encode_value({value, size}), do: encode_value({value, size, :little})
  defp encode_value({value, size, :big}), do: <<value::size(size)-big>>
  defp encode_value({value, size, :little}), do: <<value::size(size)-little>>
  defp encode_value(value) when is_binary(value), do: value
  defp encode_value(value) when is_integer(value), do: <<value>>
  defp encode_value(value) when is_boolean(value), do: <<unary(value)>>

  defp unary(val), do: if(val, do: 1, else: 0)

  def get_pda(id) do
    program_id = Solana.Key.decode!(@metadata_program_id)
    token_id = Solana.Key.decode!(id)
    {:ok, address, _nonce} = Solana.Key.find_address(["metadata", program_id, token_id], program_id)
    B58.encode58(address)
  end

  def parse(<<0x04,
              source :: binary - size(32),
              mint :: binary - size(32),
              name_length :: little-integer-size(32),
              name :: binary - size(name_length),
              symbol_length :: little-integer-size(32),
              symbol :: binary - size(symbol_length),
              uri_length :: little-integer-size(32),
              uri :: binary - size(uri_length),
              fee :: little-integer-size(16),
              has_creator :: little-integer-size(8),
              rest :: binary >>
              ) do

    metadata = %NftBridge.Metadata{
      key: 4,
      update_authority: B58.encode58(source),
      mint: B58.encode58(mint),
      primary_sale_happened: -1,
      is_mutable: -1,
      editionNonce: -1,
      tokenStandard: -1,
      data: %{
        name: parse_string(name),
        symbol: parse_string(symbol),
        uri: parse_string(uri),
        seller_fee_basis_points: fee,
        creators: []
      },
      collection: %{
        verified: -1,
        key: ""
      },
      uses: %{
        useMethod: -1,
        remaining: -1,
        total: -1
      }
    }

    if has_creator == 1 do
      << creator_length :: little-integer-size(32),
         temp :: binary >> = rest
      parse_creator(temp, 0, creator_length, [], metadata)
    else
      parse_last_fields(rest, metadata)
    end
  end

  defp parse_creator(<< creators_data :: binary>>, pos, count, creators, metadata) do
    if pos < count do
      << creator_account :: binary - size(32),
      verified :: little-integer-size(8),
      share :: little-integer-size(8),
      rest :: binary >> = creators_data

      creator = %{
        address: B58.encode58(creator_account),
        verified: verified,
        share: share
      }

      creators = [creator | creators]
      data = %{ metadata.data | creators: creators}
      metadata = %{ metadata | data: data}
      parse_creator(rest, pos + 1, count, creators, metadata)
    else
      creators = Enum.reverse(creators)
      data = %{ metadata.data | creators: creators}
      parse_last_fields(creators_data, %{ metadata | data: data})
    end
  end

  defp parse_last_fields(<<
      primary_sale_happened :: little-integer-size(8),
      is_mutable :: little-integer-size(8),
      has_edition_nonce :: little-integer-size(8),
      rest :: binary >> , metadata) do

    if has_edition_nonce  == 1 do
      metadata = parse_edition_nonce(rest , metadata)
      %{ metadata | primary_sale_happened: primary_sale_happened,
      is_mutable: is_mutable,
     }
    else
     << has_token_standard :: little-integer-size(8),
      temp :: binary >> = rest

     if has_token_standard == 1 do
        parse_token_standard(temp, %{ metadata | primary_sale_happened: primary_sale_happened,
        is_mutable: is_mutable,
     })
     else
      << has_collection :: little-integer-size(8),
        temp2 :: binary >> = temp

      if has_collection == 1 do
        parse_collection(temp2, %{ metadata | primary_sale_happened: primary_sale_happened,
        is_mutable: is_mutable})
      else
        << has_uses :: little-integer-size(8),
          temp3 :: binary >> = temp2

        if has_uses == 1 do
          parse_uses(temp3, %{ metadata | primary_sale_happened: primary_sale_happened,
          is_mutable: is_mutable})
        else
          %{ metadata | primary_sale_happened: primary_sale_happened,
          is_mutable: is_mutable}
        end
      end
     end
    end
  end

  defp parse_edition_nonce(<<
    edition_nonce :: little-integer-size(8),
    has_token_standard :: little-integer-size(8),
    rest :: binary >>,  metadata) do

    if has_token_standard == 1 do
      parse_token_standard(rest, %{ metadata | editionNonce: edition_nonce})
    else
      << has_collection :: little-integer-size(8),
      temp :: binary >> = rest

      if has_collection == 1 do
        parse_collection(temp, %{ metadata | editionNonce: edition_nonce})
      else
        << has_uses :: little-integer-size(8),
        temp2 :: binary >> = temp

        if has_uses == 1 do
          parse_uses(temp2, %{ metadata | editionNonce: edition_nonce})
        else
          %{ metadata | editionNonce: edition_nonce}
        end
      end
    end
  end

  defp parse_token_standard(<<
      tokenStandard :: little-integer-size(8),
      has_collection :: little-integer-size(8),
      rest :: binary >>,  metadata) do

    if has_collection == 1 do
      parse_collection(rest, %{ metadata | tokenStandard: tokenStandard})
    else
      << has_uses :: little-integer-size(8),
        temp :: binary >> = rest

      if has_uses == 1 do
        parse_uses(temp, %{ metadata | tokenStandard: tokenStandard})
      else
        %{ metadata | tokenStandard: tokenStandard}
      end
    end
  end

  defp parse_collection(<<
        verified :: little-integer-size(8),
        key :: binary - size(32),
        has_uses :: little-integer-size(8),
        rest :: binary >>, metadata) do

    if has_uses == 1 do
      parse_uses(rest, %{ metadata | collection: %{ verified: verified, key: B58.encode58(key)}})
    else
      %{ metadata | collection: %{ verified: verified, key: B58.encode58(key)}}
    end
  end

  defp parse_uses(<<
        use_method :: little-integer-size(8),
        remaining :: little-integer-size(64),
        total :: little-integer-size(64),
        _rest :: binary  >>, metadata) do
    %{ metadata | uses: %{ useMethod: use_method, total: total, remaining: remaining}}
  end

  defp parse_string(data) do
    [head | _tail] = String.chunk(data, :printable)
    head
  end
end
