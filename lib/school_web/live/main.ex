defmodule SchoolWeb.MainLive do
  use SchoolWeb, :live_view

  alias School.Package

  import SchoolWeb.GameComponents

  @impl true
  def mount(_params, _session, socket) do
    new_socket =
      socket
      |> assign(:local_player, true)
      |> assign(:package, %Package{})
      |> assign(:timestamp, nil)
      |> assign(:validation_result, nil)
      |> assign(:game_state, :in_progress)

    {:ok, new_socket}
  end
end
