use Mix.Config

config :hound, driver: "selenium", port: 4444, browser: "chrome", host: "${SELENIUM_HOST}", app_host: "${APP_HOST}"

config :pdi_last_hope,
  email: "${EMAIL}",
  password: "${PASSWORD}",
  issue: "${ISSUE}"