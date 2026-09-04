# VOICE_ENGINE.md — StoreVoice Voice Engine Documentation

**Purpose:** Documents the StoreVoice Voice Engine component and its integration.

**Status:** DECISION

**Scope:** This document establishes how the Voice Engine fits into the StoreVoice architecture.

---

## Voice Engine Overview

**Status:** DECISION

The StoreVoice Voice Engine is the approved reference implementation for all StoreVoice voice-related functionality. It is a production-grade implementation based on LiveKit Agents.

**Key facts:**
- The Voice Engine is the canonical voice-engine reference for future StoreVoice product builds
- Future StoreVoice product builds must use this approved Voice Engine as their reference
- AI agents must inspect the Source of Truth and the approved Voice Engine reference before creating or replacing any voice-engine functionality
- The Voice Engine must NOT be recreated independently when the approved engine can satisfy the requirement

---

## External Repository Reference

**Repository:** https://github.com/Storevoice/storevoice

**Reference Commit:** `c62f761acccb23bb6798375f7fef3ba9a1234ebc`

**Status:** FROZEN REFERENCE

**Important:** This repository is an external component. The Source of Truth repository must NOT copy its source code. Do not modify or redesign it from this repository.

**Architectural Role:** The Voice Engine is the approved StoreVoice reference implementation. It is NOT a generic public multi-project Voice API. Future architecture MAY eventually introduce an integration/API boundary between products and the Voice Engine, but that is future architectural intent only — not an existing implementation.

---

## Integration Points

**Status:** DECISION

**Current integration model:**

`Product → approved integration → Voice Engine`

**Future target integration model:**

`Multiple Products → approved Voice API / Integration Boundary → StoreVoice Voice Engine`

The future integration boundary must be designed, specified and approved before it becomes an implementation requirement. Do NOT claim that an API exists if it does not exist.

---

## Voice Engine Capabilities

[TO BE CONFIRMED]

What the Voice Engine can do.

---

## Voice Engine Limitations

[TO BE CONFIRMED]

Known limitations and constraints.

---

## Voice Engine Dependencies

[TO BE CONFIRMED]

What the Voice Engine depends on.

---

## Voice Engine API

**Status:** FUTURE INTENT

There is currently NO universal StoreVoice Voice API. The Voice Engine is accessed through direct integration.

**Future intent:** A universal StoreVoice Voice API may eventually be designed, specified, and approved. This is future architectural intent only — not an existing implementation.

---

## Voice Engine Configuration

[TO BE CONFIRMED]

How the Voice Engine is configured.

---

## Rules for Future Updates

- Voice Engine changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Voice Engine updates may require corresponding updates to REFERENCE_BASELINE.md and FROZEN_COMPONENTS.md
- Do not modify the external Voice Engine repository from this Source of Truth
- Future StoreVoice product builds must use the approved Voice Engine as their canonical reference
- Do NOT casually recreate the voice engine, replace the voice-engine architecture, substitute another STT/LLM/TTS provider, replace VAD, replace turn detection, replace interruption handling, or redesign the realtime voice pipeline
- Any such change is an architectural decision, not an ordinary implementation detail

---

**Last Updated:** 2026-09-04
**Approved By:** Change 001 — Official Voice Engine Reference & Future Build Integration