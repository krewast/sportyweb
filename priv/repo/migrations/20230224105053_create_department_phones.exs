defmodule Sportyweb.Repo.Migrations.CreateDepartmentPhones do
  use Ecto.Migration

  def change do
    create table(:department_phones, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :department_id, references(:departments, on_delete: :delete_all, type: :binary_id), null: false, default: nil
      add :phone_id, references(:phones, on_delete: :delete_all, type: :binary_id), null: false, default: nil

      timestamps()
    end

    create index(:department_phones, [:department_id])
    create unique_index(:department_phones, [:phone_id])
    create unique_index(:department_phones, [:department_id, :phone_id])
  end
end
