defmodule Livechat.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :body, :string
    field :nickname, :string

    belongs_to :room, Livechat.Chat.Room

    timestamps(type: :utc_datetime)
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:body, :nickname, :room_id])
    |> validate_required([:body, :nickname, :room_id])
    |> validate_length(:body, min: 1, max: 2000)
    |> validate_length(:nickname, min: 1, max: 30)
    |> foreign_key_constraint(:room_id)
  end
end
