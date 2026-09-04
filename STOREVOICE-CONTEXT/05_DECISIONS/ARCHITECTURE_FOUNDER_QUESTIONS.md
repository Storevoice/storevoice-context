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

## Active Unresolved Questions — Founder Decision Session

### FQ-03: Platform Centralization Level

**Current decision:**
Founder Decision 6.3 states `storevoice.ai` remains the central platform from which StoreVoice services are launched. Future specialized services or brands may exist if needed, but the underlying product remains centrally controlled. Founder Decision 6.2 establishes that StoreVoice is one Greek company rather than separate legal entities in each country.

**What remains undecided:**
The exact architectural degree of centralization. Must ALL operations (data processing, AI runtime, customer administration, billing, knowledge management) flow through the central `storevoice.ai` platform, or can certain operational aspects have regional/local variations while maintaining central control?

**Why it matters:**
This decision fundamentally affects:
* Data architecture (centralized vs. distributed data storage)
* AI runtime architecture (centralized vs. edge processing)
* Customer administration architecture (centralized vs. federated)
* Compliance architecture (single jurisdiction vs. multi-jurisdiction)
* Scaling architecture (single region vs. multi-region)

**Options:**

**Option A — Full Centralization:**
All operations, data processing, and AI runtime execute from the central `storevoice.ai` platform in Greece. No regional processing. Customer experience is localized, but all backend operations are centralized.

*Advantages:* Simplest architecture, single compliance jurisdiction, easiest to maintain, lowest operational complexity.
*Disadvantages:* Potential latency for distant European markets, single point of failure, may not meet data residency requirements if they emerge.

**Option B — Central Control with Regional Processing:**
Central platform in Greece maintains control, customer administration, and knowledge management. AI runtime and certain data processing may execute in regional European locations for latency/compliance reasons. Central orchestration remains.

*Advantages:* Better latency, potential compliance flexibility, maintains central control.
*Disadvantages:* More complex architecture, multiple compliance jurisdictions, higher operational complexity.

**Option C — Central Control with Edge AI:**
Central platform in Greece maintains control and administration. AI runtime executes at the edge (closest to the customer) for optimal latency. Data and knowledge remain centralized. Processing is distributed.

*Advantages:* Best latency, optimal AI performance, maintains central data control.
*Disadvantages:* Most complex architecture, edge infrastructure requirements, higher operational cost.

**RECOMMENDATION — NOT A DECISION:**
Option A (Full Centralization) is recommended for initial architecture. The Founder has repeatedly emphasized central control from Greece. Latency concerns can be addressed through CDN/edge networking without requiring distributed processing architecture. If regional processing becomes necessary later, the architecture can evolve. Starting simple preserves flexibility.

**Founder Decision:**
STATUS: OPEN — FOUNDER DECISION REQUIRED

---

### FQ-04: Capability Universality

**Current decision:**
Founder Decision 6.22 defines three commercial packages (A, B, Enterprise) with different feature sets. Founder Decision 6.23 states features are tied to packages and customers cannot arbitrarily bolt on individual features outside their package. Founder Decision 6.8 states autonomous actions are allowed only where included in the customer's package.

**What remains undecided:**
Which capabilities MUST be universally available to ALL customers regardless of package, and which capabilities can be package-dependent? The Founder has established package differentiation, but the exact boundary between universal platform capabilities and package-dependent capabilities remains open.

**Why it matters:**
This decision affects:
* Entitlement model architecture (what gets gated)
* Feature enforcement architecture (how gating is implemented)
* AI autonomy boundaries (what all AI colleagues can do vs. package-specific)
* Platform foundation (what is built once for all vs. what is package-specific)

**Options:**

**Option A — Minimal Universal Layer:**
Only core AI colleague functionality is universal (basic conversation, knowledge retrieval, human escalation). All advanced features (appointment scheduling, autonomous actions, multi-channel, advanced analytics) are package-dependent.

*Advantages:* Maximum package differentiation, clearest upgrade incentives, simplest universal layer.
*Disadvantages:* May create perception of limited value in lower packages, complex entitlement enforcement.

**Option B — Substantial Universal Layer:**
Core AI colleague functionality plus essential platform capabilities are universal (conversation, knowledge, multi-channel, basic analytics, basic reporting). Premium features (advanced analytics, White Glove operations, enterprise integrations) are package-dependent.

*Advantages:* Stronger base value proposition, simpler entitlement model, better customer experience across packages.
*Disadvantages:* Less package differentiation, may reduce upgrade incentive.

**Option C — Universal Platform with Feature Gating:**
All platform capabilities are technically available to all packages, but specific features, usage limits, or service levels are gated. For example, all packages get multi-channel, but Package A gets phone only, Package B gets phone + WhatsApp, Enterprise gets all channels.

*Advantages:* Unified platform architecture, flexible gating, easier to maintain.
*Disadvantages:* Complex entitlement logic, harder to explain to customers.

**RECOMMENDATION — NOT A DECISION:**
Option B (Substantial Universal Layer) is recommended. The Founder's vision emphasizes "the customer buys a working service, not technology they must manage." A strong universal layer ensures all customers get a complete, valuable service. Package differentiation can focus on service level (self-setup vs. White Glove), advanced features (appointment scheduling), and support level rather than basic platform capabilities.

**Founder Decision:**
STATUS: OPEN — FOUNDER DECISION REQUIRED

---

### FQ-06: Regulatory Adaptation Scope

**Current decision:**
Founder Decision 6.10 states StoreVoice intends to operate according to applicable European rules and regulations governing AI. Compliance is a major differentiator. When applicable European rules change, StoreVoice adapts the service as necessary. Customers do not have an option to refuse changes necessary for regulatory compliance. Compliance changes are centrally managed.

**What remains undecided:**
When applicable European rules change, must StoreVoice adapt the service for ALL customers simultaneously, or can adaptation be phased? The Founder has established that compliance is mandatory and centrally managed, but the scope and timing of adaptation across the customer base remains open.

**Why it matters:**
This decision affects:
* Deployment architecture (simultaneous vs. phased rollout)
* Testing architecture (regression scope per compliance change)
* Customer communication architecture (notification requirements)
* Operational architecture (change management processes)
* Risk architecture (liability window during phased rollout)

**Important clarification:**
This is a Founder policy question plus a legal/compliance dependency. Do NOT make legal claims. Do NOT claim that a particular operating model is legally valid merely because the Founder intends it. Separate:
* Founder policy (what StoreVoice wants to do)
* Technical implementation (how to implement it)
* Legal/compliance validation (whether it is legally valid)

The Founder may decide the desired operational policy, while legal validity remains subject to appropriate legal/compliance validation.

**Options:**

**Option A — Simultaneous Adaptation:**
When regulatory changes apply, StoreVoice adapts the service for ALL customers simultaneously. No phased rollout. All customers receive compliance updates at the same time.

*Advantages:* Simplest compliance posture, uniform customer experience, clearest liability position.
*Disadvantages:* Higher testing burden per change, potential service disruption if issues arise, requires robust deployment infrastructure.

**Option B — Phased Adaptation with Central Control:**
When regulatory changes apply, StoreVoice adapts the service in phases, but all phases are centrally controlled and executed. Customers may receive updates at different times, but StoreVoice determines the rollout schedule.

*Advantages:* Lower risk per deployment, ability to catch issues early, more controlled rollout.
*Disadvantages:* More complex deployment architecture, customers on different versions, potential confusion during transition.

**Option C — Phased Adaptation with Customer Choice:**
When regulatory changes apply, StoreVoice provides a compliance update window. Customers must implement the update within the window, but StoreVoice can offer flexibility on exact timing within the window.

*Advantages:* Customer flexibility, StoreVoice maintains control of the window.
*Disadvantages:* Most complex architecture, customers may delay, liability concerns during window.

**RECOMMENDATION — NOT A DECISION:**
Option A (Simultaneous Adaptation) is recommended. The Founder has emphasized that "customers do not have an option to refuse changes that are necessary for regulatory compliance." Simultaneous adaptation aligns with this principle and provides the clearest compliance posture. The technical architecture should support robust testing and deployment to enable safe simultaneous updates.

**Founder Decision:**
STATUS: OPEN — FOUNDER DECISION REQUIRED

---

### FQ-10: Package Evolution

**Current decision:**
Founder Decision 6.22 defines current packages (A, B, Enterprise). Founder Decision 6.23 defines package boundaries (features tied to packages, upgrade/downgrade rules). The Founder has established that packages can change through Founder-approved commercial decisions.

**What remains undecided:**
How frequently may commercial packages change, and what is the process for communicating changes to existing customers? The Founder has established that packages exist and can change, but the governance and customer-protection rules for package evolution remain open.

**Why it matters:**
This decision affects:
* Package management architecture (how packages are versioned)
* Customer communication architecture (notification requirements)
* Entitlement architecture (how changes affect existing customers)
* Commercial architecture (grandfathering vs. migration)
* Operational architecture (change management processes)

**Options:**

**Option A — Fixed Package Definitions:**
Packages are defined once and rarely change. Changes require significant business justification and extensive customer communication. Existing customers are grandfathered into their original package terms until they choose to change.

*Advantages:* Maximum customer stability, simplest architecture, clearest expectations.
*Disadvantages:* Slow to adapt to market changes, may create legacy package complexity.

**Option B — Controlled Evolution with Grandfathering:**
Packages can evolve through Founder-approved decisions. Existing customers are grandfathered into their current package terms for a defined period (e.g., 12 months) after changes. New packages apply to new customers immediately.

*Advantages:* Balance of stability and flexibility, customer protection, market adaptability.
*Disadvantages:* More complex entitlement logic, multiple package versions in production.

**Option C — Regular Evolution with Migration:**
Packages can evolve on a regular cadence (e.g., quarterly). Existing customers receive migration windows to move to new packages. Old packages are deprecated after migration windows.

*Advantages:* Regular innovation, clear package lifecycle, eventual simplification.
*Disadvantages:* Customer migration burden, more complex architecture, potential customer churn risk.

**RECOMMENDATION — NOT A DECISION:**
Option B (Controlled Evolution with Grandfathering) is recommended. The Founder's vision emphasizes customer trust and service quality. Grandfathering protects existing customers while allowing package evolution. The architecture should support package versioning and entitlement migration to enable this model.

**Founder Decision:**
STATUS: OPEN — FOUNDER DECISION REQUIRED

---

## Rules for Future Updates

- Only genuinely unresolved questions requiring Founder authority should be listed here
- Questions must be traced back to specific Founder Decisions or architectural implications
- When a question is answered, it must be removed from this document and recorded in `DECISIONS.md`
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004B.1 — Correct Architecture Decision State + Resolve Remaining Founder Questions