defmodule Firstmail.Application do
  @moduledoc false

  alias Firstmail.Utils

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    port = Application.fetch_env!(:firstmail, :server_port)
    delay = Application.fetch_env!(:firstmail, :dos_delay)
    mailer = Application.fetch_env!(:firstmail, :mailer_config)
    mailer = Keyword.update!(mailer, :pubkey, &Utils.parse_pem/1)
    database = Application.fetch_env!(:firstmail, Firstmail.Repo)[:database]
    Logger.info("Port #{port}")
    Logger.info("Db #{database}")

    children = [
      Firstmail.Repo,
      Firstmail.Migrator,
      {Firstmail.WebServer, port: port, delay: delay, mailer: mailer}
    ]

    opts = [strategy: :one_for_one, name: Firstmail.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
