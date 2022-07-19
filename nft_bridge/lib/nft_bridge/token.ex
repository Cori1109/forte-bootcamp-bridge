defmodule NftBridge.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field :owner_address, :string
    field :receipt_address, :string
    field :status, :string
    field :token_id, :string
    field :chain_id, :integer

    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:owner_address, :receipt_address, :token_id, :status, :chain_id])
    |> validate_required([:owner_address, :receipt_address, :token_id, :status, :chain_id])
  end
end
