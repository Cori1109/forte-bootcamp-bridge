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
        receipt_address: "0xd136EB70B571cEf8Db36FAd5be07cB4F76905B64",
        status: "pending",
        token_id: "81sr2GMGtRuLsu5deVseZLa9LcGudVKRcwjQCrAMWLt4"
      })
      |> NftBridge.Tokens.create_token()

    token
  end

  def token_done_fixture(attrs \\ %{}) do
    {:ok, token} =
      attrs
      |> Enum.into(%{
        owner_address: "BrjiWKs4PyViL9o7CSsy8a78ZDKDgSUDQXrJt24eVq9A",
        receipt_address: "0xd136EB70B571cEf8Db36FAd5be07cB4F76905B64",
        status: "done",
        token_id: "81sr2GMGtRuLsu5deVseZLa9LcGudVKRcwjQCrAMWLt4"
      })
      |> NftBridge.Tokens.create_token()

    token
  end
end
