# LiveChat

[![CI](https://github.com/devaloi/livechat/actions/workflows/ci.yml/badge.svg)](https://github.com/devaloi/livechat/actions/workflows/ci.yml)

Real-time chat application built with Elixir, Phoenix LiveView, and SQLite. Features instant messaging via WebSockets, chat room management, and live presence tracking — no JavaScript framework required.

## Features

- **Real-time messaging** — Messages appear instantly for all participants via Phoenix PubSub
- **Chat rooms** — Create and join named rooms with descriptions
- **Presence tracking** — See who's online in each room, updated in real-time
- **Nickname-based identity** — Simple session-based nicknames, no signup required
- **Zero-JS UI updates** — Phoenix LiveView handles all real-time DOM updates over WebSockets

## Architecture

```
┌─────────────────────────────────────────────────┐
│                   Browser                        │
│  LiveView WebSocket ←→ Phoenix LiveView Server   │
└─────────────┬───────────────────┬───────────────┘
              │                   │
       ┌──────▼──────┐    ┌──────▼──────┐
       │   PubSub    │    │  Presence   │
       │ (messages)  │    │  (online)   │
       └──────┬──────┘    └─────────────┘
              │
       ┌──────▼──────┐
       │   SQLite    │
       │  (Ecto)     │
       └─────────────┘
```

| Component | Technology |
|-----------|-----------|
| Language | Elixir 1.19+ / Erlang OTP 28 |
| Web framework | Phoenix 1.8.3 |
| Real-time UI | Phoenix LiveView 1.1 |
| Database | SQLite via ecto_sqlite3 |
| Presence | Phoenix Presence (CRDT-based) |
| CSS | Tailwind CSS + DaisyUI |

## Prerequisites

- Elixir 1.15+ with Erlang/OTP 26+
- SQLite3

## Getting Started

```bash
# Clone and setup
git clone https://github.com/devaloi/livechat.git
cd livechat
mix setup

# Start the server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) in your browser.

## Usage

1. **Enter a nickname** on the landing page
2. **Create a room** or join an existing one
3. **Chat** — messages appear in real-time for all participants
4. **See who's online** in the sidebar presence panel

Open multiple browser tabs to see real-time features in action.

## Running Tests

```bash
mix test
```

Verify clean compilation:

```bash
mix compile --warnings-as-errors
```

## Project Structure

```
livechat/
├── lib/
│   ├── livechat/
│   │   ├── chat.ex                 # Chat context (rooms, messages, PubSub)
│   │   ├── chat/
│   │   │   ├── room.ex            # Room schema
│   │   │   └── message.ex         # Message schema
│   │   ├── presence.ex            # Phoenix Presence for online tracking
│   │   └── repo.ex                # Ecto repo (SQLite)
│   └── livechat_web/
│       ├── live/
│       │   ├── lobby_live.ex      # Lobby: nickname + room list
│       │   └── chat_room_live.ex  # Chat room: messages + presence
│       ├── hooks/
│       │   └── nickname_hook.ex   # LiveView session hook
│       └── router.ex              # Routes
├── priv/repo/migrations/          # Database migrations
├── test/                          # Test suite
├── assets/                        # JS + CSS
└── config/                        # Environment configs
```

## License

MIT
