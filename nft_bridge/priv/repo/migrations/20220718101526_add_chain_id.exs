defmodule NftBridge.Repo.Migrations.AddChainId do
  use Ecto.Migration

  def change do
    alter table(:tokens) do
      add :chain_id, :integer
    end
  end
end
