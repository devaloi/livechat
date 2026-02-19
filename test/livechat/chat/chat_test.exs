defmodule Livechat.ChatTest do
  use Livechat.DataCase

  alias Livechat.Chat

  describe "rooms" do
    test "list_rooms/0 returns all rooms sorted by name" do
      {:ok, _} = Chat.create_room(%{name: "beta"})
      {:ok, _} = Chat.create_room(%{name: "alpha"})

      rooms = Chat.list_rooms()
      assert [%{name: "alpha"}, %{name: "beta"}] = rooms
    end

    test "create_room/1 with valid data creates a room" do
      assert {:ok, room} = Chat.create_room(%{name: "general", description: "Main room"})
      assert room.name == "general"
      assert room.description == "Main room"
    end

    test "create_room/1 with duplicate name returns error" do
      {:ok, _} = Chat.create_room(%{name: "general"})
      assert {:error, changeset} = Chat.create_room(%{name: "general"})
      assert %{name: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_room/1 with missing name returns error" do
      assert {:error, changeset} = Chat.create_room(%{})
      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "get_room!/1 returns the room" do
      {:ok, room} = Chat.create_room(%{name: "test"})
      assert Chat.get_room!(room.id).id == room.id
    end

    test "get_room_by_name/1 returns room or nil" do
      {:ok, room} = Chat.create_room(%{name: "lobby"})
      assert Chat.get_room_by_name("lobby").id == room.id
      assert Chat.get_room_by_name("nonexistent") == nil
    end
  end

  describe "messages" do
    setup do
      {:ok, room} = Chat.create_room(%{name: "test-room"})
      %{room: room}
    end

    test "create_message/1 with valid data creates a message", %{room: room} do
      attrs = %{body: "Hello!", nickname: "alice", room_id: room.id}
      assert {:ok, message} = Chat.create_message(attrs)
      assert message.body == "Hello!"
      assert message.nickname == "alice"
      assert message.room_id == room.id
    end

    test "create_message/1 with missing body returns error", %{room: room} do
      attrs = %{nickname: "alice", room_id: room.id}
      assert {:error, changeset} = Chat.create_message(attrs)
      assert %{body: ["can't be blank"]} = errors_on(changeset)
    end

    test "list_messages/1 returns messages for a room in order", %{room: room} do
      {:ok, _} = Chat.create_message(%{body: "First", nickname: "alice", room_id: room.id})
      {:ok, _} = Chat.create_message(%{body: "Second", nickname: "bob", room_id: room.id})

      messages = Chat.list_messages(room.id)
      assert [%{body: "First"}, %{body: "Second"}] = messages
    end

    test "list_messages/2 respects limit", %{room: room} do
      for i <- 1..5 do
        Chat.create_message(%{body: "Msg #{i}", nickname: "alice", room_id: room.id})
      end

      assert length(Chat.list_messages(room.id, 3)) == 3
    end
  end
end
