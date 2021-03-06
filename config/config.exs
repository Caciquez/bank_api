# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bank_api,
  ecto_repos: [BankApi.Repo]

# Configures the endpoint
config :bank_api, BankApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XZrIavFCr3IWbYOmVf7GK7AyO2esXPfAC6VzadnWoXR2u6qNgVZafUQjL6sgXpu5",
  render_errors: [view: BankApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BankApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :bank_api, BankApi.Guardian,
  issuer: "bank_api",
  secret_key: "FHSixxJrefHuuy+y+N6meKRu8ZSJ6b99LxkWDn5xydyRXXAo6GYZJYDDWbFbYhRl"

config :bank_api, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      # phoenix routes will be converted to swagger paths
      router: BankApiWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: BankApiWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
