defmodule SchoolWeb.MainLive do
  use SchoolWeb, :live_view

  alias School.Logic
  alias School.State

  import SchoolWeb.GameComponents

  @impl true
  def mount(_params, _session, socket) do
    package = Logic.generate_package()

    Process.send(self(), :update_rules, [])

    new_socket =
      socket
      |> assign(:local_player, true)
      |> assign(:package, package)
      |> assign(:timestamp, nil)
      |> assign(:validation_result, nil)
      |> assign(:game_state, :in_progress)
      |> assign(:rule_descriptions, [])

    {:ok, new_socket}
  end

  @impl true
  def handle_event("approve", _params, socket) do
    new_socket = validation("swipe-right", socket)

    {:noreply, new_socket}
  end

  @impl true
  def handle_event("decline", _params, socket) do
    new_socket = validation("swipe-left", socket)

    {:noreply, new_socket}
  end

  @impl true
  def handle_info(:next_package, socket) do
    package = Logic.generate_package()

    new_socket =
      socket
      |> assign(:package, package)
      |> push_event("reset-package-card", %{})

    {:noreply, new_socket}
  end

  @impl true
  def handle_info(:update_rules, socket) do
    State.set_random_rule()

    active_rules = State.get_active_rules()
    rule_descriptions = Logic.descriptions_by_rules(active_rules)

    new_socket =
      socket
      |> assign(:rule_descriptions, rule_descriptions)
      |> assign(:active_rules, active_rules)

    Process.send_after(self(), :update_rules, 5_000)

    {:noreply, new_socket}
  end

  defp validation(swipe_direction, socket) do
    new_socket =
      push_event(socket, swipe_direction, %{})

    Process.send_after(self(), :next_package, 1_000)

    new_socket
  end
end
