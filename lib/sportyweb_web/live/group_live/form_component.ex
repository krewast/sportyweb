defmodule SportywebWeb.GroupLive.FormComponent do
  use SportywebWeb, :live_component

  alias Sportyweb.Organization

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
          id="group-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.input_grids>
            <%= if @group.id do %>
              <.input_grid>
                <div class="col-span-12">
                  <.input
                    field={@form[:department_id]}
                    type="select"
                    label="Abteilung"
                    options={
                      Organization.list_departments(@group.department.club_id)
                      |> Enum.map(&{&1.name, &1.id})
                    }
                  />
                </div>
              </.input_grid>
            <% end %>

            <.input_grid class="pt-6">
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

              <div class="col-span-12 md:col-span-6">
                <.input field={@form[:creation_date]} type="date" label="Erstellungsdatum" />
              </div>
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.EmailsFormComponent.render form={@form} />
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.PhonesFormComponent.render form={@form} />
            </.input_grid>

            <.input_grid class="pt-6">
              <SportywebWeb.PolymorphicLive.NotesFormComponent.render form={@form} />
            </.input_grid>
          </.input_grids>

          <:actions>
            <div>
              <.button phx-disable-with="Speichern...">Speichern</.button>
              <.cancel_button navigate={@navigate}>Abbrechen</.cancel_button>
            </div>
            <.button
              :if={@group.id}
              class="bg-rose-700 hover:bg-rose-800"
              phx-click={JS.push("delete", value: %{id: @group.id})}
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
  def update(%{group: group} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Organization.change_group(group))
     end)}
  end

  @impl true
  def handle_event("validate", %{"group" => group_params}, socket) do
    changeset = Organization.change_group(socket.assigns.group, group_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"group" => group_params}, socket) do
    save_group(socket, socket.assigns.action, group_params)
  end

  defp save_group(socket, :edit, group_params) do
    case Organization.update_group(socket.assigns.group, group_params) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gruppe erfolgreich aktualisiert")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_group(socket, :new, group_params) do
    group_params =
      Enum.into(group_params, %{
        "department_id" => socket.assigns.group.department.id
      })

    case Organization.create_group(group_params) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Gruppe erfolgreich erstellt")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
