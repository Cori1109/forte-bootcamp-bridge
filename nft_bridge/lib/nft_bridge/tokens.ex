defmodule NftBridge.Tokens do
  @moduledoc """
  The Tokens context.
  """

  import Ecto.Query, warn: false
  alias NftBridge.Repo

  alias NftBridge.Token

  @doc """
  Returns the list of tokens.
  ## Examples
      iex> list_tokens()
      [%Token{}, ...]
  """
  def list_tokens do
    Repo.all(Token)
  end

  @doc """
  Gets a single token.
  Raises if the Token does not exist.
  ## Examples
      iex> get_token!(123)
      %Token{}
  """
  def get_token!(id) do
    Repo.get!(Token, id)
  end
  @doc """
  Creates a token.
  ## Examples
      iex> create_token(%{field: value})
      {:ok, %Token{}}
      iex> create_token(%{field: bad_value})
      {:error, ...}
  """
  def create_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a token.
  ## Examples
      iex> update_token(token, %{field: new_value})
      {:ok, %Token{}}
      iex> update_token(token, %{field: bad_value})
      {:error, ...}
  """
  def update_status!(id, status) do
    token = Repo.get!(Token, id)
    token = Ecto.Changeset.change token, status: status
    Repo.update!(token)
  end
end
