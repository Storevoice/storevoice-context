# DECISIONS.md — StoreVoice Decision Log

**Purpose:** Records all important decisions made about StoreVoice.

**Status:** DECISION

**Scope:** This document serves as the authoritative record of all decisions.

---

## Decision Log

| Date | Decision | Category | Status | Approved By | Notes |
|------|----------|----------|--------|-------------|-------|
| 2026-09-04 | Voice Engine reference established | Architecture | APPROVED | Change 001 | Frozen reference at commit c62f761acccb23bb6798375f7fef3ba9a1234ebc |
| 2026-09-04 | StoreVoice vision established | Product | APPROVED | Change 002 | AI colleague employment agency vision |
| 2026-09-04 | Shadow-producer model established | Business | APPROVED | Change 002 | AI colleague appears as part of customer's company |
| 2026-09-04 | AI colleague philosophy established | Product | APPROVED | Change 002 | Character without ego, anticipate not initiate |
| 2026-09-04 | White Glove service model established | Business | APPROVED | Change 002 | Premium service option for total relief |
| 2026-09-04 | Commercial packages established | Business | APPROVED | Change 002 | Packages A, B, and Enterprise direction |
| 2026-09-04 | Demo experience established | Product | APPROVED | Change 002 | 30-second demo with website information |
| 2026-09-04 | Knowledge boundaries established | Technical | APPROVED | Change 002 | AI never invents company knowledge |
| 2026-09-04 | Human escalation principles established | Product | APPROVED | Change 002 | Transfer must have value for both sides |
| 2026-09-04 | Engine Modification Policy (FQ-01) | Architecture | APPROVED | Change 004B | Voice Engine remains frozen by default; modification permitted only through explicit human-approved architectural change |
| 2026-09-04 | Engine Replacement Policy (FQ-02) | Architecture | APPROVED | Change 004B | Voice Engine is replaceable behind a stable platform boundary; replacement requires explicit human approval |
| 2026-09-04 | European Language Scope (FQ-05) | Architecture | APPROVED | Change 004B | Architecture must be capable of supporting all European languages and localized customer experiences |
| 2026-09-04 | White Glove Service Scope (FQ-07) | Business | APPROVED | Change 004B | White Glove provides 24/7 human responsibility and escalation, not mandatory 24/7 live staffing |
| 2026-09-04 | Customer Knowledge Ownership (FQ-08) | Architecture | APPROVED | Change 004B | Customer-specific knowledge is deleted after termination; StoreVoice may retain genuinely non-identifiable, aggregated/general insights |
| 2026-09-04 | Demo Conversion Policy (FQ-09) | Product | APPROVED | Change 004B | Demo instances are temporary by design (approximately 48 hours default); lifecycle must be measurable and configurable |
| 2026-09-04 | Platform Centralization Level (FQ-03) | Architecture | APPROVED | Change 004B.2 | StoreVoice has one central platform and authoritative control plane; regional processing remains subordinate and does not create independent standards |
| 2026-09-04 | Capability Universality (FQ-04) | Architecture | APPROVED | Change 004B.2 | StoreVoice operates one universal platform; customer access governed through package entitlements; package differences must not create separate architectures |
| 2026-09-04 | Regulatory Adaptation Scope (FQ-06) | Architecture | APPROVED | Change 004B.2 | StoreVoice centrally governs regulatory adaptation; mandatory changes cannot be refused; implementation may be phased centrally where legally permissible |
| 2026-09-04 | Package Evolution (FQ-10) | Business | APPROVED | Change 004B.2 | StoreVoice may evolve packages under central human governance; existing customers retain commitments for applicable period; material changes versioned and communicated |
| 2026-09-04 | Visual Design Authority (FD-11) | Design | APPROVED | Change 005D | StoreVoice requires dedicated Visual/Product Design capability; Frontend implements approved design but does not own design authority |
| 2026-09-04 | Design System First (FD-12) | Design | APPROVED | Change 005D | Foundational design system must be established before customer-facing frontend implementation that depends upon it |
| 2026-09-04 | Content Ownership (FD-13) | Product | APPROVED | Change 005D | StoreVoice requires dedicated Content/Product Copy capability; content is part of the product experience |
| 2026-09-04 | Product Management (FD-14) | Product | APPROVED | Change 005D | StoreVoice requires Product Management/Product Strategy capability to translate founder decisions into product requirements |
| 2026-09-04 | Agent Orchestration Before Phase 2 (FD-15) | Process | APPROVED | Change 005D | Agent organization must have executable orchestration model before Phase 2 implementation begins |
| 2026-09-04 | Visual and UX Verification (FD-16) | QA | APPROVED | Change 005D | QA must include explicit Visual and UX verification capability; QA verifies but does not independently redesign |

---

## Decision Categories

- **Product** — Product vision, features, and scope
- **Architecture** — Technical architecture and system design
- **Design** — Visual design and user experience
- **Business** — Business model and operations
- **Technical** — Implementation and technical decisions
- **Process** — Development and workflow processes

---

## Decision Template

When recording a new decision:

```
### [Decision Title]

**Date:** [Date]
**Category:** [Category]
**Status:** [APPROVED / PENDING / REJECTED]
**Approved By:** [Approver]

**Decision:**
[Description of the decision]

**Rationale:**
[Why this decision was made]

**Impact:**
[What this decision affects]

**Alternatives Considered:**
[Other options that were considered]
```

---

## Rules for Future Updates

- All decisions must be recorded in this document
- Decision changes require human owner approval
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 005D — Comprehensive Commercial Product & Autonomous Organization Model