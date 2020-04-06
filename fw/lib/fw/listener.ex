defmodule Fw.Listener do
  @moduledoc """
  DemoListener module.
  """
  require Logger

  use GenServer

  def start_link, do: start_link([])
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: {:global, Fw.Listener})

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

#  @impl true
#  def handle_continue(:setup_zwave, state) do
#    {:noreply, state}
#  end

  @impl true
  def handle_info(_, state), do: {:noreply, [], state}

  @impl true
  def handle_cast(:start, state) do
    Logger.info("Listener start received")
    GenServer.cast(Fw.Worker, :in_meeting)
    {:noreply, state}
  end

  def handle_cast(:end, state) do
    Logger.info("Listener end received")
    GenServer.cast(Fw.Worker, :free)
    {:noreply, state}
  end

  @impl true
  def handle_cast(message, state) do
    Logger.info("Received: a message: #{inspect(message)}")
    {:noreply, state}
  end

end
