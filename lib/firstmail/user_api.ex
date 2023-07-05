defmodule Firstmail.UserApi do
  alias Firstmail.UserDb
  alias Firstmail.Mailer
  alias Firstmail.Sender

  @max_body_len 256
  @token_header "fmd-token"
  @to_header "fmd-to"
  @mime_header "fmd-mime"
  @reply_header "fmd-reply"
  @subject_header "fmd-subject"
  @mimes ["text/plain", "text/html"]
  @headers %{"content-type" => "text/plain"}
  @fail_delay 1000

  def init(req, {:new, _} = state) do
    method = :cowboy_req.method(req)
    dos_delay(method, state)

    case method do
      "POST" ->
        create_user(req, state)

      _ ->
        fail_delay()
        req = :cowboy_req.reply(404, req)
        {:ok, req, state}
    end
  end

  def init(req, {:id, _} = state) do
    method = :cowboy_req.method(req)
    dos_delay(method, state)

    case method do
      "POST" ->
        send_email(req, state)

      "DELETE" ->
        delete_user(req, state)

      _ ->
        fail_delay()
        req = :cowboy_req.reply(404, req)
        {:ok, req, state}
    end
  end

  # how to avoid creation if emailing fails? transactions?
  def create_user(req, {_, %{mailer: mailer}} = state) do
    len = :cowboy_req.body_length(req)

    # find_by_email required to fetch the real id on conflict update
    # user.token to get the real updated token even if race condition
    with true <- is_integer(len),
         true <- len > 3 and len <= @max_body_len,
         {:ok, email, req} <- :cowboy_req.read_body(req),
         {:ok, _} <- UserDb.create_from_email(email),
         user <- UserDb.find_by_email(email),
         true <- user != nil,
         {:ok, _res} <- Mailer.send_create(mailer, user) do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res ->
        fail_delay()
        req = :cowboy_req.reply(400, req)
        {:ok, req, state}
    end
  end

  def delete_user(req, {_, %{mailer: mailer}} = state) do
    id = :cowboy_req.binding(:id, req)
    token = :cowboy_req.header(@token_header, req)

    with true <- is_binary(token),
         {:ok, _} <- Ecto.ULID.cast(id),
         {:ok, _} <- Ecto.ULID.cast(token),
         user <- UserDb.find_by_id_and_token(id, token),
         true <- user != nil,
         {:ok, _res} <- UserDb.delete(user),
         {:ok, _res} <- Mailer.send_delete(mailer, user) do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res ->
        fail_delay()
        req = :cowboy_req.reply(400, req)
        {:ok, req, state}
    end
  end

  def send_email(req, {_, %{mailer: mailer}} = state) do
    len = :cowboy_req.body_length(req)
    id = :cowboy_req.binding(:id, req)
    token = :cowboy_req.header(@token_header, req)
    subject = :cowboy_req.header(@subject_header, req)
    reply = :cowboy_req.header(@reply_header, req)
    mime = :cowboy_req.header(@mime_header, req, "text/plain")
    to = :cowboy_req.header(@to_header, req)
    # "user1@firstmail.one, user2@firstmail.one"

    email = %{
      subject: subject,
      reply: reply,
      mime: mime,
      to: to
    }

    with true <- is_binary(token),
         true <- is_binary(subject),
         true <- is_binary(mime),
         true <- Enum.member?(@mimes, mime),
         true <- is_binary(to),
         {:ok, _} <- Ecto.ULID.cast(id),
         {:ok, _} <- Ecto.ULID.cast(token),
         true <- is_integer(len),
         true <- len > 0 and len <= @max_body_len,
         {:ok, body, req} <- :cowboy_req.read_body(req),
         user <- UserDb.find_by_id_and_token(id, token),
         true <- user != nil,
         email <- Map.put(email, :body, body),
         email <- Map.put(email, :from, user.email),
         {:ok, _res} <- Sender.send(mailer, email) do
      req = :cowboy_req.reply(200, @headers, req)
      {:ok, req, state}
    else
      _res ->
        fail_delay()
        req = :cowboy_req.reply(400, req)
        {:ok, req, state}
    end
  end

  defp dos_delay(method, {_, %{delay: delay}}) do
    case method do
      "PUT" -> :timer.sleep(delay)
      "POST" -> :timer.sleep(delay)
      "DELETE" -> :timer.sleep(delay)
      "GET" -> :nop
    end
  end

  defp fail_delay() do
    :timer.sleep(@fail_delay)
  end
end
