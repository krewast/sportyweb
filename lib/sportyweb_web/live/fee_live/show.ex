defmodule SportywebWeb.FeeLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Legal
  alias Sportyweb.Legal.Fee

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:club_navigation_current_item, :finances)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fee = Legal.get_fee!(id, [:club])

    {:noreply,
     socket
     |> assign(:page_title, "Gebühr: #{fee.name}")
     |> assign(:fee, fee)
     |> assign(:club, fee.club)}
  end
end