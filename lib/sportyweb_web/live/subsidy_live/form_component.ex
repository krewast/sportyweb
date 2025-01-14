defmodule SportywebWeb.SubsidyLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Finance
  alias Sportyweb.Finance.Subsidy

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.card>
        <.simple_form
          for={@form}
          id="subsidy-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <.input_grid>
              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:name]} type="text" label="Name" />
              </div>

              <div class="col-span-12 md:col-span-6">
                <.input
                  field={@form[:reference_number]}
                  type="text"
                  label="Referenznummer (optional)"
                />
              </div>

              <div class="col-span-12">
                <.input field={@form[:description]} type="textarea" label="Beschreibung (optional)" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <div class="col-span-12">
                <.input field={@form[:amount]} type="text" label="Betrag in Euro" />
                <.input_description>
                  Das €-Zeichen kann, muss aber nicht angegeben werden.
                </.input_description>
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.InternalEventFormComponent.render form={@form} />
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.NotesFormComponent.render form={@form} />
            </.input_grid>

            <.input_grid :if={show_archive_message?(@subsidy)} class="pt-6">
              <div class="col-span-12">
                <div
                  class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative"
                  role="alert"
                >
                  Dieser Zuschuss kann nicht gelöscht, sondern nur archiviert werden, denn:
                  <ul class="list-disc pl-4 mb-3">
                    <li :if={Enum.any?(@subsidy.fees)}>
                      Er wird von {Enum.count(@subsidy.fees)} Gebühren verwendet.
                    </li>
                  </ul>
                  Zur Archivierung bitte das gewünschte Datum im Feld "Archiviert ab" eintragen und "Speichern" klicken.
                </div>
              </div>
            </.input_grid>

            <.input_grid :if={@subsidy.id && Subsidy.is_archived?(@subsidy)} class="pt-6">
              <div class="col-span-12">
                <div
                  class="bg-amber-100 border border-amber-400 text-amber-800 px-4 py-3 rounded relative"
                  role="alert"
                >
                  Dieser Zuschuss ist derzeit archiviert.
                  Wird das Datum im Feld "Archiviert ab" gelöscht, oder durch ein Zukünftiges ersetzt,
                  lässt sich die Archivierung komplett bzw. temporär aufheben.
                </div>
              </div>
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={show_delete_button?(@subsidy)}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @subsidy.id})}
              data-confirm="Unwiderruflich löschen?"
            >
              Löschen
            </.button>
          </:actions>
        </.simple_form>
      </.card>
    </div>
    """
  end

  @impl true
  def update(%{subsidy: subsidy} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Finance.change_subsidy(subsidy))
     end)}
  end

  @impl true
  def handle_event("validate", %{"subsidy" => subsidy_params}, socket) do
    changeset = Finance.change_subsidy(socket.assigns.subsidy, subsidy_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"subsidy" => subsidy_params}, socket) do
    save_subsidy(socket, socket.assigns.action, subsidy_params)
  end

  defp save_subsidy(socket, :edit, subsidy_params) do
    case Finance.update_subsidy(socket.assigns.subsidy, subsidy_params) do
      {:ok, _subsidy} ->
        {:noreply,
         socket
         |> put_flash(:info, "Zuschuss erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_subsidy(socket, :new, subsidy_params) do
    subsidy_params =
      Enum.into(subsidy_params, %{
        "club_id" => socket.assigns.subsidy.club.id
      })

    case Finance.create_subsidy(subsidy_params) do
      {:ok, _subsidy} ->
        {:noreply,
         socket
         |> put_flash(:info, "Zuschuss erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp show_delete_button?(subsidy) do
    subsidy.id && !Enum.any?(subsidy.fees)
  end

  defp show_archive_message?(subsidy) do
    subsidy.id && Enum.any?(subsidy.fees) && !Subsidy.is_archived?(subsidy)
  end
end
