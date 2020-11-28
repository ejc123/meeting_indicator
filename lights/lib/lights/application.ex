defmodule Lights.Application do
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lights.Supervisor]

    children =
      [
        Lights.Lights,
        Lights.OtherLights,
        Lights.Listener,
      ]

    Supervisor.start_link(children, opts)
  end

end
