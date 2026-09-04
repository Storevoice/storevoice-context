# REFERENCE_BASELINE.md — Voice Engine Reference Baseline

**Purpose:** Establishes the baseline reference for the Voice Engine component.

**Status:** DECISION

**Scope:** This document defines the reference state of the Voice Engine.

---

## Reference Commit

**Commit:** `c62f761acccb23bb6798375f7fef3ba9a1234ebc`

**Repository:** https://github.com/Storevoice/storevoice

**Status:** FROZEN REFERENCE

**Role:** This commit represents the approved StoreVoice Voice Engine reference implementation. It is the baseline for all future StoreVoice voice-related functionality. The Voice Engine is based on LiveKit Agents and is the approved canonical reference for future StoreVoice product builds.

---

## Baseline Features

**Status:** DECISION

The baseline reference includes a production-grade voice engine implementation with the following capabilities (at minimum):
- Real-time voice processing
- Voice Activity Detection (VAD)
- Turn detection
- Interruption handling
- Speech-to-Text (STT) integration
- Large Language Model (LLM) integration
- Text-to-Speech (TTS) integration
- LiveKit Agents framework integration

Future StoreVoice product builds must use this approved baseline as their canonical reference.

---

## Baseline Configuration

[TO BE CONFIRMED]

What configuration is included in the baseline reference.

---

## Baseline Dependencies

[TO BE CONFIRMED]

What dependencies are included in the baseline reference.

---

## Baseline API

**Status:** FUTURE INTENT

There is currently NO universal StoreVoice Voice API in the baseline. The Voice Engine is accessed through direct integration.

**Future intent:** A universal StoreVoice Voice API may eventually be designed, specified, and approved. This is future architectural intent only — not an existing implementation.

---

## Known Issues

[TO BE CONFIRMED]

Known issues with the baseline reference.

---

## Verification Process

[TO BE CONFIRMED]

How to verify the baseline reference is working correctly.

---

## Rules for Future Updates

- Baseline changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Baseline updates may require corresponding updates to VOICE_ENGINE.md and FROZEN_COMPONENTS.md
- The baseline is frozen and must not be modified without explicit architectural approval
- Future product builds must use this baseline as their canonical reference

---

**Last Updated:** 2026-09-04
**Approved By:** Change 001 — Official Voice Engine Reference & Future Build Integration