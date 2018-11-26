use Mix.Config

config :hound, driver: "selenium", port: 4444, browser: "chrome"

config :pdi_last_hope,
  email: System.get_env("EMAIL"),
  password: System.get_env("PASSWORD"),
  issue: System.get_env("ISSUE")