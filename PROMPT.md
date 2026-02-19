# Build livechat — Real-Time Chat with Phoenix LiveView

You are building a **portfolio project** for a Senior AI Engineer's public GitHub. It must be impressive, clean, and production-grade. Read these docs before writing any code:

1. **`EX01-elixir-phoenix-livechat.md`** — Complete project spec: architecture, PubSub topics, Presence tracking, Room GenServer, rate limiter GenServer, LiveView uploads, FTS5 search, supervision tree, phased build plan, commit plan. This is your primary blueprint. Follow it phase by phase.
2. **`github-portfolio.md`** — Portfolio goals and Definition of Done (Level 1 + Level 2). Understand the quality bar.
3. **`github-portfolio-checklist.md`** — Pre-publish checklist. Every item must pass before you're done.

---

## Instructions

### Read first, build second
Read all three docs completely before writing a single line of code. Understand the BEAM concurrency model: each user connection is a process, chat rooms are GenServer processes managed by a DynamicSupervisor, Presence is a CRDT-based distributed tracker. Understand how LiveView replaces JavaScript for real-time features, how PubSub broadcasts messages across processes, and how the supervision tree provides fault tolerance.

### Follow the phases in order
The project spec has 4 phases. Do them in order:
1. **Foundation** — project scaffold, phx_gen_auth authentication, Room/Membership/Message schemas and context, FTS5 message search
2. **LiveView Chat** — room list LiveView, chat room LiveView with real-time messaging, Presence sidebar for online users, typing indicators
3. **Uploads + OTP Patterns** — file uploads via LiveView, Room GenServer with Registry and DynamicSupervisor, rate limiter GenServer with token bucket, supervision tree
4. **Polish + Search + Testing** — message search LiveView with live results, user profile LiveView, chat UI components, comprehensive ExUnit tests, README

### Commit frequently
Follow the commit plan in the spec. Use **conventional commits** (`feat:`, `test:`, `docs:`, `chore:`). Each commit should be a logical unit.

### Quality non-negotiables
- **Zero custom JavaScript.** All real-time features — messaging, presence, typing indicators, file uploads, search — must use LiveView. The only JS should be the Phoenix LiveView hooks boilerplate in `app.js`. No React, no Alpine, no jQuery.
- **Phoenix Presence.** Use `Phoenix.Presence` for online user tracking and typing indicators. Track on mount, update on typing, handle presence diffs for UI updates. Presence is CRDT-based and distributed — use it properly.
- **GenServer patterns.** Room server and rate limiter are proper GenServer modules with `init`, `handle_call`, `handle_cast`, `handle_info`. Use `Registry` for room process naming. Use `DynamicSupervisor` to manage room server lifecycle. This shows real OTP knowledge.
- **PubSub for everything.** New messages broadcast on `room:{id}`. Room changes broadcast on `rooms:lobby`. Presence tracks on `room:{id}:presence`. LiveViews subscribe on mount and handle messages reactively.
- **FTS5 search.** Full-text search via SQLite FTS5 virtual table with triggers to keep the index in sync. No external search engine. The search LiveView updates results as the user types (debounced).
- **LiveView uploads.** Use `allow_upload` in the chat LiveView with accept filters, max size, and auto_upload. Show upload preview and progress bar. Store files in `priv/static/uploads/`. Display inline in messages.
- **phx_gen_auth.** Use Phoenix's built-in auth generator — don't build auth from scratch or use a third-party library. Extend with display_name and avatar_url fields.
- **Ecto best practices.** Changesets for validation, contexts for business logic, preloads for associations. No raw SQL except for FTS5 queries. Migrations for every schema change.
- **ExUnit tests.** Context tests (Accounts, Chat), LiveView tests (connected mount, events, PubSub updates), GenServer tests (rate limiter, room server). Use fixtures/factories for test data.
- **Format clean.** `mix format --check-formatted` must pass. Follow Elixir conventions.

### What NOT to do
- Don't add custom JavaScript for any real-time feature. LiveView handles it all.
- Don't skip GenServer patterns. Simple Agent or ETS-only approaches don't showcase OTP knowledge. Use proper GenServer modules.
- Don't use Phoenix Channels directly for chat. Use LiveView + PubSub. Channels are defined for compatibility but the primary UX is LiveView.
- Don't skip Presence. Simple "online users" lists without Presence miss the distributed systems angle.
- Don't use an external search engine (Elasticsearch, etc.). SQLite FTS5 is the correct choice for this project size.
- Don't leave `# TODO` or `# FIXME` comments anywhere.

---

## GitHub Username

The GitHub username is **devaloi**. The repository is `github.com/devaloi/livechat`. The Mix project name is `livechat`, the OTP application is `:livechat`.

## Start

Read the three docs. Then begin Phase 1 from `EX01-elixir-phoenix-livechat.md`.
