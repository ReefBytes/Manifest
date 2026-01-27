# Architecture Diagrams

> Visual documentation of the Manifest parallel LLM agent orchestration framework

**Last Updated**: 2026-01-27

---

## Table of Contents

1. [Application Architecture](#application-architecture)
2. [Bootstrap Flow](#bootstrap-flow)
3. [Parallel Agent Orchestration](#parallel-agent-orchestration)
4. [Configuration Hierarchy](#configuration-hierarchy)
5. [Command Processing Flow](#command-processing-flow)
6. [Service State Management](#service-state-management)
7. [Validation Pipeline](#validation-pipeline)

---

## Application Architecture

Complete end-to-end flow of the Manifest framework from user setup to parallel agent execution.

```mermaid
%%{init: {'theme':'neutral'}}%%
flowchart TB
    classDef user fill:#f0f9ff,stroke:#0284c7
    classDef setup fill:#f0fdf4,stroke:#16a34a
    classDef runtime fill:#fef3c7,stroke:#d97706
    classDef agent fill:#ede9fe,stroke:#7c3aed
    classDef output fill:#fee2e2,stroke:#dc2626

    USER["User"]:::user
    BOOTSTRAP["bootstrap.sh<br/>Platform Detection<br/>Dependency Install"]:::setup
    DEPLOY["Deploy to ~/.claude/<br/>Copy configs & scripts"]:::setup
    AUTH["Service Authentication<br/>Claude/Gemini/Cursor"]:::setup

    CLAUDE_USER["Claude Code User"]:::user
    COMMAND["Command Invocation<br/>/refactor, /generate-diagrams"]:::runtime
    ORCHESTRATOR["parallel_agent.sh<br/>Consensus Scoring<br/>Model Selection"]:::runtime

    subgraph Agents["Parallel Agents"]
        CURSOR["Cursor Agent<br/>IDE Context"]:::agent
        GEMINI["Gemini CLI<br/>Broad Knowledge"]:::agent
        CLAUDE_CLI["Claude CLI<br/>Deep Reasoning"]:::agent
    end

    SYNTHESIS["Result Synthesis<br/>Consensus Analysis"]:::output
    VALIDATION["Tier 1/2 Validation<br/>Security & Quality"]:::output
    FINAL["Final Output<br/>JSON/Markdown"]:::output

    USER --> BOOTSTRAP
    BOOTSTRAP --> DEPLOY
    DEPLOY --> AUTH
    AUTH --> CLAUDE_USER

    CLAUDE_USER --> COMMAND
    COMMAND --> ORCHESTRATOR
    ORCHESTRATOR --> CURSOR
    ORCHESTRATOR --> GEMINI
    ORCHESTRATOR --> CLAUDE_CLI

    CURSOR --> SYNTHESIS
    GEMINI --> SYNTHESIS
    CLAUDE_CLI --> SYNTHESIS

    SYNTHESIS --> VALIDATION
    VALIDATION --> FINAL
    FINAL --> CLAUDE_USER
```

**Key Components:**

- **bootstrap.sh**: Cross-platform setup script (macOS/Linux) that handles dependency installation and authentication
- **parallel_agent.sh**: Core orchestration engine that runs multiple LLM agents in parallel
- **Commands**: User-facing slash commands (`/refactor`, `/generate-diagrams`, etc.)
- **Parallel Agents**: Three LLM services (Cursor, Gemini, Claude) providing diverse perspectives
- **Synthesis**: Consensus scoring and disagreement resolution
- **Validation**: Two-tier security and quality checks

---

## Bootstrap Flow

Detailed sequence of bootstrap.sh execution from initial run to authenticated services.

```mermaid
%%{init: {'theme':'neutral'}}%%
sequenceDiagram
    actor User
    participant BS as bootstrap.sh
    participant Sys as System
    participant NPM as npm
    participant Files as ~/.claude/
    participant Svcs as Services Config

    User->>BS: ./bootstrap.sh
    BS->>Sys: Detect Platform (macOS/Linux)
    BS->>Sys: Check Homebrew/apt/dnf

    alt Homebrew Missing (macOS)
        BS->>Sys: Install Homebrew
    end

    BS->>Sys: Check Node.js
    alt Node.js Missing
        BS->>Sys: Install Node.js
    end

    BS->>NPM: npm install -g @anthropic-ai/claude-code
    NPM-->>BS: Claude CLI Installed

    BS->>NPM: npm install -g @google/gemini-cli
    NPM-->>BS: Gemini CLI Installed

    BS->>User: Open cursor.sh for download

    BS->>Files: Copy .claude/* to ~/.claude/
    BS->>Files: chmod +x scripts/*.sh
    BS->>Svcs: Write services.yml

    BS->>User: Authenticate Claude CLI
    User->>BS: Enter API key

    BS->>User: Authenticate Gemini CLI
    User->>BS: Enter API key

    BS->>User: Setup Complete ✓
```

**Key Steps:**

1. **Platform Detection**: Identifies OS (macOS/Linux) and package manager
2. **Dependency Installation**: Homebrew, Node.js, and npm packages
3. **File Deployment**: Copies configuration to `~/.claude/`
4. **Service Configuration**: Writes `services.yml` with enabled/disabled states
5. **Authentication**: Guides user through API key setup for each service

---

## Parallel Agent Orchestration

Core orchestration flow showing how parallel_agent.sh coordinates multiple LLM agents.

```mermaid
%%{init: {'theme':'neutral'}}%%
flowchart LR
    classDef config fill:#dbeafe,stroke:#1e40af
    classDef process fill:#dcfce7,stroke:#15803d
    classDef agent fill:#fef3c7,stroke:#a16207
    classDef result fill:#fce7f3,stroke:#be185d

    START["User Prompt"]:::config
    LOAD_CONFIG["Load services.yml<br/>Parse agent states"]:::config
    PARSE_ARGS["Parse CLI Args<br/>--cursor-only<br/>--model selection"]:::config

    SELECT_MODELS["Select Models<br/>Based on task type"]:::process

    subgraph Parallel["Parallel Execution"]
        CURSOR_RUN["Run Cursor Agent<br/>with timeout"]:::agent
        GEMINI_RUN["Run Gemini CLI<br/>with timeout"]:::agent
        CLAUDE_RUN["Run Claude CLI<br/>with timeout"]:::agent
    end

    COLLECT["Collect Outputs<br/>Handle failures"]:::process
    CONSENSUS["Calculate Consensus<br/>Score agreement"]:::result

    DECIDE{Consensus >= 80%?}

    AUTO["Auto-Proceed<br/>High Confidence"]:::result
    HIGHLIGHT["Highlight Disagreements<br/>Medium Confidence"]:::result
    ESCALATE["Escalate to User<br/>Low Confidence"]:::result

    OUTPUT["Generate Output<br/>JSON/Markdown"]:::result

    START --> LOAD_CONFIG
    LOAD_CONFIG --> PARSE_ARGS
    PARSE_ARGS --> SELECT_MODELS

    SELECT_MODELS --> CURSOR_RUN
    SELECT_MODELS --> GEMINI_RUN
    SELECT_MODELS --> CLAUDE_RUN

    CURSOR_RUN --> COLLECT
    GEMINI_RUN --> COLLECT
    CLAUDE_RUN --> COLLECT

    COLLECT --> CONSENSUS
    CONSENSUS --> DECIDE

    DECIDE -->|>= 80%| AUTO
    DECIDE -->|50-79%| HIGHLIGHT
    DECIDE -->|< 50%| ESCALATE

    AUTO --> OUTPUT
    HIGHLIGHT --> OUTPUT
    ESCALATE --> OUTPUT
```

**Consensus Thresholds:**

- **≥80%**: High confidence - proceed with unified recommendation
- **50-79%**: Medium confidence - highlight disagreements to user
- **<50%**: Low confidence - block and escalate for human review

**Model Selection by Task:**

| Task Type | Cursor | Claude | Gemini | Reason |
|-----------|--------|--------|--------|--------|
| Security | advanced | opus | pro | Maximum capability for critical code |
| Review | flash | sonnet | flash | Balanced performance/cost |
| Analyze | flash | sonnet | flash | Good reasoning without opus cost |
| Quick | mini | haiku | flash | Speed for simple queries |

---

## Configuration Hierarchy

Configuration loading and override precedence in the system.

```mermaid
%%{init: {'theme':'neutral'}}%%
flowchart TB
    classDef default fill:#f0f9ff,stroke:#0284c7
    classDef file fill:#f0fdf4,stroke:#16a34a
    classDef env fill:#fef3c7,stroke:#d97706
    classDef cli fill:#fee2e2,stroke:#dc2626
    classDef final fill:#ede9fe,stroke:#7c3aed

    subgraph Defaults["Default Values (Hardcoded)"]
        DEF_AGENTS["All agents: enabled<br/>Timeout: 600s<br/>Models: auto/sonnet/flash"]:::default
    end

    subgraph FileConfig["File Configuration"]
        SERVICES["services.yml<br/>Agent enable/disable"]:::file
        COMMAND_CFG["command_config.yml<br/>Tool policies<br/>Thresholds"]:::file
        VALIDATION["validation_criteria.yml<br/>Tier 1/2 rules"]:::file
    end

    subgraph EnvVars["Environment Variables"]
        ENV_MODELS["CURSOR_MODEL_*<br/>GEMINI_MODEL_*"]:::env
        ENV_DIRS["GEMINI_INCLUDE_DIRS"]:::env
        ENV_PREFLIGHT["CHECK_CREDITS_PREFLIGHT"]:::env
    end

    subgraph CLIArgs["CLI Arguments"]
        CLI_AGENTS["--cursor-only<br/>--gemini-only<br/>--no-claude"]:::cli
        CLI_MODELS["--cursor-model<br/>--claude-model"]:::cli
        CLI_OPTS["--timeout<br/>--output<br/>--validate"]:::cli
    end

    FINAL_CONFIG["Final Runtime Configuration"]:::final

    DEF_AGENTS --> SERVICES
    SERVICES --> ENV_MODELS
    ENV_MODELS --> CLI_AGENTS

    COMMAND_CFG --> ENV_DIRS
    ENV_DIRS --> CLI_MODELS

    VALIDATION --> ENV_PREFLIGHT
    ENV_PREFLIGHT --> CLI_OPTS

    CLI_AGENTS --> FINAL_CONFIG
    CLI_MODELS --> FINAL_CONFIG
    CLI_OPTS --> FINAL_CONFIG
```

**Override Priority (highest to lowest):**

1. **CLI Arguments**: Command-line flags (highest priority)
2. **Environment Variables**: Shell environment settings
3. **File Configuration**: YAML config files
4. **Hardcoded Defaults**: Built-in fallback values (lowest priority)

**Key Configuration Files:**

- `services.yml`: Controls which agents are enabled
- `command_config.yml`: Tool policies, thresholds, model defaults
- `validation_criteria.yml`: Security and quality validation rules

---

## Command Processing Flow

How user commands are processed from invocation to execution.

```mermaid
%%{init: {'theme':'neutral'}}%%
flowchart TB
    classDef input fill:#dbeafe,stroke:#1e40af
    classDef check fill:#fef3c7,stroke:#a16207
    classDef exec fill:#dcfce7,stroke:#15803d
    classDef output fill:#fce7f3,stroke:#be185d

    USER_CMD["User: /refactor src/"]:::input

    LOAD_CMD["Load Command<br/>.claude/commands/refactor.md"]:::exec
    PARSE_META["Parse Metadata<br/>allowed-tools<br/>description"]:::exec

    CHECK_TOOLS["Check Tool Policy<br/>from command_config.yml"]:::check

    TRIGGER_CHECK{Need Parallel<br/>Agents?}:::check

    DIRECT["Direct Execution<br/>Use allowed tools only"]:::exec

    PARALLEL["Invoke parallel_agent.sh<br/>--json --validate"]:::exec

    AGENTS["Run Agents in Parallel"]:::exec

    SYNTHESIZE["Synthesize Results<br/>If consensus < 80%"]:::exec

    VALIDATE["Run Validation<br/>Tier 1 & Tier 2 checks"]:::check

    VERDICT{Validation<br/>Verdict?}:::check

    APPROVED["APPROVED<br/>Present results"]:::output
    NEEDS_REVIEW["NEEDS_REVIEW<br/>Flag quality issues"]:::output
    BLOCKED["BLOCKED<br/>Critical failures"]:::output

    USER_CMD --> LOAD_CMD
    LOAD_CMD --> PARSE_META
    PARSE_META --> CHECK_TOOLS
    CHECK_TOOLS --> TRIGGER_CHECK

    TRIGGER_CHECK -->|always| PARALLEL
    TRIGGER_CHECK -->|never| DIRECT
    TRIGGER_CHECK -->|conditional| PARALLEL

    DIRECT --> APPROVED

    PARALLEL --> AGENTS
    AGENTS --> SYNTHESIZE
    SYNTHESIZE --> VALIDATE

    VALIDATE --> VERDICT

    VERDICT -->|Tier 1 pass<br/>Tier 2 >= 0.60| APPROVED
    VERDICT -->|Tier 1 pass<br/>Tier 2 < 0.60| NEEDS_REVIEW
    VERDICT -->|Tier 1 fail| BLOCKED
```

**Command Types:**

| Command | Parallel Agents | Validation Tier |
|---------|----------------|-----------------|
| `/refactor` | ALWAYS | Tier 1 (Security, Breaking Changes) |
| `/generate-diagrams` | CONDITIONAL (5+ modules) | Tier 2 (Quality) |
| `/improve-docs` | CONDITIONAL (>500 lines) | Tier 2 (Maintainability) |
| `/improve-readme` | NEVER | Tier 2 (Maintainability) |

---

## Service State Management

State transitions for enabled/disabled services throughout the lifecycle.

```mermaid
%%{init: {'theme':'neutral'}}%%
stateDiagram-v2
    classDef enabled fill:#dcfce7,stroke:#15803d
    classDef disabled fill:#fee2e2,stroke:#dc2626
    classDef warning fill:#fef3c7,stroke:#a16207

    [*] --> DefaultEnabled: bootstrap.sh<br/>initial setup

    DefaultEnabled --> Enabled: services.yml<br/>enabled: true
    DefaultEnabled --> Disabled: services.yml<br/>enabled: false

    Enabled --> TemporaryDisabled: CLI flag<br/>--no-claude
    Enabled --> Running: parallel_agent.sh<br/>executes

    TemporaryDisabled --> Enabled: Next invocation<br/>without flag

    Disabled --> Enabled: Reconfigure<br/>--enable-claude
    Enabled --> Disabled: Reconfigure<br/>--disable-claude

    Running --> Success: Agent completes
    Running --> CreditExhausted: Quota exceeded
    Running --> Failed: Timeout/Error

    CreditExhausted --> FallbackModel: Try cheaper model
    FallbackModel --> Success: Retry succeeds
    FallbackModel --> Failed: All models fail

    Success --> [*]
    Failed --> [*]

    class Enabled enabled
    class Running enabled
    class Success enabled
    class Disabled disabled
    class Failed disabled
    class TemporaryDisabled warning
    class CreditExhausted warning
    class FallbackModel warning
```

**State Transitions:**

1. **Bootstrap**: All services start enabled by default
2. **Configuration**: `services.yml` persists enabled/disabled state
3. **Runtime Override**: CLI flags (`--cursor-only`, `--no-claude`) temporarily modify state
4. **Execution**: Running state while agent processes request
5. **Credit Exhaustion**: Automatic fallback to cheaper models
6. **Reconfiguration**: User can change enabled state via `bootstrap.sh --reconfigure`

**Fallback Chains:**

- **Cursor**: gpt-5.2 → gpt-5.1-codex → gpt-5.1-codex-mini → auto
- **Claude**: opus → sonnet → haiku

---

## Validation Pipeline

Two-tier validation system for security-critical and quality checks.

```mermaid
%%{init: {'theme':'neutral'}}%%
flowchart TB
    classDef input fill:#dbeafe,stroke:#1e40af
    classDef tier1 fill:#fee2e2,stroke:#dc2626
    classDef tier2 fill:#fef3c7,stroke:#a16207
    classDef verdict fill:#dcfce7,stroke:#15803d

    CODE["Code/Changes"]:::input

    subgraph Tier1["Tier 1: Critical (Blocking)"]
        CROSS_VERIFY["Cross-Verification<br/>weight: 0.30<br/>threshold: 0.80"]:::tier1
        SECURITY["Security Checks<br/>weight: 0.30<br/>No injection, XSS, secrets"]:::tier1
        ERROR_HANDLING["Error Handling<br/>weight: 0.20<br/>Proper exceptions"]:::tier1
        BREAKING["Breaking Changes<br/>weight: 0.20<br/>API compatibility"]:::tier1
    end

    TIER1_CHECK{All Tier 1<br/>Checks Pass?}:::tier1

    BLOCKED["VERDICT: BLOCKED<br/>Critical failure"]:::tier1

    subgraph Tier2["Tier 2: Quality (Advisory)"]
        BUGS["Bug Detection<br/>weight: 0.25<br/>Logic errors"]:::tier2
        PERF["Performance<br/>weight: 0.25<br/>No O(n²)"]:::tier2
        MAINT["Maintainability<br/>weight: 0.25<br/>Complexity < 15"]:::tier2
        TESTS["Test Coverage<br/>weight: 0.25<br/>>= 80% coverage"]:::tier2
    end

    TIER2_SCORE["Calculate Tier 2 Score<br/>(weighted average)"]:::tier2

    TIER2_CHECK{Score >= 0.60?}:::tier2

    APPROVED["VERDICT: APPROVED<br/>All checks pass"]:::verdict
    NEEDS_REVIEW["VERDICT: NEEDS_REVIEW<br/>Quality concerns"]:::tier2

    CODE --> CROSS_VERIFY
    CODE --> SECURITY
    CODE --> ERROR_HANDLING
    CODE --> BREAKING

    CROSS_VERIFY --> TIER1_CHECK
    SECURITY --> TIER1_CHECK
    ERROR_HANDLING --> TIER1_CHECK
    BREAKING --> TIER1_CHECK

    TIER1_CHECK -->|Any Fail| BLOCKED
    TIER1_CHECK -->|All Pass| BUGS

    BUGS --> TIER2_SCORE
    PERF --> TIER2_SCORE
    MAINT --> TIER2_SCORE
    TESTS --> TIER2_SCORE

    TIER2_SCORE --> TIER2_CHECK

    TIER2_CHECK -->|>= 0.60| APPROVED
    TIER2_CHECK -->|< 0.60| NEEDS_REVIEW
```

**Tier 1 Checks (All Must Pass):**

| Check | Weight | Description |
|-------|--------|-------------|
| Cross-Verification | 0.30 | Multiple agents agree (≥80% consensus) |
| Security | 0.30 | No vulnerabilities (injection, XSS, secrets) |
| Error Handling | 0.20 | Proper exceptions, no silent failures |
| Breaking Changes | 0.20 | API compatibility maintained |

**Tier 2 Checks (Weighted Score ≥ 0.60):**

| Check | Weight | Description |
|-------|--------|-------------|
| Bug Detection | 0.25 | No logic errors, null refs, off-by-one |
| Performance | 0.25 | No O(n²), memory leaks, blocking I/O |
| Maintainability | 0.25 | Clear naming, complexity < 15 |
| Test Coverage | 0.25 | ≥80% coverage for changes |

**Verdicts:**

- **APPROVED**: Tier 1 passes, Tier 2 score ≥ 0.60
- **NEEDS_REVIEW**: Tier 1 passes, Tier 2 score < 0.60
- **BLOCKED**: Any Tier 1 check fails

---

## Related Documents

- [CLAUDE.md](../CLAUDE.md) - Repository overview and usage guide
- [.claude/CLAUDE.md](../.claude/CLAUDE.md) - Orchestration guide (deployed to ~/.claude/)
- [bootstrap.sh](../bootstrap.sh) - Bootstrap script source
- [parallel_agent.sh](../.claude/scripts/parallel_agent.sh) - Orchestration script source
- [command_config.yml](../.claude/config/command_config.yml) - Command configuration
- [validation_criteria.yml](../.claude/config/validation_criteria.yml) - Validation rules
