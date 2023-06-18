defmodule Firstmail.UserDbTest do
  use Firstmail.DataCase, async: false

  @email "test@firstmail.dev"

  test "create and recreate user test" do
    {:ok, user1} = UserDb.create_from_email(@email)
    {:ok, user2} = UserDb.create_from_email(@email)
    [user] = Repo.all(User)
    IO.inspect({user, user1, user2})
    assert user.data == user1.data
    assert user.email == user1.email
    assert user.id == user1.id
    assert user.token == user2.token
    # user2.inserted_at never reaches the db
    # assert user.inserted_at == user2.inserted_at
    assert user.updated_at == user2.updated_at
    assert user.token != user1.token
    assert user.token == user2.token
    # user2.inserted_at never reaches the db
    # assert user1.inserted_at == user2.inserted_at
    assert user.updated_at > user1.updated_at
    assert user.updated_at == user2.updated_at
  end

  test "update user test" do
    {:ok, user1} = UserDb.create_from_email(@email)
    {:ok, user2} = UserDb.update_user(user1, "UPDATED")
    user = UserDb.find_by_email(@email)
    assert user.data == "UPDATED"
    assert user.token == user2.token
    assert user.token != user1.token
    assert user.updated_at > user1.updated_at
    assert user.updated_at == user2.updated_at
  end

  test "find user from email test" do
    {:ok, user} = UserDb.create_from_email(@email)
    assert user == UserDb.find_by_email(@email)
  end

  test "find user from id and token 5m test" do
    {:ok, user} = UserDb.create_from_email(@email)
    assert [user] == Repo.all(User)
    assert user == UserDb.find_by_id_and_token_5m(user.id, user.token)
    assert nil == UserDb.find_by_id_and_token_5m(user.id, "TOKEN")

    updated_at =
      DateTime.utc_now()
      |> DateTime.add(-4, :minute)
      |> DateTime.to_naive()

    User.changeset(user, %{})
    |> Ecto.Changeset.force_change(:updated_at, updated_at)
    |> Repo.update()

    assert %{user | updated_at: updated_at} ==
             UserDb.find_by_id_and_token_5m(user.id, user.token)

    updated_at =
      DateTime.utc_now()
      |> DateTime.add(-6, :minute)
      |> DateTime.to_naive()

    User.changeset(user, %{})
    |> Ecto.Changeset.force_change(:updated_at, updated_at)
    |> Repo.update()

    assert nil == UserDb.find_by_id_and_token_5m(user.id, user.token)
  end
end
