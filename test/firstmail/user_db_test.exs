defmodule Firstmail.UserDbTest do
  use Firstmail.DataCase, async: false

  @email "test@firstmail.dev"

  test "create and recreate user test" do
    {:ok, user1} = UserDb.create_from_email(@email)
    {:ok, user2} = UserDb.create_from_email(@email)
    [user] = Repo.all(User)
    IO.inspect({user, user1, user2})
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

  test "find user from email test" do
    {:ok, user} = UserDb.create_from_email(@email)
    assert user == UserDb.find_by_email(@email)
  end

  test "find user from id and token" do
    {:ok, user} = UserDb.create_from_email(@email)
    assert [user] == Repo.all(User)
    assert user == UserDb.find_by_id_and_token(user.id, user.token)
    assert nil == UserDb.find_by_id_and_token(user.id, "TOKEN")
  end
end
