# ARCHITECTURE_FOUNDER_QUESTIONS.md — Questions Requiring Founder Authority

**Purpose:** Identifies architectural decisions that expose questions requiring Founder authority.

**Status:** OPEN

**Scope:** This document contains questions that cannot be answered technically and require Founder decision.

**Important:** Do not answer these questions yourself. They require explicit Founder authority.

---

## Voice Engine Questions

### FQ-01: Engine Modification Policy

**Question:** Does the frozen Voice Engine remain permanently frozen, or is modification allowed under defined conditions?

**Why This Matters:** This decision fundamentally affects the architecture. If the engine can be modified, capabilities like customer-configurable personas, expanded language support, and enhanced emotion handling can be implemented directly. If not, these capabilities must be implemented outside the engine.

**Current State:** The engine is frozen at commit `c62f761acccb23bb6798375f7fef3ba9a1234ebc`.

**Impact:** Affects decisions VE-01 through VE-06 in the Architecture Decision Register.

**Status:** OPEN

---

### FQ-02: Engine Replacement Policy

**Question:** Under what conditions, if any, could the frozen Voice Engine be replaced with an alternative implementation?

**Why This Matters:** If replacement is possible, the architecture can assume a clean integration boundary. If not, the architecture must work within the engine's current constraints.

**Current State:** No replacement policy exists.

**Impact:** Affects decisions PB-02 and VE-01 in the Architecture Decision Register.

**Status:** OPEN

---

## Platform Questions

### FQ-03: Platform Centralization Level

**Question:** What level of platform centralization is mandatory? Must all operations flow through the central `storevoice.ai` platform, or can regional/Local variations exist?

**Why This Matters:** This decision affects the fundamental architecture of the platform, including data storage, processing, and service delivery.

**Current State:** Founder Decision 6.3 states `storevoice.ai` remains the central platform, but the degree of centralization is not specified.

**Impact:** Affects decisions PB-01, TI-01, and LA-01 in the Architecture Decision Register.

**Status:** OPEN

---

### FQ-04: Capability Universality

**Question:** Which capabilities must be universally available to all customers, and which can be package-dependent?

**Why This Matters:** This decision affects the entitlement model, feature gating, and package differentiation.

**Current State:** Founder Decision 6.22 defines packages but does not specify which capabilities are universal vs. package-dependent.

**Impact:** Affects decisions PE-01, PE-02, and AR-04 in the Architecture Decision Register.

**Status:** OPEN

---

## Compliance Questions

### FQ-05: Legal Validity of Greek Operation

**Question:** Is the intended legal model of operation from Greece under Greek law legally valid for serving customers across Europe?

**Why This Matters:** If the legal model is invalid, the entire platform architecture may need to be restructured to comply with local regulations.

**Current State:** Founder Decision 6.2 states this is the intended model but explicitly says not to determine legal validity.

**Impact:** Affects decisions CG-01, CG-02, and CG-04 in the Architecture Decision Register.

**Status:** OPEN — LEGAL / COMPLIANCE DECISION REQUIRED

---

### FQ-06: Regulatory Adaptation Scope

**Question:** When applicable European rules change, must StoreVoice adapt the service for all customers simultaneously, or can adaptation be phased?

**Why This Matters:** This decision affects the deployment model, testing requirements, and customer communication processes.

**Current State:** Founder Decision 6.10 states StoreVoice adapts the service as necessary but does not specify the scope or timing.

**Impact:** Affects decisions CG-04 and IS-01 in the Architecture Decision Register.

**Status:** OPEN

---

## Operational Questions

### FQ-07: White Glove Service Scope

**Question:** What is the exact scope of White Glove service? Does it include 24/7 human support, or is support limited to business hours with callbacks outside those hours?

**Why This Matters:** This decision affects the human escalation architecture, staffing requirements, and service level agreements.

**Current State:** Founder Decision 6.7 states White Glove customers have 24/7 human assistance, but the exact scope is not defined.

**Impact:** Affects decisions HE-01, HE-02, and HE-04 in the Architecture Decision Register.

**Status:** OPEN

---

### FQ-08: Customer Knowledge Ownership

**Question:** After a customer leaves, may StoreVoice retain anonymized knowledge patterns for product improvement, or must all customer-specific knowledge be deleted?

**Why This Matters:** This decision affects the data retention architecture, learning systems, and compliance requirements.

**Current State:** Founder Decision 6.18 states StoreVoice may retain non-identifiable general insights, but the exact scope is not defined.

**Impact:** Affects decisions DL-01, DL-02, and KA-05 in the Architecture Decision Register.

**Status:** OPEN

---

## Commercial Questions

### FQ-09: Demo Conversion Policy

**Question:** What is the expected conversion rate from demo to paying customer, and how long should demo instances be retained?

**Why This Matters:** This decision affects the demo infrastructure requirements, storage needs, and follow-up processes.

**Current State:** Founder Decision 6.29 states demos expire after approximately 48 hours if no action is taken, but the expected conversion rate is not defined.

**Impact:** Affects decisions DM-03 and DM-04 in the Architecture Decision Register.

**Status:** OPEN

---

### FQ-10: Package Evolution

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
**Approved By:** Change 003C — Architecture Decision Preparation