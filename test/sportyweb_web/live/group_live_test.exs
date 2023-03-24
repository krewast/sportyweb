defmodule SportywebWeb.GroupLiveTest do
  use SportywebWeb.ConnCase

  import Phoenix.LiveViewTest
  import Sportyweb.AccountsFixtures
  import Sportyweb.OrganizationFixtures

  @create_attrs %{name: "some name", reference_number: "some reference_number", description: "some description", created_at: ~D[2022-11-05]}
  @update_attrs %{name: "some updated name", reference_number: "some updated reference_number", description: "some updated description", created_at: ~D[2022-11-06]}
  @invalid_attrs %{name: nil, reference_number: nil, description: nil, created_at: nil}

  setup do
    %{user: user_fixture()}
  end

  defp create_group(_) do
    group = group_fixture()
    %{group: group}
  end

  describe "Index" do
    setup [:create_group]

    test "lists all groups - default redirect", %{conn: conn, user: user} do
      {:error, _} = live(conn, ~p"/groups")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/groups")
        |> follow_redirect(conn, ~p"/clubs")

      assert conn.resp_body =~ "Vereinsübersicht"
    end

    test "lists all groups - redirect", %{conn: conn, user: user, group: group} do
      {:error, _} = live(conn, ~p"/departments/#{group.department_id}/groups")

      conn = conn |> log_in_user(user)
      {:ok, conn} =
        conn
        |> live(~p"/departments/#{group.department_id}/groups")
        |> follow_redirect(conn, ~p"/departments/#{group.department_id}")

      assert conn.resp_body =~ "Abteilung:"
    end
  end

  describe "New/Edit" do
    setup [:create_group]

    test "saves new group", %{conn: conn, user: user} do
      department = department_fixture()

      {:error, _} = live(conn, ~p"/departments/#{department}/groups/new")

      conn = conn |> log_in_user(user)
      {:ok, new_live, html} = live(conn, ~p"/departments/#{department}/groups/new")

      assert html =~ "Gruppe erstellen"

      assert new_live
              |> form("#group-form", group: @invalid_attrs)
              |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        new_live
        |> form("#group-form", group: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/departments/#{department}")

      assert html =~ "Gruppe erfolgreich erstellt"
      assert html =~ "some name"
    end

    test "cancels save new group", %{conn: conn, user: user} do
      department = department_fixture()

      conn = conn |> log_in_user(user)
      {:ok, new_live, _html} = live(conn, ~p"/departments/#{department}/groups/new")

      {:ok, _, _html} =
        new_live
        |> element("#group-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/departments/#{department}")
    end

    test "updates group", %{conn: conn, user: user, group: group} do
      {:error, _} = live(conn, ~p"/groups/#{group}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/groups/#{group}/edit")

      assert html =~ "Gruppe bearbeiten"

      assert edit_live
             |> form("#group-form", group: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#group-form", group: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/groups/#{group}")

      assert html =~ "Gruppe erfolgreich aktualisiert"
      assert html =~ "some updated name"
    end

    test "cancels updates group", %{conn: conn, user: user, group: group} do
      conn = conn |> log_in_user(user)
      {:ok, edit_live, _html} = live(conn, ~p"/groups/#{group}/edit")

      {:ok, _, _html} =
        edit_live
        |> element("#group-form a", "Abbrechen")
        |> render_click()
        |> follow_redirect(conn, ~p"/groups/#{group}")
    end

    test "deletes group", %{conn: conn, user: user, group: group} do
      {:error, _} = live(conn, ~p"/groups/#{group}/edit")

      conn = conn |> log_in_user(user)
      {:ok, edit_live, html} = live(conn, ~p"/groups/#{group}/edit")
      assert html =~ "some group name"

      {:ok, _, html} =
        edit_live
        |> element("#group-form button", "Löschen")
        |> render_click()
        |> follow_redirect(conn, ~p"/departments/#{group.department_id}")

      assert html =~ "Gruppe erfolgreich gelöscht"
      assert html =~ "Gruppen"
      refute html =~ "some group name"
    end
  end

  describe "Show" do
    setup [:create_group]

    test "displays group", %{conn: conn, user: user, group: group} do
      {:error, _} = live(conn, ~p"/groups/#{group}")

      conn = conn |> log_in_user(user)
      {:ok, _show_live, html} = live(conn, ~p"/groups/#{group}")

      assert html =~ "Gruppe:"
      assert html =~ group.name
    end
  end
end