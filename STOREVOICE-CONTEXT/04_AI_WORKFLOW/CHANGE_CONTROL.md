# CHANGE_CONTROL.md — StoreVoice Change Control Process

**Purpose:** Defines the change control process for StoreVoice modifications.

**Status:** DECISION

**Scope:** This document establishes how changes are proposed, approved, and implemented.

---

## Change Control Overview

**Status:** DECISION

Change control ensures all modifications to StoreVoice are properly authorized, documented, and validated. This includes special rules for Voice Engine modifications.

**Key principle:** The Voice Engine is frozen. Any change to the Voice Engine is an architectural decision, not an ordinary implementation detail.

---

## Voice Engine Modification Rules

**Status:** DECISION

The Voice Engine is frozen at reference commit `c62f761acccb23bb6798375f7fef3ba9a1234ebc`. Ordinary product development MUST NOT modify the frozen Voice Engine.

If a future product requirement appears to require a change to the Voice Engine:

**STOP.**

Do not implement the change automatically.

Instead:

1. **IDENTIFY** the requirement
2. **IDENTIFY** why the frozen engine is insufficient
3. **IDENTIFY** the affected Voice Engine components
4. **EXPLAIN** the proposed architectural change
5. **REQUEST** an explicit owner decision

Only after approval may the Voice Engine itself be changed.

**Forbidden changes (unless explicitly approved):**
- Recreate the voice engine
- Replace the voice-engine architecture
- Substitute another STT provider
- Substitute another LLM
- Substitute another TTS provider
- Replace VAD
- Replace turn detection
- Replace interruption handling
- Redesign the realtime voice pipeline

Any such change is an architectural decision, not an ordinary implementation detail.

---

## Change Request Process

[TO BE CONFIRMED]

How change requests are submitted and evaluated.

---

## Change Approval Process

[TO BE CONFIRMED]

How changes are approved or rejected.

---

## Change Implementation Process

[TO BE CONFIRMED]

How approved changes are implemented.

---

## Change Verification Process

[TO BE CONFIRMED]

How implemented changes are verified.

---

## Change Documentation

[TO BE CONFIRMED]

How changes are documented.

---

## Change Rollback Process

[TO BE CONFIRMED]

How changes are rolled back if necessary.

---

## Emergency Change Process

[TO BE CONFIRMED]

Process for emergency changes that bypass normal controls.

---

## Change Metrics

[TO BE CONFIRMED]

What metrics are tracked for change control.

---

## Rules for Future Updates

- Change control changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Voice Engine modifications require explicit architectural approval
- Any change to the Voice Engine is an architectural decision, not an ordinary implementation detail

---

**Last Updated:** 2026-09-04
**Approved By:** Change 001 — Official Voice Engine Reference & Future Build Integration