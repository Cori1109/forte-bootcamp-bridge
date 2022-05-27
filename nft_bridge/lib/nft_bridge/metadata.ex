defmodule NftBridge.Metadata do

  defstruct [:update_authority, :mint, :name, :symbol, :uri, :seller_fee_basis_points, :has_creator]

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
      name: parse_string(name),
      symbol: parse_string(symbol),
      uri: parse_string(uri),
      seller_fee_basis_points: fee,
      has_creator: has_creator
    }

    IO.inspect(rest)

    metadata
  end

  defp parse_string(data) do
    [head | _tail] = String.chunk(data, :printable)
    head
  end
end
