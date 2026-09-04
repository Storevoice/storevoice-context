# ARCHITECTURE_VALIDATION_004D.md — StoreVoice Architecture Validation Report

**Purpose:** Critical attack, validation, and stress-test of the approved StoreVoice target architecture before implementation begins.

**Status:** DECISION

**Scope:** This document records the findings from the architecture falsification review performed during Change 004D.

**Important:** This is NOT a redesign. This is a critical review that attempts to falsify architectural claims and identify gaps, contradictions, and risks.

---

## Executive Result

```
ARCHITECTURE VALIDATED WITH FINDINGS
```

The StoreVoice target architecture is **fundamentally sound** and reflects a faithful translation of Founder Decisions into architectural structure. The three-plane architecture is coherent. The Voice Engine boundary is correctly designed as a TARGET interface. Tenant isolation principles are correct. The knowledge lifecycle is well-defined.

However, the review identified **20 findings** across the architecture that require attention before or during implementation. None of these findings require reopening Founder Decisions. None are architectural contradictions. They are gaps, ambiguities, or areas that need more precise specification during implementation.

---

## 1. Overall Assessment

### What Works

* **Three-Plane Architecture** is coherent and useful. The Control Plane, Interaction Plane, and Operations Plane have genuinely distinct responsibilities. The dependency direction is primarily Control → Interaction → Engine, which is correct.

* **Voice Engine Boundary** is correctly designed as a TARGET architecture, not a claim that the API already exists. The boundary interface specification is clear enough for an engineering team to implement.

* **Tenant Isolation Principles** are correct. The architecture correctly states database-level isolation as the primary mechanism and lists all data types that must be isolated.

* **Knowledge Lifecycle** is well-defined and traces correctly to Founder Decisions 6.11, 6.12, 6.13, 6.18, 6.19, FQ-08.

* **Founder Decision Traceability** is complete. All 10 Founder Decisions have architectural coverage.

* **Decision Classification** is maintained throughout. No assumptions are promoted to facts. No recommendations are promoted to decisions.

### What Does Not Work (Findings)

The findings below identify areas where the architecture:

* Looks complete on paper but remains technically undefined
* Has ambiguities that could cause different engineering teams to build different things
* Has gaps that need specification during implementation
* Has areas where the boundary between planes needs more precise definition

### What Remains Uncertain

* Cloud infrastructure provider and deployment topology (correctly marked UNKNOWN)
* Observability provider and architecture (correctly marked UNKNOWN)
* Exact concurrency and latency characteristics (correctly marked UNKNOWN)
* Compliance requirements per jurisdiction (correctly marked as requiring legal review)

### Whether Implementation Can Safely Proceed

**YES** — Implementation can safely proceed. The architecture is strong enough to become the foundation for implementation. The findings below are implementable gaps, not architectural contradictions.

---

## 2. Critical Findings

### FINDING-001: Operations Plane Boundary Undefined

**Severity:** HIGH

**Architecture Area:** Three-Plane Architecture (Section 5, AD-01)

**Problem:** The Operations Plane lists responsibilities (QA, reporting, human escalation management, White Glove operations, incident management, post-incident review, learning and improvement) but does not define:

* Which components belong to the Operations Plane
* What APIs or interfaces the Operations Plane exposes
* What data the Operations Plane reads vs. writes
* How the Operations Plane interacts with the Control Plane and Interaction Plane
* Whether the Operations Plane is synchronous or asynchronous
* Whether the Operations Plane has its own data store or shares the Control Plane's

The SYSTEM_MAP.md shows the Operations Plane as a flat subgraph with four nodes (QA, Reporting, HumanEsc, WhiteGlove) but no internal structure or external connections except `QA --> Reporting` and `WhiteGlove --> HumanEsc`.

**Why It Matters:** An engineering team building the Operations Plane would not know whether to create a separate service, a module within the Control Plane, or a set of batch jobs. The boundary between "Operations" and "Control" is ambiguous for incident management (listed in both planes).

**Evidence:** ARCHITECTURE.md Section 5 lists Operations Plane responsibilities. SYSTEM_MAP.md Section 1 shows Operations Plane with 4 nodes and no connections to Control/Interaction planes except QA→Reporting and WhiteGlove→HumanEsc. ARCHITECTURE.md Section 8 lists "Incident and Safety" as a bounded context but does not clarify whether it belongs to Control or Operations.

**Recommended Resolution:** During implementation, define the Operations Plane as primarily a human-facing operational tooling layer that reads from the Control Plane and Interaction Plane event stores. Incident management should be clarified as: Control Plane owns incident state; Operations Plane provides the human interface for incident response.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-002: Interaction → Control Plane Coupling During Real-Time Conversation

**Severity:** HIGH

**Architecture Area:** Three-Plane Architecture, AD-01, AD-07

**Problem:** During a live voice conversation, the Interaction Plane must retrieve:

* Approved knowledge (from Knowledge Management — Control Plane)
* Persona definition (from AI Configuration — Control Plane)
* Behavior policies (from Behavior Config — Control Plane)
* Package entitlements (from Entitlement Engine — Control Plane)
* Compliance rules (from Compliance Service — Control Plane)
* Localization configuration (from Localization — Control Plane)

If any of these Control Plane services are unavailable, the Interaction Plane cannot start a voice session. The architecture does not define:

* Whether Control Plane data should be cached in the Interaction Plane
* What happens when Control Plane is temporarily unavailable during an active session
* Whether session startup should fail or proceed with stale cached data
* The latency impact of Control Plane queries on session startup

**Why It Matters:** Voice conversations are real-time. If the Interaction Plane makes synchronous calls to the Control Plane for every session startup, Control Plane downtime directly blocks all customer conversations. This is a critical resilience concern.

**Evidence:** ARCHITECTURE.md Section 5 shows Control → Interaction dependency. SYSTEM_MAP.md Section 1 shows `Config --> AIRuntime` and `KnowledgeMgmt --> KnowledgeRetrieval` (Control → Interaction). No caching or fallback strategy is defined.

**Recommended Resolution:** During implementation, define a caching strategy for Control Plane data in the Interaction Plane. Session startup should use cached data with a short TTL. Control Plane unavailability should not block active sessions. Define cache invalidation on configuration changes.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-003: Voice Engine Boundary — System Prompt Ownership Ambiguity

**Severity:** MEDIUM

**Architecture Area:** Voice Engine Boundary (Section 24)

**Problem:** The boundary specification lists "System Prompt" as a required input from Platform to Engine. However, the frozen Voice Engine currently constructs its own system prompt internally (in `prompts/receptionist.py`). The architecture does not clarify:

* Who constructs the system prompt — Platform or Engine?
* If the Platform constructs it, how does it handle engine-specific prompt formatting?
* If the Engine constructs it, how does the Platform ensure knowledge and policies are included?
* Is the system prompt a complete handoff or a template?

**Why It Matters:** If the Platform constructs the system prompt, it must understand engine-specific prompt formatting, which couples the Platform to the engine. If the Engine constructs it, the Platform must trust the Engine to include all required knowledge and policies, which may not be enforceable.

**Evidence:** ARCHITECTURE.md Section 24 lists "System Prompt" as required input. INTEGRATION_RULES.md Section 2 lists "System Prompt" as Platform → Engine. The frozen Voice Engine constructs prompts internally in `prompts/receptionist.py`.

**Recommended Resolution:** During implementation, clarify that the Platform provides structured data (knowledge, persona, policies) and the Engine constructs the system prompt from that data. The Platform should validate that the Engine's prompt includes required elements through telemetry/logging, not by constructing the prompt directly.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-004: Tenant Context Propagation Through Voice Engine Boundary

**Severity:** MEDIUM

**Architecture Area:** Voice Engine Boundary (Section 24), Tenant Architecture (Section 9)

**Problem:** The boundary specification lists "Session Configuration" (including "tenant context") as a required input. However, the frozen Voice Engine has no concept of "tenant." It processes audio and produces text. The architecture does not clarify:

* What "tenant context" means to the Engine (does it receive a tenant ID?)
* How the Engine ensures tenant isolation when it has no tenant concept
* Whether tenant context is for the Engine's use or purely for the Platform's audit trail
* How tenant context flows through the engine's internal processing

**Why It Matters:** If tenant context is passed to the Engine but the Engine ignores it, the architecture is misleading. If tenant context is used by the Engine, it may need modification (which violates FQ-01).

**Evidence:** ARCHITECTURE.md Section 24 lists "Tenant Context" as input. SYSTEM_MAP.md Section 6 shows `TenantCtx -->|"Tenant Context"| Boundary`. The frozen Voice Engine has no tenant concept in its codebase.

**Recommended Resolution:** During implementation, clarify that "tenant context" is metadata passed through the boundary for Platform-side audit and logging. The Engine does not need to understand or use tenant context. Tenant isolation is enforced entirely at the Platform level, not at the Engine level.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-005: Knowledge Context Serialization Format Undefined

**Severity:** MEDIUM

**Architecture Area:** Voice Engine Boundary (Section 24), Knowledge Architecture (Section 11)

**Problem:** The boundary specification lists "Knowledge Context" (approved knowledge items for this tenant) as a required input from Platform to Engine. However, the architecture does not define:

* The serialization format (JSON, plain text, structured prompt?)
* The maximum size of knowledge context
* How the Engine handles knowledge that exceeds context window limits
* Whether knowledge is provided as raw text or structured data
* How the Engine prioritizes knowledge when context window is limited

**Why It Matters:** LLMs have context window limits. If the knowledge context exceeds the limit, the Engine must decide what to include. Without defined serialization and prioritization, different implementations could produce different AI behaviors.

**Evidence:** ARCHITECTURE.md Section 24 lists "Knowledge Context" as required input. No format or size constraints are defined. The frozen Voice Engine constructs prompts internally without external knowledge injection.

**Recommended Resolution:** During implementation, define knowledge context as structured data (JSON) with metadata (priority, category, effective date). Define maximum size limits. Define truncation/prioritization strategy when knowledge exceeds context window. The Engine should receive knowledge as prompt segments, not as raw database records.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-006: Cross-Channel Customer Identity Resolution Undefined

**Severity:** MEDIUM

**Architecture Area:** Channel Architecture (Section 14), Identity and Tenant Management

**Problem:** The architecture states "Same customer identified across channels" but does not define:

* How a customer is identified across channels (phone number? email? account ID?)
* What happens when the same person calls from different phone numbers
* What happens when the same person uses phone and WhatsApp
* How the Platform links conversations from different channels to the same customer
* Whether customer identity resolution is automatic or manual

**Why It Matters:** Without defined identity resolution, each channel could create separate customer contexts, violating the "unified context" requirement. A customer calling from a different phone number might get a different AI experience.

**Evidence:** ARCHITECTURE.md Section 14 states "Same customer identified across channels" but provides no mechanism. SYSTEM_MAP.md Section 3 shows channels feeding into a single Session Manager but no identity resolution step.

**Recommended Resolution:** During implementation, define customer identity resolution as a Platform concern before session creation. Identity resolution should be based on: (1) customer account ID (if known), (2) phone number matching, (3) email matching, (4) manual linking. Each channel session should be linked to a resolved customer identity.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-007: Event Idempotency and Duplicate Handling Undefined

**Severity:** MEDIUM

**Architecture Area:** Event-Driven Architecture (AD-07, Section 25)

**Problem:** The architecture declares event-driven architecture for the Interaction Plane but does not define:

* Event idempotency contracts
* Duplicate event handling
* Event ordering guarantees
* Dead-letter handling
* Event versioning strategy
* Correlation ID requirements

**Why It Matters:** In event-driven systems, duplicate events are inevitable. Without idempotency contracts, duplicate events could cause: double billing, double escalation, duplicate audit entries, inconsistent state.

**Evidence:** AD-07 declares event-driven architecture. Section 25 lists event types but no handling guarantees. SYSTEM_MAP.md shows `EventProcessor --> EventRouter --> EventStore` but no idempotency or deduplication layer.

**Recommended Resolution:** During implementation, define: (1) all events must carry unique event IDs, (2) event handlers must be idempotent, (3) event store must support deduplication, (4) dead-letter queue for failed events, (5) correlation IDs for tracing, (6) event versioning for schema evolution.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-008: Package Entitlement Enforcement Location Undefined

**Severity:** MEDIUM

**Architecture Area:** Package/Entitlement Architecture (Section 17), AD-04

**Problem:** The architecture states "entitlements are configuration-driven" and "runtime enforce entitlements" but does not define:

* Where entitlements are evaluated (Control Plane, Interaction Plane, or both)
* Whether entitlements are checked at session startup or continuously during conversation
* What happens when entitlements change mid-session (e.g., downgrade during a call)
* How entitlements interact with the Voice Engine boundary (does the Engine receive entitlement state?)

**Why It Matters:** If entitlements are only checked at session startup, a downgrade mid-session would not take effect until the next call. If checked continuously, the Interaction Plane needs real-time entitlement access, which creates coupling to the Control Plane.

**Evidence:** Section 17 states "Entitlements are configuration-driven, not hardcoded." SYSTEM_MAP.md Section 6 shows `Entitlements -->|"Entitlement State"| Boundary` but no enforcement mechanism. AD-04 defines configuration-driven entitlements but no enforcement location.

**Recommended Resolution:** During implementation, define: (1) entitlements are evaluated at session startup and cached for the session duration, (2) entitlement changes take effect at next session, (3) entitlement state is passed to the Engine as part of session configuration, (4) the Engine respects entitlement state for tool execution.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-009: Demo Isolation Mechanism Undefined

**Severity:** LOW

**Architecture Area:** Demo Architecture (Section 19)

**Problem:** The architecture states "Demo instances are isolated from production" but does not define:

* Whether demos use separate infrastructure or logical isolation
* How demo knowledge is prevented from entering production knowledge stores
* How demo conversations are prevented from entering production audit trails
* Whether demos have their own tenant record or a special "demo" tenant type
* How demo expiry is enforced (background job? lazy deletion?)

**Why It Matters:** Without defined isolation, demo data could accidentally contaminate production. A demo that "expires" but retains data could become a compliance risk.

**Evidence:** Section 19 states "Demo instances are isolated from production" but provides no mechanism. SYSTEM_MAP.md does not show demo isolation in the data boundaries diagram.

**Recommended Resolution:** During implementation, define: (1) demos use a special "demo" tenant type with TTL, (2) demo knowledge is stored in a separate namespace, (3) demo conversations are logged separately, (4) expiry is enforced by background job that deletes demo tenant and all associated data.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-010: Human Escalation — Transfer Mechanism Technical Architecture Undefined

**Severity:** MEDIUM

**Architecture Area:** Human Escalation Architecture (Section 15)

**Problem:** The architecture describes escalation concepts (cold transfer, warm transfer, callback) but does not define the technical mechanism:

* How is a phone call transferred? (Twilio transfer API? conference bridge?)
* How is context communicated to the human agent? (In-call audio? screen pop? message?)
* How is callback scheduled? (Calendar integration? Queue system?)
* What happens when the human rejects the transfer?
* What happens when the transfer fails?
* How is the human agent's availability tracked?

**Why It Matters:** Without technical architecture for transfers, the engineering team must design the transfer mechanism from scratch. Different approaches (Twilio transfer, conference bridge, warm handoff) have very different implementation complexities.

**Evidence:** Section 15 describes escalation concepts. SYSTEM_MAP.md Section 9 shows escalation flow but no technical mechanism. The frozen Voice Engine has no transfer capability.

**Recommended Resolution:** During implementation, define: (1) cold transfer uses Twilio call transfer API, (2) warm transfer uses in-call whisper + transfer, (3) callback uses a queue system with scheduling, (4) human availability is tracked via status API, (5) transfer failure triggers callback fallback.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-011: Compliance Rule Storage and Evaluation Undefined

**Severity:** LOW

**Architecture Area:** Compliance Architecture (Section 20), AD-06

**Problem:** The architecture describes a compliance model (Jurisdiction → Regulation → Service → Date → Rules → Changes → Rollout → Audit) but does not define:

* Where compliance rules are stored (database? configuration file? rules engine?)
* How rules are versioned
* How rules are evaluated at runtime
* How mandatory changes are propagated to affected customers
* How rollout is controlled (percentage-based? region-based? customer-based?)

**Why It Matters:** Without defined rule storage and evaluation, the compliance model is conceptual only. An engineering team would need to design the compliance engine from scratch.

**Evidence:** Section 20 describes compliance model. AD-06 defines centralized compliance. No technical mechanism for rule storage or evaluation is defined.

**Recommended Resolution:** During implementation, define: (1) compliance rules are stored in a versioned configuration store, (2) rules are evaluated at session startup against customer jurisdiction, (3) mandatory changes are propagated as configuration updates, (4) rollout is controlled by customer segments.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-012: Billing State Synchronization with Entitlement State Undefined

**Severity:** MEDIUM

**Architecture Area:** Billing Architecture (Section 18), Package/Entitlement Architecture (Section 17)

**Problem:** The architecture shows billing state and entitlement state as separate concepts but does not define:

* How billing state (from Stripe) synchronizes with entitlement state (in Platform)
* What happens when Stripe webhook is delayed
* What happens when Stripe webhook is duplicated
* What happens when billing state and entitlement state disagree
* Who is authoritative — billing system or platform?

**Why It Matters:** Billing and entitlements must stay synchronized. If a customer pays but entitlements don't update, the customer loses service. If entitlements update but billing doesn't, StoreVoice loses revenue.

**Evidence:** Section 18 shows billing model. Section 17 shows entitlement model. No synchronization mechanism is defined. INTEGRATION_RULES.md Section 5 shows Stripe integration but no reconciliation.

**Recommended Resolution:** During implementation, define: (1) Stripe webhook updates billing state, (2) billing state change triggers entitlement update, (3) entitlement state is authoritative for service access, (4) billing reconciliation runs daily to catch drift, (5) webhook deduplication prevents double processing.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-013: Knowledge Conflict Detection Mechanism Undefined

**Severity:** LOW

**Architecture Area:** Knowledge Architecture (Section 11)

**Problem:** The architecture describes conflict resolution (AI must not arbitrarily select truth, conflict presented to customer, last approved remains authoritative) but does not define:

* How conflicts are detected (keyword matching? semantic similarity? manual review?)
* What constitutes a "conflict" (contradictory statements? outdated information?)
* How conflicts are presented to the customer (notification? dashboard? email?)
* How the AI operates during conflict resolution (uses last approved? refuses to answer?)

**Why It Matters:** Without defined conflict detection, the system cannot automatically surface conflicts. Manual conflict detection does not scale.

**Evidence:** Section 11 describes conflict resolution. No detection mechanism is defined. FOUNDER_DECISION_SET.md Section 6.12 defines conflict behavior but not detection.

**Recommended Resolution:** During implementation, define: (1) conflicts are detected by semantic similarity with contradictory assertions, (2) conflicts are surfaced in customer dashboard, (3) AI uses last approved version during resolution, (4) conflict resolution is a customer action.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-014: Regional Processing — Data Synchronization Undefined

**Severity:** LOW

**Architecture Area:** Regional Processing (Section 30, SYSTEM_MAP.md Section 5)

**Problem:** The architecture shows regional processing (EU-West, EU-Central, EU-East) but does not define:

* How data synchronizes between regions
* What data is region-local vs. globally replicated
* How configuration changes propagate from central to regional
* How audit data from regional processing reaches central audit store
* What happens during region failure (failover? queued?)

**Why It Matters:** Without defined synchronization, regional processing could create data inconsistencies. Configuration changes might not reach all regions. Audit data might be incomplete.

**Evidence:** Section 30 describes regional processing. SYSTEM_MAP.md Section 5 shows regional topology. No synchronization mechanism is defined.

**Recommended Resolution:** During implementation, define: (1) Control Plane data is globally replicated, (2) Interaction Plane data is region-local with async replication to central, (3) configuration changes propagate via event bus, (4) audit events are asynchronously aggregated to central, (5) region failure triggers failover to nearest healthy region.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-015: Onboarding Readiness Percentage Calculation Undefined

**Severity:** LOW

**Architecture Area:** Customer Lifecycle (Section 16), Onboarding

**Problem:** The architecture states "100% means ready to go live" and "no separate mandatory manual testing gate after 100%" but does not define:

* How readiness percentage is calculated
* What contributes to the percentage (knowledge completeness? configuration? testing?)
* Who determines when 100% is reached (system? human?)
* What happens if readiness drops below 100% after activation

**Why It Matters:** Without defined calculation, readiness percentage is arbitrary. Different customers might have different expectations of what "100%" means.

**Evidence:** Section 16 shows lifecycle states. FOUNDER_DECISION_SET.md Section 6.27 defines onboarding requirements. No calculation mechanism is defined.

**Recommended Resolution:** During implementation, define: (1) readiness is calculated from: knowledge completeness (40%), configuration completeness (30%), testing completion (30%), (2) system calculates percentage automatically, (3) human approves activation at 100%, (4) readiness does not drop after activation (knowledge updates are separate).

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-016: Emergency AI Colleague Shutdown Mechanism Undefined

**Severity:** LOW

**Architecture Area:** Incident/Safety Architecture (Section 22)

**Problem:** The architecture states "AI colleague may be taken offline to protect customers" but does not define:

* How an AI colleague is taken offline (disable tenant? disable engine? redirect calls?)
* What happens to active calls when an AI colleague is taken offline
* How the customer is notified
* How the AI colleague is brought back online
* Who has authority to take an AI colleague offline

**Why It Matters:** Without defined shutdown mechanism, emergency response is ad-hoc. Active calls could be dropped. Customers could be unaware.

**Evidence:** Section 22 describes emergency capabilities. FOUNDER_DECISION_SET.md Section 6.14 defines incident management. No shutdown mechanism is defined.

**Recommended Resolution:** During implementation, define: (1) shutdown is a Control Plane operation that sets tenant status to "offline", (2) active calls continue to completion but no new sessions start, (3) customer is notified via email/SMS, (4) reactivation requires human approval, (5) authority: StoreVoice operations team.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-017: Customer Knowledge Deletion — Derived Data Undefined

**Severity:** LOW

**Architecture Area:** Data Ownership and Learning (Section 23), FQ-08

**Problem:** The architecture states "customer-specific knowledge is deleted after termination" but does not define:

* What happens to conversation summaries derived from customer data
* What happens to analytics derived from customer conversations
* What happens to escalation patterns derived from customer interactions
* What happens to QA findings derived from customer calls
* Whether derived data is considered "customer-specific"

**Why It Matters:** If derived data (summaries, analytics, patterns) is considered customer-specific, it must be deleted. If it is considered aggregated/anonymized, it may be retained. The boundary is unclear.

**Evidence:** FQ-08 states "StoreVoice may retain genuinely non-identifiable, aggregated/general insights." Section 23 shows data boundaries. The boundary between "customer-specific" and "aggregated" is not precisely defined.

**Recommended Resolution:** During implementation, define: (1) conversation transcripts are customer-specific and deleted, (2) conversation summaries are customer-specific and deleted, (3) anonymized patterns (e.g., "customers in retail ask about hours") may be retained, (4) escalation patterns are retained only if truly anonymized, (5) QA findings are retained only if not traceable to specific customers.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-018: Package Versioning — Backward Compatibility Undefined

**Severity:** LOW

**Architecture Area:** Package/Entitlement Architecture (Section 17), FQ-10

**Problem:** The architecture states "material changes are versioned and communicated" but does not define:

* What constitutes a "material" change
* How package versions are represented (v1, v2? or feature flags?)
* How existing customers are migrated to new package versions
* What happens when a feature is removed from a package
* How the system handles customers on different package versions simultaneously

**Why It Matters:** Without defined versioning, package evolution is chaotic. Customers on different versions might have different experiences. Migration might be inconsistent.

**Evidence:** FQ-10 defines package evolution. Section 17 describes package model. No versioning mechanism is defined.

**Recommended Resolution:** During implementation, define: (1) material change = feature addition/removal or price change, (2) packages are versioned (e.g., PackageA-v1, PackageA-v2), (3) existing customers retain their version until migration, (4) migration is controlled and communicated, (5) feature removal triggers notification and grace period.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-019: Observability — Tenant-Scoped Metrics Undefined

**Severity:** LOW

**Architecture Area:** Observability (Section 27)

**Problem:** The architecture states "support tenant-scoped metrics where applicable" but does not define:

* Which metrics are tenant-scoped vs. global
* How tenant-scoped metrics are collected without performance impact
* How tenant-scoped metrics are isolated (preventing cross-tenant metric leakage)
* How tenant-scoped metrics support customer health monitoring

**Why It Matters:** Without defined tenant-scoped metrics, the operations team cannot monitor individual customer health. Cross-tenant metric leakage could violate tenant isolation.

**Evidence:** Section 27 describes observability requirements. No tenant-scoped metric architecture is defined.

**Recommended Resolution:** During implementation, define: (1) tenant-scoped metrics include: call volume, latency, error rate, escalation rate, (2) metrics are collected at the Interaction Plane with tenant context, (3) metrics are stored in tenant-partitioned time-series database, (4) global metrics are aggregated from tenant metrics.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

### FINDING-020: AI Colleague — Behavioral Boundary Enforcement Undefined

**Severity:** MEDIUM

**Architecture Area:** AI Colleague Architecture (Section 10)

**Problem:** The architecture states "behavior policies" and "safety mechanisms" but does not define:

* How behavior policies are enforced at runtime (prompt-only? structural? external guardrails?)
* What happens when the AI violates a behavior policy
* How safety mechanisms prevent harmful output
* Whether behavior policies are enforced by the Engine or the Platform
* How behavior policies interact with knowledge boundaries

**Why It Matters:** Prompt-only safety mechanisms are insufficient for production. Without structural enforcement, the AI could: disclose confidential information, make unauthorized promises, behave inappropriately, or violate compliance rules.

**Evidence:** Section 10 describes AI colleague architecture. SYSTEM_MAP.md Section 3 shows "Safety Engine" but no enforcement mechanism. FOUNDER_DECISION_SET.md Section 6.5 defines behavior principles but no enforcement.

**Recommended Resolution:** During implementation, define: (1) behavior policies are enforced at the Platform level before knowledge is sent to Engine, (2) output filtering occurs at Platform level after Engine response, (3) safety mechanisms include content filtering, output validation, and escalation triggers, (4) policy violations trigger escalation or safe fallback.

**Classification:** ARCHITECTURAL GAP — needs specification during implementation

---

## 3. Founder Decision Findings

```
Founder Decisions required: 0
```

No architectural finding requires reopening a Founder Decision. All findings are implementable gaps that can be resolved during implementation without changing business truth.

---

## 4. Technical Unknowns

### Existing Technical Unknowns (from 004C)

| ID | Unknown | Status |
|----|---------|--------|
| TU-01 | Exact production concurrency capacity | REMAINS UNKNOWN |
| TU-02 | Voice Engine boundary interface latency | REMAINS UNKNOWN |
| TU-03 | Multi-tenant database performance under load | REMAINS UNKNOWN |
| TU-04 | Knowledge retrieval latency at scale | REMAINS UNKNOWN |
| TU-05 | Cross-channel context synchronization latency | REMAINS UNKNOWN |
| TU-06 | Regional processing requirements per jurisdiction | REMAINS UNKNOWN |
| TU-07 | Exact compliance requirements per jurisdiction | REMAINS UNKNOWN |
| TU-08 | Stripe integration complexity for proration | REMAINS UNKNOWN |
| TU-09 | WhatsApp API capabilities and limitations | REMAINS UNKNOWN |
| TU-10 | Email delivery reliability and tracking | REMAINS UNKNOWN |

### New Technical Unknowns (from 004D)

| ID | Unknown | Impact | Resolution |
|----|---------|--------|------------|
| TU-11 | Control Plane cache invalidation strategy | Session startup latency | Implementation testing |
| TU-12 | Knowledge context maximum size vs. LLM context window | AI response quality | Benchmarking required |
| TU-13 | Cross-channel identity resolution accuracy | Customer experience | Implementation testing |
| TU-14 | Event processing throughput under load | Conversation capacity | Load testing required |
| TU-15 | Compliance rule evaluation latency | Session startup latency | Benchmarking required |

### Resolved Technical Unknowns

None. All existing Technical Unknowns remain valid.

---

## 5. 18-Package Validation Matrix

| # | Package | Status | Findings | Blocking? |
|---|---------|--------|----------|-----------|
| 01 | Platform Boundary | PASS WITH FINDINGS | FINDING-001 (Operations Plane boundary) | NO |
| 02 | Voice Engine Boundary | PASS WITH FINDINGS | FINDING-003 (System prompt), FINDING-004 (Tenant context), FINDING-005 (Knowledge serialization) | NO |
| 03 | Tenant and Identity | PASS | — | NO |
| 04 | Knowledge and Memory | PASS WITH FINDINGS | FINDING-013 (Conflict detection), FINDING-017 (Derived data deletion) | NO |
| 05 | AI Colleague Policy | PASS WITH FINDINGS | FINDING-020 (Behavioral enforcement) | NO |
| 06 | Localization | PASS | — | NO |
| 07 | Channels and Conversation | PASS WITH FINDINGS | FINDING-006 (Identity resolution) | NO |
| 08 | Human Escalation | PASS WITH FINDINGS | FINDING-010 (Transfer mechanism) | NO |
| 09 | Customer Lifecycle | PASS WITH FINDINGS | FINDING-015 (Readiness calculation) | NO |
| 10 | Packages and Entitlements | PASS WITH FINDINGS | FINDING-008 (Enforcement location), FINDING-018 (Versioning) | NO |
| 11 | Demo | PASS WITH FINDINGS | FINDING-009 (Isolation mechanism) | NO |
| 12 | Billing and Commercial | PASS WITH FINDINGS | FINDING-012 (Billing-entitlement sync) | NO |
| 13 | Compliance and Governance | PASS WITH FINDINGS | FINDING-011 (Rule storage/evaluation) | NO |
| 14 | Audit and Traceability | PASS | — | NO |
| 15 | Incident and Safety | PASS WITH FINDINGS | FINDING-016 (Emergency shutdown) | NO |
| 16 | Data Boundaries and Learning | PASS | — | NO |
| 17 | Provider Abstraction | PASS | — | NO |
| 18 | Operating Model | PASS | — | NO |

**Summary:** 0 BLOCKING, 14 PASS WITH FINDINGS, 4 PASS

---

## 6. Three-Plane Validation

### Control Plane

**Dependency Direction:** Control Plane is depended upon by Interaction Plane and Operations Plane. Control Plane depends on no other plane (correct).

**Ownership:** Control Plane owns authoritative state for tenants, customers, knowledge, configuration, packages, billing, compliance, audit.

**Data Ownership:** Control Plane owns its data stores. Interaction Plane reads from Control Plane but does not write (correct for most operations).

**Failure Impact:** Control Plane failure blocks session startup but does not affect active sessions (if caching is implemented — FINDING-002).

**Scaling:** Control Plane can scale independently. Interaction Plane can scale independently.

### Interaction Plane

**Dependency Direction:** Interaction Plane depends on Control Plane (correct). Interaction Plane depends on Voice Engine Boundary (correct).

**Ownership:** Interaction Plane owns session state, conversation context, real-time events.

**Data Ownership:** Interaction Plane owns session-scoped data. Durable data flows to Control Plane.

**Failure Impact:** Interaction Plane failure affects active conversations. Control Plane remains operational.

**Scaling:** Interaction Plane can scale horizontally per region.

### Operations Plane

**Dependency Direction:** Operations Plane depends on Control Plane and Interaction Plane data (correct for read-only operations).

**Ownership:** Operations Plane owns operational tooling, QA workflows, reporting interfaces.

**Data Ownership:** Operations Plane reads from Control Plane and Interaction Plane event stores. Does not own primary data.

**Failure Impact:** Operations Plane failure affects operational visibility but does not affect customer-facing service.

**Scaling:** Operations Plane can scale independently.

### Circular Dependencies

**Finding:** No circular dependencies detected between planes. The dependency direction is:

```
Control Plane ← Interaction Plane
Control Plane ← Operations Plane
Interaction Plane → Voice Engine Boundary
```

This is correct and clean.

### Coupling Analysis

**Control → Interaction:** Coupling exists for configuration delivery (correct). Should be async where possible (FINDING-002).

**Interaction → Control:** Coupling exists for knowledge retrieval and entitlement checks (correct). Should be cached (FINDING-002).

**Operations → Control:** Read-only coupling for reporting (correct). No write coupling.

**Operations → Interaction:** Read-only coupling for operational visibility (correct). No write coupling.

---

## 7. Voice Engine Boundary Validation

### Current Engine Facts

* Repository: `Storevoice/storevoice`
* Commit: `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
* Architecture: LiveKit Agents SDK-based
* Providers: Deepgram (STT), OpenAI (LLM), Cartesia (TTS), Silero (VAD)
* Configuration: Environment-based, global (not per-tenant)
* Knowledge: Hardcoded in `prompts/receptionist.py`
* Persona: Hardcoded in `prompts/receptionist.py`
* Context: Session-only, not persistent
* Memory: None
* Tools: None
* Multi-tenant: No
* Public API: No

### Target Boundary

The target boundary is a TARGET ARCHITECTURE, not a current implementation.

### What Is Proven

* The frozen Voice Engine can receive a system prompt (via environment/config)
* The frozen Voice Engine can process audio and produce text
* The frozen Voice Engine can handle interruptions
* The frozen Voice Engine can produce telemetry (latency metrics)

### What Is NOT Proven

* Whether the frozen Engine can receive external knowledge context at runtime
* Whether the frozen Engine can receive external persona definition at runtime
* Whether the frozen Engine can receive external behavior policies at runtime
* Whether the frozen Engine can produce structured conversation events (vs. just text)
* Whether the frozen Engine can produce escalation triggers
* Whether the frozen Engine can accept tool execution requests
* Whether the frozen Engine can handle multiple concurrent tenants

### Is the Boundary Implementation-Ready?

**PARTIALLY.** The boundary interface is defined at a conceptual level. However, the exact mechanism for injecting external knowledge, persona, and policies into the frozen Engine requires investigation during implementation. The frozen Engine may need an adapter layer to translate Platform commands into Engine-native configuration.

### Does Engine Modification Appear Necessary?

**NO** — Based on the current analysis, the boundary can be implemented without modifying the frozen Engine. The Platform can:

* Construct the system prompt including knowledge and policies
* Pass the constructed prompt to the Engine via configuration
* Receive text output and conversation events from the Engine
* Handle escalation at the Platform level

However, this requires verification during implementation (TU-02).

---

## 8. Tenant Isolation Validation

### Isolation Model

The architecture correctly specifies:

* Database-level tenant isolation as primary mechanism
* Application-level tenant context on all data access
* API-level tenant scoping prevents cross-tenant queries

### Remaining Risks

1. **Cache contamination:** If Control Plane data is cached in the Interaction Plane (FINDING-002), cache keys must include tenant ID to prevent cross-tenant cache hits.

2. **Event tenant context:** Events must carry tenant ID. Event handlers must validate tenant context before processing.

3. **Background jobs:** Background jobs (knowledge processing, compliance checks, billing reconciliation) must receive tenant context and process one tenant at a time.

4. **Logs and observability:** Logs must include tenant ID for debugging but must not expose tenant data across tenants.

5. **Provider calls:** External provider calls (Deepgram, OpenAI, Cartesia) may log data. Tenant context must not leak to provider logs.

6. **Vector/embedding storage:** If knowledge is stored as embeddings, vector storage must be tenant-partitioned.

### Isolation Attack Results

| Attack Vector | Risk | Mitigation |
|---------------|------|------------|
| Cross-tenant database query | LOW (database-level isolation) | Tenant ID in all queries |
| Cross-tenant cache hit | MEDIUM | Tenant-scoped cache keys |
| Cross-tenant event processing | MEDIUM | Tenant context validation |
| Cross-tenant background job | MEDIUM | Tenant-scoped job queues |
| Cross-tenant log exposure | LOW | Tenant-scoped logging |
| Cross-tenant provider leakage | LOW | Tenant context not sent to providers |
| Invalid tenant ID | MEDIUM | Validation and rejection |
| Tenant ID disappearance | LOW | Tenant ID propagated through all layers |

---

## 9. Knowledge / Memory Validation

### Knowledge Lifecycle

The knowledge lifecycle is well-defined:

```
SOURCE → INGEST → VALIDATE → REVIEW → APPROVE → VERSION → ACTIVE → UPDATE/REPLACE/BLOCK → AUDIT HISTORY
```

Each transition has:
* Ownership: Customer provides, StoreVoice validates and approves
* Authority: Last approved version is authoritative
* Auditability: Complete change record
* Tenant scope: Strictly tenant-isolated
* Rollback: Ability to revert to previous approved version

### Contradictory Information Test

Customer previously approved: "Opening hours: 09:00–17:00"
Later customer submits: "Opening hours: 10:00–18:00"

**Architecture response:**
1. Conflict detected (semantic similarity with contradictory assertions)
2. Conflict presented to customer
3. Customer decides which is correct
4. Last approved (09:00–17:00) remains authoritative
5. AI continues using 09:00–17:00 during resolution
6. When customer confirms new version, 10:00–18:00 becomes active
7. Previous version retained in audit history

**Status:** Architecture supports this correctly.

### Memory Safety Test

| Question | Architecture Answer |
|----------|-------------------|
| What is allowed to become memory? | Customer-approved durable context |
| What is forbidden? | AI-generated statements, conversation content without approval |
| Who approves durable memory? | Customer |
| Can AI-generated statement become durable truth? | NO — only customer-approved knowledge |
| Can conversation content modify knowledge? | Only through approval workflow |
| Can one customer's memory contaminate another? | NO — tenant isolation |
| What happens after deletion? | Permanent, structural |
| What happens after cancellation? | Continues through paid period, then 14-day recovery |
| What happens during recovery? | Data retained, customer can reactivate |
| What exactly must be deleted? | Customer-specific knowledge, context, memory, conversations |
| What may remain? | Anonymized aggregate insights only |

**Status:** Architecture supports this correctly.

---

## 10. Security Validation

### Structural Security Findings

| Domain | Status | Finding |
|--------|--------|---------|
| Authentication | ADEQUATE | Identity service defined, RBAC defined |
| Authorization | ADEQUATE | Tenant-scoped authorization defined |
| Tenant Isolation | ADEQUATE | Database-level isolation defined |
| Secrets | ADEQUATE | Centralized secrets management defined |
| Encryption | ADEQUATE | At rest and in transit defined |
| Privileged Access | ADEQUATE | Controlled and audited defined |
| Audit | ADEQUATE | Logged and monitored defined |
| Service-to-Service | GAP | No defined service-to-service authentication mechanism |
| API Security | ADEQUATE | Tenant-scoped APIs defined |
| Provider Credentials | ADEQUATE | Centralized management defined |

### Missing Structural Controls

1. **Service-to-service authentication:** The architecture does not define how services within the platform authenticate to each other. Recommend: mutual TLS or service mesh with identity.

2. **Rate limiting per tenant:** The architecture defines rate limiting principles but not per-tenant rate limits. Recommend: per-tenant rate limits to prevent abuse.

3. **Input validation:** The architecture does not define input validation at API boundaries. Recommend: schema validation and sanitization at all API entry points.

---

## 11. Failure / Resilience Validation

### Failure Path Analysis

| Failure | What Fails | What Remains | Customer Experience |
|---------|-----------|--------------|-------------------|
| Voice Engine unavailable | All voice sessions | Control Plane, non-voice channels | "Service temporarily unavailable" |
| Telephony unavailable | Phone channel | WhatsApp, Email, SMS | "Please use another channel" |
| LLM unavailable | AI responses | Session management, escalation | "Connecting you to a human" |
| STT unavailable | Speech recognition | All non-voice | "Please use another channel" |
| TTS unavailable | Voice output | All non-voice | "Please use another channel" |
| Database unavailable | All persistent state | Active sessions (cached) | Degrades over time |
| Cache unavailable | Performance | Functionality (slower) | Slower response |
| Queue unavailable | Async processing | Synchronous operations | Delayed operations |
| Stripe unavailable | Payment processing | Active service continues | "Payment issue, service continues" |
| Email unavailable | Email channel | Phone, WhatsApp, SMS | "Please use another channel" |
| WhatsApp unavailable | WhatsApp channel | Phone, Email, SMS | "Please use another channel" |
| Human escalation unavailable | Escalation | AI continues operating | "AI handles safely, callback scheduled" |

### Safety Principle Validation

* Safety and continuity take precedence over root-cause analysis: ✅ Architecture supports this
* Exceptional circumstances: AI colleague may be taken offline: ✅ Architecture supports this (FINDING-016)
* Every serious incident receives human review: ✅ Architecture supports this
* Structural improvements centrally implemented: ✅ Architecture supports this

---

## 12. Audit / Traceability Validation

### Can StoreVoice Reconstruct an AI Interaction?

For a historical interaction, can the system identify:

| Element | Available? | Source |
|---------|-----------|--------|
| Tenant | YES | Session metadata |
| Customer | YES | Session metadata |
| AI colleague configuration | YES | Versioned configuration store |
| Active knowledge version | YES | Knowledge versioning |
| Relevant context | YES | Conversation logging |
| Applicable policy | YES | Policy versioning |
| Package entitlement | YES | Package versioning |
| Regulatory state | YES | Compliance state logging |
| Tools used | YES | Tool execution logging |
| Human escalation | YES | Escalation logging |
| Provider state | YES | Provider telemetry |
| Important events | YES | Event store |
| Outcome | YES | Session outcome logging |

**Status:** Architecture supports full reconstruction.

### Remaining Gap

The architecture does not define the **retention period** for audit data. This should be defined during implementation based on legal requirements and business needs.

---

## 13. Implementation Readiness

| Subsystem | Status | Notes |
|-----------|--------|-------|
| Identity & Tenant Management | READY | Well-defined, implementable |
| Customer Administration | READY | Well-defined, implementable |
| Package & Entitlement Management | READY WITH TECHNICAL UNKNOWN | FINDING-008 needs specification |
| Knowledge Management | READY WITH TECHNICAL UNKNOWN | FINDING-013 needs specification |
| AI Colleague Configuration | READY | Well-defined, implementable |
| Localization | READY | Well-defined, implementable |
| Channel Management | READY WITH TECHNICAL UNKNOWN | FINDING-006 needs specification |
| Session Management | READY | Well-defined, implementable |
| Escalation | READY WITH TECHNICAL UNKNOWN | FINDING-010 needs specification |
| Billing | READY WITH TECHNICAL UNKNOWN | FINDING-012 needs specification |
| Compliance | READY WITH TECHNICAL UNKNOWN | FINDING-011 needs specification |
| Audit | READY | Well-defined, implementable |
| Incident Management | READY WITH TECHNICAL UNKNOWN | FINDING-016 needs specification |
| Demo | READY WITH TECHNICAL UNKNOWN | FINDING-009 needs specification |
| Onboarding | READY WITH TECHNICAL UNKNOWN | FINDING-015 needs specification |
| Voice Engine Integration | READY WITH TECHNICAL UNKNOWN | FINDING-003, 004, 005 need specification |
| Observability | READY WITH TECHNICAL UNKNOWN | FINDING-019 needs specification |
| Security | READY WITH TECHNICAL UNKNOWN | Service-to-service auth needs specification |

---

## 14. Required Changes Before Implementation

None of the findings are architectural contradictions that require changes to the architecture documents during 004D. All findings are specification gaps that can be resolved during implementation.

However, the following specification gaps should be addressed early in implementation to prevent inconsistent design decisions:

### CHANGE REQUIRED (Implementation Phase):

**SPEC-001:** Define Control Plane caching strategy for Interaction Plane.
**WHY:** FINDING-002 — Without caching, Control Plane failure blocks all conversations.
**OWNER:** Implementation team.
**TIMING:** Before Interaction Plane implementation.

**SPEC-002:** Define Voice Engine boundary adapter layer.
**WHY:** FINDING-003, 004, 005 — Without adapter, Platform cannot inject knowledge/policies into Engine.
**OWNER:** Implementation team.
**TIMING:** Before Voice Engine integration.

**SPEC-003:** Define event idempotency contracts.
**WHY:** FINDING-007 — Without idempotency, duplicate events cause inconsistent state.
**OWNER:** Implementation team.
**TIMING:** Before event-driven implementation.

**SPEC-004:** Define billing-entitlement synchronization mechanism.
**WHY:** FINDING-012 — Without synchronization, billing and entitlements can drift.
**OWNER:** Implementation team.
**TIMING:** Before billing integration.

**SPEC-005:** Define package versioning mechanism.
**WHY:** FINDING-018 — Without versioning, package evolution is chaotic.
**OWNER:** Implementation team.
**TIMING:** Before package system implementation.

---

## 15. Validation Summary

### Architecture Strengths

1. Three-Plane architecture is coherent and useful
2. Voice Engine boundary is correctly designed as TARGET architecture
3. Tenant isolation principles are correct
4. Knowledge lifecycle is well-defined
5. Founder Decision traceability is complete
6. Decision classification is maintained throughout
7. No false completeness — unknowns are correctly marked
8. Faithfulness to StoreVoice vision is maintained

### Architecture Weaknesses

1. Operations Plane boundary needs definition (FINDING-001)
2. Control Plane caching for Interaction Plane needs definition (FINDING-002)
3. Voice Engine boundary adapter needs specification (FINDING-003, 004, 005)
4. Cross-channel identity resolution needs mechanism (FINDING-006)
5. Event idempotency needs contracts (FINDING-007)
6. Package entitlement enforcement location needs definition (FINDING-008)
7. Demo isolation needs mechanism (FINDING-009)
8. Transfer mechanism needs technical architecture (FINDING-010)
9. Compliance rule storage needs definition (FINDING-011)
10. Billing-entitlement synchronization needs mechanism (FINDING-012)

### Overall Verdict

**The architecture is strong enough to become the foundation for implementation.** The findings are specification gaps, not architectural contradictions. They can be resolved during implementation without changing the architectural structure or Founder Decisions.

The architecture faithfully translates Founder Decisions into technical structure. It correctly identifies what is known, what is unknown, and what needs specification. It maintains the authority hierarchy. It does not invent false completeness.

**Implementation can safely proceed.**

---

## Rules for Future Updates

- This document records the findings from the Change 004D architecture validation
- Findings should be addressed during implementation
- No findings require reopening Founder Decisions
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004D — Architecture Review / Validation