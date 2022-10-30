defmodule SportywebWeb.ClubLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Organizations

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:club, Organizations.get_club!(id))}
  end

  defp page_title(:show), do: "Show Club"
  defp page_title(:edit), do: "Edit Club"
end