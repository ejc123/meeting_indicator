defmodule Lights.OtherLights do
  use GenServer, restart: :temporary

  require Logger
  require Integer
  alias Blinkchain.Point
  alias Blinkchain.Color

  @dark Color.parse("#000000")
  @white Color.parse("#ffffff")
  @pink Color.parse("#e050ac")
  @purple Color.parse("#7504b6")
  @blue Color.parse("#1760eb")
  @green Color.parse("#53b812")
  @yellow Color.parse("#58e315")
  @orange Color.parse("#db8039")
  @red Color.parse("#d82727")
  @cyan Color.parse("#65c5db")

  @default_time 60
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
    defstruct [
      :timer,
      :color1,
      :color2,
      :color3,
      :color4,
      :color5,
      :color6,
      :color7,
      :color8,
      :color9,
      :brightness,
      :off
    ]
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
      color3: @dark,
      color4: @dark,
      color5: @dark,
      color6: @dark,
      color7: @dark,
      color8: @dark,
      color9: @dark,
      brightness: 16,
      off: false
    }

    {:ok, state}
  end

  defp blank() do
    Blinkchain.fill({30, 0}, 120, 1, @dark)
    Blinkchain.set_brightness(1, 1)
    Blinkchain.render()
  end

  @impl GenServer
  def handle_call(:stop, _from, status) do
    blank()
    {:stop, :normal, status}
  end

  @impl GenServer
  def handle_cast(:off, state) do
    Logger.info("Worker: long chain off}")
    blank()

    {:noreply,
     %State{
       state
       | color1: @dark,
         color2: @dark,
         color3: @dark,
         color4: @dark,
         color5: @dark,
         color6: @dark,
         color7: @dark,
         color8: @dark,
         color9: @dark,
         off: true
     }}
  end

  @impl GenServer
  def handle_cast(:on, %State{color1: @dark, color2: @dark} = state) do
    Logger.info("Worker: long chain on}")
    blank()

    {:noreply,
     %State{
       state
       | color1: @white,
         color2: @pink,
         color3: @purple,
         color4: @blue,
         color5: @green,
         color6: @yellow,
         color7: @orange,
         color8: @red,
         color9: @cyan,
         off: false
     }}
  end

  @impl GenServer
  def handle_cast(message, state) do
    Logger.info("Long Chain: message: #{inspect(message)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:draw_frame, %State{off: true} = state) do
    Logger.debug("Long Chain :off message: draw_frame")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:draw_frame, state) do
    Logger.debug("Long Chain message: #{inspect(state)}")
    Blinkchain.set_brightness(1, Enum.at(@brightness, state.brightness))
    Blinkchain.copy(%Point{x: 30, y: 0}, %Point{x: 31, y: 0}, 119, 1)
    Blinkchain.fill(%Point{x: 30, y: 0}, 1, 1, state.color1)

    Blinkchain.render()

    get_return_value(state, 2)
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
             color2: state.color3,
             color3: state.color4,
             color4: state.color5,
             color5: state.color6,
             color6: state.color7,
             color7: state.color8,
             color8: state.color9,
             color9: state.color1,
         }}

      false ->
        {:noreply, %State{state | brightness: brightness}}
    end
  end
end
