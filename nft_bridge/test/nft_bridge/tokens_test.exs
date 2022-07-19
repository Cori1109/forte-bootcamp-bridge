defmodule NftBridge.TokensTest do
  use NftBridge.DataCase

  alias NftBridge.Tokens

  describe "tokens" do
    alias NftBridge.Token

    import NftBridge.TokensFixtures

    @invalid_attrs %{}

    test "list_tokens/0 returns all tokens" do
      token = token_fixture()
      assert Tokens.list_tokens() == [token]
    end

    test "get_token!/1 returns the token with given id" do
      token = token_fixture()
      assert Tokens.get_token!(token.id) == token
    end

    test "create_token/1 with valid data creates a token" do
      valid_attrs = %{
        owner_address: "BrjiWKs4PyViL9o7CSsy8a78ZDKDgSUDQXrJt24eVq9A",
        receipt_address: "0xd136EB70B571cEf8Db36FAd5be07cB4F76905B64",
        status: "pending",
        token_id: "81sr2GMGtRuLsu5deVseZLa9LcGudVKRcwjQCrAMWLt4",
        chain_id: 1
      }

      assert {:ok, _} = Tokens.create_token(valid_attrs)
    end

    test "create_token/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tokens.create_token(@invalid_attrs)
    end

    test "update_status/2 with valid data updates the token" do
      token = token_fixture()
      assert Tokens.update_status!(token.id, "done").status == "done"
    end

    test "get_pending_tokens/0 returns all pending tokens" do
      token = token_fixture()
      token_done = token_done_fixture()
      assert Tokens.get_pending_tokens() == [token]
      assert Tokens.get_pending_tokens() != [token_done]
    end
  end
end
