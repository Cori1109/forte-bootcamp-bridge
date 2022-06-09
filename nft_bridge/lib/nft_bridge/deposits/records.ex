defmodule NftBridge.Deposits.Records do
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    field :owner_address, :string
    field :recipient_address, :string
    field :status, Ecto.Enum, values: [:in_progress, :complete, :error]
    field :token_id, :string

    timestamps([type: :utc_datetime])
  end

  @doc false
  def changeset(records, attrs) do
    records
    |> cast(attrs, [:id, :owner_address, :recipient_address, :token_id, :status])
    |> validate_required([:id, :owner_address, :recipient_address, :token_id, :status])
    |> unique_constraint(:id)
  end
end
