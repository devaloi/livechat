defmodule LivechatWeb.ChatRoomLiveTest do
  use LivechatWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Livechat.Chat

  setup do
    {:ok, room} = Chat.create_room(%{name: "test-room"})
    %{room: room}
  end

  test "redirects to lobby when no nickname", %{conn: conn, room: room} do
    {:ok, _view, _html} = live(conn, ~p"/rooms/#{room.id}") |> follow_redirect(conn, ~p"/")
  end

  test "renders chat room with nickname", %{conn: conn, room: room} do
    conn = conn |> init_test_session(%{"nickname" => "alice"})
    {:ok, _view, html} = live(conn, ~p"/rooms/#{room.id}")
    assert html =~ "# test-room"
    assert html =~ "alice"
    assert html =~ "No messages yet"
    assert html =~ "Online"
  end

  test "sends and displays a message", %{conn: conn, room: room} do
    conn = conn |> init_test_session(%{"nickname" => "alice"})
    {:ok, view, _html} = live(conn, ~p"/rooms/#{room.id}")

    view
    |> form("form", %{body: "Hello everyone!"})
    |> render_submit()

    assert render(view) =~ "Hello everyone!"
  end

  test "receives broadcast messages", %{conn: conn, room: room} do
    conn = conn |> init_test_session(%{"nickname" => "alice"})
    {:ok, view, _html} = live(conn, ~p"/rooms/#{room.id}")

    {:ok, message} =
      Chat.create_message(%{body: "Hi from Bob!", nickname: "bob", room_id: room.id})

    Chat.broadcast_message(room.id, message)

    assert render(view) =~ "Hi from Bob!"
    assert render(view) =~ "bob"
  end
end
