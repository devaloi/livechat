# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias Livechat.Chat

unless Chat.get_room_by_name("general") do
  Chat.create_room(%{name: "general", description: "General discussion"})
end

unless Chat.get_room_by_name("random") do
  Chat.create_room(%{name: "random", description: "Off-topic conversations"})
end
