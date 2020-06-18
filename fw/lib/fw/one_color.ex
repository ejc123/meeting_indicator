defmodule Fw.OneColor do
  use GenServer

  require Logger

  defmodule State do
    defstruct [:timer, :color, :brightness]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Send ourselves a message to draw each frame every 33 ms,
    # which will end up being approximately 15 fps.
    {:ok, ref} = :timer.send_interval(120, :draw_frame)

    state = %State{
      timer: ref,
      color: Fw.colors[:dark],
      brightness: 16
    }

    {:ok, state}
  end

  @impl true
  def handle_cast(:in_meeting, state) do
    Logger.info("Worker: in_meeting}")
    {:noreply, %State{state | color: Fw.colors[:red]}}
  end

  def handle_cast(:free, state) do
    Logger.info("Worker: free}")
    {:noreply, %State{state | color: Fw.colors[:green]}}
  end

  def handle_cast(:reset, state) do
    Logger.info("Worker: reset}")
    {:noreply, %State{state | color: Fw.colors[:blue]}}
  end

  def handle_cast(:off, state) do
    Logger.info("Worker: off}")
    {:noreply, %State{state | color: Fw.colors[:dark]}}
  end

  @impl true
  def handle_cast(message, state) do
    Logger.info("Received: a message: #{inspect(message)}")
    {:noreply, state}
  end
  @impl true
  def handle_info(:draw_frame, state) do

    brightness = cond do
      state.brightness > 29 -> 0
      true -> state.brightness + 1
    end

    #Logger.info("Brightness: #{brightness} state.brightness #{state.brightness}")
    Blinkchain.set_brightness(1, Enum.at(Fw.brightness,brightness))
    Blinkchain.fill({0,0},30,1,state.color)


    Blinkchain.render()
    {:noreply, %State{state | brightness: brightness}}
  end

end
