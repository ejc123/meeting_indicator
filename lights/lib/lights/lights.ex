defmodule Lights.Lights do
  use GenServer, restart: :temporary

  require Logger
  require Integer
  alias Blinkchain.Point
  alias Blinkchain.Color

  @orange Color.parse("#db8039")
  @green Color.parse("#53b812")
  @red Color.parse("#d82727")
  @blue Color.parse("#1760eb")
  @dark Color.parse("#000000")

  @default_time 90
  @brightness [
    2,
    4,
    6,
    8,
    10,
    12,
    14,
    16,
    18,
    20,
    22,
    24,
    26,
    28,
    30,
    32,
    30,
    28,
    26,
    24,
    22,
    20,
    18,
    16,
    14,
    12,
    10,
    8,
    6,
    4
  ]

  defmodule State do
    defstruct [:timer, :color1, :color2, :brightness, :pattern, :off]
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: Lights.Lights)
  end

  @impl GenServer
  def init(_opts) do
    # Send ourselves a message to draw each frame every 120 ms,
    {:ok, ref} = :timer.send_interval(@default_time, :draw_frame)

    state = %State{
      timer: ref,
      color1: @dark,
      color2: @dark,
      brightness: 16,
      pattern: :two_color,
      off: false
    }

    {:ok, state}
  end

  defp blank() do
    Blinkchain.fill({0, 0}, 30, 1, @dark)
    Blinkchain.set_brightness(1, 1)
    Blinkchain.render()
  end

  @impl GenServer
  def handle_call(:stop, _from, status) do
    blank()
    {:stop, :normal, status}
  end

  @impl GenServer
  def handle_cast(:in_meeting, state) do
    Logger.info("Worker: in_meeting}")
    blank()

    {:noreply, %State{state | color1: @red, color2: @orange, off: false}}
  end

  @impl GenServer
  def handle_cast(:free, state) do
    Logger.info("Worker: free}")
    blank()

    {:noreply, %State{state | color1: @green, color2: @orange, off: false}}
  end

  @impl GenServer
  def handle_cast(:reset, state) do
    Logger.info("Worker: reset}")
    blank()

    {:noreply, %State{state | color1: @blue, color2: @orange, off: false}}
  end

  @impl GenServer
  def handle_cast(:off, state) do
    Logger.info("Worker: off}")
    blank()

    {:noreply, %State{state | color1: @dark, color2: @dark, off: true}}
  end

  @impl GenServer
  def handle_cast(:two_color, %State{color1: @dark, color2: @dark} = state) do
    Logger.info("Worker: two_color}")
    blank()

    {:noreply,
     %State{
       state
       | color1: @blue,
         color2: @orange,
         pattern: :two_color,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(:two_color, state) do
    Logger.info("Worker: two_color}")
    blank()

    {:noreply,
     %State{
       state
       | pattern: :two_color,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(:race, %State{color1: @dark, color2: @dark} = state) do
    Logger.info("Worker: race}")

    {:noreply,
     %State{
       state
       | color1: @blue,
         color2: @dark,
         pattern: :race,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(:race, state) do
    Logger.info("Worker: race}")

    {:noreply,
     %State{
       state
       | pattern: :race,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(:pulse, %State{color1: @dark, color2: @dark} = state) do
    Logger.info("Worker: pulse}")

    {:noreply,
     %State{
       state
       | color1: @blue,
         color2: @dark,
         pattern: :pulse,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(:pulse, state) do
    Logger.info("Worker: pulse}")

    {:noreply,
     %State{
       state
       | pattern: :pulse,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(:one_color, %State{color1: @dark, color2: @dark} = state) do
    Logger.info("Worker: one_color}")

    {:noreply,
     %State{
       state
       | color1: @blue,
         color2: @dark,
         pattern: :one_color,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(:one_color, state) do
    Logger.info("Worker: one_color}")

    {:noreply,
     %State{
       state
       | pattern: :one_color,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(message, state) do
    Logger.info("Received: a message: #{inspect(message)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:draw_frame, %State{off: true} = state) do
    Logger.debug(":off message: draw_frame")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:draw_frame, %State{pattern: :two_color} = state) do
    Logger.debug(":two_color message: #{inspect(state)}")
    Blinkchain.set_brightness(1, Enum.at(@brightness, state.brightness))
    Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 1, y: 0}, 29, 1)
    Blinkchain.fill(%Point{x: 0, y: 0}, 1, 1, state.color1)

    Blinkchain.render()

    get_return_value(state, 2)
  end

  @impl GenServer
  def handle_info(:draw_frame, %State{pattern: :race} = state) do
    Logger.debug(":race message: #{inspect(state)}")
    Blinkchain.set_brightness(1, 32)

    Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 5, y: 0}, 25, 1)
    Blinkchain.fill(%Point{x: 0, y: 0}, 5, 1, state.color1)

    Blinkchain.render()

    get_return_value(state, 5)
  end

  @impl GenServer
  def handle_info(:draw_frame, %State{pattern: :pulse} = state) do
    Logger.debug(":pulse message: #{inspect(state)}")
    Blinkchain.set_brightness(1, Enum.at(@brightness, state.brightness))

    Blinkchain.copy(%Point{x: 0, y: 0}, %Point{x: 1, y: 0}, 29, 1)
    Blinkchain.set_pixel(%Point{x: 0, y: 0}, state.color1)

    Blinkchain.render()

    {:noreply, %State{state | brightness: calculate_brightness(state)}}
  end

  @impl GenServer
  def handle_info(:draw_frame, %State{pattern: :one_color} = state) do
    Logger.debug(":one_color message: #{inspect(state)}")
    Blinkchain.set_brightness(1, 32)

    Blinkchain.fill({0, 0}, 30, 1, state.color1)
    Blinkchain.render()

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:draw_frame, state) do
    Logger.debug("Received unknown message: #{inspect(state)}")
    {:noreply, state}
  end

  defp calculate_brightness(state) do
    cond do
      state.brightness > 29 -> 0
      true -> state.brightness + 1
    end
  end

  defp get_return_value(state, mod) do
    brightness = calculate_brightness(state)

    case Integer.mod(brightness + 1, mod) == 0 do
      true ->
        {:noreply,
         %State{
           state
           | brightness: brightness,
             color1: state.color2,
             color2: state.color1
         }}

      false ->
        {:noreply, %State{state | brightness: brightness}}
    end
  end
end
