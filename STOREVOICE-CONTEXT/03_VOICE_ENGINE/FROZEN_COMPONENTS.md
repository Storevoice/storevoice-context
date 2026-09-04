# FROZEN_COMPONENTS.md — Voice Engine Frozen Components

**Purpose:** Documents components of the Voice Engine that are frozen and must not be modified.

**Status:** TO BE CONFIRMED

**Scope:** This document establishes which Voice Engine components are off-limits.

---

## Frozen Status

**Status:** FROZEN REFERENCE

**Important:** All components in the Voice Engine repository at the reference commit are considered frozen unless explicitly stated otherwise.

---

## Frozen Components

[TO BE CONFIRMED]

List of specific components that are frozen.

---

## Modification Restrictions

- Do not modify frozen components without explicit authorization
- Do not redesign frozen components
- Do not remove frozen functionality
- Do not change frozen APIs without approval
- Do not update frozen dependencies without approval

---

## Modification Process

If a frozen component needs modification:

1. **IDENTIFY** the component and reason for change
2. **STOP** — Do not proceed autonomously
3. **PROPOSE** the change with justification
4. **REQUEST** human owner approval
5. **IMPLEMENT** only after approval
6. **TEST** the change thoroughly
7. **UPDATE** this document to reflect the change

---

## Exceptions

[TO BE CONFIRMED]

Any exceptions to the frozen status.

---

## Rules for Future Updates

- Frozen component changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Frozen component updates may require corresponding updates to VOICE_ENGINE.md and REFERENCE_BASELINE.md

---

**Last Updated:** [TO BE CONFIRMED]
**Approved By:** [TO BE CONFIRMED]