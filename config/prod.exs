import Config

# Configure your database
config :firstmail, Firstmail.Repo,
  database: Path.expand("../.database/firstmail_prod.db", Path.dirname(__ENV__.file)),
  pool_size: 5

# Do not print debug messages in production
config :logger, level: :info
