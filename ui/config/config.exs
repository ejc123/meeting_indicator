import Config

if config_env() == :dev do
  config :exsync,
    extra_extensions: [".js", ".css"]
end
