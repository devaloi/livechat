defmodule Livechat.Presence do
  @moduledoc """
  Tracks which users are online in each chat room.
  """

  use Phoenix.Presence,
    otp_app: :livechat,
    pubsub_server: Livechat.PubSub
end
