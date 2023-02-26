defmodule Sportyweb.Repo.Migrations.CreateEquipmentFees do
  use Ecto.Migration

  def change do
    create table(:equipment_fees, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :equipment_id, references(:equipment, on_delete: :delete_all, type: :binary_id), null: false, default: nil
      add :fee_id, references(:fees, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:equipment_fees, [:equipment_id])
    create unique_index(:equipment_fees, [:fee_id])
    create unique_index(:equipment_fees, [:equipment_id, :fee_id])
  end
end
