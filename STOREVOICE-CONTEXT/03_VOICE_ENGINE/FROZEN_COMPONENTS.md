# FROZEN_COMPONENTS.md — Voice Engine Frozen Components

**Purpose:** Documents components of the Voice Engine that are frozen and must not be modified.

**Status:** DECISION

**Scope:** This document establishes which Voice Engine components are off-limits.

---

## Frozen Status

**Status:** FROZEN REFERENCE

**Important:** All components in the Voice Engine repository at the reference commit are considered frozen unless explicitly stated otherwise. The Voice Engine is the approved StoreVoice reference implementation and must not be modified without explicit architectural approval.

---

## Frozen Components

**Status:** DECISION

The following components are frozen at the reference commit `c62f761acccb23bb6798375f7fef3ba9a1234ebc`:

- Voice Activity Detection (VAD)
- Turn detection
- Interruption handling
- Speech-to-Text (STT) integration
- Large Language Model (LLM) integration
- Text-to-Speech (TTS) integration
- LiveKit Agents framework integration
- Real-time voice pipeline architecture

Any change to these components is an architectural decision, not an ordinary implementation detail.

---

## Modification Restrictions

- Do not modify frozen components without explicit authorization
- Do not redesign frozen components
- Do not remove frozen functionality
- Do not change frozen APIs without approval
- Do not update frozen dependencies without approval
- Do NOT casually recreate the voice engine
- Do NOT replace the voice-engine architecture
- Do NOT substitute another STT provider
- Do NOT substitute another LLM
- Do NOT substitute another TTS provider
- Do NOT replace VAD
- Do NOT replace turn detection
- Do NOT replace interruption handling
- Do NOT redesign the realtime voice pipeline
- Any such change is an architectural decision, not an ordinary implementation detail

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
- The Voice Engine is frozen and must not be modified without explicit architectural approval
- Any change to frozen components is an architectural decision, not an ordinary implementation detail

---

**Last Updated:** 2026-09-04
**Approved By:** Change 001 — Official Voice Engine Reference & Future Build Integration