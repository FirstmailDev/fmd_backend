defmodule Firstmail.Repo do
  use Ecto.Repo,
    otp_app: :firstmail,
    adapter: Ecto.Adapters.SQLite3
end
