defmodule CalculatorLvWeb.CalculatorLive do
  use Phoenix.LiveView
  alias CalculatorLvWeb.PageView

  @topic "calc"

  @valid_syntax ~r/^([-+]? ?(\d+)( ?[-+*\/] ?\g<1>)?)$/
  def mount(_params, _session, socket) do
    CalculatorLvWeb.Endpoint.subscribe(@topic)

    {
      :ok,
      assign(
        socket,
        screen: ""
      )
    }
  end

  def render(assigns), do: PageView.render("calc.html", assigns)

  def handle_event("digit", %{"digit" => digit}, socket) do
    screen = socket.assigns.screen <> digit
    CalculatorLvWeb.Endpoint.broadcast_from(self(), @topic, "edit_screen", %{screen: screen})
    {:noreply, assign(socket, screen: screen)}
  end

  def handle_event("delete", _, socket) do
    screen = String.slice(socket.assigns.screen, 0..-2)
    CalculatorLvWeb.Endpoint.broadcast_from(self(), @topic, "edit_screen", %{screen: screen})
    {:noreply, assign(socket, screen: screen)}
  end

  def handle_event("equals", _, socket) do
    screen = socket.assigns.screen

    screen =
      if String.match?(screen, @valid_syntax) do
        {eval_screen, []} = Code.eval_string(screen)
        inspect(eval_screen)
      else
        screen
      end

    CalculatorLvWeb.Endpoint.broadcast_from(self(), @topic, "edit_screen", %{screen: screen})
    {:noreply, assign(socket, screen: screen)}
  end

  def handle_event("reset", _, socket) do
    screen = ""
    CalculatorLvWeb.Endpoint.broadcast_from(self(), @topic, "edit_screen", %{screen: screen})
    {:noreply, assign(socket, screen: screen)}
  end

  def handle_info(%{topic: @topic, payload: payload}, socket) do
    {:noreply, assign(socket, :screen, payload.screen)}
  end
end
