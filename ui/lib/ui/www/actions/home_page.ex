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
        GenServer.cast({:global, Fw.Listener}, :start)
        session =
          session
          |> Session.put_flash(:info, "Meeting started")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"end" => _} ->
        Logger.info("Web end")
        GenServer.cast({:global, Fw.Listener}, :end)
        session =
          session
          |> Session.put_flash(:info, "Meeting ended")

        redirect("/")
        |> Session.embed(session, state.session_config)

      %{"reset" => _} ->
        Logger.info("Web reset")
        GenServer.cast({:global, Fw.Listener}, :reset)
        session =
          session
          |> Session.put_flash(:info, "State reset")

        redirect("/")
        |> Session.embed(session, state.session_config)

      _ ->
        redirect("/")
    end
  end

  # Template helper functions.
  # Add shared helper functions to Ui.WWW.Layout.
end
