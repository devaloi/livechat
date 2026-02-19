defmodule LivechatWeb.PageControllerTest do
  use LivechatWeb.ConnCase

  test "GET / renders the lobby", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "LiveChat"
  end
end
