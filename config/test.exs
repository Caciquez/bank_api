use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank_api, BankApiWeb.Endpoint,
  http: [port: 4002],
  server: false

config :bcrypt_elixir, :log_rounds, 4

# Print only warnings and errors during test
config :logger, level: :warn

import_config "db/#{Mix.env()}.secret.exs"
