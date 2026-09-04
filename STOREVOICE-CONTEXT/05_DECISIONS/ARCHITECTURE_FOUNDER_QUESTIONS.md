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

## Active Unresolved Questions

### Platform Questions

#### FQ-03: Platform Centralization Level

**Question:** What level of platform centralization is mandatory? Must all operations flow through the central `storevoice.ai` platform, or can regional/Local variations exist?

**Why This Matters:** This decision affects the fundamental architecture of the platform, including data storage, processing, and service delivery.

**Current State:** Founder Decision 6.3 states `storevoice.ai` remains the central platform, but the degree of centralization is not specified.

**Impact:** Affects decisions PB-01, TI-01, and LA-01 in the Architecture Decision Register.

**Status:** OPEN

---

#### FQ-04: Capability Universality

**Question:** Which capabilities must be universally available to all customers, and which can be package-dependent?

**Why This Matters:** This decision affects the entitlement model, feature gating, and package differentiation.

**Current State:** Founder Decision 6.22 defines packages but does not specify which capabilities are universal vs. package-dependent.

**Impact:** Affects decisions PE-01, PE-02, and AR-04 in the Architecture Decision Register.

**Status:** OPEN

---

### Compliance Questions

#### FQ-06: Regulatory Adaptation Scope

**Question:** When applicable European rules change, must StoreVoice adapt the service for all customers simultaneously, or can adaptation be phased?

**Why This Matters:** This decision affects the deployment model, testing requirements, and customer communication processes.

**Current State:** Founder Decision 6.10 states StoreVoice adapts the service as necessary but does not specify the scope or timing.

**Impact:** Affects decisions CG-04 and IS-01 in the Architecture Decision Register.

**Status:** OPEN

---

### Commercial Questions

#### FQ-10: Package Evolution

**Question:** How frequently may commercial packages change, and what is the process for communicating changes to existing customers?

**Why This Matters:** This decision affects the package management architecture, upgrade/downgrade processes, and customer communication systems.

**Current State:** Founder Decision 6.22 defines current packages but does not specify the change process.

**Impact:** Affects decisions PE-01, CL-05, and BC-01 in the Architecture Decision Register.

**Status:** OPEN

---

## Rules for Future Updates

- Only genuinely unresolved questions requiring Founder authority should be listed here
- Questions must be traced back to specific Founder Decisions or architectural implications
- When a question is answered, it must be removed from this document and recorded in `DECISIONS.md`
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004B — Freeze Founder Architecture Decisions