defmodule SportywebWeb.RoleLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures
  import Sportyweb.RBAC.RoleFixtures
  import Sportyweb.RBAC.UserRoleFixtures

  setup do
    user = user_fixture()
    applicationrole = application_role_fixture()
    user_application_role_fixture(%{user_id: user.id, applicationrole_id: applicationrole.id})

    club_admin = user_fixture()
    club = club_fixture()
    clubrole_admin = club_role_fixture(%{name: "Vereins Administration"})
    ucr_admin = user_club_role_fixture(%{user_id: club_admin.id, club_id: club.id, clubrole_id: clubrole_admin.id})

    clubrole_other = club_role_fixture(%{name: "Vorstand"})

    %{
      user: user,
      club_admin: club_admin,
      club: club,
      clubrole_admin: clubrole_admin,
      clubrole_other: clubrole_other,
      ucr_admin: ucr_admin
    }
  end

  describe "Index" do
    test "lists all userclubroles in club", %{conn: conn, user: user, club: club, club_admin: club_admin, clubrole_admin: clubrole_admin} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles")

      conn = conn |> log_in_user(user)
      {:ok, index_live, html} = live(conn, ~p"/clubs/#{club.id}/roles")

      assert html =~ "Rollen"
      assert html =~ club_admin.email
      assert html =~ clubrole_admin.name

      {:ok, _, newhtml} = index_live
             |> element("#roles-#{club_admin.id} a", "Bearbeiten")
             |> render_click()
             |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert newhtml =~ "Rollen von #{club_admin.email}"
    end
  end

  describe "Edit" do
    test "add clubrole to user in club", %{conn: conn, user: user, club_admin: club_admin, club: club, clubrole_other: clubrole_other} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert html =~ "Rollen von #{club_admin.email}"
      assert html =~ "im Verein #{club.name}"
      assert html =~ "im Verein #{club.name}"
      assert html =~ "Zugewiesene Rollen"
      assert html =~ "Entfernen"
      assert html =~ "Verfügbare Rollen zur Zuweisung"
      assert html =~ "Hinzufügen"

      {:ok, _, addhtml} =
        edit_live
        |> element("#available_club_roles-#{clubrole_other.id} button", "Hinzufügen")
        |> render_click()
        |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

        assert addhtml =~ "Rollen von #{club_admin.email}"
        refute addhtml =~ "Hinzufügen"
        assert addhtml =~ "Die Rolle wurde dem Nutzer erfolgreich hinzugefügt."
    end

    test "remove clubrole to user in club", %{conn: conn, user: user, club_admin: club_admin, club: club, ucr_admin: ucr_admin} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert html =~ "Rollen von #{club_admin.email}"
      assert html =~ "im Verein #{club.name}"
      assert html =~ "Zugewiesene Rollen"
      assert html =~ "Entfernen"
      assert html =~ "Verfügbare Rollen zur Zuweisung"
      assert html =~ "Hinzufügen"

      {:ok, _, removehtml} =
      edit_live
      |> element("#assigned_club_roles-#{ucr_admin.id} button", "Entfernen")
      |> render_click()
      |> follow_redirect(conn, ~p"/clubs/#{club.id}/roles/#{club_admin.id}/edit")

      assert removehtml =~ "Rollen von #{club_admin.email}"
      refute removehtml =~ "Entfernen"
      assert removehtml =~ "Die Rolle wurde erfolgreich vom Nutzer entfernt."
    end
  end

  describe "New" do
    test "add userclubrole to club", %{conn: conn, user: user, club: club} do
      {:error, _} = live(conn, ~p"/clubs/#{club.id}/roles/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/clubs/#{club.id}/roles/new")

      assert html =~ "Mitarbeiter zu #{club.name} hinzufügen"
      assert html =~ "Verwalter: #{user.email}"

      email = unique_user_email()
      {:ok, _, newhtml} = new_live
      |> form("#add_user_form", user: %{email: email})
      |> render_submit()
      |> follow_redirect(conn,  ~p"/clubs/#{club.id}/roles/#{Sportyweb.Accounts.get_user_by_email(email).id}/edit")

      added_user = Sportyweb.Accounts.get_user_by_email(email)
      assert email == added_user.email

      assert newhtml =~ "Vergib dem Nutzer eine Rolle um ihn dem Verein hinzuzufügen."
      assert newhtml =~ "Rollen von #{added_user.email}"
      assert newhtml =~ "im Verein #{club.name}"
      assert newhtml =~ "Zugewiesene Rollen"
      refute newhtml =~ "Entfernen"
      assert newhtml =~ "Verfügbare Rollen zur Zuweisung"
      assert newhtml =~ "Hinzufügen"
    end
  end
end
