defmodule Sportyweb.Organization.DepartmentPhone do
  @moduledoc """
  Associative entity, part of a [polymorphic association with many to many](https://hexdocs.pm/ecto/polymorphic-associations-with-many-to-many.html).
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Sportyweb.Organization.Department
  alias Sportyweb.Polymorphic.Phone

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "department_phones" do
    belongs_to :department, Department
    belongs_to :phone, Phone

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(department_phone, attrs) do
    department_phone
    |> cast(attrs, [:department_id, :phone_id])
    |> validate_required([:department_id, :phone_id])
    |> unique_constraint(:phone_id, name: "department_phones_phone_id_index")
  end
end
