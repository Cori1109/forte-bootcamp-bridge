defmodule NftBridge.MetadataTest do
  use NftBridge.DataCase

  alias NftBridge.Metadata

  describe "metadata" do
    import NftBridge.MetadataFixtures

    test "parse with one creator" do
      metadata = token_metadata_with_one_creators()
      parsed = Metadata.parse(metadata)
      IO.inspect(parsed)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.data.name == "Game - DevNet"
      assert parsed.data.symbol == "GME"
      assert parsed.data.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.data.seller_fee_basis_points == 0
      assert parsed.data.creators == [%{
        address: "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH",
        verified: 1,
        share: 100
      }]
      assert parsed.primary_sale_happened == 0
      assert parsed.is_mutable === 1
    end

    test "parse with two creators" do
      metadata = token_metadata_with_two_creators()
      parsed = Metadata.parse(metadata)
      IO.inspect(parsed)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.data.name == "Game - DevNet"
      assert parsed.data.symbol == "GME"
      assert parsed.data.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.data.seller_fee_basis_points == 0
      assert parsed.data.creators == [%{
        address: "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH",
        verified: 1,
        share: 100
      },
      %{
        address: "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH",
        verified: 0,
        share: 99
      }]
      assert parsed.primary_sale_happened == 0
      assert parsed.is_mutable == 1
    end

    test "parse without creators" do
      metadata = token_metadata_without_creators()
      parsed = Metadata.parse(metadata)
      IO.inspect(parsed)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.data.name == "Game - DevNet"
      assert parsed.data.symbol == "GME"
      assert parsed.data.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.data.seller_fee_basis_points == 0
      assert parsed.data.creators == []
      assert parsed.primary_sale_happened == 0
      assert parsed.is_mutable == 1
    end
  end
end
