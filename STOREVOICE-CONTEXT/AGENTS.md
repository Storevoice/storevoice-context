# AGENTS.md — AI Governance Rules

**Purpose:** Mandatory governance rules for all AI agents and human developers working with StoreVoice Source of Truth.

**Status:** TO BE CONFIRMED

---

## Mandatory Workflow

All AI agents must follow this exact sequence:

### THINK → SPECIFY → FREEZE → BUILD → TEST → AUDIT → COMMIT → FREEZE

### Step-by-step requirements:

1. **Understand the request** — Do not proceed without clear understanding.
2. **Inspect the existing system** — Review current state before making changes.
3. **Identify relevant files/components** — Know exactly what will be affected.
4. **Identify what is already working** — Do not break working functionality.
5. **Identify possible side effects** — Consider ripple effects.
6. **Propose the smallest coherent change** — Minimize scope.
7. **Check the Source of Truth** — Consult this repository before implementation.
8. **Implement only the approved scope** — Do not exceed authorized boundaries.
9. **Test the change** — Verify functionality.
10. **Audit for regressions** — Ensure nothing was broken.
11. **Report what changed** — Document modifications.
12. **Update the Source of Truth** — When a decision actually changed.
13. **Commit/freeze the resulting state** — When appropriate.

---

## Forbidden Actions

### NEVER:

* Redesign unrelated areas
* Change approved visual direction because of personal preference
* Change architecture without authorization
* Rewrite entire files unnecessarily
* Remove working functionality
* Invent requirements
* Turn assumptions into facts
* Silently resolve conflicting requirements
* Modify frozen components without explicit authorization

---

## Conflict Resolution

If a conflict exists:

**STOP → IDENTIFY CONFLICT → REPORT → REQUEST DECISION**

Do not attempt to resolve conflicts autonomously.

---

## Change Size Classification

### SMALL
Local, low-risk change.

**Process:** `INSPECT → IMPLEMENT → TEST`

### MEDIUM
Potentially affects multiple components.

**Process:** `INSPECT → IMPACT ANALYSIS → PLAN → IMPLEMENT → TEST → AUDIT`

### LARGE / ARCHITECTURAL
Changes architecture, product behaviour, major UX, design system, data model, integrations, or frozen components.

**Process:** `INSPECT → IMPACT ANALYSIS → PROPOSAL → STOP → OWNER APPROVAL → IMPLEMENT → TEST → AUDIT`

The AI must not independently convert a large change into an implementation decision.

---

## Authority Hierarchy

1. Human owner
2. Approved Source of Truth
3. Approved architectural/design/product decisions
4. Existing tested implementation
5. AI recommendations
6. AI assumptions

**AI recommendations are NOT decisions.**

The human owner has final authority over:
- Product
- Business model
- UX
- Visual direction
- Architecture
- Scope
- Major changes

---

## Information Classification

Every important piece of information must be distinguishable as:

- `FACT` — Verified, established information
- `DECISION` — Approved and recorded decision
- `ASSUMPTION` — Unverified belief, not established
- `RECOMMENDATION` — Suggestion requiring approval

**Never present an assumption or recommendation as an established decision.**

---

## Visual Reference Lifecycle

```text
INSPIRATION
↓
UNDER REVIEW
↓
APPROVED
↓
IMPLEMENTED
↓
FROZEN
```

An image alone is never a design decision. A visual reference becomes authoritative only after the human owner approves the resulting specification.

---

## Source of Truth Location

This repository (`STOREVOICE-CONTEXT/`) is the authoritative Source of Truth for StoreVoice.

All AI agents must consult this repository before making changes to the StoreVoice application.

---

## Rules for Future Updates

- Updates to this document require human owner approval
- Changes must be recorded in `05_DECISIONS/CHANGELOG.md`
- All modifications must follow the governance workflow defined above

---

**Last Updated:** [TO BE CONFIRMED]
**Approved By:** [TO BE CONFIRMED]