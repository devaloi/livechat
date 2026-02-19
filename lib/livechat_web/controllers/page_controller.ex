defmodule LivechatWeb.PageController do
  use LivechatWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
