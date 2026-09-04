# CAPABILITY_GAP_ANALYSIS.md — StoreVoice Architecture Readiness

**Purpose:** Determines the current capability position of the existing StoreVoice system against Founder Decision-derived platform requirements.

**Status:** DECISION

**Scope:** This document provides a factual analysis of what exists, what is partial, what is missing, what is unknown, and what requires architectural decisions.

**Important:** This is NOT architecture. This is a capability gap analysis.

---

## Executive Summary

### What the existing Voice Engine already provides

The existing Voice Engine (`Storevoice/storevoice` at commit `c62f761acccb23bb6798375f7fef3ba9a1234ebc`) is a production-grade realtime conversational voice engine built on LiveKit Agents SDK. It provides:

* Real-time voice pipeline (WebRTC → VAD → Turn Detection → STT → LLM → TTS)
* Multilingual support (English, Dutch, French, German)
* Provider isolation (Deepgram STT, OpenAI LLM, Cartesia TTS)
* Latency instrumentation and metrics collection
* Interruption handling
* Basic AI receptionist persona
* Docker deployment capability
* Environment-based configuration

### What major platform capabilities are missing

The existing Voice Engine is a conversational runtime only. It does NOT provide:

* Multi-tenant architecture
* Customer knowledge management
* Customer administration
* Payment integration
* Package management
* Human escalation workflows
* Channel management (WhatsApp, email, SMS)
* Localization beyond language switching
* Compliance mechanisms
* Audit trails
* Incident management
* Demo functionality
* Onboarding workflows

### What major capabilities are partial

* **AI colleague persona** — Basic persona exists but is not customer-configurable
* **Language support** — 4 languages supported, but not all European countries
* **Human escalation** — Mentioned in prompts but not implemented as a workflow

### What remains unknown

* Whether the system can support multiple concurrent customers
* Whether knowledge can be updated without restart
* Whether the system can be configured per-customer

### Whether any existing implementation conflicts with Founder Decisions

No direct conflicts were identified. The existing Voice Engine is a specialized conversational runtime that can serve as a foundation for the future platform.

---

## Capability Matrix

| Requirement | Status | Current Evidence | Gap | Architecture Decision Needed |
|-------------|--------|------------------|-----|------------------------------|
| **A. Multi-tenancy** | | | | |
| Strict tenant isolation | MISSING | No multi-tenant code in `agent.py`, `config.py`, or `server.py` | Complete platform capability required | OPEN |
| Customer identity representation | MISSING | No customer concept in codebase | Customer management system required | OPEN |
| Tenant-separated data | MISSING | No data persistence layer | Data architecture required | OPEN |
| Tenant-separated knowledge | MISSING | Knowledge is hardcoded in `prompts/receptionist.py` | Knowledge management system required | OPEN |
| Tenant-separated configuration | MISSING | Configuration is global via environment variables | Per-customer configuration system required | OPEN |
| **B. Knowledge Management** | | | | |
| Customer knowledge | MISSING | Knowledge is static in `RECEPTIONIST_SYSTEM_PROMPT` | Dynamic knowledge system required | OPEN |
| Approved knowledge | MISSING | No approval workflow | Knowledge approval system required | OPEN |
| Knowledge updates | MISSING | No update mechanism | Knowledge update workflow required | OPEN |
| Corrections | MISSING | No correction mechanism | Knowledge correction system required | OPEN |
| Conflicting information | MISSING | No conflict detection | Conflict detection and resolution system required | OPEN |
| Approval state | MISSING | No approval state tracking | Approval state management required | OPEN |
| Version history | MISSING | No versioning | Version control system required | OPEN |
| Knowledge audit history | MISSING | No audit trail | Audit trail system required | OPEN |
| **C. AI Colleague Behavior** | | | | |
| Persona | PARTIAL | Basic persona in `RECEPTIONIST_SYSTEM_PROMPT` | Customer-configurable personas required | OPEN |
| System behavior | EXISTS | Behavior defined in prompts | Behavior customization system required | OPEN |
| Language | EXISTS | 4 languages supported (`en,nl,fr,de`) | All European languages required | OPEN |
| Conversational behavior | EXISTS | Real-time conversation with interruption handling | Enhanced conversational capabilities required | OPEN |
| Context | PARTIAL | Conversation context maintained during session | Persistent context across sessions required | OPEN |
| Memory | MISSING | No memory between sessions | Memory system required | OPEN |
| Emotion handling | MISSING | No emotion recognition or response | Emotion recognition system required | OPEN |
| Escalation | PARTIAL | Mentioned in prompts but not implemented | Human escalation workflow required | OPEN |
| Human handoff | MISSING | No human handoff mechanism | Human handoff system required | OPEN |
| Autonomous actions | MISSING | No autonomous action framework | Autonomous action framework required | OPEN |
| **D. Human Escalation** | | | | |
| Human transfer | MISSING | No transfer mechanism | Transfer system required | OPEN |
| Warm transfer | MISSING | No warm transfer | Warm transfer system required | OPEN |
| Cold transfer | MISSING | No cold transfer | Cold transfer system required | OPEN |
| Context handoff | MISSING | No context handoff | Context handoff system required | OPEN |
| Callback | MISSING | No callback mechanism | Callback system required | OPEN |
| Escalation rules | MISSING | No escalation rules engine | Rules engine required | OPEN |
| Human availability | MISSING | No availability tracking | Availability tracking required | OPEN |
| **E. Channels** | | | | |
| Phone | EXISTS | LiveKit WebRTC for voice | Phone channel via Twilio required | OPEN |
| WhatsApp | MISSING | No WhatsApp integration | WhatsApp integration required | OPEN |
| Email | MISSING | No email integration | Email integration required | OPEN |
| SMS | MISSING | No SMS integration | SMS integration required | OPEN |
| **F. Localization** | | | | |
| Multiple languages | EXISTS | 4 languages supported | All European languages required | OPEN |
| Language detection | EXISTS | Auto-detection via Deepgram | Enhanced detection required | OPEN |
| Language switching | EXISTS | Smooth language switching | Country-specific behavior required | OPEN |
| Country-specific behavior | MISSING | No country-specific behavior | Country-specific behavior system required | OPEN |
| Country-specific wording | MISSING | No country-specific wording | Wording customization required | OPEN |
| Cultural localization | MISSING | No cultural adaptation | Cultural adaptation system required | OPEN |
| Localized customer-facing communication | MISSING | No localized documentation/invoices | Localization system required | OPEN |
| **G. Compliance** | | | | |
| Transparency | PARTIAL | AI identifies as AI receptionist | Enhanced transparency mechanisms required | OPEN |
| Consent/notice mechanisms | MISSING | No consent mechanisms | Consent management required | OPEN |
| Data controls | MISSING | No data control mechanisms | Data control system required | OPEN |
| Auditability | PARTIAL | Metrics collection exists | Enhanced auditability required | OPEN |
| Access controls | MISSING | No access control system | Access control system required | OPEN |
| Retention/deletion | MISSING | No retention/deletion mechanisms | Retention/deletion system required | OPEN |
| Logging | PARTIAL | Basic logging exists | Enhanced logging required | OPEN |
| **H. Audit Trail** | | | | |
| Knowledge at point in time | MISSING | No knowledge versioning | Knowledge versioning required | OPEN |
| Configuration at point in time | MISSING | No configuration versioning | Configuration versioning required | OPEN |
| Relevant AI behavior | PARTIAL | Metrics collected | Behavior logging required | OPEN |
| Conversation context | PARTIAL | Session metrics collected | Context logging required | OPEN |
| What the AI said | MISSING | No conversation logging | Conversation logging required | OPEN |
| Relevant system events | PARTIAL | Basic logging exists | Event logging required | OPEN |
| **I. Incident Management** | | | | |
| Monitoring | PARTIAL | Metrics collection exists | Enhanced monitoring required | OPEN |
| Alerts | MISSING | No alerting system | Alerting system required | OPEN |
| Incident detection | MISSING | No incident detection | Incident detection required | OPEN |
| Incident logging | MISSING | No incident logging | Incident logging required | OPEN |
| Incident history | MISSING | No incident history | Incident history required | OPEN |
| Rollback | MISSING | No rollback mechanism | Rollback system required | OPEN |
| Service shutdown | MISSING | No shutdown mechanism | Shutdown system required | OPEN |
| Recovery | MISSING | No recovery mechanism | Recovery system required | OPEN |
| Alternative service | MISSING | No alternative service | Alternative service required | OPEN |
| **J. Technology Provider Abstraction** | | | | |
| STT abstraction | EXISTS | `build_stt()` function isolates Deepgram | Provider abstraction exists | OPEN |
| LLM abstraction | EXISTS | `build_llm()` function isolates OpenAI | Provider abstraction exists | OPEN |
| TTS abstraction | EXISTS | `build_tts()` function isolates Cartesia | Provider abstraction exists | OPEN |
| Provider isolation | EXISTS | Clean boundaries in `agent.py` | Enhanced isolation required | OPEN |
| Replacement capability | PARTIAL | Plugin mode exists | Production replacement capability required | OPEN |
| Configuration boundaries | EXISTS | Configuration centralized in `config.py` | Per-customer configuration required | OPEN |
| **K. Customer Lifecycle** | | | | |
| Onboarding | MISSING | No onboarding workflow | Onboarding system required | OPEN |
| Customer configuration | MISSING | No customer configuration | Configuration system required | OPEN |
| Upgrades | MISSING | No upgrade mechanism | Upgrade system required | OPEN |
| Downgrades | MISSING | No downgrade mechanism | Downgrade system required | OPEN |
| Cancellation | MISSING | No cancellation mechanism | Cancellation system required | OPEN |
| 14-day recovery | MISSING | No recovery mechanism | Recovery system required | OPEN |
| Permanent deletion | MISSING | No deletion mechanism | Deletion system required | OPEN |
| Reactivation | MISSING | No reactivation mechanism | Reactivation system required | OPEN |
| New-customer re-onboarding | MISSING | No re-onboarding mechanism | Re-onboarding system required | OPEN |
| **L. Packages and Permissions** | | | | |
| Package A | MISSING | No package concept | Package system required | OPEN |
| Package B | MISSING | No package concept | Package system required | OPEN |
| Enterprise | MISSING | No package concept | Package system required | OPEN |
| Feature entitlements | MISSING | No entitlement system | Entitlement system required | OPEN |
| Package-based permissions | MISSING | No permission system | Permission system required | OPEN |
| Upgrade/downgrade behavior | MISSING | No upgrade/downgrade behavior | Behavior system required | OPEN |
| **M. Demo** | | | | |
| Website scraping | MISSING | No scraping capability | Scraping system required | OPEN |
| Temporary demo agent | MISSING | No demo agent | Demo agent system required | OPEN |
| Scraped-knowledge-only behavior | MISSING | No demo-specific behavior | Demo behavior required | OPEN |
| Approximately 90-second demo experience | MISSING | No demo timing | Demo experience required | OPEN |
| Demo expiry | MISSING | No expiry mechanism | Expiry system required | OPEN |
| Prospect identification | MISSING | No prospect identification | Prospect system required | OPEN |
| Follow-up workflow | MISSING | No follow-up workflow | Follow-up system required | OPEN |
| **N. Payments** | | | | |
| Stripe | MISSING | No payment integration | Stripe integration required | OPEN |
| Prepaid subscriptions | MISSING | No subscription system | Subscription system required | OPEN |
| Monthly cancellation | MISSING | No cancellation system | Cancellation system required | OPEN |
| Prorated upgrade | MISSING | No proration system | Proration system required | OPEN |
| End-of-period downgrade | MISSING | No downgrade system | Downgrade system required | OPEN |
| Cancellation | MISSING | No cancellation system | Cancellation system required | OPEN |
| Account recovery | MISSING | No recovery system | Recovery system required | OPEN |
| **O. European Customer Administration** | | | | |
| Centralized customer administration | MISSING | No administration system | Administration system required | OPEN |
| Country localization | MISSING | No localization system | Localization system required | OPEN |
| Invoices | MISSING | No invoicing system | Invoicing system required | OPEN |
| Reports | MISSING | No reporting system | Reporting system required | OPEN |
| Customer communication | MISSING | No communication system | Communication system required | OPEN |
| Customer contact management | MISSING | No contact management | Contact management required | OPEN |
| **P. Data Ownership and Data Learning** | | | | |
| Customer data isolation | MISSING | No data isolation | Data isolation system required | OPEN |
| Anonymization | MISSING | No anonymization | Anonymization system required | OPEN |
| Aggregation | MISSING | No aggregation | Aggregation system required | OPEN |
| Cross-customer analytics | MISSING | No analytics system | Analytics system required | OPEN |
| Deletion | MISSING | No deletion system | Deletion system required | OPEN |
| Preventing customer knowledge leakage | MISSING | No leakage prevention | Leakage prevention required | OPEN |

---

## Current Voice Engine vs Future Platform

### CURRENT VOICE ENGINE

What exists today in `Storevoice/storevoice`:

* Real-time conversational voice engine
* LiveKit Agents SDK-based architecture
* Multilingual support (4 languages)
* Provider isolation (Deepgram, OpenAI, Cartesia)
* Latency instrumentation
* Interruption handling
* Basic AI receptionist persona
* Docker deployment
* Environment-based configuration

### FUTURE STOREVOICE PLATFORM

What the Founder Decisions require but may not yet exist:

* Multi-tenant platform architecture
* Customer knowledge management
* Customer administration
* Payment integration
* Package management
* Human escalation workflows
* Channel management (phone, WhatsApp, email, SMS)
* European localization
* Compliance mechanisms
* Audit trails
* Incident management
* Demo functionality
* Onboarding workflows

---

## Gap Categories

### PRODUCT GAPS

The following capabilities do not exist as product features:

* Customer knowledge management
* Customer administration
* Package management
* Human escalation workflows
* Demo functionality
* Onboarding workflows
* Customer lifecycle management

### PLATFORM GAPS

The following capabilities require platform infrastructure:

* Multi-tenant architecture
* Data persistence and isolation
* Payment integration
* Channel integrations (WhatsApp, email, SMS)
* Localization system
* Compliance mechanisms
* Audit trails
* Incident management

### VOICE ENGINE GAPS

The following capabilities specifically concern the frozen engine:

* Customer-configurable personas
* All European language support
* Enhanced emotion handling
* Persistent context across sessions
* Memory between sessions

### OPERATIONAL GAPS

The following capabilities require human/process operations:

* White Glove service operations
* Knowledge collection and training
* Quality assurance workflows
* Customer support processes

### COMPLIANCE GAPS

The following compliance requirements have not yet been established:

* Legal compliance mechanisms
* Data protection implementation
* Regulatory monitoring processes
* Customer consent mechanisms

---

## Protected Engine Check

### 1. Which Founder Requirements can already be supported by the frozen Voice Engine?

* Real-time conversational capability
* Basic AI colleague persona
* Multilingual conversation (4 languages)
* Provider isolation for STT, LLM, TTS
* Interruption handling
* Latency instrumentation

### 2. Which requirements belong outside the Voice Engine?

* Multi-tenant architecture
* Customer knowledge management
* Customer administration
* Payment integration
* Package management
* Human escalation workflows
* Channel management
* Localization beyond language switching
* Compliance mechanisms
* Audit trails
* Incident management
* Demo functionality
* Onboarding workflows

### 3. Which requirements would require changes to the Voice Engine?

* Customer-configurable personas (currently hardcoded)
* All European language support (currently 4 languages)
* Enhanced emotion handling (currently basic)
* Persistent context across sessions (currently session-only)
* Memory between sessions (currently none)

### 4. Which requirements can be satisfied without modifying the Voice Engine?

* Multi-tenant architecture (platform layer)
* Customer knowledge management (platform layer)
* Customer administration (platform layer)
* Payment integration (platform layer)
* Package management (platform layer)
* Human escalation workflows (platform layer)
* Channel management (platform layer)
* Localization system (platform layer)
* Compliance mechanisms (platform layer)
* Audit trails (platform layer)
* Incident management (platform layer)
* Demo functionality (platform layer)
* Onboarding workflows (platform layer)

---

## Rules for Future Updates

- This document is a factual analysis, not a design document
- All findings must have evidence from the codebase
- UNKNOWN status must be used when evidence is insufficient
- No architectural decisions should be made in this document
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 003B — Architecture Readiness / Existing Capability & Gap Analysis