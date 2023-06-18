defmodule Firstmail.WebServerTest do
  use Firstmail.DataCase, async: false

  @email "test@firstmail.dev"
  @user1 "ssh-ed25519 PUBKEY nobody@localhost"
  @user2 "ssh-ed25519 UPDATED nobody@localhost"
  @toms 4000

  defp build_headers(opts \\ []) do
    length = Keyword.get(opts, :length, 0)
    token = Keyword.get(opts, :token)

    %{
      "Accept" => "text/plain",
      "Content-Type" => "text/plain",
      "Content-Length" => "#{length}"
    }
    |> Map.merge(if token != nil, do: %{"Gak-Token" => "#{token}"}, else: %{})
  end

  test "web server ping test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    stream_ref = :gun.get(conn_pid, '/api/ping')
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    {:ok, body} = :gun.await_body(conn_pid, stream_ref)
    assert body == "pong"
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "create user api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    headers = build_headers(length: String.length(@email))
    stream_ref = :gun.post(conn_pid, '/api/user', headers, @email)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    user = UserDb.find_by_email(@email)
    assert nil != user || user.id
    user = UserDb.find_by_id(user.id)
    assert @email == user.email
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "recreate user api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user0} = UserDb.create_from_email(@email)
    headers = build_headers(length: String.length(@email))
    stream_ref = :gun.post(conn_pid, '/api/user', headers, @email)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    user = UserDb.find_by_email(@email)
    assert nil != user || user.id
    user = UserDb.find_by_id(user.id)
    assert @email == user.email
    assert user0.id == user.id
    assert user0.token != user.token
    assert user0.updated_at != user.updated_at
    assert user0.inserted_at == user.inserted_at
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "delete user api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user} = UserDb.create_from_email(@email)
    headers = build_headers(token: user.token)
    stream_ref = :gun.delete(conn_pid, '/api/user/#{user.id}', headers)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    assert nil == UserDb.find_by_email(@email)
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "update user user api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user} = UserDb.create_from_email(@email)
    headers = build_headers(token: user.token)
    stream_ref = :gun.put(conn_pid, '/api/user/#{user.id}', headers, @user2)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    user2 = UserDb.find_by_email(@email)
    assert @user2 == user2.data
    assert user.token != user2.token
    assert :ok == :gun.shutdown(conn_pid)
  end

  test "get user user api test" do
    port = WebServer.get_port()
    {:ok, conn_pid} = :gun.open('127.0.0.1', port)
    assert_receive {:gun_up, ^conn_pid, :http}
    {:ok, user} = UserDb.create_from_email(@email)
    headers = build_headers()
    stream_ref = :gun.get(conn_pid, '/api/user/#{user.id}', headers)
    assert_receive {:gun_response, ^conn_pid, ^stream_ref, _, 200, _}, @toms
    {:ok, body} = :gun.await_body(conn_pid, stream_ref)
    assert @user1 == body
    assert :ok == :gun.shutdown(conn_pid)
  end
end
