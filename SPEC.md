# EX01: livechat — Real-Time Chat with Phoenix LiveView

**Catalog ID:** EX01 | **Size:** M | **Language:** Elixir 1.18 / Phoenix 1.7
**Repo name:** `livechat`
**One-liner:** A real-time chat application with Phoenix LiveView — chat rooms, presence tracking, typing indicators, message history, file uploads, message search, and zero custom JavaScript for all real-time features.

---

## Why This Stands Out

- **Zero JavaScript for real-time** — every interactive feature (messaging, presence, typing indicators, file uploads) is powered by LiveView over WebSocket, showcasing Elixir's killer feature
- **Phoenix Presence** — distributed, CRDT-based presence tracking for online users and typing indicators, demonstrating understanding of Elixir's distributed systems primitives
- **BEAM concurrency model** — each user connection is a lightweight process, chat rooms are GenServer processes, supervision trees manage fault tolerance — this is what makes Elixir special
- **GenServer rate limiter** — custom rate limiting implemented as a GenServer with token bucket algorithm, showing OTP design patterns beyond basic web development
- **LiveView uploads** — file and image sharing via LiveView's built-in upload system with progress tracking, image preview, and server-side validation — no JavaScript upload libraries
- **Message search** — full-text search across message history using SQLite FTS5, demonstrating database-level text search without external search engines
- **Supervision trees** — proper OTP application structure with supervisors for room registry, presence, and rate limiter processes — shows production Elixir thinking
- **phx_gen_auth** — Phoenix's built-in auth generator for secure registration, login, and session management — no third-party auth libraries

---

## Architecture

```
livechat/
├── lib/
│   ├── livechat/
│   │   ├── application.ex           # OTP application: supervision tree
│   │   ├── repo.ex                  # Ecto repo (SQLite)
│   │   ├── accounts/
│   │   │   ├── user.ex              # User schema: email, hashed_password, display_name, avatar_url
│   │   │   ├── user_token.ex        # Session tokens (phx_gen_auth)
│   │   │   └── accounts.ex          # Account context: register, login, get_user, update_profile
│   │   ├── chat/
│   │   │   ├── room.ex              # Room schema: name, description, slug, creator_id, is_private
│   │   │   ├── membership.ex        # Membership schema: user_id, room_id, role (admin/member), joined_at
│   │   │   ├── message.ex           # Message schema: body, user_id, room_id, attachment_url, inserted_at
│   │   │   └── chat.ex              # Chat context: rooms CRUD, messages, memberships, search
│   │   ├── rooms/
│   │   │   ├── registry.ex          # Room registry GenServer: track active rooms
│   │   │   └── server.ex            # Room GenServer: manage state, broadcast messages
│   │   └── rate_limiter.ex          # GenServer rate limiter: token bucket per user
│   ├── livechat_web/
│   │   ├── router.ex                # Routes: auth, room, live routes
│   │   ├── endpoint.ex              # Phoenix endpoint configuration
│   │   ├── channels/
│   │   │   ├── user_socket.ex       # Socket authentication
│   │   │   └── room_channel.ex      # Room channel for PubSub (backup for non-LiveView)
│   │   ├── presence.ex              # Phoenix Presence module
│   │   ├── live/
│   │   │   ├── room_live/
│   │   │   │   ├── index.ex         # Room list LiveView: browse, create, join
│   │   │   │   ├── show.ex          # Chat room LiveView: messages, input, presence sidebar
│   │   │   │   ├── form_component.ex  # Create/edit room form (LiveComponent)
│   │   │   │   └── message_component.ex  # Single message display (LiveComponent)
│   │   │   ├── search_live.ex       # Message search LiveView with live results
│   │   │   └── profile_live.ex      # User profile edit LiveView
│   │   ├── components/
│   │   │   ├── layouts.ex           # App and auth layouts
│   │   │   ├── core_components.ex   # Core UI components (Phoenix defaults + custom)
│   │   │   ├── chat_components.ex   # Chat-specific components: message bubble, room card, user badge
│   │   │   └── upload_components.ex # Upload preview, progress bar components
│   │   ├── user_auth.ex             # Auth plugs (phx_gen_auth generated)
│   │   ├── user_session_controller.ex  # Session controller (phx_gen_auth)
│   │   └── user_registration_controller.ex  # Registration controller (phx_gen_auth)
├── priv/
│   ├── repo/
│   │   └── migrations/              # Ecto migrations
│   └── static/
│       └── uploads/                 # Uploaded files directory
├── test/
│   ├── livechat/
│   │   ├── accounts_test.exs        # Account context tests
│   │   ├── chat_test.exs            # Chat context tests (rooms, messages, search)
│   │   ├── rate_limiter_test.exs    # Rate limiter GenServer tests
│   │   └── rooms/
│   │       ├── registry_test.exs    # Room registry tests
│   │       └── server_test.exs      # Room server tests
│   ├── livechat_web/
│   │   ├── live/
│   │   │   ├── room_live_test.exs   # Room list and chat LiveView tests
│   │   │   └── search_live_test.exs # Search LiveView tests
│   │   ├── presence_test.exs        # Presence tracking tests
│   │   └── controllers/
│   │       ├── user_session_controller_test.exs
│   │       └── user_registration_controller_test.exs
│   ├── support/
│   │   ├── conn_case.ex             # Test case for controller tests
│   │   ├── data_case.ex             # Test case for context tests
│   │   ├── fixtures.ex              # Test data factories
│   │   └── channel_case.ex          # Test case for channel tests
│   └── test_helper.exs
├── config/
│   ├── config.exs                   # Base configuration
│   ├── dev.exs                      # Development config (SQLite path, LiveReload)
│   ├── test.exs                     # Test config (async-safe SQLite)
│   ├── prod.exs                     # Production config
│   └── runtime.exs                  # Runtime secrets (env vars)
├── assets/
│   ├── css/
│   │   └── app.css                  # Tailwind CSS imports + custom styles
│   ├── js/
│   │   └── app.js                   # Phoenix LiveView JS hooks (minimal)
│   └── tailwind.config.js           # Tailwind configuration
├── mix.exs                          # Project deps and config
├── mix.lock
├── .formatter.exs                   # Elixir formatter config
├── .gitignore
├── LICENSE
└── README.md
```

---

## PubSub Topics

| Topic | Published Events | Subscribers |
|-------|-----------------|-------------|
| `room:{room_id}` | `new_message`, `message_deleted`, `user_typing`, `user_stopped_typing` | Room LiveView (show.ex) |
| `room:{room_id}:presence` | Presence diffs (joins, leaves) | Room LiveView presence sidebar |
| `rooms:lobby` | `room_created`, `room_updated`, `room_deleted` | Room list LiveView (index.ex) |
| `user:{user_id}` | `notification` (mentioned, invited) | User-specific LiveView hooks |

---

## Presence Tracking

```elixir
# Track user joining a room
Presence.track(self(), "room:#{room_id}:presence", user.id, %{
  display_name: user.display_name,
  avatar_url: user.avatar_url,
  typing: false,
  joined_at: DateTime.utc_now()
})

# Update typing status
Presence.update(self(), "room:#{room_id}:presence", user.id, fn meta ->
  Map.put(meta, :typing, true)
end)

# Get online users for a room
presences = Presence.list("room:#{room_id}:presence")
# => %{"user_1" => %{metas: [%{display_name: "Alice", typing: false}]}, ...}
```

---

## Room GenServer

```elixir
defmodule Livechat.Rooms.Server do
  use GenServer

  # State: %{room_id, recent_messages, member_count, created_at}

  def start_link(room_id), do: GenServer.start_link(__MODULE__, room_id, name: via(room_id))

  def broadcast_message(room_id, message), do: GenServer.cast(via(room_id), {:broadcast, message})
  def get_state(room_id), do: GenServer.call(via(room_id), :get_state)

  # Uses Registry for process naming: {:via, Registry, {Livechat.RoomRegistry, room_id}}
end
```

---

## Rate Limiter (GenServer)

```elixir
defmodule Livechat.RateLimiter do
  use GenServer

  # Token bucket per user
  # Config: max_tokens (10), refill_rate (1 per second), refill_interval (1000ms)

  def check_rate(user_id), do: GenServer.call(__MODULE__, {:check, user_id})
  # Returns :ok | {:error, :rate_limited, retry_after_ms}

  # Periodic refill via Process.send_after/3
  def handle_info(:refill, state), do: # add tokens to all buckets, schedule next refill
end
```

---

## LiveView Upload Config

```elixir
# In show.ex LiveView
@impl true
def mount(_params, _session, socket) do
  {:ok,
   socket
   |> allow_upload(:attachment,
     accept: ~w(.jpg .jpeg .png .gif .webp .pdf .txt),
     max_entries: 3,
     max_file_size: 10_000_000,  # 10 MB
     auto_upload: true
   )}
end

# Upload progress and preview handled entirely by LiveView — zero JS
```

---

## Message Search (SQLite FTS5)

```sql
-- Migration: Create FTS5 virtual table
CREATE VIRTUAL TABLE messages_fts USING fts5(
  body,
  content='messages',
  content_rowid='id'
);

-- Triggers to keep FTS index in sync
CREATE TRIGGER messages_ai AFTER INSERT ON messages BEGIN
  INSERT INTO messages_fts(rowid, body) VALUES (new.id, new.body);
END;
```

```elixir
# In chat.ex context
def search_messages(room_id, query) do
  Repo.all(
    from m in Message,
      join: fts in fragment("messages_fts"),
      on: m.id == fts.rowid,
      where: m.room_id == ^room_id and fragment("messages_fts MATCH ?", ^query),
      order_by: [desc: fragment("rank")],
      limit: 50,
      preload: [:user]
  )
end
```

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Language | Elixir 1.18 |
| Framework | Phoenix 1.7 |
| Real-time | Phoenix LiveView 1.0 |
| Presence | Phoenix Presence (CRDT-based) |
| ORM | Ecto 3.12 |
| Database | SQLite via Ecto SQLite3 |
| Search | SQLite FTS5 (full-text search) |
| Auth | phx_gen_auth (built-in generator) |
| CSS | Tailwind CSS (built-in with Phoenix 1.7) |
| Uploads | LiveView uploads (built-in) |
| Process Management | GenServer, Registry, Supervisor |
| Testing | ExUnit (built-in) |
| Formatting | mix format |

---

## Phased Build Plan

### Phase 1: Foundation

**1.1 — Project setup**
- `mix phx.new livechat --database sqlite3`
- Verify Phoenix 1.7 with LiveView, Tailwind, and esbuild
- Configure `config/dev.exs` and `config/test.exs` for SQLite
- Verify `mix test` passes on fresh scaffold

**1.2 — Authentication**
- Run `mix phx.gen.auth Accounts User users`
- Adds: User schema, user_token, registration/login controllers, auth plugs
- Add `display_name` and `avatar_url` fields to User schema
- Migration for user table + tokens
- Tests: registration, login, logout, session management (generated + custom)

**1.3 — Chat schemas + context**
- `Room` schema: name, description, slug (unique), creator_id (FK→User), is_private
- `Membership` schema: user_id, room_id, role (admin/member), joined_at
- `Message` schema: body, user_id (FK→User), room_id (FK→Room), attachment_url, inserted_at
- `Chat` context: create_room, list_rooms, get_room, join_room, leave_room, create_message, list_messages
- Migrations for all tables
- Tests: CRUD for rooms, memberships, messages; context functions

**1.4 — Message search (FTS5)**
- Migration: create `messages_fts` virtual table with triggers
- `Chat.search_messages(room_id, query)` using FTS5 MATCH
- Tests: insert messages, search by keyword, ranking works

### Phase 2: LiveView Chat

**2.1 — Room list LiveView**
- `RoomLive.Index`: list all rooms, show member counts, join buttons
- Create room: modal with `FormComponent` LiveComponent
- PubSub: subscribe to `rooms:lobby`, update list on room_created/updated/deleted
- Tests: renders room list, create room via form, real-time update on PubSub

**2.2 — Chat room LiveView**
- `RoomLive.Show`: message list, message input, send on Enter
- Load last 50 messages on mount, infinite scroll for history (load more on scroll up)
- New messages: broadcast via PubSub `room:{room_id}`, prepend to list
- `MessageComponent`: avatar, display name, timestamp, message body, attachment preview
- Rate limiting: check `RateLimiter.check_rate(user_id)` before creating message
- Tests: renders messages, send message appears, rate limit blocks rapid messages

**2.3 — Presence sidebar**
- Track user join/leave via `Presence.track` on mount/unmount
- Sidebar: list online users with avatar and display name
- Subscribe to presence diffs, update sidebar reactively
- Tests: user appears on join, disappears on leave

**2.4 — Typing indicators**
- On keydown in message input: `Presence.update` with `typing: true`
- Debounce: clear typing after 2 seconds of inactivity (`:clear_typing` timer)
- Display "Alice is typing..." below message list for users with `typing: true`
- Tests: typing shows indicator, stops after timeout

### Phase 3: Uploads + OTP Patterns

**3.1 — File uploads**
- LiveView `allow_upload` in chat room: images + documents
- Upload preview: thumbnail for images, file icon for documents
- Progress bar via LiveView upload progress tracking
- Save to `priv/static/uploads/` with unique filenames
- Store `attachment_url` in message record
- Display: inline image preview or download link in MessageComponent
- Tests: upload file, message has attachment, preview renders

**3.2 — Room GenServer**
- `Rooms.Server` GenServer per active room: hold recent message cache, member count
- `Rooms.Registry` via Elixir `Registry`: lookup room server by room_id
- `DynamicSupervisor` to start/stop room servers on demand
- Room server starts when first user joins, stops after idle timeout
- Tests: start/stop server, broadcast message, idle shutdown

**3.3 — Rate limiter GenServer**
- `RateLimiter` GenServer: token bucket per user_id
- Config: 10 messages per 10 seconds per user
- `check_rate(user_id)` → `:ok` or `{:error, :rate_limited, retry_after_ms}`
- Periodic token refill via `Process.send_after`
- Tests: allows burst, blocks after limit, refills over time

**3.4 — Supervision tree**
- Application supervisor starts: Repo, PubSub, Presence, Endpoint, RateLimiter, RoomRegistry, RoomSupervisor
- One-for-one strategy for independent processes
- Room DynamicSupervisor for room servers
- Tests: application starts cleanly, processes registered

### Phase 4: Polish + Search + Testing

**4.1 — Message search LiveView**
- `SearchLive`: search input with live results (debounced, updates as you type)
- Scoped to current room or global (with room name in results)
- FTS5 ranking for result ordering
- Highlight matching terms in results
- Click result → navigate to room with message highlighted
- Tests: search returns results, scoping works, no results shown

**4.2 — User profile LiveView**
- `ProfileLive`: edit display_name, avatar_url
- Avatar upload via LiveView uploads
- Tests: update profile, avatar upload works

**4.3 — Chat components**
- `chat_components.ex`: message_bubble (with variants for own vs other), room_card, user_badge, online_indicator
- `upload_components.ex`: upload_preview, progress_bar, file_icon
- Responsive design: mobile-friendly chat layout, collapsible sidebar
- Tests: components render with various props

**4.4 — Comprehensive ExUnit tests**
- Context tests: Accounts, Chat (CRUD, search, memberships)
- LiveView tests: room list, chat room, presence, typing, uploads, search
- GenServer tests: rate limiter, room server, registry
- Controller tests: auth flows (generated + custom)
- Minimum coverage: all happy paths + key error paths

**4.5 — README and documentation**
- Badges, install, quick start (3 commands: deps, migrate, server)
- Screenshots (placeholder)
- Architecture overview: LiveView, PubSub, Presence, GenServer
- OTP supervision tree diagram
- Features list with "zero JavaScript" emphasis
- Development commands (test, format, routes)
- Deployment notes

---

## Commit Plan

1. `chore: scaffold Phoenix project with LiveView and SQLite`
2. `feat: add user authentication with phx_gen_auth`
3. `feat: add Room, Membership, and Message schemas with context`
4. `feat: add FTS5 message search with SQLite`
5. `feat: add room list LiveView with create form`
6. `feat: add chat room LiveView with real-time messaging`
7. `feat: add Presence tracking with online user sidebar`
8. `feat: add typing indicators via Presence updates`
9. `feat: add file uploads with LiveView upload system`
10. `feat: add Room GenServer with Registry and DynamicSupervisor`
11. `feat: add rate limiter GenServer with token bucket`
12. `feat: add OTP supervision tree for all processes`
13. `feat: add message search LiveView with live results`
14. `feat: add user profile LiveView with avatar upload`
15. `feat: add chat and upload UI components`
16. `test: add comprehensive ExUnit tests for contexts and LiveViews`
17. `docs: add README with architecture, features, and setup guide`
