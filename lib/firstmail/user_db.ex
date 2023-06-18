defmodule Firstmail.UserDb do
  alias Firstmail.Repo
  alias Firstmail.User
  import Ecto.Query

  @data "ssh-ed25519 PUBKEY nobody@localhost"

  def create_from_email(email) do
    token = Ecto.ULID.generate()

    %User{}
    |> User.changeset(%{email: email, token: token, data: @data})
    |> Repo.insert(conflict_target: :email, on_conflict: {:replace, [:token, :updated_at]})
  end

  def update_user(user, data) do
    token = Ecto.ULID.generate()

    user
    |> User.changeset(%{token: token, data: data})
    |> Repo.update()
  end

  def find_by_id(id) do
    Repo.get_by(User, id: id)
  end

  def find_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def find_by_id_and_token_5m(id, token) do
    updated =
      DateTime.utc_now()
      |> DateTime.add(-5, :minute)
      |> DateTime.to_naive()

    from(pk in User,
      where: pk.id == ^id and pk.token == ^token and pk.updated_at > ^updated
    )
    |> Repo.one()
  end

  def delete_unused_24h() do
    inserted =
      DateTime.utc_now()
      |> DateTime.add(-24, :hour)
      |> DateTime.to_naive()

    from(pk in User,
      where: pk.data == @data and pk.inserted_at < ^inserted
    )
    |> Repo.delete_all()
  end

  def delete(user) do
    Repo.delete(user)
  end
end
