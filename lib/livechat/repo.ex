defmodule Livechat.Repo do
  use Ecto.Repo,
    otp_app: :livechat,
    adapter: Ecto.Adapters.SQLite3
end
