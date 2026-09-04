# INTEGRATION_RULES.md — StoreVoice Integration Policies

**Purpose:** Defines rules and standards for integrating StoreVoice with external systems.

**Status:** DECISION

**Scope:** This document establishes how StoreVoice interacts with external dependencies.

---

## External Dependencies

**Status:** DECISION

The primary external dependency for StoreVoice is:

**Voice Engine:**
- Repository: https://github.com/Storevoice/storevoice
- Reference Commit: `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
- Status: FROZEN REFERENCE
- Role: Approved StoreVoice reference implementation for voice-related functionality

Future StoreVoice product builds must use this approved Voice Engine as their canonical reference. AI agents must inspect the Source of Truth and the approved Voice Engine reference before creating or replacing any voice-engine functionality.

---

## Integration Patterns

**Status:** DECISION

**Current integration model for Voice Engine:**

`Product → approved integration → Voice Engine`

**Future target integration model:**

`Multiple Products → approved Voice API / Integration Boundary → StoreVoice Voice Engine`

The future integration boundary must be designed, specified and approved before it becomes an implementation requirement. Do NOT claim that an API exists if it does not exist.

---

## API Standards

[TO BE CONFIRMED]

Standards for API design and consumption.

---

## Authentication Requirements

[TO BE CONFIRMED]

How external integrations are authenticated.

---

## Data Mapping

[TO BE CONFIRMED]

How data is mapped between StoreVoice and external systems.

---

## Error Handling

[TO BE CONFIRMED]

How integration errors are handled.

---

## Rate Limiting

[TO BE CONFIRMED]

What rate limiting rules apply to integrations.

---

## Fallback Procedures

[TO BE CONFIRMED]

What happens when integrations fail.

---

## Security Requirements

[TO BE CONFIRMED]

Security standards for integrations.

---

## Monitoring & Logging

[TO BE CONFIRMED]

How integrations are monitored and logged.

---

## Rules for Future Updates

- Integration changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Integration updates may require corresponding updates to ARCHITECTURE.md and SYSTEM_MAP.md
- Voice Engine integration is the primary external dependency
- Future StoreVoice product builds must use the approved Voice Engine as their canonical reference
- Any change to the Voice Engine integration pattern is an architectural decision

---

**Last Updated:** 2026-09-04
**Approved By:** Change 001 — Official Voice Engine Reference & Future Build Integration