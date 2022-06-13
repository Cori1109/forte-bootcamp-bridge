defmodule NftBridge.MetadataTest do
  use NftBridge.DataCase

  alias NftBridge.Metadata

  describe "metadata parser" do
    import NftBridge.MetadataFixtures

    test "parse with one creator" do
      metadata = token_metadata_with_one_creators()
      parsed = Metadata.parse(metadata)
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
      assert parsed.editionNonce == 253
      assert parsed.tokenStandard == 0
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse with two creators" do
      metadata = token_metadata_with_two_creators()
      parsed = Metadata.parse(metadata)
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
      assert parsed.editionNonce == 253
      assert parsed.tokenStandard  == 1
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse without creators" do
      metadata = token_metadata_without_creators()
      parsed = Metadata.parse(metadata)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.data.name == "Game - DevNet"
      assert parsed.data.symbol == "GME"
      assert parsed.data.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.data.seller_fee_basis_points == 0
      assert parsed.data.creators == []
      assert parsed.primary_sale_happened == 0
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == 253
      assert parsed.tokenStandard == 2
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse without edition and token standard" do
      metadata = token_metadata_without_edition_and_token_standard()
      parsed = Metadata.parse(metadata)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.data.name == "Game - DevNet"
      assert parsed.data.symbol == "GME"
      assert parsed.data.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.data.seller_fee_basis_points == 0
      assert parsed.data.creators == []
      assert parsed.primary_sale_happened == 0
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == -1
      assert parsed.tokenStandard == -1
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse with edition without token  standard" do
      metadata = token_metadata_with_edition_without_token_standard()
      parsed = Metadata.parse(metadata)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.data.name == "Game - DevNet"
      assert parsed.data.symbol == "GME"
      assert parsed.data.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.data.seller_fee_basis_points == 0
      assert parsed.data.creators == []
      assert parsed.primary_sale_happened == 0
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == 253
      assert parsed.tokenStandard == -1
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse without edition with token standard" do
      metadata = token_metadata_without_edition_with_token_standard()
      parsed = Metadata.parse(metadata)
      assert parsed.update_authority == "FzVaYRJbM65LVVLxrxv5L8pjKm6o1qAzU1L2XLxKkeqH"
      assert parsed.mint == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.data.name == "Game - DevNet"
      assert parsed.data.symbol == "GME"
      assert parsed.data.uri == "https://arweave.net/B4T7noSr8mhPCekdMKWQI2haqnHrjsdJOwWG8I7fVbw"
      assert parsed.data.seller_fee_basis_points == 0
      assert parsed.data.creators == []
      assert parsed.primary_sale_happened == 0
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == -1
      assert parsed.tokenStandard == 2
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse with collection" do
      metadata = token_metadata_with_collection()
      parsed = Metadata.parse(metadata)
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
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == 253
      assert parsed.tokenStandard == 0
      assert parsed.collection.key == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.collection.verified == 1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse without optionals with collection" do
      metadata = token_metadata_without_optionals_with_collection()
      parsed = Metadata.parse(metadata)
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
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == -1
      assert parsed.tokenStandard == -1
      assert parsed.collection.key == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.collection.verified == 1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse without optionals with collection and uses" do
      metadata = token_metadata_without_optionals_with_collection_and_uses()
      parsed = Metadata.parse(metadata)
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
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == -1
      assert parsed.tokenStandard == -1
      assert parsed.collection.key == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.collection.verified == 1
      assert parsed.uses.useMethod == 2
      assert parsed.uses.remaining  == 32
      assert parsed.uses.total  == 48
    end

    test "parse without optionals with uses" do
      metadata = token_metadata_without_optionals_with_uses()
      parsed = Metadata.parse(metadata)
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
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == -1
      assert parsed.tokenStandard == -1
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == 2
      assert parsed.uses.remaining  == 32
      assert parsed.uses.total  == 48
    end

    test "parse without optionals" do
      metadata = token_metadata_without_optionals()
      parsed = Metadata.parse(metadata)
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
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == -1
      assert parsed.tokenStandard == -1
      assert parsed.collection.key == ""
      assert parsed.collection.verified == -1
      assert parsed.uses.useMethod == -1
      assert parsed.uses.remaining  == -1
      assert parsed.uses.total  == -1
    end

    test "parse full" do
      metadata = token_metadata_full()
      parsed = Metadata.parse(metadata)
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
      assert parsed.is_mutable == 1
      assert parsed.editionNonce == 253
      assert parsed.tokenStandard == 0
      assert parsed.collection.key == "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      assert parsed.collection.verified == 1
      assert parsed.uses.useMethod == 2
      assert parsed.uses.remaining  == 32
      assert parsed.uses.total  == 48
    end
  end

  describe "pda" do
    test "get pda" do
      pda = Metadata.get_pda("9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG")
      assert pda == "4t9YYr6Z3hi9jZkLu6QvXxSUzHhdJ4jmmm9hoU5QhnqY"
    end
  end
end
