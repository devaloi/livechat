defmodule LivechatWeb.Hooks.NicknameHook do
  @moduledoc """
  LiveView hook that loads the nickname from the session into assigns.
  """

  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    nickname = Map.get(session, "nickname")
    {:cont, assign(socket, :nickname, nickname)}
  end
end
