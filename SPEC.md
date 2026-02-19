# A09: agentforge — Multi-Agent Orchestration Framework

**Catalog ID:** A09 | **Size:** L | **Language:** Go 1.26
**Repo name:** `agentforge`
**One-liner:** A multi-agent orchestration framework — a supervisor agent decomposes tasks into a dependency DAG, delegates to specialized sub-agents (researcher, coder, reviewer, writer), manages shared memory, and synthesizes results. Built from primitives, no frameworks.

---

## Why This Stands Out

- **The flagship AI project** — this is the most impressive, most complex project in the entire portfolio
- **Supervisor agent** — receives a complex task, uses chain-of-thought planning to decompose it into a DAG of sub-tasks with dependencies
- **Specialized agents** — researcher (web search), coder (code generation), reviewer (code review), writer (text synthesis) — each with a system prompt, tools, and memory
- **Agent execution loop** — the core pattern: system prompt → user message → LLM → tool call → execute tool → feed result → repeat until done
- **Shared memory** — key-value store that agents read/write for collaboration (researcher stores findings, coder reads them)
- **DAG execution engine** — topological sort, parallel execution of independent sub-tasks, respects dependencies
- **Tool system** — JSON Schema tool definitions, timeout-guarded execution, result parsing, extensible tool registry
- **Multi-provider LLM** — interface supporting OpenAI, Anthropic, and Ollama with streaming
- **Token budget management** — per-agent conversation history with automatic trimming when approaching token limits
- **Observability** — structured logging of every agent decision, tool call, and result — full execution trace
- **CLI** — `agentforge run "Build a REST API in Go"` — runs the full multi-agent flow in the terminal with live output
- **No LangChain/LangGraph/CrewAI** — built from raw HTTP calls and Go primitives, demonstrating deep understanding of how agent systems actually work
- **YAML configuration** — agent definitions, tool registrations, and LLM settings all in YAML — agents are configurable without code changes

---

## Architecture

```
agentforge/
├── cmd/
│   └── agentforge/
│       └── main.go                        # CLI entry: parse args, load config, run supervisor
├── internal/
│   ├── agent/
│   │   ├── agent.go                       # Core agent: system prompt, tools, memory, execution loop
│   │   ├── agent_test.go
│   │   ├── config.go                      # Agent config: name, model, system prompt, tools, limits
│   │   ├── loop.go                        # Execution loop: prompt → LLM → tool call → result → repeat
│   │   ├── loop_test.go
│   │   └── types.go                       # AgentResult, AgentStatus, LoopState
│   ├── supervisor/
│   │   ├── supervisor.go                  # Supervisor agent: receives task, plans, delegates, synthesizes
│   │   ├── supervisor_test.go
│   │   ├── planner.go                     # Task decomposition: complex task → DAG of sub-tasks
│   │   ├── planner_test.go
│   │   ├── synthesizer.go                 # Result synthesis: merge sub-agent outputs into final answer
│   │   └── synthesizer_test.go
│   ├── agents/
│   │   ├── researcher.go                  # Researcher agent: web search tool, extract + summarize info
│   │   ├── researcher_test.go
│   │   ├── coder.go                       # Coder agent: code generation tool, write + explain code
│   │   ├── coder_test.go
│   │   ├── reviewer.go                    # Reviewer agent: code review tool, analyze code for issues
│   │   ├── reviewer_test.go
│   │   ├── writer.go                      # Writer agent: text generation, format + structure prose
│   │   └── writer_test.go
│   ├── planner/
│   │   ├── dag.go                         # DAG data structure: nodes, edges, topological sort
│   │   ├── dag_test.go
│   │   ├── task.go                        # SubTask: id, description, agent type, dependencies, status
│   │   └── task_test.go
│   ├── executor/
│   │   ├── executor.go                    # DAG executor: run sub-tasks respecting dependencies
│   │   ├── executor_test.go
│   │   ├── parallel.go                    # Parallel execution with errgroup + semaphore
│   │   └── parallel_test.go
│   ├── memory/
│   │   ├── store.go                       # Shared memory: thread-safe key-value store
│   │   ├── store_test.go
│   │   └── types.go                       # MemoryEntry: key, value, author (agent name), timestamp
│   ├── tools/
│   │   ├── registry.go                    # Tool registry: register, list, get, invoke
│   │   ├── registry_test.go
│   │   ├── tool.go                        # Tool interface: Name, Description, Schema, Execute
│   │   ├── web_search.go                  # Web search tool (simulated or API-backed)
│   │   ├── web_search_test.go
│   │   ├── code_gen.go                    # Code generation tool (delegates to LLM with code prompt)
│   │   ├── code_review.go                 # Code review tool (analyzes code for issues)
│   │   ├── text_gen.go                    # Text generation tool (delegates to LLM with writing prompt)
│   │   ├── read_file.go                   # Read file from disk (sandboxed)
│   │   ├── write_file.go                  # Write file to disk (sandboxed output directory)
│   │   ├── memory_read.go                 # Read from shared memory
│   │   ├── memory_write.go                # Write to shared memory
│   │   └── schema.go                      # JSON Schema builder for tool parameters
│   ├── provider/
│   │   ├── provider.go                    # LLM provider interface: ChatComplete, Stream
│   │   ├── openai.go                      # OpenAI: chat/completions with function calling
│   │   ├── openai_test.go
│   │   ├── anthropic.go                   # Anthropic: messages API with tool_use
│   │   ├── anthropic_test.go
│   │   ├── ollama.go                      # Ollama: local model API with tool support
│   │   ├── ollama_test.go
│   │   ├── mock.go                        # Mock provider for deterministic testing
│   │   └── types.go                       # Message, ToolCall, ToolResult, Usage, StreamChunk
│   ├── history/
│   │   ├── history.go                     # Conversation history per agent with token counting
│   │   ├── history_test.go
│   │   ├── trimmer.go                     # Token budget trimmer: drop oldest messages to fit limit
│   │   └── trimmer_test.go
│   ├── config/
│   │   ├── loader.go                      # Load YAML config files: agents, tools, providers
│   │   ├── loader_test.go
│   │   └── types.go                       # Config structs: AgentConfig, ToolConfig, ProviderConfig
│   └── observability/
│       ├── logger.go                      # Structured logger: agent events, tool calls, decisions
│       ├── logger_test.go
│       ├── trace.go                       # Execution trace: full DAG execution timeline
│       └── types.go                       # TraceEvent, TraceSpan, EventType
├── config/
│   ├── agents.yaml                        # Agent definitions: name, model, system prompt, tools
│   ├── tools.yaml                         # Tool registrations: name, description, schema
│   └── providers.yaml                     # LLM provider config: API keys (env refs), models, defaults
├── examples/
│   ├── simple/main.go                     # Single-agent: researcher answers a question
│   ├── code-task/main.go                  # Multi-agent: plan → code → review → deliver
│   └── research-report/main.go            # Multi-agent: research → write → synthesize report
├── testdata/
│   ├── mock_responses/                    # Scripted LLM responses for deterministic tests
│   │   ├── planner_response.json
│   │   ├── researcher_response.json
│   │   ├── coder_response.json
│   │   └── reviewer_response.json
│   └── configs/                           # Test config files
│       ├── test_agents.yaml
│       └── test_tools.yaml
├── go.mod
├── go.sum
├── Makefile                               # build, test, lint, run, examples
├── .env.example                           # OPENAI_API_KEY, ANTHROPIC_API_KEY, OLLAMA_URL
├── .gitignore
├── .golangci.yml
├── LICENSE
└── README.md
```

---

## Core Concepts

### Agent Execution Loop

```
┌─────────────────────────────────────────┐
│              Agent Loop                  │
│                                          │
│  System Prompt + User Message            │
│         ↓                                │
│  Call LLM (with tool schemas)            │
│         ↓                                │
│  Response has tool_call? ──→ NO ──→ Done │
│         ↓ YES                            │
│  Validate args against schema            │
│         ↓                                │
│  Execute tool (with timeout)             │
│         ↓                                │
│  Append tool_result to history           │
│         ↓                                │
│  Token budget check → trim if needed     │
│         ↓                                │
│  Loop back to "Call LLM"                 │
│  (max iterations guard)                  │
└─────────────────────────────────────────┘
```

### Supervisor Flow

```
User: "Build a REST API for a todo app in Go"
         ↓
┌─ Supervisor ──────────────────────────────────┐
│  1. Plan: decompose task into sub-tasks        │
│     → research: "Go REST API best practices"   │
│     → code: "Implement todo CRUD handlers"     │
│     → code: "Implement data models"            │
│     → review: "Review generated code"          │
│     → writer: "Write API documentation"        │
│                                                │
│  2. Build DAG:                                 │
│     research ──→ code(handlers) ──→ review     │
│                  code(models) ────→ review      │
│                                    review ──→ writer │
│                                                │
│  3. Execute DAG (parallel where possible):     │
│     Step 1: research (independent)             │
│     Step 2: code(handlers) + code(models)      │
│     Step 3: review                             │
│     Step 4: writer                             │
│                                                │
│  4. Synthesize: merge all outputs into final   │
└───────────────────────────────────────────────┘
```

---

## Agent Types

| Agent | System Prompt Focus | Tools | Output |
|-------|-------------------|-------|--------|
| Supervisor | Task decomposition, planning, delegation | planner (internal) | Sub-task DAG + final synthesis |
| Researcher | Information gathering, summarization | web_search, memory_write | Research findings stored in shared memory |
| Coder | Code generation, implementation | code_gen, write_file, memory_read, memory_write | Generated code files + explanation |
| Reviewer | Code analysis, bug detection, improvements | code_review, memory_read | Review comments + approval/rejection |
| Writer | Documentation, structuring, formatting | text_gen, memory_read | Formatted text documents |

---

## Tool Definitions

| Tool | Parameters | Returns | Timeout |
|------|-----------|---------|---------|
| `web_search` | `query: string` | `results: [{title, snippet, url}]` | 10s |
| `code_gen` | `language: string, task: string, context: string` | `code: string, explanation: string` | 30s |
| `code_review` | `code: string, language: string` | `issues: [{severity, line, message}], approved: bool` | 15s |
| `text_gen` | `topic: string, style: string, context: string` | `text: string` | 20s |
| `read_file` | `path: string` | `content: string` | 5s |
| `write_file` | `path: string, content: string` | `success: bool` | 5s |
| `memory_read` | `key: string` | `value: string, found: bool` | 1s |
| `memory_write` | `key: string, value: string` | `success: bool` | 1s |

---

## Shared Memory

```go
// Agents collaborate through shared memory
memory.Write("research_findings", "Go REST APIs typically use...")   // researcher writes
findings := memory.Read("research_findings")                         // coder reads
memory.Write("generated_code", "package main\n...")                  // coder writes
code := memory.Read("generated_code")                                // reviewer reads
```

| Operation | Thread-Safe | Description |
|-----------|-------------|-------------|
| `Read(key)` | Yes (RLock) | Read value by key, returns (value, found) |
| `Write(key, value)` | Yes (Lock) | Write value, records author + timestamp |
| `List()` | Yes (RLock) | List all keys with metadata |
| `Delete(key)` | Yes (Lock) | Remove key |

---

## YAML Configuration

### agents.yaml

```yaml
agents:
  researcher:
    model: gpt-4o
    provider: openai
    system_prompt: |
      You are a research assistant. Your job is to find accurate, relevant
      information using web search. Summarize findings clearly and store
      them in shared memory for other agents to use.
    tools: [web_search, memory_write]
    max_iterations: 5
    token_budget: 8000

  coder:
    model: gpt-4o
    provider: openai
    system_prompt: |
      You are an expert software engineer. Write clean, well-documented,
      production-quality code. Read research findings from shared memory
      for context. Write generated code to files.
    tools: [code_gen, read_file, write_file, memory_read, memory_write]
    max_iterations: 10
    token_budget: 16000

  reviewer:
    model: claude-sonnet-4-20250514
    provider: anthropic
    system_prompt: |
      You are a senior code reviewer. Analyze code for bugs, security issues,
      performance problems, and style. Be constructive and specific.
    tools: [code_review, memory_read]
    max_iterations: 3
    token_budget: 8000

  writer:
    model: gpt-4o-mini
    provider: openai
    system_prompt: |
      You are a technical writer. Create clear, well-structured documentation.
      Read context from shared memory to understand what was built.
    tools: [text_gen, memory_read]
    max_iterations: 5
    token_budget: 8000
```

---

## CLI Usage

```
agentforge run "Build a REST API for a todo app in Go"
agentforge run --config ./config/ "Research quantum computing advances in 2025"
agentforge run --provider anthropic --model claude-sonnet-4-20250514 "Review this Go code for issues"
agentforge agents list                    # List configured agents
agentforge tools list                     # List registered tools
agentforge config validate ./config/      # Validate configuration files
```

### CLI Output (during execution)

```
🔵 Supervisor: Planning task decomposition...
   → Created 4 sub-tasks in dependency DAG

📋 Execution Plan:
   Step 1: [researcher] Research Go REST API best practices
   Step 2: [coder] Implement data models  |  [coder] Implement handlers
   Step 3: [reviewer] Review generated code
   Step 4: [writer] Write API documentation

🔍 Researcher: Starting "Research Go REST API best practices"
   🔧 web_search("Go REST API best practices 2025")
   📝 Stored findings in shared memory: research_findings
   ✅ Completed in 4.2s

💻 Coder: Starting "Implement data models" (parallel)
   📖 Read: research_findings
   🔧 code_gen(language="go", task="todo data models")
   💾 Wrote: output/models.go
   ✅ Completed in 8.1s

💻 Coder: Starting "Implement handlers" (parallel)
   📖 Read: research_findings
   🔧 code_gen(language="go", task="todo CRUD handlers")
   💾 Wrote: output/handlers.go
   ✅ Completed in 12.3s

🔎 Reviewer: Starting "Review generated code"
   📖 Read: generated_code
   🔧 code_review(language="go")
   ✅ Approved with 2 minor suggestions. Completed in 5.7s

📝 Writer: Starting "Write API documentation"
   📖 Read: research_findings, generated_code, review_results
   🔧 text_gen(topic="todo API docs")
   💾 Wrote: output/README.md
   ✅ Completed in 6.8s

🏁 Task Complete (37.1s total)
   Files generated: output/models.go, output/handlers.go, output/README.md
   Agents used: 4 | Tool calls: 9 | Total tokens: 24,847
```

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Language | Go 1.26 |
| HTTP | stdlib `net/http` (for LLM API calls) |
| JSON | stdlib `encoding/json` |
| YAML | `gopkg.in/yaml.v3` |
| CLI | `cobra` + `pflag` |
| Concurrency | `errgroup` + semaphore channel |
| LLM Providers | OpenAI, Anthropic, Ollama (raw HTTP, no SDKs) |
| Testing | stdlib + mock provider + table-driven |
| Linting | golangci-lint |

---

## Phased Build Plan

### Phase 1: Foundation & Types

**1.1 — Project setup**
- `go mod init github.com/devaloi/agentforge`
- Directory structure, Makefile, `.gitignore`, `.golangci.yml`
- Add LICENSE (MIT), `.env.example`

**1.2 — Core types**
- `Message` struct: Role (system/user/assistant/tool), Content, ToolCalls, ToolCallID
- `ToolCall` struct: ID, Name, Arguments (JSON string)
- `ToolResult` struct: ToolCallID, Content, IsError
- `AgentConfig`: Name, Model, Provider, SystemPrompt, Tools (list), MaxIterations, TokenBudget
- `SubTask`: ID, Description, AgentType, Dependencies ([]string), Status, Result
- Tests: type construction, JSON marshaling round-trips

**1.3 — Configuration loader**
- Load `agents.yaml`: parse into `[]AgentConfig`
- Load `tools.yaml`: parse into `[]ToolConfig`
- Load `providers.yaml`: parse into `ProviderConfig` (API keys from env vars, not YAML)
- Validate: agent references valid provider, tools exist, required fields present
- Tests: load valid config, missing fields, invalid references

### Phase 2: LLM Providers & History

**2.1 — Provider interface**
- `Provider` interface: `ChatComplete(ctx, messages []Message, tools []Tool, config Config) (*Response, error)`
- `Response`: Content string, ToolCalls []ToolCall, Usage (prompt tokens, completion tokens)
- `StreamChunk`: Delta content, tool call delta, finish reason
- Provider registry: get provider by name

**2.2 — OpenAI provider**
- HTTP POST to `chat/completions` with function calling
- Format messages: system, user, assistant, tool roles
- Format tools: JSON Schema function definitions
- Parse response: extract content, tool_calls, usage
- Streaming: SSE parsing, yield chunks
- Tests with httptest: success, tool call, streaming, error, rate limit

**2.3 — Anthropic provider**
- HTTP POST to `messages` API with tool_use
- Format messages: Anthropic's content block format
- Parse tool_use content blocks vs text blocks
- Handle stop_reason: "end_turn" vs "tool_use"
- Tests with httptest matching OpenAI coverage

**2.4 — Ollama provider**
- HTTP POST to local Ollama API (`/api/chat`)
- Format messages and tools for Ollama's format
- Parse response with tool calls
- Tests with httptest

**2.5 — Conversation history**
- Per-agent message history: append user, assistant, tool messages
- Token counting: approximate count (chars / 4 as rough estimate)
- Trimmer: when approaching token budget, drop oldest non-system messages
- Configurable token budget per agent
- Tests: append, trim at budget, system message preserved, accurate counting

### Phase 3: Tool System & Shared Memory

**3.1 — Tool interface and registry**
- `Tool` interface: `Name() string`, `Description() string`, `Schema() JSONSchema`, `Execute(ctx, params map[string]any) (*ToolResult, error)`
- `Registry`: Register, Get, List, Invoke (with timeout)
- JSON Schema for each tool's parameters: type, properties, required
- Invoke wraps Execute with `context.WithTimeout`
- Tests: register, invoke, timeout, unknown tool, schema validation

**3.2 — Built-in tools**
- `web_search`: query → results array (simulated with configurable mock/real API)
- `code_gen`: language + task + context → generated code + explanation (delegates to LLM)
- `code_review`: code + language → issues array + approved bool (delegates to LLM)
- `text_gen`: topic + style + context → generated text (delegates to LLM)
- `read_file`: path → content (sandboxed to output directory)
- `write_file`: path + content → success (sandboxed to output directory)
- Each tool has JSON Schema, timeout config, error handling
- Tests for each tool (mock LLM for generation tools)

**3.3 — Memory tools and shared store**
- `SharedMemory`: thread-safe key-value store (`sync.RWMutex` + map)
- `MemoryEntry`: Value, Author (agent name), Timestamp, Tags
- `memory_read` tool: read key from shared memory
- `memory_write` tool: write key to shared memory with agent attribution
- `List()`: return all keys with metadata
- Tests: concurrent read/write, agent attribution, list keys

### Phase 4: Agent Execution Loop

**4.1 — Core agent loop**
- `Agent` struct: config, provider, tools (registry), history, memory (shared)
- `Run(ctx, task string) (*AgentResult, error)`:
  1. Append system prompt to history
  2. Append user message (task) to history
  3. Call provider with history + tool schemas
  4. If response has tool calls → execute each tool → append results → loop
  5. If response has no tool calls → return content as final result
  6. Max iterations guard with clear error
- `AgentResult`: Content, ToolCallsUsed, TokensUsed, Duration
- Tests with mock provider: no tools, single tool call, multi-tool chain, max iterations

**4.2 — Specialized agent constructors**
- `NewResearcher(config, provider, memory)` — configured with researcher system prompt + tools
- `NewCoder(config, provider, memory)` — configured with coder system prompt + tools
- `NewReviewer(config, provider, memory)` — configured with reviewer system prompt + tools
- `NewWriter(config, provider, memory)` — configured with writer system prompt + tools
- Each reads its config from agents.yaml, registers its tools subset
- Tests: each agent type runs with mock provider, uses correct tools

### Phase 5: Planning & DAG Execution

**5.1 — DAG data structure**
- `DAG` struct: nodes map, edges adjacency list
- `AddNode(task SubTask)`, `AddEdge(from, to string)` — dependency: `from` must complete before `to`
- `TopologicalSort() ([][]string, error)` — return execution layers (parallel groups)
- Cycle detection: return error if DAG has cycles
- `Ready(completed []string) []string` — return tasks whose dependencies are all completed
- Tests: simple chain, diamond dependency, parallel groups, cycle detection

**5.2 — Task planner**
- `Plan(ctx, task string, provider Provider) (*DAG, error)`
- Send task to supervisor LLM with planning prompt
- Planning prompt instructs LLM to decompose into sub-tasks with JSON output:
  ```json
  {
    "tasks": [
      {"id": "research", "description": "...", "agent": "researcher", "depends_on": []},
      {"id": "code_models", "description": "...", "agent": "coder", "depends_on": ["research"]},
      {"id": "review", "description": "...", "agent": "reviewer", "depends_on": ["code_models"]}
    ]
  }
  ```
- Parse LLM response into DAG structure
- Validate: all dependencies reference valid task IDs, agent types exist
- Tests with mock provider: simple plan, complex plan, invalid plan handling

**5.3 — DAG executor**
- `Execute(ctx, dag *DAG, agentFactory AgentFactory) (*ExecutionResult, error)`
- Get execution layers from topological sort
- For each layer: run all tasks in parallel (`errgroup` with semaphore)
- Each task: create agent of specified type, run with task description
- Collect results per task, update task status
- If a task fails: mark dependents as blocked, continue independent tasks
- `ExecutionResult`: per-task results, total duration, success/failure counts
- Tests: sequential execution, parallel execution, failure propagation, timeout

### Phase 6: Supervisor & Synthesis

**6.1 — Supervisor agent**
- `Supervisor` struct: planner, executor, synthesizer, config
- `Run(ctx, task string) (*SupervisorResult, error)`:
  1. Call planner to decompose task into DAG
  2. Log execution plan
  3. Call executor to run DAG
  4. Call synthesizer to merge results
  5. Return final synthesized output
- Pass shared memory to all sub-agents for collaboration
- Tests: full flow with mock provider (scripted planning + execution responses)

**6.2 — Result synthesizer**
- `Synthesize(ctx, task string, results map[string]*AgentResult, provider Provider) (string, error)`
- Send all sub-task results to LLM with synthesis prompt
- Synthesis prompt: "Given the original task and these sub-agent results, produce the final comprehensive output"
- Format results clearly for the LLM (task description + agent output for each)
- Tests: synthesis produces coherent output, handles partial failures

**6.3 — Observability**
- Structured logger: `slog` with JSON output
- Log events: `agent_start`, `agent_complete`, `tool_call`, `tool_result`, `plan_created`, `task_started`, `task_completed`, `task_failed`
- Each event includes: timestamp, agent name, duration, token usage
- Execution trace: collect all events into a timeline, printable summary
- Tests: events logged correctly, trace reconstruction

### Phase 7: CLI & Examples

**7.1 — CLI with cobra**
- `agentforge run <task>` — run supervisor with task
  - `--config` — config directory (default `./config/`)
  - `--provider` — override default provider
  - `--model` — override default model
  - `--verbose` — show detailed execution trace
  - `--output-dir` — directory for generated files (default `./output/`)
- `agentforge agents list` — list configured agents with tools
- `agentforge tools list` — list registered tools with schemas
- `agentforge config validate <dir>` — validate config files
- Live output during execution: agent status, tool calls, progress

**7.2 — Example programs**
- `simple/main.go`: single researcher agent answers a question
- `code-task/main.go`: multi-agent code generation (plan → code → review → deliver)
- `research-report/main.go`: multi-agent research report (research → write → synthesize)
- Each example is self-contained with inline config (no YAML dependency)

**7.3 — Integration tests**
- Full supervisor test: task → plan → execute → synthesize with mock provider
- Multi-agent collaboration test: agents read/write shared memory correctly
- DAG execution test: parallel tasks run concurrently, dependencies respected
- Failure handling test: sub-agent failure doesn't crash supervisor
- Config loading test: YAML files parse and validate correctly

### Phase 8: Documentation & Polish

**8.1 — YAML config files**
- `config/agents.yaml`: all 4 agent types with realistic system prompts
- `config/tools.yaml`: all tools with JSON Schema parameter definitions
- `config/providers.yaml`: provider configs with env var references for API keys

**8.2 — README**
- Architecture diagram (supervisor flow)
- Quick start: `go build && agentforge run "Build a REST API"`
- Agent types table with descriptions
- Tool reference table
- Configuration guide (YAML format)
- CLI usage with examples
- How to add custom agents and tools
- Example execution output (the full CLI output shown above)
- Design decisions: why no LangChain, why DAG, why shared memory

**8.3 — Final checks**
- `go build ./...` clean
- `go test -race ./...` all pass
- `golangci-lint run` clean
- CLI: `agentforge run`, `agentforge agents list`, `agentforge tools list` all work
- Config validation catches errors
- Example programs run with mock provider
- No `// TODO` or `// FIXME`
- Fresh clone → build → run (with mock) works

---

## Commit Plan

1. `chore: scaffold project with directory structure and config`
2. `feat: add core types — Message, ToolCall, SubTask, AgentConfig`
3. `feat: add YAML configuration loader with validation`
4. `feat: add LLM provider interface and mock provider`
5. `feat: add OpenAI provider with function calling and streaming`
6. `feat: add Anthropic provider with tool_use support`
7. `feat: add Ollama provider for local models`
8. `feat: add conversation history with token budget trimming`
9. `feat: add tool interface, registry, and JSON Schema definitions`
10. `feat: add built-in tools — web search, code gen, code review, text gen`
11. `feat: add file tools — read and write with sandboxing`
12. `feat: add shared memory store with agent attribution`
13. `feat: add memory read/write tools`
14. `feat: add core agent execution loop with max iterations`
15. `feat: add specialized agent constructors (researcher, coder, reviewer, writer)`
16. `feat: add DAG data structure with topological sort and cycle detection`
17. `feat: add task planner — decompose task into sub-task DAG via LLM`
18. `feat: add DAG executor with parallel execution and failure handling`
19. `feat: add supervisor agent with plan-execute-synthesize flow`
20. `feat: add result synthesizer for merging sub-agent outputs`
21. `feat: add structured logging and execution trace`
22. `feat: add CLI with cobra — run, agents list, tools list, config validate`
23. `feat: add example programs — simple, code-task, research-report`
24. `test: add integration tests for full supervisor flow`
25. `feat: add YAML config files for agents, tools, and providers`
26. `docs: add README with architecture, configuration, and usage guide`
27. `chore: final lint pass and cleanup`
