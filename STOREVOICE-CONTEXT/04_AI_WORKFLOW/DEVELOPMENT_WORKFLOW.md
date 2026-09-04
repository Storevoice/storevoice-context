# DEVELOPMENT_WORKFLOW.md — StoreVoice Development Process

**Purpose:** Defines the development workflow for StoreVoice.

**Status:** TO BE CONFIRMED

**Scope:** This document establishes how development work is organized and executed.

---

## Development Workflow Overview

**Status:** DECISION

StoreVoice is developed as a multi-disciplinary autonomous product organization, not simply a coding-agent swarm.

The workflow follows the complete product lifecycle:

```text
DISCOVER
  ↓
DEFINE
  ↓
SPECIFY
  ↓
DESIGN
  ↓
FREEZE
  ↓
BUILD
  ↓
TEST
  ↓
REVIEW
  ↓
RED TEAM
  ↓
COMMERCIAL VALIDATION
  ↓
UX/VISUAL VALIDATION
  ↓
ACCEPT
  ↓
COMMIT
  ↓
AUDIT AGAIN
```

### Agent Orchestration

The Orchestrator coordinates all agent activities:

* decomposes approved work
* determines dependencies
* selects appropriate agents
* provides required context
* dispatches work
* collects artifacts
* tracks status
* detects blockers
* initiates reviews
* initiates revisions
* coordinates parallel work
* enforces gates
* escalates unresolved authority conflicts
* verifies completion

### Dependency Types

**Sequential** — One output required before another agent begins.

**Parallel** — Independent workstreams operating simultaneously.

**Gated** — Downstream implementation waits for approval or validation.

### Revision Loop

When work fails validation:

```text
BUILD
 ↓
TEST
 ↓
AUDIT
 ↓
FAIL
 ↓
IDENTIFY FAILURE OWNER
 ↓
RETURN CONTEXT + FINDINGS
 ↓
REVISE
 ↓
RETEST
 ↓
RE-AUDIT
```

### Authority Escalation

If an agent encounters conflicting decisions, missing decisions, or authority conflicts:

**STOP → IDENTIFY → DOCUMENT → ESCALATE**

The Orchestrator surfaces the issue to the correct authority.

---

## Branching Strategy

[TO BE CONFIRMED]

How code branches are managed.

---

## Commit Standards

[TO BE CONFIRMED]

Standards for commit messages and practices.

---

## Code Review Process

[TO BE CONFIRMED]

How code reviews are conducted.

---

## Testing Requirements

[TO BE CONFIRMED]

What testing is required before deployment.

---

## Deployment Process

[TO BE CONFIRMED]

How code is deployed to production.

---

## Environment Management

[TO BE CONFIRMED]

How development, staging, and production environments are managed.

---

## Dependency Management

[TO BE CONFIRMED]

How dependencies are managed and updated.

---

## Documentation Requirements

[TO BE CONFIRMED]

What documentation is required for development work.

---

## Rules for Future Updates

- Development workflow changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** [TO BE CONFIRMED]
**Approved By:** [TO BE CONFIRMED]