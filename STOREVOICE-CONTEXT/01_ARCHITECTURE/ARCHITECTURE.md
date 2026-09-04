# ARCHITECTURE.md — StoreVoice Target Architecture

**Purpose:** Defines the target architecture that transforms approved StoreVoice business truth, Founder Decisions, platform requirements, and the frozen Voice Engine reference into a coherent, implementation-ready architecture specification.

**Status:** DECISION

**Scope:** This document establishes the complete architectural foundation for StoreVoice as a European white-glove service company delivering AI colleagues as an ongoing service.

**Important:** This is TARGET ARCHITECTURE. No architecture was implemented during this change. The Voice Engine was NOT modified. No application code was written. No infrastructure was provisioned.

---

## 1. Architectural Purpose

StoreVoice is:

> **A total-solution employment agency for AI colleagues.**

The architecture must support StoreVoice as:

* A European white-glove service company
* Delivering AI colleagues as an ongoing service
* Operating from one central platform
* Serving all European countries
* Providing 24/7 human responsibility and escalation
* Maintaining strict tenant isolation
* Supporting controlled package evolution
* Enabling centralized regulatory adaptation

The architecture is NOT primarily for:

* An AI playground
* A generic chatbot
* A developer API
* A simple SaaS dashboard
* A collection of independent AI agents
* A technology demo

---

## 2. Architectural Principles

### Authority Hierarchy

```
HUMAN FOUNDER
↓
APPROVED SOURCE OF TRUTH
↓
APPROVED ARCHITECTURE
↓
EXISTING TESTED IMPLEMENTATION
↓
AI RECOMMENDATIONS
↓
AI ASSUMPTIONS
```

AI recommendations are NOT Founder decisions.

AI assumptions are NOT facts.

Never silently promote either into business truth.

### Architectural Principles

1. **Business truth drives architecture** — Never reverse the order
2. **One central platform** — One authoritative control plane, one product standard
3. **Universal platform, package entitlements** — Capabilities are gated, not separate architectures
4. **Frozen Voice Engine** — Modification permitted only through explicit human-approved architectural change
5. **Stable boundaries** — Platform boundary must survive engine replacement
6. **Multi-tenant isolation** — Cross-tenant information leakage must be structurally difficult
7. **Centralized regulatory adaptation** — Mandatory changes cannot be refused
8. **Human responsibility above autonomous AI** — Important decisions remain human decisions
9. **Localization as capability** — Not a collection of country-specific code forks
10. **Provider abstraction** — Business domains must not depend on provider-specific logic
11. **No false completeness** — "Not yet known" is better than invented certainty
12. **Faithfulness over sophistication** — Architecture must serve StoreVoice, not impress

---

## 3. Authority Hierarchy

The architectural authority hierarchy, as established by the Founder Decisions:

### Source Hierarchy

1. **Human Founder decisions** — Authoritative, not to be altered without explicit founder approval
2. **Approved Source of Truth** — The STOREVOICE-CONTEXT repository
3. **Approved architectural/product/design decisions** — Decisions recorded in this repository
4. **Existing tested implementation** — The frozen Voice Engine at commit `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
5. **AI recommendations** — Suggestions requiring approval
6. **AI assumptions** — Unverified beliefs, not established

### Decision Classification

Every major architectural choice must be classified:

* `FACT` — Verified, established information
* `FOUNDER DECISION` — Approved and recorded by founder authority
* `ARCHITECTURAL DECISION` — Technical decision necessary for coherent architecture
* `ASSUMPTION` — Unverified belief, not established
* `RECOMMENDATION` — Suggestion requiring approval
* `TECHNICAL UNKNOWN` — Not yet known, requires future validation

Never blur these categories.

---

## 4. System Boundaries

### What the StoreVoice Platform IS

The StoreVoice Platform is:

* The central control plane for all StoreVoice operations
* The authoritative source for customer configuration, knowledge, and AI colleague behavior
* The orchestration layer for channels, providers, and escalation
* The administrative interface for StoreVoice operations
* The delivery mechanism for AI colleagues as a service

### What the StoreVoice Platform is NOT

The StoreVoice Platform is NOT:

* The Voice Engine itself (the engine is an external component behind a stable boundary)
* A generic AI framework
* A telephony provider
* A payment processor
* A cloud infrastructure provider

### Boundaries

```
┌─────────────────────────────────────────────┐
│           STOREVOICE PLATFORM               │
│                                             │
│  Control Plane    │    Interaction Plane     │
│  ─────────────    │    ─────────────────     │
│  Identity         │    Channel Sessions      │
│  Tenants          │    Conversation Context  │
│  Customers        │    AI Colleague Runtime  │
│  Packages         │    Knowledge Retrieval   │
│  Billing          │    Escalation            │
│  Configuration    │    Tool Execution        │
│  Localization     │    Real-time Events      │
│  Knowledge Mgmt   │                          │
│  Compliance       │                          │
│  Audit            │                          │
│  Incidents        │                          │
│  Onboarding       │                          │
│  Demos            │                          │
│                                             │
├─────────────────────────────────────────────┤
│         VOICE ENGINE BOUNDARY               │
│         (Stable Interface)                  │
├─────────────────────────────────────────────┤
│         FROZEN VOICE ENGINE                 │
│         (External Component)                │
└─────────────────────────────────────────────┘
```

### External Systems

* **Voice Engine** — Frozen reference at `Storevoice/storevoice` commit `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
* **Telephony** — Twilio (current direction, not permanent decision)
* **Payments** — Stripe (current direction, not permanent decision)
* **Cloud Infrastructure** — To be determined during implementation
* **Observability** — To be determined during implementation

---

## 5. Target Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CUSTOMER                              │
│              (Phone / WhatsApp / Email / SMS)            │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              STOREVOICE PLATFORM                         │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   CONTROL    │  │ INTERACTION │  │  OPERATIONS  │    │
│  │   PLANE      │  │   PLANE     │  │    PLANE     │    │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              VOICE ENGINE BOUNDARY                       │
│              (Stable Interface)                          │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│              FROZEN VOICE ENGINE                         │
│              (LiveKit Agents / Deepgram / OpenAI /       │
│               Cartesia)                                  │
└─────────────────────────────────────────────────────────┘
```

### Three-Plane Architecture

The StoreVoice Platform is organized into three conceptual planes:

#### Control Plane

Responsible for:

* Tenant management
* Identity and authorization
* Customer configuration
* Package entitlements
* Billing state
* Regulatory policy
* Localization configuration
* AI colleague configuration
* Knowledge approval
* Audit policy
* Operational controls
* Incident controls
* Provider configuration
* Onboarding workflows
* Demo management

#### Interaction Plane

Responsible for:

* Live conversations
* Voice sessions
* Channel sessions
* AI colleague runtime
* Knowledge retrieval
* Conversation context
* Escalation workflows
* Real-time events
* Tool execution

#### Operations Plane

Responsible for:

* Quality assurance
* Reporting
* Customer insight
* Human escalation management
* White Glove operations
* Incident management
* Post-incident review
* Learning and improvement

---

## 6. Control Plane

The Control Plane is the authoritative administrative layer of the StoreVoice Platform.

### Control Plane Domains

```
┌─────────────────────────────────────────┐
│           CONTROL PLANE                 │
│                                         │
│  Identity & Tenant Management           │
│  Customer Administration                │
│  Package & Entitlement Management       │
│  Billing & Subscription Management      │
│  Knowledge Management & Approval        │
│  AI Colleague Configuration             │
│  Localization Configuration             │
│  Compliance & Regulatory Management     │
│  Audit & Traceability                   │
│  Incident Management                    │
│  Onboarding Management                  │
│  Demo Management                        │
│  Provider Configuration                 │
│  Operational Controls                   │
│                                         │
└─────────────────────────────────────────┘
```

### Control Plane Responsibilities

The Control Plane:

* Maintains the authoritative state of all tenants, customers, and configurations
* Enforces package entitlements and feature access
* Manages knowledge lifecycle (ingest, validate, approve, version, activate, update, block, delete)
* Tracks compliance state across jurisdictions
* Maintains audit trails for incident investigation
* Manages customer lifecycle (signup, onboarding, activation, operation, upgrade, downgrade, cancellation, recovery, deletion)
* Controls demo creation and lifecycle
* Configures localization per tenant
* Manages provider selection and configuration

---

## 7. Interaction/Execution Plane

The Interaction Plane handles all real-time customer interactions.

### Interaction Plane Domains

```
┌─────────────────────────────────────────┐
│         INTERACTION PLANE               │
│                                         │
│  Channel Management                     │
│  Session Management                     │
│  AI Colleague Runtime                   │
│  Knowledge Retrieval                    │
│  Context Management                     │
│  Escalation Orchestration               │
│  Tool Execution                         │
│  Real-time Event Processing             │
│                                         │
└─────────────────────────────────────────┘
```

### Interaction Plane Responsibilities

The Interaction Plane:

* Manages channel sessions (phone, WhatsApp, email, SMS)
* Maintains conversation context within sessions
* Retrieves approved knowledge for the tenant
* Enforces AI colleague behavior policies
* Handles escalation triggers and handoff
* Executes tools within authorized boundaries
* Processes real-time events from the Voice Engine
* Manages interruption handling and turn detection

---

## 8. Major Bounded Contexts

The following bounded contexts are derived from the Founder Decisions, platform requirements, and capability gaps:

### Identity and Tenant Management

**Responsibility:** Manages customer identity, tenant creation, tenant isolation, and administrative access.

**Key concepts:**
* Tenant (customer account)
* Identity (customer identity)
* Administrative access (roles, permissions)
* Tenant lifecycle states

**Boundaries:**
* Each tenant is strictly isolated
* Tenant data, configuration, knowledge, and context must not cross boundaries
* Central infrastructure may be shared; customer information remains separated

**Source:** Founder Decision 6.17 (Multi-Tenant Principle)

---

### Customer Administration

**Responsibility:** Manages customer-facing administration, localized to the customer's country.

**Key concepts:**
* Customer profile
* Contact management
* Communication preferences
* Localized customer-facing interfaces

**Boundaries:**
* One central European customer administration from Greece
* Customer-facing administration is localized
* No separate country-specific customer administrations

**Source:** Founder Decision 6.21 (Central Customer Administration)

---

### Package and Entitlement Management

**Responsibility:** Defines commercial packages, feature entitlements, and package-based permissions.

**Key concepts:**
* Package definition (versioned)
* Feature entitlements
* Package versioning
* Upgrade/downgrade rules
* White Glove service level

**Boundaries:**
* One universal platform; capabilities gated through entitlements
* Package differences must not create separate architectures
* Existing customers retain commitments for applicable period

**Source:** Founder Decisions 6.22, 6.23 (Commercial Packages, Package Boundaries), FQ-04, FQ-10

---

### Knowledge Management

**Responsibility:** Manages the lifecycle of customer knowledge from ingestion to deletion.

**Key concepts:**
* Knowledge source (customer-provided, documents, onboarding)
* Knowledge ingestion
* Knowledge validation
* Knowledge approval
* Knowledge versioning
* Active knowledge
* Knowledge update/replace/block
* Conflict detection and resolution
* Knowledge audit history
* Knowledge deletion

**Boundaries:**
* Customer knowledge is tenant-isolated
* AI never invents company knowledge
* Conflicts are surfaced to the customer; last approved information remains authoritative
* Customer-specific knowledge is deleted after termination
* StoreVoice may retain non-identifiable aggregated insights

**Source:** Founder Decisions 6.11, 6.12, 6.13, 6.18, 6.19, FQ-08

---

### AI Colleague Runtime

**Responsibility:** Defines AI colleague persona, behavior policies, autonomy boundaries, and safety mechanisms.

**Key concepts:**
* Persona definition
* Behavior policy
* Autonomy boundaries
* Safety mechanisms
* Emotion handling
* Knowledge boundary enforcement

**Boundaries:**
* Character is allowed; ego is not
* AI may anticipate human experience but must not manufacture it
* Technical capability does not automatically imply business authorization
* Autonomy exists inside human-defined boundaries

**Source:** Founder Decisions 6.5, 6.6, 6.8

---

### Localization

**Responsibility:** Manages country-aware localization across all customer-facing experiences.

**Key concepts:**
* Locale
* Language
* Communication style
* Formality
* Cultural expression
* Customer-facing documentation
* Invoices
* Reports
* AI colleague behavior

**Boundaries:**
* Architecture must be capable of supporting all European languages
* Localization is NOT merely translation
* Individual languages may be rolled out progressively
* Architecture must not artificially limit to current 4 languages

**Source:** Founder Decisions 6.4, FQ-05

---

### Channel and Conversation Management

**Responsibility:** Manages communication channels and conversation lifecycle.

**Key concepts:**
* Channel (phone, WhatsApp, email, SMS)
* Conversation session
* Conversation context
* Channel-specific behavior
* Unified cross-channel context

**Boundaries:**
* AI is the first contact point across all channels
* Do not infer separate AI agents for each channel
* Conversation context should unify across channels

**Source:** Founder Decisions 6.25, 6.26

---

### Human Escalation

**Responsibility:** Manages human handoff, transfer, callback, and context handoff.

**Key concepts:**
* Escalation triggers
* Cold transfer
* Warm transfer
* Callback scheduling
* Context handoff
* Human availability

**Boundaries:**
* Human escalation is appropriate when: decision required, emotion useful, caller requests human, AI lacks knowledge, human can materially help
* White Glove: 24/7 human responsibility and escalation
* NOT: 24/7 permanently staffed live operators
* Outside human availability: AI handles safely, preserves context, arranges follow-up

**Source:** Founder Decisions 6.7, FQ-07

---

### Customer Lifecycle

**Responsibility:** Manages customer journey from prospect to deletion.

**Key concepts:**
* Prospect
* Demo
* Customer
* Onboarding
* Ready
* Active
* Upgrade pending
* Downgrade pending
* Cancellation pending
* Paid period
* Recovery
* Deleted

**Boundaries:**
* Services are prepaid
* Standard packages are monthly cancellable
* 14-day recovery period
* Permanent deletion after recovery
* Returning customer after deletion treated as new customer

**Source:** Founder Decisions 6.20, 6.27

---

### Billing and Commercial

**Responsibility:** Manages payment processing, subscriptions, and commercial operations.

**Key concepts:**
* Subscription (prepaid)
* Payment processing (Stripe)
* Proration (upgrade)
* Downgrade timing (end of month)
* Cancellation
* Renewal

**Boundaries:**
* Stripe handles payments
* Services are prepaid
* Customer administration is centralized
* Do not make Stripe the entire commercial architecture

**Source:** Founder Decisions 6.23, 6.24

---

### Onboarding

**Responsibility:** Manages customer onboarding workflows.

**Key concepts:**
* Self-setup
* White Glove onboarding
* Knowledge collection
* Configuration
* Testing/refinement
* Progress visibility
* Readiness percentage
* Activation

**Boundaries:**
* White Glove onboarding is human-led
* Target approximately 5-7 days, quality is readiness gate
* 100% means ready to go live
* No separate mandatory manual testing gate after 100%

**Source:** Founder Decision 6.27

---

### Demo

**Responsibility:** Manages temporary demo instances.

**Key concepts:**
* Website scraping
* Temporary knowledge
* Temporary AI colleague
* Demo interaction
* Conversion/follow-up
* Expiration/deletion

**Boundaries:**
* Demo is temporary (approximately 48 hours default)
* Uses only scraped website knowledge
* Not a full production trial
* Demo data cannot accidentally become production knowledge
* Lifecycle must be measurable and configurable

**Source:** Founder Decisions 6.29, FQ-09

---

### Compliance and Regulatory

**Responsibility:** Manages regulatory compliance across jurisdictions.

**Key concepts:**
* Jurisdiction awareness
* Applicable regulation
* Service applicability
* Effective dates
* Compliance rules
* Mandatory changes
* Controlled rollout
* Auditability
* Risk handling

**Boundaries:**
* Central regulatory governance
* Mandatory changes cannot be refused
* Customers accept StoreVoice service under applied rules
* Do not invent legal requirements

**Source:** Founder Decisions 6.10, FQ-06

---

### Audit and Traceability

**Responsibility:** Maintains ability to reconstruct relevant incidents.

**Key concepts:**
* What the AI said
* What knowledge was active
* What context was available
* What configuration applied
* What package/entitlements applied
* What policy applied
* What provider/version was used
* What escalation occurred
* What human intervention occurred
* Relevant timestamps

**Boundaries:**
* Balance auditability with privacy and data-minimization
* Complete technical audit trail initially managed by StoreVoice
* StoreVoice determines which relevant portions are shared with customers

**Source:** Founder Decision 6.13

---

### Incident and Safety

**Responsibility:** Manages incident detection, escalation, containment, and review.

**Key concepts:**
* Incident detection
* Incident state
* Severity
* Escalation
* Operational containment
* AI colleague disable/offline
* Fallback
* Customer continuity
* Human review
* Post-incident analysis
* Cross-customer investigation
* Centralized structural improvements

**Boundaries:**
* Safety and continuity come before complete root-cause analysis
* Exceptional circumstances: AI colleague may be taken offline
* Every serious incident receives human post-incident review
* Approved structural improvements are centrally implemented

**Source:** Founder Decision 6.14

---

### Data Ownership and Learning

**Responsibility:** Manages boundaries between customer data and StoreVoice general learning.

**Key concepts:**
* Tenant data (customer-owned)
* Customer knowledge
* Conversation data
* Operational telemetry
* Audit data
* Aggregated learning
* Anonymized learning
* StoreVoice-owned general knowledge

**Boundaries:**
* Customer owns business information provided
* StoreVoice owns technology, platform, general methodologies
* Customer-specific knowledge deleted after termination
* StoreVoice may retain non-identifiable aggregated insights
* No customer-specific knowledge may silently become general knowledge

**Source:** Founder Decisions 6.18, 6.19, FQ-08

---

### Provider Abstraction

**Responsibility:** Isolates external provider dependencies from business domains.

**Key concepts:**
* STT provider
* LLM provider
* TTS provider
* Telephony provider
* Payment provider
* Cloud infrastructure provider
* Observability provider

**Boundaries:**
* Provider replacement must not contaminate business domains
* Current providers are facts/references where verified
* They are NOT automatically permanent architectural decisions
* Prefer replaceable dependencies where practical

**Source:** Founder Decision 6.9, Current Voice Engine Capability

---

## 9. Tenant Architecture

### Multi-Tenant Principle

StoreVoice is ALWAYS multi-tenant.

Each customer has strict separation of:

* Identity
* Data
* Knowledge
* Configuration
* Context
* Conversations
* Memory
* Audit data

Shared infrastructure is permitted.

Cross-tenant customer information is NOT.

### Tenant Isolation Model

```
┌─────────────────────────────────────────┐
│         SHARED INFRASTRUCTURE           │
│                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐│
│  │Tenant A │  │Tenant B │  │Tenant C ││
│  │         │  │         │  │         ││
│  │Identity │  │Identity │  │Identity ││
│  │Data     │  │Data     │  │Data     ││
│  │Knowledge│  │Knowledge│  │Knowledge││
│  │Config   │  │Config   │  │Config   ││
│  │Context  │  │Context  │  │Context  ││
│  │Convo    │  │Convo    │  │Convo    ││
│  │Memory   │  │Memory   │  │Memory   ││
│  │Audit    │  │Audit    │  │Audit    ││
│  └─────────┘  └─────────┘  └─────────┘│
│                                         │
└─────────────────────────────────────────┘
```

### Tenant Isolation Requirements

* Tenant isolation must be structurally difficult to violate, not merely prohibited by documentation
* Database-level tenant isolation is the primary mechanism
* Application-level tenant context is enforced on all data access
* API-level tenant scoping prevents cross-tenant queries
* Configuration is per-tenant, not globally shared
* Knowledge is per-tenant, not shared across tenants
* Conversations are per-tenant, not shared across tenants
* Audit data is per-tenant, not shared across tenants

---

## 10. AI Colleague Architecture

### Conceptual Model

The AI colleague is composed of:

* **Identity** — Name, role, persona definition
* **Persona** — How the AI presents itself
* **Behavior Policy** — What the AI may and may not do
* **Knowledge** — What the AI knows about the customer's business
* **Context** — Current conversation and session state
* **Memory** — Persistent information across sessions (where permitted)
* **Permissions** — What the AI is authorized to do
* **Package Entitlements** — What capabilities are available
* **Localization** — Language, style, cultural expression
* **Compliance Constraints** — Regulatory rules that apply
* **Operational State** — Online, offline, degraded
* **Conversation State** — Current interaction state

### Durable vs. Ephemeral

| Element | Durable | Ephemeral |
|---------|---------|-----------|
| Identity | Yes | No |
| Persona | Yes | No |
| Behavior Policy | Yes | No |
| Knowledge (approved) | Yes | No |
| Knowledge (draft) | Yes | No |
| Context (current) | No | Yes |
| Session Context | No | Yes |
| Memory | Yes | No |
| Permissions | Yes | No |
| Package Entitlements | Yes | No |
| Localization Config | Yes | No |
| Compliance Rules | Yes | No |
| Operational State | Yes | Partially |
| Conversation State | No | Yes |

### Tenant-Specific vs. Centrally Governed

| Element | Tenant-Specific | Centrally Governed |
|---------|-----------------|---------------------|
| Identity | Yes | No |
| Persona | Yes | Templates centrally governed |
| Behavior Policy | Yes | Boundaries centrally governed |
| Knowledge | Yes | No |
| Localization | Yes | Framework centrally governed |
| Compliance | No | Yes, applied per-jurisdiction |
| Safety Rules | No | Yes |
| Autonomy Boundaries | Package-specific | Package definitions centrally governed |

### Customer-Editable vs. System-Controlled

| Element | Customer-Editable | System-Controlled |
|---------|-------------------|-------------------|
| Knowledge content | Yes | No |
| Knowledge approval | No | Yes |
| Persona (within bounds) | Yes | Boundaries enforced |
| Behavior Policy | No | Yes |
| Package Entitlements | No | Yes |
| Compliance Rules | No | Yes |
| Safety Rules | No | Yes |
| Localization Config | Yes | Within framework |

### Persona Philosophy

> **"A persona is how the AI starts; context and experience make it a colleague."**

The persona is the initial configuration. Over time, through interactions and accumulated context, the AI colleague develops into a more experienced, context-aware colleague.

The architecture must support this evolution without creating unnecessary technical complexity.

---

## 11. Knowledge Architecture

### Knowledge Lifecycle

```
SOURCE
  ↓
INGEST
  ↓
VALIDATE
  ↓
REVIEW
  ↓
APPROVE
  ↓
VERSION
  ↓
ACTIVE KNOWLEDGE
  ↓
UPDATE / REPLACE / BLOCK
  ↓
AUDIT HISTORY
```

### Knowledge Model

Each knowledge item has:

* **Provenance** — Where the information came from
* **Source Attribution** — Who provided it
* **Approval State** — Draft, Pending, Approved, Rejected, Blocked
* **Effective Dates** — When applicable (where relevant)
* **Conflicts** — Whether it conflicts with other knowledge
* **Authoritative State** — Whether it is the current approved version
* **Rollback** — Ability to revert to previous approved version
* **Audit History** — Complete change record
* **Customer Visibility** — What the customer can see
* **Deletion** — Ability to delete when required

### Conflict Resolution

When information conflicts:

1. AI must not arbitrarily select the truth
2. Conflict is presented to the customer
3. Customer decides which information is correct
4. Last approved information remains authoritative until customer confirms
5. AI continues using safe approved information while conflict is unresolved

### Knowledge Separation

**Customer-Specific Knowledge:**
* Provided by customer during onboarding
* Maintained by StoreVoice as part of service
* Strictly tenant-isolated
* Deleted after customer termination
* Subject to audit trail

**StoreVoice General Knowledge / Aggregated Learning:**
* Anonymized patterns
* Aggregated patterns
* General QA findings
* General knowledge gaps
* General operational experience
* NOT customer-identifiable
* NOT reconstructable to specific customers
* Retained after customer leaves

---

## 12. Context/Memory Architecture

### Context Hierarchy

```
Current Conversation Context (ephemeral)
    ↓
Session Context (ephemeral)
    ↓
Durable Customer Context (persistent)
    ↓
Approved Business Knowledge (persistent)
    ↓
AI Colleague Persona (persistent)
    ↓
Interaction History (persistent, governed)
```

### Current Conversation Context

* Active within a single conversation turn
* Includes current user utterance, AI response, and immediate context
* Ephemeral — does not persist beyond the conversation

### Session Context

* Active within a single interaction session
* Includes conversation history within the session
* Includes current topic, sentiment, and intent
* Ephemeral — does not persist beyond the session

### Durable Customer Context

* Persistent across sessions
* Includes customer-specific information the AI should remember
* Includes interaction patterns and preferences
* Governed by retention policies
* Customer-visible and customer-editable

### Approved Business Knowledge

* Persistent across sessions
* Includes company information, products, services, policies
* Versioned and auditable
* Customer-visible and customer-editable (with approval)

### Interaction History

* Persistent across sessions
* Includes summaries of past conversations
* NOT raw conversation transcripts (unless required for audit)
* Governed by retention and privacy policies
* Used for context enrichment, not direct recall

### Governance Boundaries

* Not all historical conversations should become AI memory
* Customer controls what durable context the AI maintains
* Retention policies govern how long context is maintained
* Deletion is permanent and structural

---

## 13. Localization Architecture

### Localization as Structured Configuration

Localization is NOT:

* A collection of country-specific code forks
* `GermanCustomerCode`
* `FrenchCustomerCode`
* `DutchCustomerCode`

Localization IS:

* Structured configuration and data
* Reusable mechanisms for locale, language, country, cultural rules
* Applied uniformly across the platform

### Localization Dimensions

| Dimension | Scope | Example |
|-----------|-------|---------|
| Language | All European languages | EN, NL, FR, DE, ES, IT, PT, PL, etc. |
| Locale | Country-specific formatting | Date, currency, number formats |
| Communication Style | Formal/informal, direct/indirect | DE: formal; NL: informal |
| Cultural Expression | Country-specific cultural norms | Greetings, politeness patterns |
| Formality | Formal/informal register | DE: "Sie"; NL: "je" |
| Customer-Facing Documentation | Localized UI, emails, reports | All user-facing text |
| Invoices | Localized invoice format | Country-specific requirements |
| Reports | Localized reporting | Customer-facing reports |
| AI Behavior | Country-specific AI behavior | Communication style, cultural norms |

### Language Rollout Strategy

* Architecture must support all European languages
* Individual languages may be rolled out progressively
* Current Voice Engine supports: EN, NL, FR, DE
* Future language expansion must not require architectural changes
* Platform must be capable of supporting languages beyond current 4

---

## 14. Channel Architecture

### Supported Channels

| Channel | Status | Provider | Notes |
|---------|--------|----------|-------|
| Phone | Current | Twilio (direction) | Local number provisioning desired |
| WhatsApp | Future | TBD | Integration required |
| Email | Future | TBD | Integration required |
| SMS | Future | TBD | Integration required |

### Channel Architecture Principles

* AI is the first contact point across all channels
* Do not infer separate AI agents for each channel
* Design a coherent conversation/contact architecture
* Unified context across channels
* Channel-specific behavior where appropriate

### Unified Context

Customer context should unify across channels:

* Same customer identified across channels
* Conversation history accessible across channels
* Escalation state shared across channels
* Knowledge and configuration shared across channels

---

## 15. Human Escalation Architecture

### Escalation Triggers

Human escalation is appropriate when:

* A decision is required
* Emotion makes human involvement materially useful
* The caller explicitly requests a human
* The AI lacks required knowledge
* A human can materially help

### Transfer Types

**Cold Transfer:**
* Transfer the caller with structured context
* Customer does not need to repeat their story
* Context includes: what customer needs, why AI could not complete, which human is appropriate

**Warm Transfer:**
* AI prepares the human verbally and supplies structured context
* Then connects the customer
* Context includes summary of conversation, customer intent, urgency

**Callback:**
* If no human is available, preserve relevant context
* Schedule follow-up at appropriate time
* Context should include only what the human needs

### Context Handoff

The AI must preserve:

* What the customer needs
* Why the AI could not complete the task
* Which human colleague or department is appropriate
* Relevant conversation context
* Customer contact information
* Urgency and sensitivity indicators

### Human Availability

* White Glove: 24/7 human responsibility and escalation
* NOT: 24/7 permanently staffed live operators
* When human available: transfer possible
* When human unavailable: AI handles safely, preserves context, arranges callback

---

## 16. Customer Lifecycle

### Lifecycle States

```
PROSPECT
    ↓
DEMO (temporary, ~48 hours)
    ↓
CONVERSION
    ↓
CUSTOMER
    ↓
ONBOARDING
    ↓
READY (100%)
    ↓
ACTIVE
    ↓
UPGRADE_PENDING ─────→ ACTIVE (new package)
    ↓
DOWNGRADE_PENDING ───→ ACTIVE (end of month)
    ↓
CANCELLATION_PENDING → PAID_PERIOD (prepaid)
    ↓
RECOVERY (14 days)
    ↓
DELETED (permanent)
```

### State Transitions

| From | To | Trigger | Authority |
|------|----|---------|-----------|
| PROSPECT | DEMO | Demo request | System |
| DEMO | CONVERSION | Customer signs up | Customer |
| DEMO | EXPIRED | 48 hours elapsed | System |
| CUSTOMER | ONBOARDING | Subscription starts | Customer |
| ONBOARDING | READY | 100% readiness | System |
| ACTIVE | UPGRADE_PENDING | Customer requests upgrade | Customer |
| UPGRADE_PENDING | ACTIVE | Upgrade processed | System |
| ACTIVE | DOWNGRADE_PENDING | Customer requests downgrade | Customer |
| DOWNGRADE_PENDING | ACTIVE | End of month | System |
| ACTIVE | CANCELLATION_PENDING | Customer cancels | Customer |
| CANCELLATION_PENDING | PAID_PERIOD | Cancellation processed | System |
| PAID_PERIOD | RECOVERY | Paid period ends | System |
| RECOVERY | ACTIVE | Customer reactivates | Customer |
| RECOVERY | DELETED | 14 days elapsed | System |
| DELETED | (new customer) | New signup | Customer |

---

## 17. Package/Entitlement Architecture

### Package Model

```
Package
    ↓
Version
    ↓
Entitlements
    ↓
Customer Subscription
    ↓
Effective Entitlement State
```

### Current Packages

| Package | Price | Features | Service Level |
|---------|-------|----------|---------------|
| A | €29/month | Basic AI colleague telephone answering | Self-setup OR White Glove |
| B | €29 first month, €59/month | A + appointment scheduling | Self-setup OR White Glove |
| Enterprise | High monthly fee | High-touch total service | White Glove inherent |

### Entitlement Architecture

* Entitlements are configuration-driven, not hardcoded
* Package versioning supports evolution
* Existing customers retain commitments for applicable period
* Material changes are versioned and communicated
* Upgrade is immediate and prorated
* Downgrade takes effect at end of month

### Package Evolution

* StoreVoice may evolve packages under central human governance
* Existing customers retain agreed functionality for paid period
* Material changes are versioned, communicated, and migrated through controlled process
* Mandatory regulatory or safety changes remain governed centrally

---

## 18. Billing Architecture

### Billing Model

```
Customer
    ↓
Subscription (prepaid)
    ↓
Package
    ↓
Package Version
    ↓
Entitlement State
    ↓
Billing State
    ↓
Payment Processing (Stripe)
```

### Billing Principles

* Services are prepaid
* Stripe handles payment processing
* Stripe is an external provider, not the entire commercial architecture
* Business domain must not depend on Stripe-specific objects

### Billing Operations

| Operation | Timing | Proration |
|-----------|--------|-----------|
| Upgrade | Immediate | Prorated |
| Downgrade | End of month | None |
| Cancellation | End of paid period | None |
| Reactivation | Immediate | New subscription |

---

## 19. Demo Architecture

### Demo Lifecycle

```
WEBSITE
    ↓
SCRAPE
    ↓
TEMPORARY KNOWLEDGE
    ↓
TEMPORARY AI COLLEAGUE
    ↓
DEMO INTERACTION (~90 seconds)
    ↓
CONVERSION / FOLLOW-UP
    ↓
EXPIRATION / DELETION (~48 hours)
```

### Demo Principles

* Demo is temporary by design (approximately 48 hours default)
* Uses only scraped website knowledge
* Not a full production trial
* Demo data cannot accidentally become production knowledge
* Lifecycle must be measurable and configurable
* No assumed conversion rate becomes a hard architectural constraint

### Demo Isolation

* Demo instances are isolated from production
* Demo knowledge is separate from production knowledge
* Demo configuration is temporary
* Demo data is deleted after expiry

---

## 20. Compliance Architecture

### Compliance Model

```
JURISDICTION
    ↓
APPLICABLE REGULATION
    ↓
SERVICE APPLICABILITY
    ↓
EFFECTIVE DATE
    ↓
COMPLIANCE RULES
    ↓
MANDATORY CHANGES
    ↓
CONTROLLED ROLLOUT
    ↓
AUDITABILITY
```

### Compliance Principles

* Central regulatory governance
* Mandatory changes cannot be refused by customers
* Customers accept StoreVoice service under applied rules
* Do not invent legal requirements
* Legal interpretation belongs to future compliance/legal workstream
* Implementation may be phased centrally where legally permissible

### Compliance Dimensions

* Jurisdiction awareness
* Applicable regulation tracking
* Service applicability determination
* Effective date management
* Compliance rule enforcement
* Mandatory change rollout
* Exception status tracking (where legally permitted)
* Audit history

---

## 21. Audit Architecture

### Audit Requirements

StoreVoice must be able to reconstruct:

* What the AI said
* What knowledge was active
* What context was available
* What configuration applied
* What package/entitlements applied
* What policy applied
* What provider/version was used
* What escalation occurred
* What human intervention occurred
* Relevant timestamps

### Audit Approach

* Knowledge is versioned — point-in-time reconstruction is possible
* Configuration is versioned — point-in-time reconstruction is possible
* Conversations are logged — context can be reconstructed
* Actions are logged — AI behavior can be reconstructed
* Balance auditability with privacy and data-minimization
* Complete technical audit trail initially managed by StoreVoice
* StoreVoice determines which relevant portions are shared with customers

---

## 22. Incident/Safety Architecture

### Incident Detection

* Monitoring-based detection
* Threshold-based alerting
* Customer-reported incidents
* Operational anomaly detection

### Incident Response

```
DETECTION
    ↓
CLASSIFICATION (severity)
    ↓
CONTAINMENT (operational)
    ↓
ESCALATION (human)
    ↓
RESOLUTION
    ↓
POST-INCIDENT REVIEW
    ↓
STRUCTURAL IMPROVEMENTS
```

### Safety Principles

* Safety and continuity come before complete root-cause analysis
* Exceptional circumstances: AI colleague may be taken offline
* Every serious incident receives human post-incident review
* Approved structural improvements are centrally implemented for relevant customers
* StoreVoice proactively investigates problems that could affect multiple customers

### Emergency Capabilities

* AI colleague disable/offline capability
* Fallback behavior when AI cannot operate
* Customer continuity during incidents
* Human review and intervention

---

## 23. Provider Abstraction

### Provider Categories

| Category | Current Provider | Status | Abstraction Level |
|----------|-----------------|--------|-------------------|
| STT | Deepgram Nova-3 | FACT (current) | Exists (build_stt) |
| LLM | OpenAI GPT-4.1 | FACT (current) | Exists (build_llm) |
| TTS | Cartesia Sonic-3 | FACT (current) | Exists (build_tts) |
| Telephony | Twilio | DIRECTION (not permanent) | To be designed |
| Payments | Stripe | DIRECTION (not permanent) | To be designed |
| Cloud | TBD | UNKNOWN | To be designed |
| Observability | TBD | UNKNOWN | To be designed |

### Provider Abstraction Principles

* Provider replacement must not contaminate business domains
* Current providers are facts/references where verified
* They are NOT automatically permanent architectural decisions
* Prefer replaceable dependencies where practical
* Provider interfaces should be clean and well-defined
* Business logic must not depend on provider-specific objects

---

## 24. Voice Engine Boundary

This is one of the most critical architectural boundaries.

### Boundary Design

```
┌─────────────────────────────────────────┐
│         STOREVOICE PLATFORM             │
│                                         │
│  Voice Session Request                  │
│  Configuration (persona, knowledge,     │
│    context, policies)                   │
│  Channel Information                    │
│  Tenant Context                         │
│                                         │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│       VOICE ENGINE BOUNDARY             │
│       (Stable Interface)                │
│                                         │
│  Input:                                 │
│  - Session configuration                │
│  - Knowledge context                    │
│  - Persona definition                   │
│  - Behavior policies                    │
│  - Channel parameters                   │
│                                         │
│  Output:                                │
│  - Conversation events                  │
│  - Transcription                        │
│  - AI responses                         │
│  - Escalation triggers                  │
│  - Telemetry                            │
│  - Errors                               │
│                                         │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│         FROZEN VOICE ENGINE             │
│         (External Component)            │
│                                         │
│  LiveKit Agents SDK                     │
│  Deepgram Nova-3 (STT)                 │
│  OpenAI GPT-4.1 (LLM)                 │
│  Cartesia Sonic-3 (TTS)               │
│  Silero VAD                            │
│  Turn Detection                        │
│  Interruption Handling                  │
│                                         │
└─────────────────────────────────────────┘
```

### Boundary Responsibilities

**Platform Responsibilities:**
* Tenant context and isolation
* Knowledge retrieval and approval
* Persona configuration
* Behavior policy enforcement
* Package entitlement enforcement
* Channel management
* Escalation orchestration
* Audit logging
* Compliance enforcement

**Engine Responsibilities:**
* Real-time voice processing
* Speech-to-text conversion
* Language model inference
* Text-to-speech synthesis
* Voice Activity Detection
* Turn detection
* Interruption handling
* Basic conversation flow

### Input Contract (Platform → Engine)

| Input | Description | Required |
|-------|-------------|----------|
| Session configuration | Channel, language, tenant context | Yes |
| Knowledge context | Approved knowledge for this tenant | Yes |
| Persona definition | How the AI should present itself | Yes |
| Behavior policies | What the AI may and may not do | Yes |
| System prompt | Base prompt with knowledge and policies | Yes |
| Channel parameters | Phone number, caller info, etc. | Yes |

### Output Contract (Engine → Platform)

| Output | Description | Required |
|--------|-------------|----------|
| Transcription | What the user said | Yes |
| AI response | What the AI said | Yes |
| Conversation events | Turn, interruption, etc. | Yes |
| Escalation trigger | When escalation is needed | Conditional |
| Telemetry | Latency, errors, metrics | Yes |
| Error events | When something goes wrong | Yes |

### Session Lifecycle

```
PLATFORM: Create session
    ↓
PLATFORM: Configure (persona, knowledge, context, policies)
    ↓
BOUNDARY: Start session
    ↓
ENGINE: Process conversation
    ↓
BOUNDARY: Stream events (transcription, response, telemetry)
    ↓
PLATFORM: Handle events (escalation, audit, context update)
    ↓
BOUNDARY: End session
    ↓
PLATFORM: Record session, update audit
```

### Configuration Boundary

* Platform provides configuration to engine
* Engine does not manage configuration
* Configuration changes during session are platform-initiated
* Engine receives configuration snapshots, not live configuration streams

### Context Boundary

* Platform maintains durable context
* Engine receives context snapshot at session start
* Engine does not persist context
* Context updates during session are platform-managed

### Interruption Handling Boundary

* Engine handles real-time interruption detection
* Engine handles turn detection and VAD
* Platform receives interruption events
* Platform may influence behavior through policy updates

### Tool Boundary

* Engine may request tool execution
* Platform provides tool implementation
* Tool execution is governed by package entitlements and safety policies
* Engine does not execute tools directly

### Telemetry Boundary

* Engine produces telemetry (latency, errors, metrics)
* Platform consumes telemetry for monitoring and audit
* Telemetry is tenant-scoped where applicable
* Telemetry supports incident investigation

### Error Boundary

* Engine produces error events
* Platform handles error recovery
* Platform determines fallback behavior
* Error handling is governed by safety policies

### Provider Boundary

* Engine manages STT, LLM, TTS providers
* Platform does not directly interact with voice providers
* Provider selection is engine-internal
* Platform may influence provider selection through configuration

### Versioning and Compatibility

* Boundary interface is versioned
* Platform and engine may evolve independently within boundary contract
* Backward compatibility is maintained within major versions
* Breaking changes require coordinated migration

### Replacement Strategy

The architecture must allow:

```
CURRENT ENGINE
    → ADAPTER/BOUNDARY
    → FUTURE ENGINE
```

Without reconstructing the StoreVoice platform.

**Replacement requirements:**
* New engine must implement the boundary interface
* Platform configuration must be engine-agnostic
* Knowledge and context must be portable
* Audit trail must be maintained during transition
* Customer continuity must be preserved
* Rollback capability must exist

---

## 25. API/Event Architecture

### API Boundaries

The StoreVoice Platform exposes:

* **External APIs** — Customer-facing and partner-facing
* **Internal Service Interfaces** — Between platform domains
* **Webhooks** — Event notifications to external systems
* **Domain Events** — Internal event-driven communication
* **Integration Events** — Cross-boundary events

### API Principles

* Focus on stable business boundaries, not speculative endpoints
* Distinguish COMMAND, QUERY, and EVENT
* APIs are tenant-scoped
* APIs enforce package entitlements
* APIs produce audit events

### Key API Groups

| Group | Purpose | Tenancy |
|-------|---------|---------|
| Identity API | Customer authentication and authorization | Tenant-scoped |
| Tenant API | Tenant management | Admin |
| Customer API | Customer administration | Tenant-scoped |
| Knowledge API | Knowledge lifecycle management | Tenant-scoped |
| Configuration API | AI colleague configuration | Tenant-scoped |
| Package API | Package and entitlement management | Tenant-scoped |
| Billing API | Subscription and payment management | Tenant-scoped |
| Channel API | Channel session management | Tenant-scoped |
| Escalation API | Human escalation management | Tenant-scoped |
| Audit API | Audit trail access | Admin |
| Incident API | Incident management | Admin |
| Onboarding API | Onboarding workflow management | Tenant-scoped |
| Demo API | Demo creation and management | Prospect-scoped |
| Compliance API | Regulatory compliance management | Admin |
| Reporting API | Customer insight and reporting | Tenant-scoped |

### Event Architecture

| Event Type | Purpose | Example |
|------------|---------|---------|
| Domain Event | State change within a domain | KnowledgeApproved |
| Integration Event | Cross-boundary notification | ConversationCompleted |
| Command | Request to perform action | CreateTenant |
| Query | Request for information | GetCustomerConfig |
| Webhook | External notification | PaymentReceived |

---

## 26. Security Architecture

### Security Principles

* Authentication for all access
* Authorization for all operations
* Tenant isolation is structural, not just policy
* Secrets management for all credentials
* Encryption at rest and in transit
* Privileged access is audited
* Administrative access is controlled
* Provider credentials are managed centrally

### Security Domains

| Domain | Concern | Approach |
|--------|---------|----------|
| Authentication | Who is accessing | Identity service |
| Authorization | What they can do | Role-based + package entitlements |
| Tenant Isolation | Cross-tenant access prevention | Structural isolation |
| Secrets | Credential management | Centralized secrets management |
| Encryption | Data protection | At rest and in transit |
| Privileged Access | Administrative operations | Controlled and audited |
| Audit | Security events | Logged and monitored |

---

## 27. Observability

### Observability Requirements

Architecture must support operational visibility across:

* Calls and conversations
* Latency (STT, LLM, TTS, total)
* Channel performance
* Interruption handling
* Escalation events
* Errors and failures
* Provider failures
* Customer health
* QA metrics
* Incidents

### Telemetry Categories

| Category | Metrics | Source |
|----------|---------|--------|
| Voice | Latency, quality, interruptions | Voice Engine |
| Conversation | Duration, turns, escalation | Platform |
| Channel | Volume, response time, delivery | Channel providers |
| Business | Customers, packages, revenue | Billing system |
| Operational | Incidents, resolution time, QA | Operations |
| Provider | Availability, latency, errors | Provider monitoring |

---

## 28. Resilience

### Resilience Design

| Failure | Response | Graceful Degradation |
|---------|----------|---------------------|
| Provider failure | Fallback provider or queue | Reduced capability, not total failure |
| Region failure | Failover to healthy region | Service continues in available region |
| Service degradation | Reduced functionality | Core service prioritized |
| Voice Engine failure | Queue and retry | Callback when restored |
| Database failure | Read replicas, backup | Read-only mode |
| Network failure | Retry, cache | Cached responses where safe |
| Human escalation failure | Fallback to callback | Context preserved, follow-up scheduled |
| Messaging failure | Retry, alternative channel | Message queued for delivery |

### Availability Principles

* Do not promise impossible availability
* Design for graceful degradation
* Core service prioritized over advanced features
* Customer continuity maintained during failures
* Recovery processes are tested

---

## 29. Scalability

### Scalability Principles

* Architecture must support growth without redesign
* Vertical scaling where appropriate
* Horizontal scaling where appropriate
* Tenant isolation must not degrade with scale
* Knowledge retrieval must remain performant

### Technical Unknowns

The following capacity parameters are NOT yet known and require future validation:

| Parameter | Status | Validation Required |
|-----------|--------|-------------------|
| Concurrent calls per tenant | UNKNOWN | Load testing |
| Total concurrent calls | UNKNOWN | Load testing |
| Total tenants | UNKNOWN | Growth projection |
| Knowledge base size per tenant | UNKNOWN | Usage analysis |
| Database throughput | UNKNOWN | Benchmarking |
| API request rate | UNKNOWN | Usage analysis |

> `TECHNICAL UNKNOWN` — These are not invented numbers. They require future validation experiments.

---

## 30. Deployment Topology

### Target Deployment Topology

```
┌─────────────────────────────────────────────────┐
│              CONTROL PLANE                       │
│              (Central)                           │
│                                                 │
│  Identity Service                               │
│  Tenant Service                                 │
│  Knowledge Service                              │
│  Configuration Service                          │
│  Billing Service                                │
│  Compliance Service                             │
│  Audit Service                                  │
│  Incident Service                               │
│                                                 │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│              INTERACTION PLANE                   │
│              (Region-Aware)                      │
│                                                 │
│  Channel Gateways                               │
│  Session Managers                               │
│  AI Colleague Runtimes                          │
│  Escalation Orchestrators                        │
│                                                 │
└────────────────────┬────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────┐
│         VOICE ENGINE BOUNDARY                    │
│         (Stable Interface)                       │
├─────────────────────────────────────────────────┤
│         FROZEN VOICE ENGINE                      │
│         (External Component)                     │
└─────────────────────────────────────────────────┘
```

### Regional Processing

Central control plane is the authority.

Regional processing may exist where required for:

* Compliance (data residency)
* Latency (voice processing)
* Resilience (geographic distribution)
* Capacity (load distribution)
* Provider availability (provider regional presence)

Regional processing remains subordinate to the central platform.

### Environments

| Environment | Purpose | Data |
|-------------|---------|------|
| Development | Active development | Synthetic |
| Staging | Pre-production validation | Anonymized |
| Production | Live service | Real customer data |

---

## 31. Migration Strategy

### Migration Principles

The migration from frozen Voice Engine to platform architecture must:

* Preserve customer continuity
* Preserve existing functionality
* Support rollback
* Maintain compatibility
* Allow controlled replacement

### Migration Approach

```
CURRENT FROZEN VOICE ENGINE
    ↓
IDENTIFY STABLE BOUNDARY
    ↓
BUILD PLATFORM AROUND ENGINE
    ↓
ENGINE REMAINS BEHIND BOUNDARY
    ↓
FUTURE: REPLACE ENGINE IF NEEDED
    ↓
PLATFORM UNAFFECTED
```

### Migration Constraints

* No migration code should be written during 004C
* Migration is a future implementation concern
* The boundary must be designed now to enable migration later
* Customer continuity is the top priority during any migration

---

## 32. Technical Constraints

### Frozen Voice Engine Constraints

* Repository: `Storevoice/storevoice`
* Reference Commit: `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
* Status: FROZEN REFERENCE
* Must NOT be modified without explicit human-approved architectural change
* Must NOT be redesigned, recreated, or replaced without approval

### Current Provider Facts

| Provider | Role | Status | Is This Permanent? |
|----------|------|--------|-------------------|
| Deepgram Nova-3 | STT | Current | NO — replaceable |
| OpenAI GPT-4.1 | LLM | Current | NO — replaceable |
| Cartesia Sonic-3 | TTS | Current | NO — replaceable |
| LiveKit Agents | Framework | Current | NO — replaceable |
| Silero | VAD | Current | NO — replaceable |
| Twilio | Telephony | Direction | NO — not permanent |
| Stripe | Payments | Direction | NO — not permanent |

### Infrastructure Constraints

* Current Oracle VM is a reference/fact, not the final production architecture
* Current LiveKit Cloud configuration is not the permanent platform architecture
* Do not overfit target architecture to today's infrastructure

---

## 33. Architectural Decisions

### Decision AD-01: Three-Plane Architecture

**Decision:** The StoreVoice Platform is organized into Control Plane, Interaction Plane, and Operations Plane.

**Rationale:** Separation of concerns between administrative operations, real-time interactions, and operational management. Aligns with the Founder Decision for one central platform with clear domain boundaries.

**Alternatives:** Single monolithic architecture; two-plane architecture (control + interaction).

**Consequences:** Clearer domain boundaries; more complex initial design; better scalability.

**Reversibility:** High — architectural organization can evolve.

**Dependencies:** None.

**Affected Domains:** All domains.

**Classification:** ARCHITECTURAL DECISION

---

### Decision AD-02: Voice Engine as External Component Behind Stable Boundary

**Decision:** The Voice Engine is treated as an external component behind a stable, versioned boundary interface.

**Rationale:** FQ-01 (Engine is frozen by default) and FQ-02 (Engine is replaceable behind stable boundary). The platform must not depend on engine internals. Future engine replacement must not require platform reconstruction.

**Alternatives:** Engine as integral platform component; engine as embedded library.

**Consequences:** Platform and engine can evolve independently; boundary interface must be carefully designed; initial integration may be more complex.

**Reversibility:** Medium — boundary design is significant but can evolve.

**Dependencies:** FQ-01, FQ-02.

**Affected Domains:** Voice Engine, AI Colleague Runtime, Channel Management.

**Classification:** FOUNDER DECISION + ARCHITECTURAL DECISION

---

### Decision AD-03: Database-Level Tenant Isolation

**Decision:** Tenant isolation is primarily enforced at the database level, with application-level tenant context on all data access.

**Rationale:** FQ-08 and Founder Decision 6.17 require strict tenant isolation. Database-level isolation makes cross-tenant leakage structurally difficult, not merely prohibited by documentation.

**Alternatives:** Application-level isolation only; infrastructure-level isolation; hybrid approaches.

**Consequences:** Stronger isolation guarantee; potential performance considerations; more complex data access patterns.

**Reversibility:** High — isolation mechanism can evolve.

**Dependencies:** TI-01 (Tenant Model).

**Affected Domains:** All tenant-scoped domains.

**Classification:** ARCHITECTURAL DECISION

---

### Decision AD-04: Configuration-Driven Package Entitlements

**Decision:** Package entitlements are configuration-driven, not hardcoded in application code.

**Rationale:** FQ-04 (one universal platform, entitlements gate access) and FQ-10 (package evolution under central governance). Configuration-driven entitlements support evolution without code changes.

**Alternatives:** Code-based entitlements; feature flags; hybrid approaches.

**Consequences:** Packages can evolve without code deployment; configuration management becomes critical; entitlement enforcement must be consistent.

**Reversibility:** High — entitlement mechanism can evolve.

**Dependencies:** PE-01 (Package Definition).

**Affected Domains:** Packages, Entitlements, All capability domains.

**Classification:** ARCHITECTURAL DECISION

---

### Decision AD-05: Structured Knowledge Lifecycle

**Decision:** Knowledge follows a structured lifecycle: Source → Ingest → Validate → Review → Approve → Version → Active → Update/Replace/Block → Audit History.

**Rationale:** Founder Decisions 6.11, 6.12, 6.13 require knowledge governance, conflict resolution, and audit trails. The lifecycle ensures knowledge quality and traceability.

**Alternatives:** Simple versioning; event-sourced knowledge; direct editing.

**Consequences:** Clear governance process; more complex knowledge management; better audit trail.

**Reversibility:** High — knowledge model can evolve.

**Dependencies:** KA-01 (Knowledge Model).

**Affected Domains:** Knowledge Management, AI Colleague Runtime, Audit.

**Classification:** ARCHITECTURAL DECISION

---

### Decision AD-06: Centralized Compliance with Jurisdiction Awareness

**Decision:** Compliance is centrally governed with jurisdiction-aware rule application.

**Rationale:** FQ-06 (central regulatory governance, mandatory changes cannot be refused). Centralized compliance ensures consistent application while allowing jurisdiction-specific rules.

**Alternatives:** Per-customer compliance; distributed compliance; hybrid approaches.

**Consequences:** Consistent compliance application; centralized management; potential complexity in multi-jurisdiction scenarios.

**Reversibility:** High — compliance model can evolve.

**Dependencies:** CG-01 (Transparency Mechanisms).

**Affected Domains:** Compliance, Regulatory, All tenant-scoped domains.

**Classification:** ARCHITECTURAL DECISION

---

### Decision AD-07: Event-Driven Interaction Plane

**Decision:** The Interaction Plane uses event-driven architecture for real-time conversation processing.

**Rationale:** Voice conversations are inherently real-time and event-driven. Event-driven architecture aligns with the natural flow of voice interactions.

**Alternatives:** Request-response architecture; synchronous processing; hybrid approaches.

**Consequences:** Better real-time performance; more complex event management; eventual consistency considerations.

**Reversibility:** High — interaction model can evolve.

**Dependencies:** None.

**Affected Domains:** Channel Management, Conversation, Voice Engine Integration.

**Classification:** ARCHITECTURAL DECISION

---

### Decision AD-08: Platform-Level Context and Memory

**Decision:** Context and memory are managed at the platform level, not within the Voice Engine.

**Rationale:** FQ-01 (engine modification only when capability cannot reasonably be implemented outside engine). Context persistence and memory can be implemented at the platform level without engine modification.

**Alternatives:** Engine-level context; hybrid context; external memory service.

**Consequences:** Engine remains unmodified; platform manages context lifecycle; context is portable across engine replacements.

**Reversibility:** High — context management can evolve.

**Dependencies:** VE-04 (Context Persistence), VE-05 (Memory System).

**Affected Domains:** AI Colleague Runtime, Knowledge, Context Management.

**Classification:** ARCHITECTURAL DECISION

---

## 34. Technical Unknowns

The following technical unknowns require future validation:

| ID | Unknown | Impact | Resolution |
|----|---------|--------|------------|
| TU-01 | Exact production concurrency capacity | Scalability planning | Load testing required |
| TU-02 | Voice Engine boundary interface latency | Performance optimization | Benchmarking required |
| TU-03 | Multi-tenant database performance under load | Tenant isolation design | Load testing required |
| TU-04 | Knowledge retrieval latency at scale | User experience | Benchmarking required |
| TU-05 | Cross-channel context synchronization latency | User experience | Implementation testing |
| TU-06 | Regional processing requirements per jurisdiction | Deployment topology | Legal/compliance review |
| TU-07 | Exact compliance requirements per jurisdiction | Compliance architecture | Legal/compliance review |
| TU-08 | Stripe integration complexity for proration | Billing architecture | Implementation evaluation |
| TU-09 | WhatsApp API capabilities and limitations | Channel architecture | Provider evaluation |
| TU-10 | Email delivery reliability and tracking | Channel architecture | Provider evaluation |

> `TECHNICAL UNKNOWN` — These are not invented capabilities. They require future validation experiments.

---

## 35. Future Evolution Principles

### Architecture Evolution

* Architecture may evolve as StoreVoice grows
* Evolution must preserve Founder Decisions
* Evolution must preserve customer continuity
* Evolution must maintain tenant isolation
* Evolution must maintain audit trails

### Technology Evolution

* Better technology may replace existing technology
* The decision to replace production technology is ALWAYS human
* AI may test, compare, and advise
* AI may NOT autonomously decide to replace production technology
* Existing customer continuity has priority over immediately adopting new technology

### Package Evolution

* StoreVoice may evolve packages under central human governance
* Existing customers retain commitments for applicable period
* Material changes are versioned, communicated, and migrated through controlled process
* Mandatory regulatory or safety changes remain governed centrally

### Engine Evolution

* Voice Engine may be modified only through explicit human-approved architectural change
* Voice Engine may be replaced behind the stable platform boundary
* Replacement requires explicit human approval
* Customer continuity takes precedence

---

## Rules for Future Updates

- Architecture changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Architecture updates may require corresponding updates to SYSTEM_MAP.md and INTEGRATION_RULES.md
- Voice Engine modifications require explicit architectural approval
- Any change to the Voice Engine is an architectural decision, not an ordinary implementation detail

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004C — Architecture Design