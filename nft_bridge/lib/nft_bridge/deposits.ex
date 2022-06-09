defmodule NftBridge.Deposits do
  @moduledoc """
  The Deposits context.
  """

  import Ecto.Query, warn: false
  alias NftBridge.Repo

  alias NftBridge.Deposits.Records

  @doc """
  Returns the list of records.

  ## Examples

    iex> list_records()
    [%Records{}, ...]

  """

  def list_records do
    Repo.all(Records)
  end

  @doc """
  Gets a single records.

  Raises `Ecto.NoResultsError` if the Records does not exist.
  ## Examples
      iex> get_records!(123)
      %Records{}
      iex> get_records!(456)
      ** (Ecto.NoResultsError)

  """

  def get_records!(id), do: Repo.get!(Records, id)

  @doc """
  Creates a records.

  ## Examples

      iex> create_records(%{field: value})
      {:ok, %Records{}}

      iex> create_records(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_records(attrs \\ %{}) do
    %Records{}
    |> Records.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a records.

  ## Examples

      iex> update_records(records, %{field: new_value})
      {:ok, %Records{}}

      iex> update_records(records, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_records(%Records{} = records, attrs) do
    records
    |> Records.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a records.

  ## Examples

      iex> delete_records(records)
      {:ok, %Records{}}

      iex> delete_records(records)
      {:error, %Ecto.Changeset{}}
  """
  def delete_records(%Records{} = records) do
    Repo.delete(records)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking records changes.

  ## Examples

      iex> change_records(records)
      %Ecto.Changeset{data: %Records{}}
  """
  def change_records(%Records{} = records, attrs \\ %{}) do
    Records.changeset(records, attrs)
  end
end
