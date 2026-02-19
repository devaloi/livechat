defmodule LivechatWeb.ChatRoomLive do
  use LivechatWeb, :live_view

  alias Livechat.Chat

  @impl true
  def mount(%{"id" => id}, session, socket) do
    nickname = Map.get(session, "nickname")

    if is_nil(nickname) do
      {:ok, push_navigate(socket, to: ~p"/")}
    else
      room = Chat.get_room!(id)
      messages = Chat.list_messages(room.id)

      if connected?(socket) do
        Chat.subscribe(room.id)
      end

      {:ok,
       socket
       |> assign(:room, room)
       |> assign(:nickname, nickname)
       |> assign(:messages, messages)
       |> assign(:message_form, to_form(%{"body" => ""}))}
    end
  end

  @impl true
  def handle_event("send_message", %{"body" => body}, socket) do
    body = String.trim(body)

    if body != "" do
      attrs = %{
        body: body,
        nickname: socket.assigns.nickname,
        room_id: socket.assigns.room.id
      }

      case Chat.create_message(attrs) do
        {:ok, message} ->
          Chat.broadcast_message(socket.assigns.room.id, message)
          {:noreply, assign(socket, :message_form, to_form(%{"body" => ""}))}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to send message.")}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    {:noreply, assign(socket, :messages, socket.assigns.messages ++ [message])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex flex-col h-[calc(100vh-12rem)]">
        <div class="flex items-center justify-between mb-4">
          <div class="flex items-center gap-2">
            <.link navigate={~p"/"} class="btn btn-ghost btn-sm">← Back</.link>
            <h1 class="text-xl font-bold"># {@room.name}</h1>
          </div>
          <span class="badge badge-primary">{@nickname}</span>
        </div>

        <div
          id="messages"
          phx-hook="ScrollBottom"
          class="flex-1 overflow-y-auto space-y-2 p-4 bg-base-200 rounded-box"
        >
          <%= if @messages == [] do %>
            <p class="text-center text-base-content/60 py-8">
              No messages yet. Start the conversation!
            </p>
          <% end %>
          <%= for message <- @messages do %>
            <div id={"msg-#{message.id}"} class={[
              "chat",
              if(message.nickname == @nickname, do: "chat-end", else: "chat-start")
            ]}>
              <div class="chat-header text-xs opacity-70 mb-1">
                {message.nickname}
                <time class="text-xs opacity-50">
                  {Calendar.strftime(message.inserted_at, "%H:%M")}
                </time>
              </div>
              <div class={[
                "chat-bubble",
                if(message.nickname == @nickname, do: "chat-bubble-primary", else: "")
              ]}>
                {message.body}
              </div>
            </div>
          <% end %>
        </div>

        <form phx-submit="send_message" class="flex gap-2 mt-4">
          <input
            type="text"
            name="body"
            value={@message_form[:body].value}
            placeholder="Type a message..."
            class="input input-bordered flex-1"
            autocomplete="off"
            autofocus
          />
          <button type="submit" class="btn btn-primary">Send</button>
        </form>
      </div>
    </Layouts.app>
    """
  end
end
