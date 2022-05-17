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
        owner_address: "6yabVNKW1zATEhw2bZJpQKAp7YHPVBKBFhNpRERX5jta",
        receipt_address: "0xecf482f4A1c156936582F9073b97187F8463a173",
        status: "pending",
        token_id: "EeYQPBEuiFKgMdjDUFqt6PcXXa19V2Eor8XL7YCoxfSd"
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
  end
end
