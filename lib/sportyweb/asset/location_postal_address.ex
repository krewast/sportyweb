defmodule Sportyweb.Asset.LocationPostalAddress do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Asset.Location
  alias Sportyweb.Polymorphic.PostalAddress

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "location_postal_addresses" do
    belongs_to :location, Location
    belongs_to :postal_address, PostalAddress

    timestamps()
  end

  @doc false
  def changeset(location_postal_address, attrs) do
    location_postal_address
    |> cast(attrs, [:location_id, :postal_address_id])
    |> validate_required([:location_id, :postal_address_id])
    |> unique_constraint(:postal_address_id,
      name: "location_postal_addresses_postal_address_id_index"
    )
  end
end