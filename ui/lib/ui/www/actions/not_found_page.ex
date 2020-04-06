defmodule Ui.WWW.Actions.NotFoundPage do
  use Raxx.SimpleServer

  use Ui.WWW.Layout,
    arguments: [],
    optional: [title: "Nothing Here"]

  @impl Raxx.SimpleServer
  def handle_request(_request, _state) do
    response(:not_found)
    |> render()
  end
end
