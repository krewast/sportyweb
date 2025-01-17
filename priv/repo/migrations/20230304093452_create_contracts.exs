defmodule Sportyweb.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :signing_date, :date, null: false
      add :start_date, :date, null: false
      add :first_billing_date, :date, null: true
      add :termination_date, :date, null: true
      add :archive_date, :date, null: true
      add :club_id, references(:clubs, on_delete: :delete_all, type: :binary_id), null: false

      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id),
        null: false

      add :fee_id, references(:fees, on_delete: :restrict, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:contracts, [:club_id])
    create index(:contracts, [:contact_id])
    create index(:contracts, [:fee_id])
  end
end
