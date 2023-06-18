import Config

# Configure your database
config :firstmail, Firstmail.Repo,
  database: Path.expand("../.database/firstmail_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
