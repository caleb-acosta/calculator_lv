defmodule CalculatorLvWeb.CalculatorLive do
  use Phoenix.LiveView
  alias CalculatorLvWeb.PageView

  @topic "calc"

  @valid_syntax ~r/^([-+]? ?(\d+|\d+\.\d+) [-+*\/] [-+]? ?(\d+|\d+\.\d+))$/
  def mount(_params, _session, socket) do
    CalculatorLvWeb.Endpoint.subscribe(@topic)

    {
      :ok,
      assign(
        socket,
        ans: "",
        operation: "",
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

  def handle_event("operation", %{"operation" => operation}, socket) do
    IO.inspect(socket.assigns)
    ans = do_operation(socket.assigns.ans, socket.assigns.operation, socket.assigns.screen)
    {:noreply, assign(socket, operation: operation, screen: "", ans: ans)}
  end

  def handle_event("equals", _, socket) do
    screen = do_operation(socket.assigns.ans, socket.assigns.operation, socket.assigns.screen)
    CalculatorLvWeb.Endpoint.broadcast_from(self(), @topic, "edit_screen", %{screen: screen})
    {:noreply, assign(socket, screen: screen, ans: screen, operation: "")}
  end

  def handle_event("reset", _, socket) do
    CalculatorLvWeb.Endpoint.broadcast_from(self(), @topic, "edit_screen", %{})
    {:noreply, assign(socket, screen: "", ans: "", operation: "")}
  end

  def handle_info(%{topic: @topic, payload: payload}, socket) do
    {:noreply, assign(socket, :screen, payload.screen)}
  end

  def do_operation("", _, input), do: input

  def do_operation(ans, "", _), do: ans

  def do_operation(ans, operation, input) do
    expression = ans <> " " <> operation <> " " <> input

    if String.match?(expression, @valid_syntax) do
      {eval_string, []} = Code.eval_string(expression)
      inspect(eval_string)
    else
      ans
    end
  end
end
