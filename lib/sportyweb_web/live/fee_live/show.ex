defmodule SportywebWeb.FeeLive.Show do
  use SportywebWeb, :live_view

  alias Sportyweb.Finance
  alias Sportyweb.Finance.Fee

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    fee =
      Finance.get_fee!(id, [
        :ancestors,
        :club,
        :contracts,
        :internal_events,
        :notes,
        :subsidy,
        :successor
      ])

    fee_title = if fee.is_general, do: "Allgemeine", else: "Spezifische"

    club_navigation_current_item =
      case fee.type do
        "department" -> :structure
        "group" -> :structure
        "event" -> :calendar
        "location" -> :assets
        "equipment" -> :assets
        _ -> :fees
      end

    {:noreply,
     socket
     |> assign(:club_navigation_current_item, club_navigation_current_item)
     |> assign(:page_title, "#{fee_title} Gebühr: #{fee.name}")
     |> assign(:fee, fee)
     |> assign(:club, fee.club)}
  end
end
