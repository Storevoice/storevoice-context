# Change 005I.2 — Final Report

Baseline:
2466bda

OpenCode:
1.18.26

Project Provider:
anthropic (from project opencode.json)

Project Model:
claude-sonnet-4-6 (from project opencode.json)

Project Model ID:
anthropic/claude-sonnet-4-6

UI Provider:
UNVERIFIED

UI Model:
Nemotron 3.5 Lightning

UI Model ID:
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free

MiMo Provider:
UNVERIFIED

MiMo Model ID:
NOT FOUND

Nemotron Provider:
openrouter (from user config)

Nemotron Model ID:
openrouter/nvidia/nemotron-3-ultra-550b-a55b:free

Anthropic Endpoint:
http://127.0.0.1:3456/messages (configured; not reachable)

MiMo Endpoint:
UNVERIFIED

Nemotron Endpoint:
UNVERIFIED (not project-configured; UI-visible only)

Claude runtime:
BLOCKED — ANTHROPIC_BASE_URL=http://127.0.0.1:3456 proxy not running

Nemotron runtime:
NOT TESTED — model not in project config; CLI blocked from repo directory

MiMo V2.5 runtime:
NOT FOUND — not configured in any OpenCode configuration (project or user)

Provider connectivity:
BLOCKED — ANTHROPIC_BASE_URL proxy not running

Model identity:
BLOCKED — UNVERIFIED for CLI execution from repo directory

Actual model inference:
BLOCKED — CLI cannot reach any model provider from repo directory

Orchestrator compatibility:
BLOCKED — cannot invoke agent

Root cause:
ENVIRONMENT_CONFIGURATION_ERROR — Project opencode.json configures anthropic/claude-sonnet-4-6 with ANTHROPIC_BASE_URL=http://127.0.0.1:3456; the Anthropic proxy endpoint is not running, blocking all CLI agent execution. The project configuration itself is valid; the blockage is environmental.

Configuration discrepancy:
Project config (anthropic/claude-sonnet-4-6 with ANTHROPIC_BASE_URL) differs from user config (omniroute/groq/qwen/qwen3.8-27b + OpenRouter Nemotron models). When opencode run is invoked from the repository directory, the project-level opencode.json takes precedence, selecting the Anthropic model. The user config's Nemotron 3.5 Lightning is visible/selectable in the OpenCode UI but is not the project-configured model and cannot be executed from the repo directory. The Anthropic proxy at 3456 is not running, blocking all CLI agent execution.

Repository changes:
NONE

Environment-only changes:
ANTHROPIC_BASE_URL=http://127.0.0.1:3456 — environment variable configured but proxy process not running; GROQ_API_KEY and OPENROUTER_API_KEY present as cloud service keys but not routed through project configuration

Diagnostic report:
.opencode/tests/005I1-PROVIDER-CLI-ALIGNMENT.md

Commit:
NONE

Push:
NOT REQUIRED

Working tree:
CLEAN

005I.2:
BLOCKED

Phase 2:
LOCKED