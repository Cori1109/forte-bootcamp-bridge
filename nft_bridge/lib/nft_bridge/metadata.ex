defmodule NftBridge.Metadata do

  defstruct [:update_authority, :mint, :primary_sale_happened, :is_mutable,
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
      primary_sale_happened: 0,
      is_mutable: 0,
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
      _rest :: binary >> , metadata) do
    %{ metadata | primary_sale_happened: primary_sale_happened, is_mutable: is_mutable}
  end

  defp parse_string(data) do
    [head | _tail] = String.chunk(data, :printable)
    head
  end
end
