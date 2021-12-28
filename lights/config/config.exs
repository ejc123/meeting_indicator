import Config

config :lights, target: Mix.target()

config :logger,
level: :info,
utc_log: true

import_config "blinkchain.exs"

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
#
#  import_config "#{config_env()}.exs"
