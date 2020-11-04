defmodule Fw.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]

    #    result = start_ssh()
    #    Logger.warn("SSH #{inspect(result)}")

    children =
      [
        {Registry, keys: :unique, name: WorkerRegistry},
        Fw.Lights,
        Fw.Listener
      ] ++ children(target())

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

  def target() do
    Application.get_env(:fw, :target)
  end
end
