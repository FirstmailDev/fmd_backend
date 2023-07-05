import Config

# priv key already embedded in config.exs
if config_env() == :prod and System.get_env("RELEASE_NAME") != nil do
  port = System.get_env("FMD_SERVER_PORT", "31682")
  {:ok, hostname} = :inet.gethostname()

  config :firstmail, Firstmail.Repo,
    database: System.get_env("FMD_DATABASE_PATH") || raise("Missing FMD_DATABASE_PATH"),
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  config :firstmail,
    server_port: String.to_integer(port),
    mailer_config: [
      baseurl: "https://firstmail.dev",
      hostname: hostname |> to_string(),
      enabled: System.get_env("FMD_MAILER_ENABLED", "false") |> String.to_atom()
    ]
end
