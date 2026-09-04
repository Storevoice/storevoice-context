# ARCHITECTURE_FOUNDER_QUESTIONS.md — Questions Requiring Founder Authority

**Purpose:** Identifies architectural decisions that expose questions requiring Founder authority.

**Status:** DECISION

**Scope:** This document contains questions that cannot be answered technically and require Founder decision.

**Important:** Do not answer these questions yourself. They require explicit Founder authority.

---

## Resolved Questions (Change 004B)

The following questions have been resolved by Founder authority during Architecture Decision Session 004B:

* **FQ-01 — Engine Modification Policy** → RESOLVED: Voice Engine remains frozen by default; modification permitted only through explicit human-approved architectural change when required capability cannot reasonably be implemented outside the engine.
* **FQ-02 — Engine Replacement Policy** → RESOLVED: Voice Engine is replaceable behind a stable platform boundary; replacement requires explicit human approval.
* **FQ-05 — European Language Scope** → RESOLVED: Architecture must be capable of supporting all European languages and localized customer experiences; individual languages may be rolled out progressively.
* **FQ-07 — White Glove Service Scope** → RESOLVED: White Glove provides 24/7 human responsibility and escalation, not mandatory 24/7 live staffing.
* **FQ-08 — Customer Knowledge Ownership** → RESOLVED: Customer-specific knowledge is deleted after termination; StoreVoice may retain genuinely non-identifiable, aggregated/general insights.
* **FQ-09 — Demo Conversion Policy** → RESOLVED: Demo instances are temporary by design (approximately 48 hours default); lifecycle must be measurable and configurable.

See `DECISIONS.md` for the complete record of these Founder-authorized decisions.

---

## Resolved Questions (Change 004B.2)

The following questions have been resolved by Founder authority during Architecture Decision Session 004B.2:

* **FQ-03 — Platform Centralization Level** → RESOLVED: StoreVoice has one central platform and authoritative control plane. Regional processing may be introduced where required or materially beneficial for compliance, latency, resilience, capacity, or provider availability. Regional processing remains subordinate to the central StoreVoice platform and does not create independent product or platform standards.
* **FQ-04 — Capability Universality** → RESOLVED: StoreVoice operates one universal platform containing the capabilities required to support its European service model. Customer access to capabilities is governed through package entitlements, configuration, regulatory availability, and operational permissions. Package differences must not create separate platform architectures or incompatible product standards.
* **FQ-06 — Regulatory Adaptation Scope** → RESOLVED: StoreVoice centrally governs regulatory adaptation across the platform. Regulatory changes are applied according to applicable jurisdiction, service, legal requirements, deadlines, risk, and operational readiness. Mandatory changes cannot be refused by customers. Where legally permissible, implementation may be phased centrally without creating independent customer-specific regulatory standards.
* **FQ-10 — Package Evolution** → RESOLVED: StoreVoice may evolve its commercial packages and platform capabilities under central human governance. Existing customers retain their agreed package functionality and commercial commitments for the applicable paid or committed period. Material package changes are versioned and communicated clearly, and migration is controlled rather than imposed arbitrarily. Mandatory regulatory or safety changes remain governed by the central compliance and safety rules.

See `DECISIONS.md` for the complete record of these Founder-authorized decisions.

---

## Complete Founder Question Status

All ten Founder Questions are now RESOLVED:

| ID | Question | Status | Change |
|----|----------|--------|--------|
| FQ-01 | Engine Modification Policy | RESOLVED | 004B |
| FQ-02 | Engine Replacement Policy | RESOLVED | 004B |
| FQ-03 | Platform Centralization Level | RESOLVED | 004B.2 |
| FQ-04 | Capability Universality | RESOLVED | 004B.2 |
| FQ-05 | European Language Scope | RESOLVED | 004B |
| FQ-06 | Regulatory Adaptation Scope | RESOLVED | 004B.2 |
| FQ-07 | White Glove Service Scope | RESOLVED | 004B |
| FQ-08 | Customer Knowledge Ownership | RESOLVED | 004B |
| FQ-09 | Demo Conversion Policy | RESOLVED | 004B |
| FQ-10 | Package Evolution | RESOLVED | 004B.2 |

**0 OPEN FOUNDER QUESTIONS**

---

## Rules for Future Updates

- Only genuinely unresolved questions requiring Founder authority should be listed here
- Questions must be traced back to specific Founder Decisions or architectural implications
- When a question is answered, it must be removed from this document and recorded in `DECISIONS.md`
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004B.2 — Record, Trace, and Freeze All Founder Decisions