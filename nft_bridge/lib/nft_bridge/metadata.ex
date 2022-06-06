defmodule NftBridge.Metadata do

  defstruct [:update_authority, :mint, :primary_sale_happened, :is_mutable, :editionNonce, :tokenStandard,
   data: { :name, :symbol, :uri, :seller_fee_basis_points, :creators }]

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
      %{ metadata | primary_sale_happened: primary_sale_happened,
          is_mutable: is_mutable,
       }
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
        %{ metadata | editionNonce: edition_nonce}
      end
  end

  defp parse_token_standard(<<
      tokenStandard :: little-integer-size(8),has_edition_nonce :: little-integer-size(8),
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
      %{ metadata | primary_sale_happened: primary_sale_happened,
          is_mutable: is_mutable,
       }
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
        %{ metadata | editionNonce: edition_nonce}
      end
  end

  defp parse_token_standard(<<
      tokenStandard :: little-integer-size(8),
      _rest :: binary >> , metadata) do
    %{ metadata | tokenStandard: tokenStandard}
  end

  defp parse_string(data) do
    [head | _tail] = String.chunk(data, :printable)
    head
  end
end
