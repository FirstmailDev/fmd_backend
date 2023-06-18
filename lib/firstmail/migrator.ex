defmodule Firstmail.Migrator do
  require Logger

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :worker,
      restart: :transient,
      shutdown: 500
    }
  end

  def start_link() do
    {:ok, spawn_link(fn -> init() end)}
  end

  def init() do
    path = Application.app_dir(:firstmail, "priv/repo/migrations")
    # does not work for sqlite :memory:
    # returns list of applied migration ids
    result = Ecto.Migrator.run(Firstmail.Repo, path, :up, all: true)
    Logger.info("Migration result #{inspect(result)}")
  end
end
