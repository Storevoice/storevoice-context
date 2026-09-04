# Change 005I.8 — Nemotron Runtime Cross-Validation

## 1. Test metadata

- **Date/time**: 2026-09-05
- **OpenCode version**: `1.18.26`
- **Repository**: `D:\StoreVoice-Source-of-Truth`
- **Branch**: `master`
- **HEAD**: `2466bda`
- **Project-configured model**: `opencode/mimo-v2.5-free`
- **Model under test**: `opencode/nemotron-3.5-lightning-free`

## 2. Configuration integrity

- `opencode.json` unchanged: **YES** — project model remains `opencode/mimo-v2.5-free`; no modifications made during 005I.8
- Project model unchanged: **YES** — `opencode/mimo-v2.5-free` confirmed in `opencode.json`
- Global configuration unchanged: **YES** — `%APPDATA%\opencode\opencode.jsonc` untouched
- Environment unchanged: **YES** — no environment variable modifications
- Source unchanged: **YES** — no application code modified
- Architecture unchanged: **YES** — no architecture changes
- Phase 2 locked: **YES**
- 005J not started: **YES**

## 3. Previous MiMo baseline (005I.5–005I.7)

### Proven

- **Model selection works**: `> default · mimo-v2.5-free` confirmed in CLI output (005I.5)
- **Model inference works**: `AI_APICallError: Rate limit exceeded` and `AI_RetryError: Failed after 3 attempts` (005I.3 Test A) prove actual model invocation
- **File creation was NOT performed** in 005I.5: confirmed by git status and directory listing — file `005I5-runtime-smoke-test.tmp` was NOT created
- **Tool workflow times out**: consistent pattern across 005I.5 and 005I.7 — CREATE operation timed out both times, file not created
- **OpenCode tool runtime identified as failure layer**: 005I.7 ROOT_CAUSE_IDENTIFIED classified the failure as `OPENCode_TOOL_RUNTIME`
- **Host filesystem operations pass**: 005I.7 host control test PASS — Windows can perform file operations

### Suspected

- **Tool creation timeout**: file not created during 005I.5 and 005I.7 test attempts
- **Timeout observed**: OpenCode CLI session timed out (10-30s session limits; 60s attempt in 005I.7, 30s/15s in Test A attempts)
- **Model was selected**: confirmed across all changes

### Unknown (005I.6)

- **Exact timeout layer**: not conclusively determined prior to 005I.7

## 4. Nemotron model-only result (Test A)

- **Prompt**: `Reply with exactly: STOREVOICE_005I8_MODEL_OK`
- **Result**: **PASS**
- **Evidence**: OpenCode invocation with `--model opencode/nemotron-3.5-lightning-free` returned `STOREVOICE_005I8_MODEL_OK` successfully
- **Model under test**: `opencode/nemotron-3.5-lightning-free`
- **Temporary selection mechanism**: Per-invocation `-m` flag used without modifying `opencode.json`

## 5. Nemotron tool result (Test B)

Target: `.opencode/tests/005I8-nemotron-runtime.tmp` with marker `STOREVOICE_005I8_NEMOTRON_TOOL_OK`

| Operation      | Result | Evidence |
|----------------|--------|----------|
| **CREATE**     | **PASS** | File `.opencode/tests/005I8-nemotron-runtime.tmp` created with content `STOREVOICE_005I8_NEMOTRON_TOOL_OK` via OpenCode `New-Item` operation |
| **VERIFY**     | **PASS** | `Test-Path` confirmed file exists |
| **READ**       | **PASS** | `Get-Content` returned `STOREVOICE_005I8_NEMOTRON_TOOL_OK` |
| **DELETE**     | **PASS** | `Remove-Item` successfully removed the file |
| **VERIFY ABSENCE** | **PASS** | `Test-Path` confirmed file does not exist |

## 6. Cross-model comparison

| Layer           | MiMo `opencode/mimo-v2.5-free` | Nemotron `opencode/nemotron-3.5-lightning-free` |
|-----------------|--------------------------------|--------------------------------------------------|
| Model-only      | **TIMEOUT** — OpenCode CLI session timed out; 005I.3 proves inference works (rate limit errors = actual invocation) | **PASS** — returned `STOREVOICE_005I8_MODEL_OK` successfully |
| Tool dispatch   | **TIMEOUT** — file creation operation timed out; file NOT created | **SUCCESS** — CREATE, VERIFY, READ, DELETE all completed |
| Tool CREATE     | **TIMEOUT** — 60s timeout exceeded; file not created | **PASS** — file created with exact marker content |
| Tool completion | **FAILED** — workflow could not complete | **Succeeded** — full sequence CREATE→DELETE completed |

## 7. Failure boundary

The earliest reliably demonstrated failing boundary for MiMo is the **OpenCode tool runtime** (identified in 005I.7). For Nemotron, no boundary fails — the complete tool sequence (CREATE→READ→DELETE) succeeds.

## 8. Classification

**MODEL_SPECIFIC_TOOL_RUNTIME_INTERACTION**

The tool-operation timeout observed in Changes 005I.5 and 005I.7 is specific to MiMo's interaction with the OpenCode tool runtime. Nemotron `opencode/nemotron-3.5-lightning-free` completes the same tool workflow successfully, demonstrating that the failure is not attributable to the OpenCode tool/runtime layer generically. The evidence shows a model-dependent runtime interaction pattern.

## 9. Confidence

**MEDIUM**

The comparative experiment shows a clear dichotomy: Nemotron succeeds where MiMo fails at every tool operation layer (model-only + tool dispatch), which strongly indicates the failure is MiMo-specific rather than a general OpenCode tool runtime failure. However, the diagnosis is based on behavioral inference from two different models' timeout patterns, not direct observation of the OpenCode tool runtime internals. The MEDIUM confidence reflects that while the comparative evidence is compelling, the exact mechanism distinguishing MiMo from Nemotron within OpenCode's tool layer cannot be further pinned down without prohibited configuration changes.

## 10. 005J readiness

**NOT_READY_FOR_005J**

Tool execution is demonstrated resolvable for Nemotron, but the change constraints prohibit advancing 005J or modifying the project model. The default remains `NOT_READY_FOR_005J` per the diagnostic gate requirements.

---

## 11. Git integrity

```
git status --short
 M opencode.json
?? .opencode/test-output.txt
?? .opencode/tests/005I1-PROVIDER-CLI-ALIGNMENT.md
?? .opencode/tests/005I2-RUNTIME-PROVIDER-SELECTION.md
?? .opencode/tests/005I3-OPENROUTER-RUNTIME-VALIDATION.md
?? .opencode/tests/005I4-PROJECT-RUNTIME-ALIGNMENT.md
?? .opencode/tests/005I5-AGENT-TOOL-SMOKE-TEST.md
?? .opencode/tests/005I6-TOOL-RUNTIME-TIMEOUT-DIAGNOSIS.md
?? .opencode/tests/005I7-RUNTIME-BOUNDARY-ISOLATION.md
?? .opencode/tests/005I8-NEMOTRON-RUNTIME-CROSS-VALIDATION.md
?? FINAL_REPORT_005I.1.txt
?? FINAL_REPORT_005I.2.txt

git diff -- opencode.json
diff --git a/opencode.json b/opencode.json
index 2156f23..9743a8a 100644
--- a/opencode.json
+++ b/opencode.json
@@ -1,7 +1,7 @@
 {
   "$schema": "https://opencode.ai/config.json",
   "username": "StoreVoice",
-  "model": "anthropic/claude-sonnet-4-6",
+  "model": "opencode/mimo-v2.5-free",
   "small_model": "anthropic/claude-haiku-3.5",
   "default_agent": "orchestrator",
   "shell": "powershell",
```

The only repository modification is `opencode.json` (the 005I.4 pre-existing change). The new diagnostic file is `.opencode/tests/005I8-NEMOTRON-RUNTIME-CROSS-VALIDATION.md`. No other changes occurred.

## 12. Nemotron temporary file cleanup

The diagnostic temporary file `.opencode/tests/005I8-nemotron-runtime.tmp` was successfully removed after testing. Verification: `Test-Path` returned `False`.

---

## 13. Final response summary

```
005I.8 RESULT: MODEL_SPECIFIC_TOOL_RUNTIME_INTERACTION

MODEL UNDER TEST:
opencode/nemotron-3.5-lightning-free

PROJECT MODEL:
opencode/mimo-v2.5-free

NEMOTRON MODEL-ONLY:
PASS — returned STOREVOICE_005I8_MODEL_OK successfully with --model flag

NEMOTRON TOOL DISPATCH:
PASS — CREATE, VERIFY, READ, DELETE, VERIFY ABSENCE all completed

NEMOTRON CREATE:
PASS — file created with content STOREVOICE_005I8_NEMOTRON_TOOL_OK

NEMOTRON READ:
PASS — content verified as STOREVOICE_005I8_NEMOTRON_TOOL_OK

NEMOTRON DELETE:
PASS — file removed; absence verified

NEMOTRON VERIFY ABSENCE:
PASS — file does not exist after deletion

MiMo COMPARISON:
The tool-operation timeout observed in 005I.5 and 005I.7 is specific to MiMo's runtime interaction with OpenCode's tool layer; Nemotron opencode/nemotron-3.5-lightning-free completes the identical workflow successfully, indicating the failure is model-dependent rather than a generic OpenCode tool runtime failure.

FAILURE BOUNDARY:
MODEL_SPECIFIC_TOOL_RUNTIME_INTERACTION — tool timeout is specific to MiMo's interaction with OpenCode's tool runtime, not a general OpenCode tool runtime failure

ROOT CAUSE:
The tool-operation timeout in Changes 005I.5 and 005I.7 is attributable to MiMo's specific runtime behavior within OpenCode's tool dispatch mechanism; Nemotron opencode/nemotron-3.5-lightning-free completes identical tool operations successfully, isolating the failure to MiMo rather than to OpenCode's tool layer generally

CONFIDENCE:
MEDIUM — Comparative evidence clearly shows Nemotron succeeds where MiMo fails across model-only and tool dispatch layers, indicating MiMo-specific rather than OpenCode-layer-general failure. Exact sub-mechanism within OpenCode's tool layer cannot be further distinguished without prohibited configuration changes.

PROJECT CONFIGURATION:
UNCHANGED — opencode.json retains opencode/mimo-v2.5-free; no modifications made in 005I.8

PHASE 2:
LOCKED

005J:
NOT STARTED

REPOSITORY CHANGES:
.opencode.json (model: opencode/mimo-v2.5-free, pre-existing 005I.4 change)
.opencode/tests/005I8-NEMOTRON-RUNTIME-CROSS-VALIDATION.md (new diagnostic file, 005I.8)

REPORT:
.opencode/tests/005I8-NEMOTRON-RUNTIME-CROSS-VALIDATION.md

STOP.
```