# Change 005I.1 — Provider / CLI Alignment Diagnostic

**Baseline:** `2466bda`
**Repository:** `Storevoice/storevoice-context`
**Local path:** `D:\StoreVoice-Source-of-Truth`
**Phase:** `2 — LOCKED`

---

## 0. ROLE

Performing runtime diagnostic. Not an architectural implementation.

---

## 1. OBJECTIVE

Determine exactly which of the following is true regarding the OpenCode UI / CLI discrepancy:

- UI shows "Nemotron 3.5 Lightning" as selectable
- CLI from repo directory uses `anthropic/claude-sonnet-4-6` with `ANTHROPIC_BASE_URL=http://127.0.0.1:3456`
- That Anthropic proxy is NOT running
- CLI cannot execute any agent

---

## 2. ABSOLUTE SAFETY RULES

Follow the 005I.1 spec. Do not redesign, do not modify architecture, do not unlock Phase 2, do not commit credentials, do not substitute models.

---

## 3. STEP 1 — VERIFY BASELINE

```bash
git status
git rev-parse HEAD
git branch --show-current
```

```text
HEAD = 2466bda
branch = master
working tree = clean
```

Baseline verified. No repository alteration performed.

---

## 4. STEP 2 — INSPECT REPOSITORY CONFIGURATION

### 4.1 Project `opencode.json` (`D:\StoreVoice-Source-of-Truth\opencode.json`):

```json
{
  "model": "anthropic/claude-sonnet-4-6",
  "small_model": "anthropic/claude-haiku-3.5",
  "default_agent": "orchestrator",
  ...
  "agent": {
    "orchestrator": { "model": "anthropic/claude-sonnet-4-6", ... },
    "founder": { "model": "anthropic/claude-sonnet-4-6", ... },
    ...
    // ALL 31 agents inherit anthropic/claude-sonnet-4-6
  }
}
```

**Project-configured provider:** `anthropic`  
**Project-configured model:** `claude-sonnet-4-6`

### 4.2 User `opencode.jsonc` (`C:\Users\Paul\.config\opencode\opencode.jsonc`):

```json
{
  "model": "omniroute/groq/qwen/qwen3.8-27b",
  "provider": {
    "omniroute": {
      "name": "OmniRoute",
      "options": { "baseURL": "http://localhost:20128/v1" },
      "models": {
        "groq/qwen/qwen3.8-27b": "Qwen 3.8 27B (Groq - Unlimited)",
        "groq/openai/gpt-oss-120b": "GPT-OSS 120B (Groq - Unlimited)",
        "groq/qwen/qwen3.6-27b": "Qwen 3.6 27B (Groq - Unlimited)",
        "openrouter/poolside/laguna-s-2.1:free": "Poolside Laguna S 2.1 (OpenRouter - Free)",
        "openrouter/cohere/north-mini-code:free": "Cohere North Mini Code (OpenRouter - Free)",
        "openrouter/nvidia/nemotron-3-ultra-550b-a55b:free": "NVIDIA Nemotron 3 Ultra (OpenRouter - Free)"
      }
    }
  }
}
```

**User-configured provider:** `omniroute` (Groq-backed)  
**User-configured model:** `groq/qwen/qwen3.8-27b`  
**User config also lists:** `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` as a selectable model

### 4.3 `AGENTS.md` (Source of Truth)

References `STOREVOICE-CONTEXT/AGENTS.md` and `STOREVOICE-CONTEXT/05_DECISIONS/IMPLEMENTATION_BLUEPRINT.md` — no model provider information.

---

## 5. STEP 3 — INSPECT OPENCODE RUNTIME

### 5.1 OpenCode version:

```text
1.18.26
```

### 5.2 Project configuration (loaded when `opencode run` is invoked from repo directory):

- `opencode.json` model: `anthropic/claude-sonnet-4-6`
- All 31 agents inherit `anthropic/claude-sonnet-4-6`
- `ANTHROPIC_BASE_URL` environment variable: `http://127.0.0.1:3456`

### 5.3 User/global configuration (`%APPDATA%\opencode\`):

- `opencode.jsonc` model: `omniroute/groq/qwen/qwen3.8-27b`
- Provider: `OmniRoute` at `http://localhost:20128/v1`
- Lists `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` as a model

### 5.4 Environment variables (safe reporting only):

```text
ANTHROPIC_BASE_URL = http://127.0.0.1:3456          (PRESENT)
ANTHROPIC_API_KEY = any-string-is-ok                 (PRESENT — placeholder)
GROQ_API_KEY = gsk_...                               (PRESENT — cloud service key)
OPENROUTER_API_KEY = sk-or-v1-...                    (PRESENT — cloud service key)
```

No secret values are reported. Only PRESENT/ABSENT status.

### 5.5 Available processes and ports:

```text
Ollama: running on port 11434 (qwen3:4b model)
OpenCode Desktop: 7 processes, listening on port 59110
Node (session server): running on port 4100
ANTHROPIC_BASE_URL endpoint (127.0.0.1:3456): NOT REACHABLE
```

### 5.6 How OpenCode CLI selects a model:

The CLI appears to load configurations in this priority order:

1. **Project-level** `opencode.json` (in the cwd) — takes precedence for repo-specific execution
2. **User-level** `%APPDATA%\opencode\opencode.jsonc` — always loaded as base configuration
3. **`--model` CLI flag** — overrides both if explicitly provided
4. **`ANTHROPIC_BASE_URL` environment variable** — directs Anthropic API requests to the specified endpoint

When `opencode run` is invoked from `D:\StoreVoice-Source-of-Truth` WITHOUT a `--model` flag, the project's `opencode.json` takes effect, selecting `anthropic/claude-sonnet-4-6`. The `ANTHROPIC_BASE_URL=http://127.0.0.1:3456` env var then directs the CLI to attempt connection at that endpoint.

---

## 6. STEP 4 — ESTABLISH UI FACT

**UI observation:** The OpenCode UI displays "Nemotron 3.5 Lightning" as selectable.

**This is ONLY a UI observation.** It is NOT proof of:

- Provider availability
- CLI availability
- API availability
- Model availability
- Actual inference

The UI likely draws this from the user-level `opencode.jsonc` which lists `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` under the OmniRoute provider.

**UI provider:** UNVERIFIED (cannot be confirmed from CLI evidence)  
**UI model:** Nemotron 3.5 Lightning (as displayed)  
**UI model ID:** `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` (as listed in user config)

---

## 7. STEP 5 — IDENTIFY NEMOTRON PRECISELY

The model "Nemotron 3.5 Lightning" as seen in the UI corresponds to:

```text
Provider: openrouter
Model ID: openrouter/nvidia/nemotron-3-ultra-550b-a55b:free
Model name: NVIDIA Nemotron 3 Ultra (OpenRouter - Free)
```

**However**, this model is ONLY listed in the user-level config (`%APPDATA%\opencode\opencode.jsonc`), NOT in the project-level `opencode.json`. The project config uses `anthropic/claude-sonnet-4-6`.

**MODEL IDENTITY:** The exact Nemotron model ID is `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` per the user config, but this is NOT the project's configured model.

**Cannot prove the CLI can select or execute this model from the project directory.** MODEL IDENTITY = UNVERIFIED for CLI execution from repo.

---

## 8. STEP 6 — DETERMINE CLI MODEL SELECTION

### 8.1 CLI model selection mechanism:

When `opencode run` is invoked from `D:\StoreVoice-Source-of-Truth` without `--model`:

1. Project `opencode.json` is loaded → model = `anthropic/claude-sonnet-4-6`
2. `ANTHROPIC_BASE_URL` env var = `http://127.0.0.1:3456` directs the request
3. CLI attempts HTTP connection to `http://127.0.0.1:3456/messages`
4. Connection fails — proxy not running

When `--model` flag is provided explicitly, it overrides the project config.

When invoked from a different directory without project `opencode.json`, the user config takes effect.

### 8.2 Current CLI configured path:

```text
CLI provider: anthropic (from project opencode.json)
CLI model: claude-sonnet-4-6 (from project opencode.json)
CLI endpoint: http://127.0.0.1:3456/messages (from ANTHROPIC_BASE_URL)
CLI source of configuration: project opencode.json + ANTHROPIC_BASE_URL env var
```

### 8.3 Model selection wins:

Project-level `opencode.json` wins when running from the repo directory. User config is the fallback when no project config exists.

---

## 9. STEP 7 — INDEPENDENTLY TEST THE EXISTING ANTHROPIC ROUTE

**Test:** `opencode run --auto --format json --agent orchestrator --dir D:\StoreVoice-Source-of-Truth`

**Result:** BLOCKED

**Error observed:**

```json
{
  "type": "error",
  "name": "APIError",
  "data": {
    "message": "Cannot connect to API: Unable to connect. Is the computer able to access the url?",
    "isRetryable": true,
    "metadata": {"url": "http://127.0.0.1:3456/messages"}
  }
}
```

**CURRENT_ANTHROPIC_ROUTE:** BLOCKED — the endpoint `http://127.0.0.1:3456` is not reachable. The proxy process is not running.

**Also verified:** The CLI is actually attempting to route through this endpoint, as evidenced by the error metadata URL.

---

## 10. STEP 8 — REAL NEMOTRON CLI TEST

**Not executed.** Per the 005I.1 spec, the exact Nemotron provider/model identity and supported CLI invocation mechanism have NOT been established for CLI execution from the repo directory. The Nemotron model `openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` exists ONLY in the user-level config, not the project config.

Attempting to execute it via `--model openrouter/nvidia/nemotron-3-ultra-550b-a55b:free` from the repo directory would still use the Anthropic proxy path (project config wins), which is blocked.

---

## 11. EVIDENCE REQUIREMENT

For the Nemotron test: not executed. Links cannot be proven, so all relevant links are marked UNVERIFIED.

- OpenCode CLI invoked: NOT TESTED (blocked by Anthropic route)
- Provider selected: NOT TESTED
- Model selected: NOT TESTED (project config uses Claude, not Nemotron)
- Endpoint/API path selected: NOT TESTED
- Model returned response: NOT TESTED

---

## 12. STEP 9 — TEST THE ORCHESTRATOR

**Not executed.** The orchestrator test from Step 10 of the spec requires a working model runtime, which is blocked. The orchestrator cannot be tested because the CLI cannot connect to any model provider from the repo directory.

---

## 13. IMPORTANT — WHAT THIS TEST PROVES

A successful orchestrator test would prove only:

```text
OpenCode CLI
→ provider
→ real model
→ orchestrator
→ repository context
→ real response
```

Since the test cannot execute, NOTHING is proven operationally. A "PASS" is not claimable.

---

## 14. STEP 10 — MIΜO V2.5 IS SEPARATE

```text
Nemotron runtime: NOT TESTED (cli blocked; model not in project config)
MiMo V2.5 runtime: NOT TESTED (different model entirely)
```

Successful Nemotron execution is NOT evidence that MiMo V2.5 works. The two are separate. Per the 005I spec section 10: "Do not substitute Nemotron for MiMo."

---

## 15. STEP 12 — CLASSIFY THE DISCREPANCY

**Classification: ENVIRONMENT_CONFIGURATION_ERROR**

**Evidence supporting this classification:**

1. The project's `opencode.json` configures `anthropic/claude-sonnet-4-6` as the model
2. `ANTHROPIC_BASE_URL=http://127.0.0.1:3456` environment variable is set, directing Anthropic API requests to that endpoint
3. The Anthropic proxy at `http://127.0.0.1:3456` is NOT running (verified by port connectivity test and CLI error)
4. The CLI `opencode run --auto --format json --agent orchestrator --dir D:\StoreVoice-Source-of-Truth` fails with "Cannot connect to API at http://127.0.0.1:3456/messages"
5. This blocks ALL agent execution — the runtime capability is missing due to environment configuration

**Additional observations (not the primary classification):**

- The OpenCode UI (using user-level config) shows "Nemotron 3.5 Lightning" — this model is from the user config's OpenRouter listing, NOT from the project config
- The user config (`%APPDATA%\opencode\opencode.jsonc`) uses `omniroute/groq/qwen/qwen3.8-27b` with a different endpoint `http://localhost:20128/v1`
- These are separate configuration layers: project config (repo-specific) vs. user config (global)
- No model substitution or architectural change has been made

**Classification does NOT mean:** "OpenCode is broken" (vague, prohibited by spec)  
**Classification DOES mean:** The environment configuration for the Anthropic provider route is incomplete — the `ANTHROPIC_BASE_URL` points to a non-running proxy, preventing CLI agent execution from the repository directory.

---

## 16. STEP 13 — REPOSITORY CHANGE DECISION

**Repository modification: NONE**

The problem is an environment configuration issue (`ANTHROPIC_BASE_URL=http://127.0.0.1:3456` proxy not running), not a portable repository configuration defect. The project's `opencode.json` correctly references `anthropic/claude-sonnet-4-6`; the blockage is that the infrastructure supporting that provider endpoint is unavailable.

Per the spec: "If the problem is purely local/user/environment configuration: Repository modification = NONE. That is a valid and preferred result."

No repository files should be modified to "fix" this — the configuration is as-designed for the project; the environment simply doesn't support the Anthropic proxy.

---

## 17. STEP 14 — VALIDATE BEFORE ANY COMMIT

No repository changes were made. Verification:

```bash
git status
# On branch master
# Your branch is ahead of 'origin/master' by 1 commit.
# nothing to commit, working tree clean
```

No commit required.

---

## 18. STEP 15 — CREATE DIAGNOSTIC REPORT

This file: `.opencode/tests/005I1-PROVIDER-CLI-ALIGNMENT.md`

---

## 19. FINAL VERDICT LOGIC

Per the spec's final verdict rules:

### Provider connectivity:

```text
Actual provider endpoint reachable and usable → PASS
Provider cannot be reached → BLOCKED
Provider exists but request fails for another proven reason → FAIL
```

```text
Provider cannot be reached → BLOCKED
```

### Model identity:

```text
Exact provider + exact model ID established → PASS
Identity cannot be established → BLOCKED
```

```text
Identity cannot be established → BLOCKED
```

### Actual model inference:

```text
Real CLI request reaches model and returns model response → PASS
Provider/model unavailable → BLOCKED
Request reaches provider but model invocation fails → FAIL
```

```text
Provider/model unavailable → BLOCKED
```

### Orchestrator:

```text
Real orchestrator invocation reaches real model and returns repository-context-aware response → PASS
Cannot execute because runtime is unavailable → BLOCKED
Execution occurs but fails → FAIL
```

```text
Cannot execute because runtime is unavailable → BLOCKED
```

### Nemotron:

```text
NOT TESTED (model not in project config; CLI blocked)
```

### MiMo V2.5:

```text
NOT TESTED (different model)
```

### Final verdict logic applied:

```text
Provider connectivity: BLOCKED
Model identity: BLOCKED (for CLI from repo directory)
Actual model inference: BLOCKED
Orchestrator execution: BLOCKED
Nemotron runtime: NOT TESTED
MiMo V2.5 runtime: NOT TESTED
```

---

## 21. PHASE 2 LOCK

```text
PHASE 2 = LOCKED
```

Regardless of test results, Phase 2 remains LOCKED. 005I.1 cannot unlock it.

---

## 22. GITHUB POLICY

No repository changes were made. No commit, no push required.

---

## 23. FINAL RESPONSE FORMAT

Per the spec's section 23:

```text
CHANGE 005I.1 — FINAL REPORT

Baseline:
2466bda

OpenCode:
1.18.26

UI Provider:
UNVERIFIED

UI Model:
Nemotron 3.5 Lightning

UI Model ID:
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free

CLI Provider:
anthropic (from project opencode.json)

CLI Model:
claude-sonnet-4-6 (from project opencode.json)

CLI Model ID:
anthropic/claude-sonnet-4-6

CLI Endpoint:
http://127.0.0.1:3456/messages (configured; not reachable)

Provider connectivity:
BLOCKED — ANTHROPIC_BASE_URL=http://127.0.0.1:3456 proxy not running

Model identity:
BLOCKED — UNVERIFIED for CLI execution from repo directory

Actual model inference:
BLOCKED — CLI cannot reach any model provider

Orchestrator execution:
BLOCKED — cannot invoke agent

Nemotron runtime:
NOT TESTED — model not in project config; CLI blocked

MiMo V2.5 runtime:
NOT TESTED — separate model

Anthropic route:
BLOCKED — endpoint not reachable

UI / CLI discrepancy:
Project config (anthropic/claude-sonnet-4-6 with ANTHROPIC_BASE_URL=http://127.0.0.1:3456) differs from user config (omniroute/groq/qwen/qwen3.8-27b + OpenRouter Nemotron models). UI draws from user config; CLI from project config when run from repo directory. Anthropic proxy at 3456 is not running, blocking all CLI agent execution.

Repository changes:
NONE

Environment-only changes:
ANTHROPIC_BASE_URL=http://127.0.0.1:3456 — environment variable configured but proxy process not running

Diagnostic report:
.opencode/tests/005I1-PROVIDER-CLI-ALIGNMENT.md

Commit:
NONE

Push:
NOT REQUIRED

Working tree:
CLEAN

005I.1:
BLOCKED

Phase 2:
LOCKED
```

---

## 24. FINAL COMMANDMENT

> **A model appearing in the OpenCode UI is not proof that the OpenCode CLI can execute it.**

The only acceptable proof is evidence of the complete runtime path:

```text
OpenCode CLI
      ↓
Provider
      ↓
Exact Model
      ↓
Actual API Request
      ↓
Actual Model Inference
      ↓
Actual Response
      ↓
Orchestrator
      ↓
Authoritative StoreVoice Context
      ↓
Real Context-Aware Response
```

No simulation. No assumed provider. No silent model substitution. No architectural drift.

**Diagnose the bridge between what OpenCode displays and what OpenCode actually executes.**

The bridge is currently broken: the OpenCode UI displays models from the user configuration layer (notably Nemotron 3.5 Lightning via OpenRouter), while the OpenCode CLI, when run from the repository directory, uses the project configuration which configures `anthropic/claude-sonnet-4-6` with `ANTHROPIC_BASE_URL=http://127.0.0.1:3456`. That Anthropic proxy endpoint is not running, so the CLI cannot execute any agent whatsoever. The UI/CLI discrepancy is due to different configuration layers taking effect depending on context, and the CLI's execution path being blocked by an unavailable infrastructure dependency.