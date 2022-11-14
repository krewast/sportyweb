defmodule Sportyweb.OrganizationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sportyweb.Organization` context.
  """

  @doc """
  Generate a unique club website_url.
  """
  def unique_club_website_url, do: "some website_url#{System.unique_integer([:positive])}"

  @doc """
  Generate a club.
  """
  def club_fixture(attrs \\ %{}) do
    {:ok, club} =
      attrs
      |> Enum.into(%{
        founded_at: ~D[2022-11-05],
        name: "some name",
        reference_number: "some reference_number",
        website_url: unique_club_website_url()
      })
      |> Sportyweb.Organization.create_club()

    club
  end

  @doc """
  Generate a department.
  """
  def department_fixture(attrs \\ %{}) do
    {:ok, department} =
      attrs
      |> Enum.into(%{
        created_at: ~D[2022-11-05],
        name: "some name",
        type: "some type"
      })
      |> Sportyweb.Organization.create_department()

    department
  end
end