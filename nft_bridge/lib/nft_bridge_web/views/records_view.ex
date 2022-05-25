defmodule NftBridgeWeb.RecordsView do
  use NftBridgeWeb, :view
  alias NftBridgeWeb.RecordsView

  def render("index.json", %{records: records}) do
    %{data: render_many(records, RecordsView, "records.json")}
  end

  def render("show.json", %{records: records}) do
    %{data: render_one(records, RecordsView, "records.json")}
  end

  def render("records.json", %{records: records}) do
    %{
      id: records.id,
      id: records.id,
      created_at: records.created_at,
      updated_at: records.updated_at,
      owner_address: records.owner_address,
      recipient_address: records.recipient_address,
      token_id: records.token_id,
      status: records.status
    }
  end
end
