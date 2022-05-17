defmodule NftBridge.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :owner_address, :string
    field :receipt_address, :string
    field :status, :string
    field :token_id, :string

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:owner_address, :receipt_address, :status, :token_id])
    |> validate_required([:owner_address, :receipt_address, :status, :token_id])
  end
end
