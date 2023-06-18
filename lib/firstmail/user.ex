defmodule Firstmail.User do
  use Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :naive_datetime_usec]
  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field(:email, :string)
    field(:data, :string)
    field(:token, :string)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :data, :token])
    |> validate_required([:email, :data, :token])
    |> validate_format(
      :email,
      ~r/^[-_a-zA-Z0-9]+(\.[-_a-zA-Z0-9]+)*@([-_a-zA-Z0-9]+\.)+[a-zA-Z]+$/
    )
    |> unique_constraint(:email)
  end
end
