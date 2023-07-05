defmodule Firstmail.UserDb do
  alias Firstmail.Repo
  alias Firstmail.User

  def create_from_email(email) do
    token = Ecto.ULID.generate()

    %User{}
    |> User.changeset(%{email: email, token: token})
    |> Repo.insert(conflict_target: :email, on_conflict: {:replace, [:token, :updated_at]})
  end

  def find_by_id(id) do
    Repo.get_by(User, id: id)
  end

  def find_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def find_by_id_and_token(id, token) do
    Repo.get_by(User, id: id, token: token)
  end

  def delete(user) do
    Repo.delete(user)
  end
end
