defmodule Fw.TwoColor do
  use GenServer

  require Logger
  require Integer
  alias Blinkchain.Point

  defmodule State do
    defstruct [:timer, :color1, :color2, :brightness]
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
      color1: Fw.colors[:dark],
      color2: Fw.colors[:dark],
      brightness: 16
    }

    {:ok, state}
  end

  @impl true
  def handle_cast(:in_meeting, state) do
    Logger.info("Worker: in_meeting}")
    {:noreply, %State{state | color1: Fw.colors[:red], color2: Fw.colors[:yellow]}}
  end

  def handle_cast(:free, state) do
    Logger.info("Worker: free}")
    {:noreply, %State{state | color1: Fw.colors[:green], color2: Fw.colors[:yellow]}}
  end

  def handle_cast(:reset, state) do
    Logger.info("Worker: reset}")
    {:noreply, %State{state | color1: Fw.colors[:blue], color2: Fw.colors[:yellow]}}
  end

  def handle_cast(:off, state) do
    Logger.info("Worker: off}")
    {:noreply, %State{state | color1: Fw.colors[:dark], color2: Fw.colors[:dark]}}
  end

  @impl true
  def handle_cast(message, state) do
    Logger.info("Received: a message: #{inspect(message)}")
    {:noreply, state}
  end
  @impl true
  def handle_info(:draw_frame, state) do

    #Logger.info("Brightness: #{brightness} state.brightness #{state.brightness}")
    (0..29)
    |> Enum.map(fn x -> %Point{x: x, y: 0} end)
    |> Enum.each(
      fn point -> case (Integer.is_even(point)) do
                    true -> Blinkchain.set_pixel(point ,state.color2)
                    false -> Blinkchain.set_pixel(point, state.color1)
                  end
      end)

    brightness = cond do
      state.brightness > 29 -> 0
      true -> state.brightness + 1
    end

    Blinkchain.set_brightness(1, Enum.at(Fw.brightness,state.brightness))
    Blinkchain.render()
    {:noreply, %State{state | brightness: brightness}}
  end

end
