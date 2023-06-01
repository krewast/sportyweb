defmodule Sportyweb.FinanceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Finance` context.
  """

  import Sportyweb.OrganizationFixtures

  @doc """
  Generate a fee.
  """
  def fee_fixture(attrs \\ %{}) do
    club = club_fixture()

    {:ok, fee} =
      attrs
      |> Enum.into(%{
        club_id: club.id,
        is_general: true,
        type: "club",
        name: "some name",
        reference_number: "some reference_number",
        description: "some description",
        base_fee_in_eur: 42,
        base_fee_in_eur_cent: 4200,
        admission_fee_in_eur: 15,
        admission_fee_in_eur_cent: 1500,
        is_for_contact_group_contacts_only: true,
        is_recurring: true,
        minimum_age_in_years: 18,
        maximum_age_in_years: 50,
        commission_date: ~D[2023-02-24],
        archive_date: ~D[2023-02-24],
      })
      |> Sportyweb.Finance.create_fee()

    fee
  end

  @doc """
  Generate a subsidy.
  """
  def subsidy_fixture(attrs \\ %{}) do
    {:ok, subsidy} =
      attrs
      |> Enum.into(%{
        archive_date: ~D[2023-05-29],
        commission_date: ~D[2023-05-29],
        description: "some description",
        name: "some name",
        reference_number: "some reference_number",
        value: 42
      })
      |> Sportyweb.Finance.create_subsidy()

    subsidy
  end
end
