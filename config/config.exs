# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Custom: Use tzdata as TimeZoneDatabase
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Custom: Configures Money
# https://github.com/kipcole9/money
config :ex_money,
  default_cldr_backend: Sportyweb.Cldr

config :sportyweb,
  ecto_repos: [Sportyweb.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :sportyweb, SportywebWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: SportywebWeb.ErrorHTML, json: SportywebWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Sportyweb.PubSub,
  live_view: [signing_salt: "RpRbYTuH"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :sportyweb, Sportyweb.Mailer, adapter: Swoosh.Adapters.Local

# Custom: Configures jobs for Quantum (cron-like scheduler)
# https://github.com/quantum-elixir/quantum-core
config :sportyweb, Sportyweb.Scheduler,
  jobs: [
    {"@daily", {Sportyweb.Accounting, :create_todays_transactions, []}}
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  sportyweb: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.4", # IMPORTANT NOTE: Versions > 3.2.4 break the coloring of buttons. Check after future upgrade!
  sportyweb: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
