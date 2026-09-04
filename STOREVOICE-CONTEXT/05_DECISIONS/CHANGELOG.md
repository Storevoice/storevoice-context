# CHANGELOG.md — StoreVoice Source of Truth Changes

**Purpose:** Records all changes made to the StoreVoice Source of Truth.

**Status:** DECISION

**Scope:** This document serves as the change log for the Source of Truth repository.

---

## Change Log

| Date | File | Change Type | Description | Changed By |
|------|------|-------------|-------------|------------|
| 2026-09-04 | Multiple | CREATED | Phase 1: Initialize StoreVoice Source of Truth repository | Change 001 |
| 2026-09-04 | Multiple | UPDATED | Establish frozen voice engine reference | Change 001 |
| 2026-09-04 | 00_CORE/VISION.md | UPDATED | Establish founder-approved StoreVoice vision | Change 002 |
| 2026-09-04 | 00_CORE/PRODUCT_CONTRACT.md | UPDATED | Establish product definition and scope | Change 002 |
| 2026-09-04 | 00_CORE/BUSINESS_RULES.md | UPDATED | Establish business rules and pricing | Change 002 |
| 2026-09-04 | 02_DESIGN/UX_RULES.md | UPDATED | Establish AI colleague experience principles | Change 002 |
| 2026-09-04 | 05_DECISIONS/DECISIONS.md | UPDATED | Record Change 002 decisions | Change 002 |
| 2026-09-04 | 05_DECISIONS/CHANGELOG.md | UPDATED | Record Change 002 changes | Change 002 |
| 2026-09-04 | 05_DECISIONS/FOUNDER_DECISION_SET.md | CREATED | Consolidate founder decision set | Change 003A |
| 2026-09-04 | 05_DECISIONS/FOUNDER_DECISION_TO_PLATFORM_REQUIREMENTS.md | CREATED | Derive platform requirements from founder decisions | Change 003A |
| 2026-09-04 | 05_DECISIONS/OPEN_DECISIONS.md | CREATED | Record unresolved decisions | Change 003A |
| 2026-09-04 | 05_DECISIONS/CAPABILITY_GAP_ANALYSIS.md | CREATED | Architecture readiness capability analysis | Change 003B |
| 2026-09-04 | 05_DECISIONS/ARCHITECTURE_DECISION_REGISTER.md | CREATED | Architecture decision map for future design | Change 003C |
| 2026-09-04 | 05_DECISIONS/ARCHITECTURE_FOUNDER_QUESTIONS.md | CREATED | Questions requiring Founder authority | Change 003C |
| 2026-09-04 | 05_DECISIONS/ARCHITECTURE_DECISION_PACKAGES.md | CREATED | Organized decision packages for systematic decision-making | Change 004A |
| 2026-09-04 | 05_DECISIONS/OPEN_DECISIONS.md | UPDATED | Cross-referenced architecture decisions | Change 004A |
| 2026-09-04 | 05_DECISIONS/ARCHITECTURE_FOUNDER_QUESTIONS.md | UPDATED | Resolved 6 Founder questions, updated status to DECISION | Change 004B |
| 2026-09-04 | 05_DECISIONS/ARCHITECTURE_DECISION_REGISTER.md | UPDATED | Traced 18 decisions to frozen Founder decisions | Change 004B |
| 2026-09-04 | 05_DECISIONS/DECISIONS.md | UPDATED | Recorded 6 Founder-authorized architecture decisions | Change 004B |
| 05_DECISIONS/FOUNDER_DECISION_TO_PLATFORM_REQUIREMENTS.md | UPDATED | Added frozen Founder decisions to 6 platform requirements sections | Change 004B |
| 05_DECISIONS/ARCHITECTURE_FOUNDER_QUESTIONS.md | UPDATED | Prepared Founder Decision Session for FQ-03, FQ-04, FQ-06, FQ-10 | Change 004B.1 |
| 05_DECISIONS/ARCHITECTURE_FOUNDER_QUESTIONS.md | UPDATED | Marked FQ-03, FQ-04, FQ-06, FQ-10 as RESOLVED; all 10 Founder Questions now resolved | Change 004B.2 |
| 05_DECISIONS/ARCHITECTURE_DECISION_REGISTER.md | UPDATED | Added 4 frozen Founder decisions from Change 004B.2 | Change 004B.2 |
| 05_DECISIONS/DECISIONS.md | UPDATED | Recorded 4 Founder-authorized architecture decisions from Change 004B.2 | Change 004B.2 |
| 05_DECISIONS/FOUNDER_DECISION_TO_PLATFORM_REQUIREMENTS.md | UPDATED | Added frozen Founder decisions to platform requirements sections for FQ-03, FQ-04, FQ-06, FQ-10 | Change 004B.2 |
| 05_DECISIONS/FOUNDER_DECISION_SET.md | UPDATED | Added sections 6.31-6.34 for FQ-03, FQ-04, FQ-06, FQ-10 | Change 004B.2 |
| 01_ARCHITECTURE/ARCHITECTURE.md | UPDATED | Complete target architecture design with 35 required sections | Change 004C |
| 01_ARCHITECTURE/SYSTEM_MAP.md | UPDATED | Comprehensive system map with Mermaid diagrams | Change 004C |
| 01_ARCHITECTURE/INTEGRATION_RULES.md | UPDATED | Complete integration rules and provider abstraction | Change 004C |
| 05_DECISIONS/ARCHITECTURE_VALIDATION_004D.md | CREATED | Architecture validation report with 20 findings across all domains | Change 004D |
| 05_DECISIONS/CHANGELOG.md | UPDATED | Recorded Change 004D entries | Change 004D |
| 05_DECISIONS/IMPLEMENTATION_BLUEPRINT.md | CREATED | Complete implementation blueprint with 35 sections (A-AI), 15 implementation phases, 5 specification gap resolutions | Change 004E |
| 05_DECISIONS/CHANGELOG.md | UPDATED | Recorded Change 004E entries | Change 004E |
| 05_DECISIONS/FOUNDER_DECISION_SET.md | UPDATED | Added FD-11 through FD-16: Visual Design Authority, Design System First, Content Ownership, Product Management, Agent Orchestration Before Phase 2, Visual and UX Verification (sections 6.35-6.40) | Change 005D |
| 05_DECISIONS/IMPLEMENTATION_BLUEPRINT.md | UPDATED | Expanded agent organization from 17 engineering roles to complete commercial product organization (40 roles); added orchestration model, context propagation, handoffs, dependency model, failure handling, revision loops, design-to-code pipeline, commercial quality gate, no fabrication rule, design autopilot, continuous improvement loop | Change 005D |
| 05_DECISIONS/DECISIONS.md | UPDATED | Recorded FD-11 through FD-16 as Founder-approved decisions | Change 005D |
| 04_AI_WORKFLOW/QUALITY_GATES.md | UPDATED | Added multi-dimensional quality gates: technical, product, UX, visual, brand, copy, commercial, operational, trust, European | Change 005D |
| 04_AI_WORKFLOW/DEVELOPMENT_WORKFLOW.md | UPDATED | Added agent orchestration workflow, design-to-code pipeline, revision loop, authority escalation | Change 005D |
| 05_DECISIONS/IMPLEMENTATION_BLUEPRINT.md | UPDATED | Replaced Section AB with complete Agent Topology & Orchestration Specification (31 agents across 10 layers, capability-to-agent matrix, context architecture, handoff contract, artifact model, dependency model, revision model, failure model, human escalation, autonomous execution loop, change classification, commercial acceptance, agent scorecard, OpenCode implementation contract, Phase 2 gate) | Change 005E |
| .opencode/ | CREATED | Implemented OpenCode agent organization with 31 agents across 10 layers | Change 005F |
| opencode.json | CREATED | OpenCode configuration with agent definitions, permissions, and references | Change 005F |
| .opencode/agent/ | CREATED | Agent definitions for all 31 agents with proper boundaries and permissions | Change 005F |
| .opencode/orchestration/ | CREATED | Orchestration infrastructure specifications (context, artifacts, state, dependencies, revision, failure, scope, escalation, audit, Phase 2 gate) | Change 005F |
| .opencode/tests/ | CREATED | Orchestration test suite (end-to-end, fresh-context, revision, failure-isolation, scope-violation, escalation, parallelism) | Change 005F |

---

## Change Types

- **CREATED** — New file or directory created
- **UPDATED** — Existing file modified
- **DELETED** — File or directory removed
- **MOVED** — File or directory relocated

---

## Change Template

When recording a new change:

```
### [Date] — [File/Directory Path]

**Change Type:** [CREATED / UPDATED / DELETED / MOVED]
**Changed By:** [Who made the change]
**Reason:** [Why the change was made]
**Impact:** [What this change affects]
**Approval:** [Who approved the change]
```

---

## Rules for Future Updates

- All changes to the Source of Truth must be recorded here
- Changes require human owner approval (except for initial setup)
- All modifications must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 005F — OpenCode Agent Organization & Orchestrator Implementation