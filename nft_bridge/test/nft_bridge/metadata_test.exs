defmodule NftBridge.MetadataTest do
  use NftBridge.DataCase

  alias NftBridge.Metadata

  describe "metadata" do
    import NftBridge.MetadataFixtures

    test "parse" do
      metadata = token_metadata()
      parsed = Metadata.parse(metadata)
      IO.inspect(parsed)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.name == "Game - DevNet"
      assert parsed.symbol == "GME"
      assert parsed.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.seller_fee_basis_points == 0
      assert parsed.has_creator == 1
    end
  end
end
