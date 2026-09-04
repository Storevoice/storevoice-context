# ARCHITECTURE_DECISION_REGISTER.md — StoreVoice Architectural Decision Map

**Purpose:** Identifies and structures the architectural decisions that must be made before architecture can be designed.

**Status:** DECISION

**Scope:** This document is the decision map required to create the architecture. It is NOT the architecture.

**Important:** Every decision point traces back to a Founder Decision, Platform Requirement, Capability Gap, or Frozen Voice Engine constraint.

---

## Frozen Founder Decisions (Change 004B)

The following Founder decisions have been frozen during Architecture Decision Session 004B:

* **FQ-01 — Engine Modification Policy:** Voice Engine remains frozen by default; modification permitted only through explicit human-approved architectural change when required capability cannot reasonably be implemented outside the engine without compromising correctness, performance, maintainability, or product requirements.
* **FQ-02 — Engine Replacement Policy:** Voice Engine is replaceable, but the StoreVoice platform contract is not; architecture must maintain a clean Voice Engine boundary/interface; replacement requires explicit human approval.
* **FQ-05 — European Language Scope:** Architecture must be capable of supporting all European languages and localized customer experiences; individual languages and markets may be rolled out progressively; localization includes more than translation.
* **FQ-07 — White Glove Service Scope:** White Glove provides 24/7 human responsibility and escalation, not mandatory 24/7 live staffing; when immediate human intervention is required outside human availability, the AI must handle the situation safely, preserve relevant context, and arrange appropriate human follow-up/callback.
* **FQ-08 — Customer Knowledge Ownership:** Customer-specific knowledge is deleted after termination; StoreVoice may retain genuinely non-identifiable, aggregated/general insights; architecture must maintain hard distinction between tenant/customer data and StoreVoice-owned general learning.
* **FQ-09 — Demo Conversion Policy:** Demo instances are temporary by design (approximately 48 hours default); lifecycle must be measurable and configurable; no assumed conversion rate becomes a hard architectural constraint.

## Frozen Founder Decisions (Change 004B.2)

The following Founder decisions have been frozen during Architecture Decision Session 004B.2:

* **FQ-03 — Platform Centralization Level:** StoreVoice has one central platform and authoritative control plane. Regional processing may be introduced where required or materially beneficial for compliance, latency, resilience, capacity, or provider availability. Regional processing remains subordinate to the central StoreVoice platform and does not create independent product or platform standards.
* **FQ-04 — Capability Universality:** StoreVoice operates one universal platform containing the capabilities required to support its European service model. Customer access to capabilities is governed through package entitlements, configuration, regulatory availability, and operational permissions. Package differences must not create separate platform architectures or incompatible product standards.
* **FQ-06 — Regulatory Adaptation Scope:** StoreVoice centrally governs regulatory adaptation across the platform. Regulatory changes are applied according to applicable jurisdiction, service, legal requirements, deadlines, risk, and operational readiness. Mandatory changes cannot be refused by customers. Where legally permissible, implementation may be phased centrally without creating independent customer-specific regulatory standards.
* **FQ-10 — Package Evolution:** StoreVoice may evolve its commercial packages and platform capabilities under central human governance. Existing customers retain their agreed package functionality and commercial commitments for the applicable paid or committed period. Material package changes are versioned and communicated clearly, and migration is controlled rather than imposed arbitrarily. Mandatory regulatory or safety changes remain governed by the central compliance and safety rules.

---

## Decision Categories

### A. Platform Boundary

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| PB-01 | Platform Scope | What capabilities belong to the StoreVoice Platform vs. external providers? | Defines system boundaries and responsibilities | Founder Decision 6.1, 6.3 | OPEN | Platform-only / Platform + integrations / Hybrid | Founder | YES |
| PB-02 | Voice Engine Role | What is the relationship between the StoreVoice Platform and the frozen Voice Engine? | Determines integration pattern and modification needs | Founder Decision 6.5, FQ-02 (Frozen) | FQ-02 DECIDED: Engine is replaceable behind stable platform boundary | Engine as black box / Engine as component / Engine as reference | Founder | YES |
| PB-03 | Operational Boundaries | What capabilities require human/operational processes vs. technical automation? | Defines automation vs. human intervention boundaries | Founder Decision 6.6, 6.7 | OPEN | Fully automated / Human-in-the-loop / Hybrid | Founder | NO |

### B. Voice Engine Boundary

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| VE-01 | Engine Modification | Under what conditions, if any, may the frozen Voice Engine be modified? | Determines whether engine changes are possible | Frozen Engine Constraint, Founder Decision 6.9, FQ-01 (Frozen) | FQ-01 DECIDED: Frozen by default; modification permitted only through explicit human-approved architectural change when required capability cannot reasonably be implemented outside the engine | Permanently frozen / Conditionally modifiable / Replaceable | Founder | YES |
| VE-02 | Persona Configuration | How will customer-configurable personas be supported? | Current persona is hardcoded in prompts | Capability Gap: AI Colleague Behavior, FQ-01 (Frozen) | FQ-01 DECIDED: Modification permitted only when capability cannot reasonably be implemented outside the engine | Engine modification / Platform-level injection / External configuration | Founder | YES |
| VE-03 | Language Expansion | How will all European languages be supported beyond the current 4? | Current engine supports en, nl, fr, de | Capability Gap: Localization, FQ-05 (Frozen), FQ-01 (Frozen) | FQ-05 DECIDED: Architecture must support all European languages; FQ-01 DECIDED: Modification permitted only when capability cannot reasonably be implemented outside the engine | Engine modification / Multiple engine instances / Platform-level language handling | Founder | YES |
| VE-04 | Context Persistence | How will persistent context across sessions be achieved? | Current context is session-only | Capability Gap: AI Colleague Behavior, FQ-01 (Frozen) | FQ-01 DECIDED: Modification permitted only when capability cannot reasonably be implemented outside the engine | Engine modification / Platform-level context store / Hybrid | Founder | YES |
| VE-05 | Memory System | How will memory between sessions be implemented? | Currently no memory exists | Capability Gap: AI Colleague Behavior, FQ-01 (Frozen) | FQ-01 DECIDED: Modification permitted only when capability cannot reasonably be implemented outside the engine | Engine modification / Platform-level memory / External memory system | Founder | YES |
| VE-06 | Emotion Handling | How will enhanced emotion recognition and response be implemented? | Currently basic or non-existent | Capability Gap: AI Colleague Behavior, FQ-01 (Frozen) | FQ-01 DECIDED: Modification permitted only when capability cannot reasonably be implemented outside the engine | Engine modification / Platform-level emotion processing / External service | Founder | NO |

### C. Tenant Isolation

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| TI-01 | Tenant Model | How will strict tenant separation be architecturally guaranteed? | Core Founder Requirement for multi-tenancy | Founder Decision 6.17 | OPEN | Database-level / Application-level / Infrastructure-level / Hybrid | Founder | YES |
| TI-02 | Configuration Isolation | How will customer-specific configuration be isolated? | Prevents cross-tenant configuration leakage | Founder Decision 6.17 | OPEN | Per-tenant config / Shared config with tenant context / Hybrid | Founder | YES |
| TI-03 | Knowledge Isolation | How will customer-specific knowledge be isolated? | Prevents cross-tenant knowledge leakage | Founder Decision 6.17, 6.18 | OPEN | Per-tenant knowledge store / Shared store with tenant isolation / Hybrid | Founder | YES |
| TI-04 | Conversation Isolation | How will customer-specific conversations be isolated? | Prevents cross-tenant conversation leakage | Founder Decision 6.17 | OPEN | Per-tenant conversation store / Shared store with tenant isolation / Hybrid | Founder | YES |
| TI-05 | Audit Isolation | How will customer-specific audit information be isolated? | Maintains audit trail integrity per tenant | Founder Decision 6.13 | OPEN | Per-tenant audit store / Shared store with tenant isolation / Hybrid | Founder | YES |

### D. Customer Identity and Account Model

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| CI-01 | Customer Identity | How will customer identity be represented in the system? | Foundation for all tenant-specific operations | Founder Decision 6.17 | OPEN | Centralized identity service / Distributed identity / Hybrid | Founder | YES |
| CI-02 | Account Boundaries | What constitutes an "account" vs. a "tenant" vs. a "customer"? | Defines organizational hierarchy | Founder Decision 6.17, 6.21 | OPEN | Single-level / Multi-level / Hierarchical | Founder | YES |
| CI-03 | Administrative Access | How will administrative access be structured? | Defines who can manage what | Founder Decision 6.15 | OPEN | Role-based / Attribute-based / Hybrid | Founder | NO |
| CI-04 | Customer Lifecycle States | What states can a customer account be in? | Defines lifecycle management | Founder Decision 6.20 | OPEN | Simple states / Complex state machine / Hybrid | Founder | NO |

### E. Knowledge Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| KA-01 | Knowledge Model | How will customer knowledge be structured and stored? | Foundation for AI colleague operation | Founder Decision 6.11, 6.13 | OPEN | Document-based / Graph-based / Hybrid | Founder | YES |
| KA-02 | Knowledge Versioning | How will knowledge versions be managed? | Supports audit trail and conflict resolution | Founder Decision 6.13 | OPEN | Immutable versions / Mutable with history / Hybrid | Founder | YES |
| KA-03 | Approval Workflow | How will knowledge approval be managed? | Ensures knowledge quality and correctness | Founder Decision 6.11, 6.12 | OPEN | Manual approval / Automated validation / Hybrid | Founder | YES |
| KA-04 | Conflict Resolution | How will conflicting information be detected and resolved? | Prevents AI from making arbitrary decisions | Founder Decision 6.12 | OPEN | Customer-resolved / StoreVoice-resolved / Hybrid | Founder | YES |
| KA-05 | Knowledge Deletion | How will knowledge deletion be implemented? | Supports customer exit requirements | Founder Decision 6.20, FQ-08 (Frozen) | FQ-08 DECIDED: Customer-specific knowledge is deleted after termination; StoreVoice may retain genuinely non-identifiable, aggregated/general insights | Soft delete / Hard delete / Hybrid | Founder | NO |
| KA-06 | Knowledge Audit | How will knowledge changes be audited? | Supports compliance and incident investigation | Founder Decision 6.13 | OPEN | Append-only log / Event sourcing / Hybrid | Founder | NO |

### F. AI Colleague Runtime

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| AR-01 | Persona Management | How will AI colleague personas be defined and managed? | Supports customer-configurable AI behavior | Founder Decision 6.5 | OPEN | Template-based / Custom definition / Hybrid | Founder | YES |
| AR-02 | Behavior Policies | How will central StoreVoice policies vs. customer-specific policies be enforced? | Ensures compliance while allowing customization | Founder Decision 6.5, 6.8 | OPEN | Policy engine / Rule-based / Hybrid | Founder | YES |
| AR-03 | Context Management | How will conversation context be managed across sessions? | Supports continuity and memory | Founder Decision 6.5 | OPEN | Session-based / Persistent / Hybrid | Founder | YES |
| AR-04 | Autonomy Boundaries | How will AI autonomy boundaries be defined and enforced? | Prevents unauthorized autonomous actions | Founder Decision 6.8 | OPEN | Package-based / Rule-based / Hybrid | Founder | YES |
| AR-05 | Safety Mechanisms | How will safety boundaries be implemented? | Prevents harmful AI behavior | Founder Decision 6.5, 6.6 | OPEN | Content filtering / Behavior monitoring / Hybrid | Founder | YES |

### G. Localization Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| LA-01 | Localization Scope | What aspects of the experience require localization? | Defines breadth of localization effort | Founder Decision 6.4, FQ-05 (Frozen) | FQ-05 DECIDED: Architecture must support all European languages and localized customer experiences; localization includes more than translation | Language-only / Full cultural adaptation / Hybrid | Founder | YES |
| LA-02 | Language Support | Which European languages must be supported? | Defines language coverage requirements | Founder Decision 6.4, FQ-05 (Frozen) | FQ-05 DECIDED: Architecture must support all European languages; individual languages may be rolled out progressively | All EU languages / Major languages / Phased approach | Founder | YES |
| LA-03 | Cultural Adaptation | How will cultural adaptation be implemented beyond translation? | Ensures native-feeling experience | Founder Decision 6.4, FQ-05 (Frozen) | FQ-05 DECIDED: Localization includes more than translation; architecture must allow country-specific language, wording, communication style, formality, cultural behavior, customer-facing experience | Template-based / Custom per country / Hybrid | Founder | NO |
| LA-04 | Localized Content | How will customer-facing documentation, invoices, and reports be localized? | Supports complete localized experience | Founder Decision 6.4, FQ-05 (Frozen) | FQ-05 DECIDED: Architecture must support country-specific customer-facing experience | Template system / Dynamic generation / Hybrid | Founder | NO |

### H. Channel Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| CH-01 | Channel Support | Which communication channels must be supported? | Defines channel coverage requirements | Founder Decision 6.25 | OPEN | Phone only / Phone + messaging / Full omni-channel | Founder | YES |
| CH-02 | Unified Context | How will customer context be unified across channels? | Ensures consistent experience across channels | Founder Decision 6.25 | OPEN | Channel-specific / Unified / Hybrid | Founder | YES |
| CH-03 | Channel-Specific Behavior | How will channel-specific behavior be managed? | Different channels have different capabilities | Founder Decision 6.25 | OPEN | Shared behavior / Channel-specific / Hybrid | Founder | NO |

### I. Human Escalation Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| HE-01 | Escalation Rules | How will escalation rules be defined and enforced? | Determines when human intervention occurs | Founder Decision 6.7, FQ-07 (Frozen) | FQ-07 DECIDED: White Glove provides 24/7 human responsibility and escalation, not mandatory 24/7 live staffing | Rule-based / ML-based / Hybrid | Founder | YES |
| HE-02 | Human Availability | How will human availability be tracked? | Determines escalation routing | Founder Decision 6.7, FQ-07 (Frozen) | FQ-07 DECIDED: When immediate human intervention is required outside human availability, the AI must handle the situation safely, preserve relevant context, and arrange appropriate human follow-up/callback | Schedule-based / Real-time / Hybrid | Founder | NO |
| HE-03 | Transfer Mechanisms | How will cold/warm transfers be implemented? | Defines transfer capabilities | Founder Decision 6.7 | OPEN | Telephony-based / Application-based / Hybrid | Founder | NO |
| HE-04 | Callback System | How will callback scheduling be implemented? | Supports after-hours escalation | Founder Decision 6.7, FQ-07 (Frozen) | FQ-07 DECIDED: When immediate human intervention is required outside human availability, the AI must arrange appropriate human follow-up/callback | Manual scheduling / Automated / Hybrid | Founder | NO |
| HE-05 | Context Handoff | How will context be handed off during escalation? | Prevents customer from repeating information | Founder Decision 6.7, FQ-07 (Frozen) | FQ-07 DECIDED: The AI must preserve relevant context during escalation | Summary-based / Full context / Hybrid | Founder | NO |

### J. Customer Lifecycle

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| CL-01 | Onboarding Process | How will customer onboarding be structured? | Defines customer activation process | Founder Decision 6.27 | OPEN | Self-service / White Glove / Hybrid | Founder | YES |
| CL-02 | Knowledge Collection | How will customer knowledge be collected during onboarding? | Supports AI colleague setup | Founder Decision 6.27 | OPEN | Document upload / Interview-based / Hybrid | Founder | NO |
| CL-03 | Progress Tracking | How will onboarding progress be tracked and displayed? | Provides visibility to customer | Founder Decision 6.27 | OPEN | Percentage-based / Milestone-based / Hybrid | Founder | NO |
| CL-04 | Activation Process | How will AI colleague activation be managed? | Defines go-live process | Founder Decision 6.27 | OPEN | Manual activation / Automated / Hybrid | Founder | NO |
| CL-05 | Upgrade/Downgrade | How will package changes be managed? | Supports commercial flexibility | Founder Decision 6.23 | OPEN | Immediate / Scheduled / Hybrid | Founder | NO |
| CL-06 | Cancellation Process | How will customer cancellation be managed? | Supports customer exit | Founder Decision 6.20 | OPEN | Self-service / Assisted / Hybrid | Founder | NO |
| CL-07 | Recovery Period | How will the 14-day recovery period be implemented? | Supports customer reactivation | Founder Decision 6.20 | OPEN | Automated / Manual / Hybrid | Founder | NO |
| CL-08 | Permanent Deletion | How will permanent deletion be implemented? | Supports compliance and data protection | Founder Decision 6.20 | OPEN | Automated / Manual verification / Hybrid | Founder | NO |

### K. Package / Entitlement Model

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| PE-01 | Package Definition | How will commercial packages be defined in the system? | Defines feature availability | Founder Decision 6.22 | OPEN | Configuration-based / Code-based / Hybrid | Founder | YES |
| PE-02 | Feature Entitlements | How will feature entitlements be enforced? | Prevents unauthorized feature access | Founder Decision 6.23 | OPEN | Package-based / Permission-based / Hybrid | Founder | YES |
| PE-03 | White Glove Service | How will White Glove service level be represented? | Defines premium service capabilities | Founder Decision 6.28 | OPEN | Package attribute / Separate service level / Hybrid | Founder | NO |
| PE-04 | Enterprise Model | How will Enterprise package be differentiated? | Defines high-touch service model | Founder Decision 6.22 | OPEN | Package tier / Separate product / Hybrid | Founder | NO |

### L. Demo Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| DM-01 | Website Ingestion | How will prospect websites be ingested for demo creation? | Enables automated demo setup | Founder Decision 6.29 | OPEN | Scraping / API-based / Manual / Hybrid | Founder | YES |
| DM-02 | Demo Isolation | How will demo instances be isolated from production? | Prevents demo impact on production | Founder Decision 6.29 | OPEN | Separate infrastructure / Logical isolation / Hybrid | Founder | YES |
| DM-03 | Demo Expiration | How will demo expiration be managed? | Supports commercial process | Founder Decision 6.29, FQ-09 (Frozen) | FQ-09 DECIDED: Demo instances are temporary by design (approximately 48 hours default); lifecycle must be measurable and configurable | Time-based / Activity-based / Hybrid | Founder | NO |
| DM-04 | Conversion Process | How will demo-to-customer conversion be managed? | Supports sales process | Founder Decision 6.29, FQ-09 (Frozen) | FQ-09 DECIDED: No assumed conversion rate becomes a hard architectural constraint; conversion rate is a commercial metric that may change over time | Manual / Automated / Hybrid | Founder | NO |

### M. Billing and Commercial Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| BC-01 | Payment Integration | How will payment processing be integrated? | Supports subscription management | Founder Decision 6.24 | OPEN | Stripe integration / Custom / Hybrid | Founder | YES |
| BC-02 | Subscription Model | How will prepaid subscriptions be managed? | Defines billing cycle | Founder Decision 6.24 | OPEN | Monthly / Usage-based / Hybrid | Founder | NO |
| BC-03 | Proration Logic | How will upgrade proration be calculated? | Ensures fair billing | Founder Decision 6.23 | OPEN | Daily / Monthly / Hybrid | Founder | NO |
| BC-04 | Cancellation Timing | How will cancellation timing be managed? | Defines service continuation | Founder Decision 6.20 | OPEN | Immediate / End-of-period / Hybrid | Founder | NO |

### N. Compliance and Governance Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| CG-01 | Transparency Mechanisms | How will AI transparency be implemented? | Supports regulatory compliance | Founder Decision 6.5, 6.10 | OPEN | Disclosure-based / Consent-based / Hybrid | Founder | YES |
| CG-02 | Data Handling | How will customer data handling be implemented? | Supports data protection requirements | Founder Decision 6.11 | OPEN | Consent-based / Legitimate interest / Hybrid | Founder | YES |
| CG-03 | Retention Policies | How will data retention be implemented? | Supports compliance and customer exit | Founder Decision 6.20 | OPEN | Policy-based / Customer-configurable / Hybrid | Founder | NO |
| CG-04 | Regulatory Adaptation | How will regulatory changes be managed? | Supports ongoing compliance | Founder Decision 6.10 | OPEN | Centralized / Distributed / Hybrid | Founder | NO |

### O. Audit and Reconstruction

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| AR-01 | Knowledge Reconstruction | How will knowledge at a point in time be reconstructed? | Supports incident investigation | Founder Decision 6.13 | OPEN | Versioning / Event sourcing / Hybrid | Founder | YES |
| AR-02 | Configuration Reconstruction | How will configuration at a point in time be reconstructed? | Supports incident investigation | Founder Decision 6.13 | OPEN | Versioning / Snapshotting / Hybrid | Founder | YES |
| AR-03 | Conversation Reconstruction | How will conversation context be reconstructed? | Supports incident investigation | Founder Decision 6.13 | OPEN | Logging / Event sourcing / Hybrid | Founder | YES |
| AR-04 | Action Reconstruction | How will AI actions be reconstructed? | Supports incident investigation | Founder Decision 6.13 | OPEN | Logging / Event sourcing / Hybrid | Founder | YES |

### P. Incident and Safety Architecture

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| IS-01 | Incident Detection | How will incidents be detected? | Enables proactive incident management | Founder Decision 6.14 | OPEN | Monitoring-based / Threshold-based / Hybrid | Founder | YES |
| IS-02 | Severity Classification | How will incident severity be classified? | Determines response priority | Founder Decision 6.14 | OPEN | Manual / Automated / Hybrid | Founder | NO |
| IS-03 | Emergency Shutdown | How will emergency AI colleague shutdown be implemented? | Protects customers during serious incidents | Founder Decision 6.14 | OPEN | Manual / Automated / Hybrid | Founder | NO |
| IS-04 | Recovery Process | How will service recovery be managed? | Ensures business continuity | Founder Decision 6.14 | OPEN | Manual / Automated / Hybrid | Founder | NO |
| IS-05 | Post-Incident Review | How will post-incident reviews be managed? | Supports continuous improvement | Founder Decision 6.14 | OPEN | Manual / Template-based / Hybrid | Founder | NO |

### Q. Data Ownership and Learning Boundaries

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| DL-01 | Customer Data Boundary | How will customer-specific data be distinguished from StoreVoice general knowledge? | Enforces ownership boundaries | Founder Decision 6.19, FQ-08 (Frozen) | FQ-08 DECIDED: Architecture must maintain hard distinction between tenant/customer data and StoreVoice-owned general learning | Logical separation / Physical separation / Hybrid | Founder | YES |
| DL-02 | Anonymization Process | How will anonymization be implemented for learning? | Supports cross-customer learning | Founder Decision 6.18, FQ-08 (Frozen) | FQ-08 DECIDED: StoreVoice may retain genuinely non-identifiable, aggregated/general insights | Automated / Manual / Hybrid | Founder | NO |
| DL-03 | Aggregation Process | How will aggregation be implemented? | Supports product improvement | Founder Decision 6.18, FQ-08 (Frozen) | FQ-08 DECIDED: StoreVoice may retain genuinely non-identifiable, aggregated/general insights | Real-time / Batch / Hybrid | Founder | NO |
| DL-04 | Leakage Prevention | How will customer knowledge leakage be prevented? | Protects customer confidentiality | Founder Decision 6.18, FQ-08 (Frozen) | FQ-08 DECIDED: Customer data must not cross tenant boundaries | Technical controls / Process controls / Hybrid | Founder | YES |

### R. Provider Abstraction

| ID | Decision Area | Question | Why It Matters | Source | Current State | Options | Decision Owner | Blocking? |
|----|---------------|----------|----------------|--------|---------------|---------|----------------|-----------|
| PA-01 | STT Abstraction | How will STT provider abstraction be maintained? | Avoids vendor lock-in | Current Voice Engine Capability | EXISTS | Provider interface / Direct integration / Hybrid | Founder | NO |
| PA-02 | LLM Abstraction | How will LLM provider abstraction be maintained? | Avoids vendor lock-in | Current Voice Engine Capability | EXISTS | Provider interface / Direct integration / Hybrid | Founder | NO |
| PA-03 | TTS Abstraction | How will TTS provider abstraction be maintained? | Avoids vendor lock-in | Current Voice Engine Capability | EXISTS | Provider interface / Direct integration / Hybrid | Founder | NO |
| PA-04 | Telephony Abstraction | How will telephony provider abstraction be implemented? | Avoids vendor lock-in | Capability Gap: Channels | OPEN | Provider interface / Direct integration / Hybrid | Founder | NO |
| PA-05 | Payment Abstraction | How will payment provider abstraction be implemented? | Avoids vendor lock-in | Capability Gap: Payments | OPEN | Provider interface / Direct integration / Hybrid | Founder | NO |

---

## Decision Dependencies

The following dependencies exist between decisions:

* **TI-01 (Tenant Model)** → affects → **TI-02, TI-03, TI-04, TI-05** (Configuration, Knowledge, Conversation, Audit Isolation)
* **TI-01** → affects → **CI-01 (Customer Identity)**
* **CI-01** → affects → **CL-01 (Onboarding Process)**
* **CL-01** → affects → **KA-01 (Knowledge Model)**
* **KA-01** → affects → **KA-02, KA-03, KA-04, KA-05, KA-06** (Versioning, Approval, Conflict, Deletion, Audit)
* **PE-01 (Package Definition)** → affects → **PE-02 (Feature Entitlements)**
* **PE-02** → affects → **AR-04 (Autonomy Boundaries)**
* **VE-01 (Engine Modification)** → affects → **VE-02, VE-03, VE-04, VE-05, VE-06** (Persona, Language, Context, Memory, Emotion)
* **LA-01 (Localization Scope)** → affects → **LA-02, LA-03, LA-04** (Language, Cultural, Content)
* **CH-01 (Channel Support)** → affects → **CH-02, CH-03** (Unified Context, Channel-Specific)
* **HE-01 (Escalation Rules)** → affects → **HE-02, HE-03, HE-04, HE-05** (Availability, Transfer, Callback, Context)

---

## Rules for Future Updates

- Every decision point must have a source justification
- No new business decisions disguised as technical decisions
- No implementation architecture designed in this document
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004B — Freeze Founder Architecture Decisions