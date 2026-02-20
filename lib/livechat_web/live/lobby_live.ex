defmodule LivechatWeb.LobbyLive do
  use LivechatWeb, :live_view

  alias Livechat.Chat

  @impl true
  def mount(_params, session, socket) do
    nickname = Map.get(session, "nickname")
    rooms = Chat.list_rooms()

    {:ok,
     socket
     |> assign(:nickname, nickname)
     |> assign(:rooms, rooms)
     |> assign(:room_form, to_form(Chat.change_room(%Chat.Room{})))}
  end

  @impl true
  def handle_event("set_nickname", %{"nickname" => nickname}, socket) do
    nickname = String.trim(nickname)

    if String.length(nickname) > 0 and String.length(nickname) <= 30 do
      {:noreply,
       socket
       |> assign(:nickname, nickname)
       |> push_event("store_nickname", %{nickname: nickname})}
    else
      {:noreply, put_flash(socket, :error, "Nickname must be 1-30 characters.")}
    end
  end

  def handle_event("create_room", %{"room" => room_params}, socket) do
    case Chat.create_room(room_params) do
      {:ok, _room} ->
        {:noreply,
         socket
         |> assign(:rooms, Chat.list_rooms())
         |> assign(:room_form, to_form(Chat.change_room(%Chat.Room{})))}

      {:error, changeset} ->
        {:noreply, assign(socket, :room_form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="max-w-xl mx-auto">
        <h1 class="text-3xl font-bold text-center mb-8">💬 LiveChat</h1>

        <%= if @nickname do %>
          <div class="mb-6 text-center">
            <span class="badge badge-primary badge-lg">Chatting as: {@nickname}</span>
          </div>

          <div class="card bg-base-200 shadow mb-6">
            <div class="card-body">
              <h2 class="card-title">Create a Room</h2>
              <.form for={@room_form} phx-submit="create_room" class="flex gap-2 flex-wrap">
                <div class="flex gap-2 flex-1">
                  <input
                    type="text"
                    name="room[name]"
                    value={@room_form[:name].value}
                    placeholder="Room name"
                    class="input input-bordered flex-1"
                    required
                    maxlength="50"
                  />
                  <button type="submit" class="btn btn-primary">Create</button>
                </div>
                <%= for {msg, _} <- @room_form[:name].errors do %>
                  <p class="text-error text-sm w-full">{msg}</p>
                <% end %>
              </.form>
            </div>
          </div>

          <div class="space-y-2">
            <h2 class="text-xl font-semibold">Rooms</h2>
            <%= if @rooms == [] do %>
              <p class="text-base-content/60">No rooms yet. Create one above!</p>
            <% else %>
              <%= for room <- @rooms do %>
                <.link
                  navigate={~p"/rooms/#{room.id}"}
                  class="card bg-base-200 shadow hover:shadow-md transition-shadow cursor-pointer block"
                >
                  <div class="card-body py-3">
                    <div class="flex justify-between items-center">
                      <span class="font-medium"># {room.name}</span>
                      <span class="text-sm text-base-content/60">{room.description}</span>
                    </div>
                  </div>
                </.link>
              <% end %>
            <% end %>
          </div>
        <% else %>
          <div class="card bg-base-200 shadow">
            <div class="card-body items-center text-center">
              <h2 class="card-title">Choose a Nickname</h2>
              <form
                phx-submit="set_nickname"
                phx-hook="StoreNickname"
                id="nickname-form"
                class="flex gap-2 w-full max-w-xs"
              >
                <input
                  type="text"
                  name="nickname"
                  placeholder="Your nickname"
                  class="input input-bordered flex-1"
                  required
                  maxlength="30"
                  autofocus
                />
                <button type="submit" class="btn btn-primary">Join</button>
              </form>
            </div>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
