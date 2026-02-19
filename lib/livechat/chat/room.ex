defmodule Livechat.Chat.Room do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rooms" do
    field :name, :string
    field :description, :string, default: ""

    has_many :messages, Livechat.Chat.Message

    timestamps(type: :utc_datetime)
  end

  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 50)
    |> validate_length(:description, max: 200)
    |> unique_constraint(:name)
  end
end
