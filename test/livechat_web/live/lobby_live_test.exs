defmodule LivechatWeb.LobbyLiveTest do
  use LivechatWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders nickname form when no nickname in session", %{conn: conn} do
    {:ok, view, html} = live(conn, ~p"/")
    assert html =~ "Choose a Nickname"
    assert has_element?(view, "input[name='nickname']")
  end

  test "shows rooms list after setting nickname", %{conn: conn} do
    conn = conn |> init_test_session(%{"nickname" => "alice"})
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "Chatting as: alice"
    assert html =~ "Create a Room"
  end

  test "creates a room and displays it", %{conn: conn} do
    conn = conn |> init_test_session(%{"nickname" => "alice"})
    {:ok, view, _html} = live(conn, ~p"/")

    view
    |> form("form", room: %{name: "general"})
    |> render_submit()

    assert render(view) =~ "# general"
  end

  test "shows error for duplicate room name", %{conn: conn} do
    {:ok, _} = Livechat.Chat.create_room(%{name: "general"})
    conn = conn |> init_test_session(%{"nickname" => "alice"})
    {:ok, view, _html} = live(conn, ~p"/")

    html =
      view
      |> form("form", room: %{name: "general"})
      |> render_submit()

    assert html =~ "has already been taken"
  end
end
