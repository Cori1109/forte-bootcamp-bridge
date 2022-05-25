defmodule NftBridge.Deposits.Records do
  use Ecto.Schema
  import Ecto.Changeset

  schema "records" do
    field :created_at, :utc_datetime
    # field :id, Ecto.UUID
    field :owner_address, :string
    field :recipient_address, :string
    field :status, Ecto.Enum, values: [:in_progress, :complete, :error]
    field :token_id, :string
    # field :updated_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(records, attrs) do
    records
    |> cast(attrs, [:id, :created_at, :updated_at, :owner_address, :recipient_address, :token_id, :status])
    |> validate_required([:id, :created_at, :updated_at, :owner_address, :recipient_address, :token_id, :status])
    |> unique_constraint(:id)
  end
end
