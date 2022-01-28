defmodule Fw.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    if target() != :host do
      setup_wifi()
    end
    opts = [strategy: :one_for_one, name: Fw.Supervisor]

    children =
      [ ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    []
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Fw.Worker.start_link(arg)
      # {Fw.Worker, arg},
    ]
  end

  defp setup_wifi() do
    kv = Nerves.Runtime.KV.get_all()

    if true?(kv["wifi_force"]) or wlan0_unconfigured?() do
      ssid = kv["wifi_ssid"]
      passphrase = kv["wifi_passphrase"]

      unless empty?(ssid) do
        _ = VintageNetWiFi.quick_configure(ssid, passphrase)
        :ok
      end
    end
  end

    defp wlan0_unconfigured?() do
    "wlan0" in VintageNet.configured_interfaces() and
      VintageNet.get_configuration("wlan0") == %{type: VintageNetWiFi}
  end

  defp true?(""), do: false
  defp true?(nil), do: false
  defp true?("false"), do: false
  defp true?("FALSE"), do: false
  defp true?(_), do: true

  defp empty?(""), do: true
  defp empty?(nil), do: true
  defp empty?(_), do: false

  def target() do
    Application.get_env(:fw, :target)
  end
end
