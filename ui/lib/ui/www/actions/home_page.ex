defmodule Ui.WWW.Actions.HomePage do
  use Raxx.SimpleServer
  use Ui.WWW.Layout, arguments: [:greeting, :csrf_token]
  alias Raxx.Session

  require Logger

  @impl Raxx.SimpleServer
  def handle_request(request = %{method: :GET}, state) do
    {:ok, session} = Session.extract(request, state.session_config)

    {csrf_token, session} = Session.get_csrf_token(session)
    {flash, session} = Session.pop_flash(session)

    greeting = Ui.welcome_message(session[:name])

    response(:ok)
    |> Session.embed(session, state.session_config)
    |> render(greeting, csrf_token, flash: flash)
  end

  def handle_request(request = %{method: :POST}, state) do
    data = URI.decode_query(request.body)
    {:ok, session} = Session.extract(request, data["_csrf_token"], state.session_config)

    case data do
      %{"start" => _} ->
        Logger.info("Web start")
        GenServer.cast({:global, Lights.Listener}, :start)

        session =
          session
          |> Session.put_flash(:info, "Meeting started")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"end" => _} ->
        Logger.info("Web end")
        GenServer.cast({:global, Lights.Listener}, :end)

        session =
          session
          |> Session.put_flash(:info, "Meeting ended")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"reset" => _} ->
        Logger.info("Web reset")
        GenServer.cast({:global, Lights.Listener}, :reset)

        session =
          session
          |> Session.put_flash(:info, "State reset")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"off" => _} ->
        Logger.info("Web off")
        GenServer.cast({:global, Lights.Listener}, :off)

        session =
          session
          |> Session.put_flash(:info, "You can shut off now")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"two_color" => _} ->
        Logger.info("Two Color")
        GenServer.cast({:global, Lights.Listener}, :two_color)

        session =
          session
          |> Session.put_flash(:info, "Changed pattern to two color")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"one_color" => _} ->
        Logger.info("One Color")
        GenServer.cast({:global, Lights.Listener}, :one_color)

        session =
          session
          |> Session.put_flash(:info, "Changed pattern to one color")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"race" => _} ->
        Logger.info("Race")
        GenServer.cast({:global, Lights.Listener}, :race)

        session =
          session
          |> Session.put_flash(:info, "Changed pattern to race")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"pulse" => _} ->
        Logger.info("Pulse")
        GenServer.cast({:global, Lights.Listener}, :pulse)

        session =
          session
          |> Session.put_flash(:info, "Changed pattern to pulse")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"on_other" => _} ->
        Logger.info("Long Chain on")
        GenServer.cast({:global, Lights.Listener}, :on_other)

        session =
          session
          |> Session.put_flash(:info, "Turned Long Chain On")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"off_other" => _} ->
        Logger.info("Long Chain off")
        GenServer.cast({:global, Lights.Listener}, :off_other)

        session =
          session
          |> Session.put_flash(:error, "Turned Long Chain Off")

        redirect("/")
        |> Session.embed(session, state.session_config)

      _ ->
        redirect("/")
    end
  end

  # Template helper functions.
  # Add shared helper functions to Ui.WWW.Layout.
end
