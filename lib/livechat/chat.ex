defmodule Livechat.Chat do
  @moduledoc """
  Context for chat rooms and messages.
  """

  import Ecto.Query
  alias Livechat.Repo
  alias Livechat.Chat.{Room, Message}

  # Rooms

  def list_rooms do
    Repo.all(from r in Room, order_by: [asc: r.name])
  end

  def get_room!(id), do: Repo.get!(Room, id)

  def get_room_by_name(name), do: Repo.get_by(Room, name: name)

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  # Messages

  def list_messages(room_id, limit \\ 50) do
    from(m in Message,
      where: m.room_id == ^room_id,
      order_by: [asc: m.inserted_at, asc: m.id],
      limit: ^limit
    )
    |> Repo.all()
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  # PubSub

  @pubsub Livechat.PubSub

  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(@pubsub, topic(room_id))
  end

  def broadcast_message(room_id, message) do
    Phoenix.PubSub.broadcast(@pubsub, topic(room_id), {:new_message, message})
  end

  defp topic(room_id), do: "room:#{room_id}"
end
