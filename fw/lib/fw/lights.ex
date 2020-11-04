defmodule Fw.Lights do
  use GenServer, restart: :temporary

  require Logger
  require Integer
  alias Blinkchain.Point

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: Fw.Lights)
  end

  @impl GenServer
  def init(_opts) do
    # Send ourselves a message to draw each frame every 33 ms,
    # which will end up being approximately 15 fps.
    {:ok, ref} = :timer.send_interval(120, :draw_frame)

    state = %Fw.State{
      timer: ref,
      color1: Fw.colors()[:dark],
      color2: Fw.colors()[:dark],
      brightness: 16,
      pattern: :two_color
    }

    {:ok, state}
  end

  def fill(state) do
    case state.pattern do
      :two_color ->
        0..29
        |> Enum.each(fn
          x ->
            case Integer.is_even(x) do
              true -> Blinkchain.set_pixel(%Point{x: x, y: 0}, state.color2)
              false -> Blinkchain.set_pixel(%Point{x: x, y: 0}, state.color1)
            end

          :race ->
            Blinkchain.fill({0, 0}, 30, 1, state.color1)

          :pulse ->
            Blinkchain.fill({0, 0}, 30, 1, state.color1)

          :one_color ->
            Blinkchain.fill({0, 0}, 30, 1, state.color1)
        end)
    end
  end

  @impl GenServer
  def handle_call(:stop, _from, status) do
    {:stop, :normal, status}
  end

  @impl GenServer
  def handle_cast(:in_meeting, state) do
    Logger.info("Worker: in_meeting}")
    {:noreply, %State{state | color1: Fw.colors()[:red], color2: Fw.colors()[:yellow]}}
  end

  @impl GenServer
  def handle_cast(:free, state) do
    Logger.info("Worker: free}")
    {:noreply, %State{state | color1: Fw.colors()[:green], color2: Fw.colors()[:yellow]}}
  end

  @impl GenServer
  def handle_cast(:reset, state) do
    Logger.info("Worker: reset}")
    {:noreply, %State{state | color1: Fw.colors()[:blue], color2: Fw.colors()[:yellow]}}
  end

  @impl GenServer
  def handle_cast(:off, state) do
    Logger.info("Worker: off}")
    {:noreply, %State{state | color1: Fw.colors()[:dark], color2: Fw.colors()[:dark]}}
  end

  @impl GenServer
  def handle_cast(:two_color, state) do
    Logger.info("Worker: off}")

    {:noreply,
     %State{state | color1: Fw.colors()[:blue], color2: Fw.colors()[:yellow], pattern: :two_color}}
  end

  @impl GenServer
  def handle_cast(:race, state) do
    Logger.info("Worker: off}")

    {:noreply,
     %State{state | color1: Fw.colors()[:blue], color2: Fw.colors()[:blue], pattern: :race}}
  end

  @impl GenServer
  def handle_cast(:pulse, state) do
    Logger.info("Worker: off}")

    {:noreply,
     %State{state | color1: Fw.colors()[:blue], color2: Fw.colors()[:blue], pattern: :pulse}}
  end

  @impl GenServer
  def handle_cast(:one_color, state) do
    Logger.info("Worker: off}")

    {:noreply,
     %State{state | color1: Fw.colors()[:blue], color2: Fw.colors()[:blue], pattern: :one_color}}
  end

  @impl GenServer
  def handle_cast(message, state) do
    Logger.info("Received: a message: #{inspect(message)}")
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:draw_frame, state) do
    if state.color1 == Fw.colors()[:dark] && state.color2 == Fw.colors()[:dark] do
      {:noreply, %State{state | brightness: brightness}}
    else
      Blinkchain.set_brightness(1, Enum.at(Fw.brightness(), state.brightness))

      case state.pattern do
        :two_color ->
          0..29
          |> Enum.each(fn
            x ->
              case Integer.is_even(x) do
                true -> Blinkchain.set_pixel(%Point{x: x, y: 0}, state.color2)
                false -> Blinkchain.set_pixel(%Point{x: x, y: 0}, state.color1)
              end
          end)

        :race ->
          Blinkchain.fill({0, 0}, 30, 1, state.color1)

        :pulse ->
          Blinkchain.fill({0, 0}, 30, 1, state.color1)

        :one_color ->
          Blinkchain.fill({0, 0}, 30, 1, state.color1)
      end

      Blinkchain.render()

      brightness =
        cond do
          state.brightness > 29 -> 0
          true -> state.brightness + 1
        end

      case state.pattern do
        :two_color ->
          case Integer.mod(brightness + 1, 4) == 0 do
            true ->
              {:noreply,
               %State{state | brightness: brightness, color1: state.color2, color2: state.color1}}

            false ->
              {:noreply, %State{state | brightness: brightness}}
          end

        _ ->
          {:noreply, %State{state | brightness: brightness}}
      end
    end
  end
end
