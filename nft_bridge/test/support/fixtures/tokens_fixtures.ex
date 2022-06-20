defmodule NftBridge.TokensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `NftBridge.Tokens` context.
  """

  @doc """
  Generate a token.
  """
  def token_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        owner_address: "BrjiWKs4PyViL9o7CSsy8a78ZDKDgSUDQXrJt24eVq9A",
        receipt_address: "0xc354a878bcD24eBd597732CBEf7a4fc925653c9B",
        status: "pending",
        token_id: "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      })
      |> NftBridge.Tokens.create_token()

    token
  end

  def token_done_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        owner_address: "BrjiWKs4PyViL9o7CSsy8a78ZDKDgSUDQXrJt24eVq9A",
        receipt_address: "0xc354a878bcD24eBd597732CBEf7a4fc925653c9B",
        status: "done",
        token_id: "9bnSBxC8PQrzWCQ7nH3nrv96YaH34o39iaxN74q1reVG"
      })
      |> NftBridge.Tokens.create_token()

    token
  end
end
