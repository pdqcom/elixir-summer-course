defmodule SchoolWeb.MainLive do
  use SchoolWeb, :live_view

  #alias School.Package
  import SchoolWeb.GameComponents

  @impl true
  def mount(_params, _session, socket) do
    new_socket =
      socket
      # SHC2 - local_player: true
      |> assign(:local_player, false)
      # SHC2 - package: %Package{}
      |> assign(:package, nil)
      |> assign(:timestamp, nil)
      |> assign(:validation_result, nil)
      |> assign(:game_state, :in_progress)

    {:ok, new_socket}
  end
end
