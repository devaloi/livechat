defmodule LivechatWeb.NicknameController do
  use LivechatWeb, :controller

  def set(conn, %{"nickname" => nickname}) do
    conn
    |> put_session(:nickname, nickname)
    |> json(%{ok: true})
  end
end
