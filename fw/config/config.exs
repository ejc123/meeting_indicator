# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

Application.start(:nerves_bootstrap)

import_config "../../ui/config/config.exs"
import_config "../../lights/config/config.exs"

config :fw, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware,
  rootfs_overlay: "rootfs_overlay",
  provisioning: "config/provisioning.conf"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1585625975"

config :nerves, rpi_v2_ack: true

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [{LoggerFileBackend, :info_log}, {LoggerFileBackend, :error_log}, RingLogger], level: :info

config :logger, :info_log,
path: "/root/info.log",
level: :info

config :logger, :error_log,
path: "/root/error.log",
level: :error

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if Mix.target() != :host do
  import_config "target.exs"
end
