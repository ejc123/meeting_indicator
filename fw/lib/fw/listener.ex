defmodule Fw.Listener do
  @moduledoc """
  DemoListener module.
  """
  require Logger

  use GenServer

  def start_link, do: start_link([])
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: {:global, Fw.Listener})

  @impl GenServer
  def init(init_arg) do
    Nerves.Runtime.validate_firmware()
    {:ok, init_arg}
  end

  @impl GenServer
  def handle_info(_, state), do: {:noreply, [], state}

  @impl GenServer
  def handle_cast(:start, state) do
    Logger.info("Listener start received")
    GenServer.cast(Fw.Lights, :in_meeting)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:end, state) do
    Logger.info("Listener end received")
    GenServer.cast(Fw.Lights, :free)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:reset, state) do
    Logger.info("Listener reset received")
    GenServer.cast(Fw.Lights, :reset)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:off, state) do
    Logger.info("Listener off received")
    GenServer.cast(Fw.Lights, :off)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:one_color, state) do
    Logger.info("Listener one_color received")
    GenServer.cast(Fw.Lights, :one_color)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:two_color, state) do
    Logger.info("Listener two_color received")
    GenServer.cast(Fw.Lights, :two_color)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:race, state) do
    Logger.info("Listener race received")
    GenServer.cast(Fw.Lights, :race)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:pulse, state) do
    Logger.info("Listener pulse received")
    GenServer.cast(Fw.Lights, :pulse)
    {:noreply, state}
  end


  @impl GenServer
  def handle_cast(message, state) do
    Logger.info("Received: a message: #{inspect(message)}")
    {:noreply, state}
  end
end
