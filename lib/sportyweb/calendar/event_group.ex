defmodule Sportyweb.Calendar.EventGroup do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Calendar.Event
  alias Sportyweb.Organization.Group

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "event_groups" do
    belongs_to :event, Event
    belongs_to :group, Group

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event_group, attrs) do
    event_group
    |> cast(attrs, [:event_id, :group_id])
    |> validate_required([:event_id, :group_id])
    |> unique_constraint(:group_id, name: "event_groups_group_id_index")
  end
end
