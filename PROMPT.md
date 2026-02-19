# Build agentforge — Multi-Agent Orchestration Framework

You are building a **portfolio project** for a Senior AI Engineer's public GitHub. It must be impressive, clean, and production-grade. This is the **flagship AI project** in the entire portfolio — it needs to be the most technically impressive piece. Read these docs before writing any code:

1. **`A09-go-multi-agent.md`** — Complete project spec: architecture, agent types, tool definitions, DAG execution, shared memory, supervisor flow, YAML configuration, CLI, commit plan. This is your primary blueprint. Follow it phase by phase.
2. **`github-portfolio.md`** — Portfolio goals and Definition of Done (Level 1 + Level 2). Understand the quality bar.
3. **`github-portfolio-checklist.md`** — Pre-publish checklist. Every item must pass before you're done.

---

## Instructions

### Read first, build second
Read all three docs completely before writing a single line of code. This is a complex system with many interacting parts. Understand the agent execution loop (prompt → LLM → tool call → result → repeat), the supervisor pattern (plan → delegate → synthesize), the DAG executor (topological sort, parallel execution), and the shared memory model (agents collaborate through a key-value store). Internalize the full architecture before you start.

### Follow the phases in order
The project spec has 8 phases. This is an L-size project — do them in strict order:
1. **Foundation & Types** — project setup, core types (Message, ToolCall, SubTask, AgentConfig), YAML config loader
2. **LLM Providers & History** — provider interface, OpenAI/Anthropic/Ollama implementations, conversation history with token budget trimming
3. **Tool System & Shared Memory** — tool interface and registry with JSON Schema, all built-in tools, shared memory store with agent attribution
4. **Agent Execution Loop** — core loop (prompt → LLM → tool call → result → repeat), specialized agent constructors
5. **Planning & DAG Execution** — DAG data structure with topological sort, task planner (LLM-powered decomposition), DAG executor with parallel execution
6. **Supervisor & Synthesis** — supervisor agent orchestrating the full flow, result synthesizer, structured observability logging
7. **CLI & Examples** — cobra CLI with run/list/validate commands, example programs, integration tests
8. **Documentation & Polish** — YAML config files, comprehensive README, final lint and checks

### Commit frequently
Follow the commit plan in the spec (27 commits). Use **conventional commits**. Each commit should be a logical unit. This is an L-size project — the commit history should tell the story of building a complex system incrementally.

### Quality non-negotiables
- **The agent loop must be clean and readable.** A reader should understand the entire agent pattern from `loop.go`. The loop itself should be ~30-50 lines. All complexity is in the supporting types, not the loop.
- **The supervisor is the star.** The plan → delegate → execute → synthesize flow must be clear, well-logged, and testable. A recruiter reading the supervisor code should immediately see you understand multi-agent orchestration.
- **DAG execution is correct.** Topological sort, cycle detection, parallel execution of independent tasks, dependency-respecting ordering. This is a graph algorithm interview question made real.
- **Shared memory enables collaboration.** Agents don't just run in isolation — the researcher stores findings, the coder reads them, the reviewer reads the code. This collaboration through shared memory is what makes this a multi-agent system, not just multiple single agents.
- **Provider abstraction is clean.** OpenAI, Anthropic, and Ollama all implement the same interface. Switching providers is a config change. The agent doesn't know which provider it's using.
- **Tool system uses JSON Schema.** Every tool has a formal parameter schema. The agent sends tool schemas to the LLM. Arguments are validated before execution. This mirrors how OpenAI and Anthropic actually define tools.
- **Mock provider for all tests.** No test hits a real LLM API. The mock provider returns scripted responses including tool calls. This makes tests fast, deterministic, and CI-friendly.
- **Token budget management.** Each agent has a configurable token budget. When history approaches the limit, oldest non-system messages are trimmed. This prevents runaway costs and context overflow.
- **Observability tells the story.** Every agent decision, tool call, and result is logged with structured data. The execution trace can be printed as a timeline. A debugging developer can follow exactly what happened.
- **YAML configuration is the control plane.** Agents, tools, and providers are defined in YAML. You can add a new agent by adding a YAML block — no code changes. This shows production-grade configurability.
- **CLI output is beautiful.** The execution output shown in the spec (with emojis, progress, timing) must look professional in the terminal. This is the first thing someone runs.
- **Lint clean.** `golangci-lint run` and `go vet` must pass with zero warnings.

### What NOT to do
- Don't use LangChain, LangGraph, CrewAI, or any agent framework. This IS the framework, built from primitives. Using an existing framework defeats the entire purpose.
- Don't use LLM SDKs (openai-go, anthropic-go). Raw `net/http` calls to the APIs. This shows you understand the underlying protocols.
- Don't hardcode agent definitions in Go. Agents must be configurable via YAML. The code provides the engine; YAML provides the configuration.
- Don't skip the DAG executor. Running sub-tasks sequentially is trivial. The DAG with parallel execution and dependency resolution is what makes this impressive.
- Don't skip shared memory. Without it, this is just "run 4 agents independently." Shared memory is what makes agents collaborate.
- Don't make the agent loop a monolith. The loop, tool execution, history management, and provider calls should be separate, testable units.
- Don't leave `// TODO` or `// FIXME` comments anywhere.
- Don't commit `.env` files or any API keys.

---

## GitHub Username

The GitHub username is **devaloi**. For Go module paths, use `github.com/devaloi/agentforge`. All internal imports must use this module path.

## Start

Read the three docs. Then begin Phase 1 from `A09-go-multi-agent.md`.
