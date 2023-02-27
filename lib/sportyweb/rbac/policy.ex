defmodule Sportyweb.RBAC.Policy do
  use SportywebWeb, :verified_routes

  alias Sportyweb.Organization

  alias Sportyweb.RBAC.UserRole
  alias Sportyweb.RBAC.Role.RolePermissionMatrix, as: RPM

  def on_mount(:permissions, params, _session, socket) do
    action = socket.assigns.live_action
    view = get_live_view(socket.view)

    if is_application_admin_or_tester(socket.assigns.current_user) || permit?(socket.assigns.current_user, action, view, params) do
      {:cont,
        socket
        |> Phoenix.LiveView.attach_hook(:load_associated_clubs, :handle_params, &load_associated_clubs/3)}
    else
      {:halt,
        socket
        |> Phoenix.LiveView.put_flash(:error, "Zugriff verweigert.")
        |> Phoenix.LiveView.push_navigate(to: error_redirect(action, view, params))}
    end
  end

  def is_application_admin_or_tester(user) do
    user
    |> UserRole.list_users_applicationroles()
    |> Enum.map(&(&1.applicationrole.name))
    |> Enum.map(&(RPM.to_role_atom(:application, &1)))
    |> Enum.map(&(Enum.member?([:admin, :tester], &1)))
    |> Enum.member?(true)
  end

  def permit?(_user, :index, :ClubLive, _params), do: true
  def permit?(_user, :new, :ClubLive, _params), do: false
  def permit?(user, action, :ClubLive = view, %{"id" => club_id}), do: is_allowed?(user.id, action, club_id, view)

  def permit?(user, action, :DepartmentLive = view, params) do
    club_id = if Map.has_key?(params, "club_id"), do: params["club_id"], else: params["id"] |> Organization.get_department!() |> Map.get(:club_id)
    dept_id = if Map.has_key?(params, "id"), do: params["id"], else: nil
    is_allowed?(user.id, action, club_id, view, dept_id)
  end

  def permit?(user, action, :RoleLive = view, %{"club_id" => club_id}), do: is_allowed?(user.id, action, club_id, view)

  def permit?(_user, _action, _view, _params), do: false


  defp get_live_view(view), do: view |> Kernel.inspect() |> String.split(".") |> Enum.at(1) |> String.to_atom()

  defp is_allowed?(user_id, action, club_id, view, dept_id \\ nil) do
    user_roles = list_users_roles_in_club(user_id, club_id, dept_id)
    is_associated_to_club = length(user_roles) > 0
    is_associated_to_department = [] |> maybe_add_department_roles(user_id, club_id, dept_id) |> length() > 0

    permissions = [:club, :department] |> Enum.map(&(RPM.role_permission_matrix(&1))) |> List.flatten()

    user_roles
    |> Enum.reduce([], fn role, acc -> acc ++ Keyword.get_values(permissions, role) end)
    |> Enum.map(&(Map.get(&1, view)))
    |> RPM.basic_permissions_when_associated_to_club(is_associated_to_club, view)
    |> RPM.basic_permissions_when_associated_to_department(is_associated_to_department, view)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.member?(action)
  end

  defp list_users_roles_in_club(user_id, club_id, dept_id) do
    user_id
    |> get_users_club_roles(club_id)
    |> maybe_add_department_roles(user_id, club_id, dept_id)
  end

  defp get_users_club_roles(user_id, club_id) do
    user_id
    |> UserRole.list_users_clubroles_in_a_club(club_id)
    |> Enum.map(&(&1.clubrole.name))
    |> Enum.map(&(RPM.to_role_atom(:club, &1)))
  end

  defp maybe_add_department_roles(current_roles, user_id, club_id, nil) do
    club_id
    |> Organization.list_departments()
    |> Enum.map(&(UserRole.list_users_departmentroles_in_a_department(user_id, &1.id)))
    |> List.flatten()
    |> Enum.map(&(&1.departmentrole.name))
    |> Enum.uniq()
    |> Enum.map(&(RPM.to_role_atom(:department, &1)))
    |> Kernel.++(current_roles)
  end

  defp maybe_add_department_roles(current_roles, user_id, _club_id, dept_id) do
    user_id
    |> UserRole.list_users_departmentroles_in_a_department(dept_id)
    |> Enum.map(&(&1.departmentrole.name))
    |> Enum.map(&(RPM.to_role_atom(:department, &1)))
    |> Kernel.++(current_roles)
  end

  defp load_associated_clubs(_params, _url, socket) do
    socket = if get_live_view(socket.view) == :ClubLive
                && socket.assigns.live_action == :index
                && is_application_admin_or_tester(socket.assigns.current_user) == false
    do
      socket
      |> Phoenix.Component.assign(:clubs, socket.assigns.clubs
        |> Enum.reduce([], &(if user_associated_with_club?(socket.assigns.current_user, &1),
          do: &2 ++ [&1],
          else: &2)))
    else
      socket
    end

    {:cont, socket}
  end

  defp user_associated_with_club?(user, club) do
    user.id
    |> list_users_roles_in_club(club.id, nil)
    |> length()
    |> Kernel.>(0)
  end

  defp error_redirect(action, :ClubLive, _params) when action in [:new, :edit, :show], do: ~p"/clubs"
  defp error_redirect(_action, :ClubLive, %{"id" => club_id}), do: ~p"/clubs/#{club_id}"
  defp error_redirect(_action, :DepartmentLive, %{"club_id" => club_id}), do: ~p"/clubs/#{club_id}"
  defp error_redirect(_action, :DepartmentLive, %{"id" => dept_id}), do: ~p"/clubs/#{dept_id |> Organization.get_department!() |> Map.get(:club_id)}"
  defp error_redirect(_action, :RoleLive, %{"club_id" => club_id}), do: ~p"/clubs/#{club_id}"
  defp error_redirect(_action, _view, _params), do: ~p"/clubs"
end
