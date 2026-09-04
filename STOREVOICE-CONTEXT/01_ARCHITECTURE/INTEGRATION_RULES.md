# INTEGRATION_RULES.md — StoreVoice Integration Policies

**Purpose:** Defines rules and standards for integrating StoreVoice with external systems, including the frozen Voice Engine, telephony, payments, and other providers.

**Status:** DECISION

**Scope:** This document establishes how StoreVoice interacts with external dependencies, clearly distinguishing CURRENT VERIFIED INTEGRATION from TARGET ARCHITECTURAL INTEGRATION.

---

## 1. Integration Principles

### Core Principles

1. **Provider abstraction** — Business domains must not depend on provider-specific logic
2. **Stable boundaries** — Integration boundaries must survive provider replacement
3. **Tenant isolation** — All integrations must respect tenant boundaries
4. **Auditability** — All integrations must produce audit events
5. **Resilience** — Integration failures must not cause total service failure
6. **Security** — All integrations must be authenticated and authorized
7. **Observability** — All integrations must be monitored and logged
8. **Replaceability** — Providers must be replaceable without contaminating business domains

### Integration Classification

| Type | Description | Example |
|------|-------------|---------|
| CURRENT VERIFIED | Existing integration with evidence | Voice Engine (frozen) |
| TARGET ARCHITECTURAL | Designed but not yet implemented | Platform ↔ Voice Engine boundary |
| DIRECTION | Founder-approved direction, not permanent | Twilio, Stripe |
| UNKNOWN | Not yet determined | Cloud infrastructure provider |

---

## 2. Voice Engine Integration

### Current Verified Integration

**Status:** FACT

The current Voice Engine integration is:

* Repository: `Storevoice/storevoice`
* Reference Commit: `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
* Status: FROZEN REFERENCE
* Architecture: LiveKit Agents SDK-based
* Providers: Deepgram (STT), OpenAI (LLM), Cartesia (TTS), Silero (VAD)

**Current integration model:**

```
Product → approved integration → Voice Engine
```

**Important:** This is the CURRENT integration model. The TARGET integration model is different.

### Target Architectural Integration

**Status:** TARGET ARCHITECTURE (not yet implemented)

**Future target integration model:**

```
StoreVoice Platform → Voice Engine Boundary (Stable Interface) → Voice Engine
```

The Voice Engine Boundary is a TARGET architecture. It does NOT currently exist as a public API. It must be designed, specified, and approved before implementation.

### Voice Engine Boundary Specification

#### Boundary Interface

| Direction | Interface | Description |
|-----------|-----------|-------------|
| Platform → Engine | Session Configuration | Channel, language, tenant context |
| Platform → Engine | Knowledge Context | Approved knowledge for tenant |
| Platform → Engine | Persona Definition | How AI presents itself |
| Platform → Engine | Behavior Policies | What AI may/may not do |
| Platform → Engine | System Prompt | Base prompt with knowledge/policies |
| Platform → Engine | Channel Parameters | Phone number, caller info |
| Engine → Platform | Transcription | What user said |
| Engine → Platform | AI Response | What AI said |
| Engine → Platform | Conversation Events | Turn, interruption, etc. |
| Engine → Platform | Escalation Trigger | When escalation needed |
| Engine → Platform | Telemetry | Latency, errors, metrics |
| Engine → Platform | Error Events | When something goes wrong |

#### Boundary Responsibilities

**Platform responsibilities at boundary:**
* Tenant context and isolation
* Knowledge retrieval and approval
* Persona configuration
* Behavior policy enforcement
* Package entitlement enforcement
* Channel management
* Escalation orchestration
* Audit logging
* Compliance enforcement

**Engine responsibilities at boundary:**
* Real-time voice processing
* Speech-to-text conversion
* Language model inference
* Text-to-speech synthesis
* Voice Activity Detection
* Turn detection
* Interruption handling
* Basic conversation flow

#### Boundary Replacement

The boundary must support:

```
Current Engine → Adapter/Boundary → Future Engine
```

Without reconstructing the StoreVoice platform.

**Replacement requirements:**
* New engine must implement the boundary interface
* Platform configuration must be engine-agnostic
* Knowledge and context must be portable
* Audit trail must be maintained during transition
* Customer continuity must be preserved
* Rollback capability must exist

### Voice Engine Modification Rules

**Status:** FOUNDER DECISION (FQ-01)

The Voice Engine remains frozen by default.

Modification is permitted only through an explicit human-approved architectural change when the required capability cannot reasonably be implemented outside the engine without compromising correctness, performance, maintainability, or product requirements.

**Forbidden changes (unless explicitly approved):**
* Recreate the voice engine
* Replace the voice-engine architecture
* Substitute another STT provider
* Substitute another LLM
* Substitute another TTS provider
* Replace VAD
* Replace turn detection
* Replace interruption handling
* Redesign the realtime voice pipeline

Any such change is an architectural decision, not an ordinary implementation detail.

---

## 3. Telephony Integration

### Current Direction

**Status:** DIRECTION (not permanent decision)

* Provider: Twilio (current direction)
* Local number provisioning desired
* Automatic provisioning desired
* Alternatives may be used when local telecom rules or availability require

### Target Architecture

**Status:** TARGET ARCHITECTURE

Telephony integration must:

* Support phone channel for customer contact
* Support local number provisioning per country
* Support automatic number provisioning where possible
* Support fallback when local rules require alternatives
* Abstract telephony provider from business domains
* Support provider replacement

### Telephony Abstraction

```
StoreVoice Platform → Telephony Interface → Telephony Provider
```

The Telephony Interface abstracts provider-specific logic from the platform.

### Integration Points

| Function | Provider | Status |
|----------|----------|--------|
| Inbound calling | Twilio | DIRECTION |
| Outbound calling | Twilio | DIRECTION |
| Local number provisioning | Twilio | DIRECTION |
| Call recording | Twilio | DIRECTION |
| Call transfer | Twilio | DIRECTION |
| SMS sending | Twilio | DIRECTION |

---

## 4. Messaging Integration

### WhatsApp

**Status:** TARGET ARCHITECTURE (not yet implemented)

* Integration required
* Provider to be determined
* Must support AI colleague as first contact point
* Must support context continuity with phone channel

### Email

**Status:** TARGET ARCHITECTURE (not yet implemented)

* Integration required
* Provider to be determined
* Must support AI colleague as first contact point
* Must support context continuity with other channels

### SMS

**Status:** TARGET ARCHITECTURE (not yet implemented)

* Integration required
* Provider to be determined (potentially Twilio)
* Must support follow-up sequencing
* Must support demo follow-up

---

## 5. Payment Integration

### Current Direction

**Status:** DIRECTION (not permanent decision)

* Provider: Stripe
* Services are prepaid
* Monthly cancellable standard packages
* Centralized customer administration

### Target Architecture

**Status:** TARGET ARCHITECTURE

Payment integration must:

* Support subscription management (prepaid)
* Support immediate upgrade with proration
* Support end-of-month downgrade
* Support cancellation with service continuation through paid period
* Support 14-day recovery period
* Abstract payment provider from business domains
* Support provider replacement

### Payment Abstraction

```
StoreVoice Platform → Payment Interface → Payment Provider (Stripe)
```

The Payment Interface abstracts provider-specific logic from the platform.

### Integration Points

| Function | Provider | Status |
|----------|----------|--------|
| Subscription creation | Stripe | DIRECTION |
| Payment processing | Stripe | DIRECTION |
| Upgrade proration | Stripe | DIRECTION |
| Downgrade scheduling | Stripe | DIRECTION |
| Cancellation | Stripe | DIRECTION |
| Webhook handling | Stripe | DIRECTION |
| Invoice generation | Stripe | DIRECTION |

---

## 6. Cloud Infrastructure Integration

### Status

**Status:** UNKNOWN (to be determined during implementation)

* Cloud provider: TBD
* Deployment architecture: TBD
* Scaling architecture: TBD
* Backup/recovery: TBD

### Requirements

Cloud infrastructure must:

* Support multi-tenant isolation
* Support regional processing where required
* Support compliance with data residency requirements
* Support scaling for growth
* Support disaster recovery
* Support secrets management
* Support observability

---

## 7. Observability Integration

### Status

**Status:** UNKNOWN (to be determined during implementation)

* Observability provider: TBD
* Logging architecture: TBD
* Metrics architecture: TBD
* Tracing architecture: TBD

### Requirements

Observability must:

* Support operational visibility across all components
* Support tenant-scoped metrics where applicable
* Support incident investigation
* Support QA metrics
* Support provider performance monitoring
* Support customer health monitoring

---

## 8. Stable Interfaces

### Interface Principles

All integration interfaces must be:

* **Well-defined** — Clear contract for input/output
* **Versioned** — Interface version tracked
* **Backward compatible** — Within major versions
* **Tenant-scoped** — All operations are tenant-contextualized
* **Authenticated** — All access is authenticated
* **Authorized** — All operations are authorized
* **Audited** — All operations produce audit events
* **Monitored** — All operations are monitored
* **Error-handled** — Graceful degradation on failure

### Interface Categories

| Category | Purpose | Examples |
|----------|---------|----------|
| External API | Customer/partner facing | Customer API, Demo API |
| Internal Service | Between platform domains | Knowledge API, Config API |
| Webhook | External notifications | Payment webhook |
| Domain Event | Internal events | KnowledgeApproved |
| Integration Event | Cross-boundary | ConversationCompleted |

---

## 9. Provider Abstraction Rules

### Abstraction Requirements

All external providers must be abstracted behind stable interfaces:

* Business domains must not import provider-specific libraries
* Provider configuration must be centralized
* Provider credentials must be managed centrally
* Provider health must be monitored
* Provider replacement must not require business domain changes

### Provider Categories

| Category | Current | Replaceable | Abstraction Level |
|----------|---------|-------------|-------------------|
| STT | Deepgram Nova-3 | YES | Exists (build_stt) |
| LLM | OpenAI GPT-4.1 | YES | Exists (build_llm) |
| TTS | Cartesia Sonic-3 | YES | Exists (build_tts) |
| Telephony | Twilio | YES | To be designed |
| Payments | Stripe | YES | To be designed |
| Cloud | TBD | YES | To be designed |
| Observability | TBD | YES | To be designed |

### Provider Replacement Process

1. Identify provider to be replaced
2. Evaluate replacement provider
3. Ensure replacement implements boundary interface
4. Test replacement in staging
5. Plan migration with customer continuity
6. Execute migration with rollback capability
7. Monitor post-migration performance
8. Decommission old provider

---

## 10. Authentication and Authorization

### Authentication

All integration access must be authenticated:

* Service-to-service authentication
* API key management
* Token-based authentication
* Certificate management where applicable

### Authorization

All integration operations must be authorized:

* Tenant-scoped authorization
* Role-based access control
* Package entitlement enforcement
* Operational permission checks

### Secrets Management

All credentials must be managed centrally:

* Provider API keys
* Database credentials
* Service certificates
* Encryption keys
* Rotation policies

---

## 11. Error Handling

### Error Categories

| Category | Severity | Response |
|----------|----------|----------|
| Transient | Low | Retry with backoff |
| Persistent | Medium | Fallback provider or degraded mode |
| Critical | High | Escalation and incident |
| Security | Critical | Immediate containment |

### Retry Policy

* Transient errors: Exponential backoff, max 3 retries
* Persistent errors: Fallback provider or degraded mode
* Critical errors: Immediate escalation
* Security errors: Immediate containment

### Fallback Procedures

| Integration | Fallback | Degradation |
|-------------|----------|-------------|
| Voice Engine | Queue and retry | Callback when restored |
| STT Provider | Alternative provider | Reduced quality |
| LLM Provider | Alternative provider | Reduced capability |
| TTS Provider | Alternative provider | Reduced quality |
| Telephony | Alternative provider | Channel unavailable |
| Payments | Manual processing | Service continues |

---

## 12. Rate Limiting

### Rate Limiting Principles

* Rate limits protect provider resources
* Rate limits protect platform stability
* Rate limits are per-tenant where applicable
* Rate limits are configurable per provider

### Rate Limit Categories

| Category | Scope | Action on Limit |
|----------|-------|-----------------|
| API requests | Per-tenant | Queue or reject |
| Voice sessions | Per-tenant | Queue or callback |
| Knowledge queries | Per-tenant | Cache or queue |
| Provider calls | Global | Queue or degrade |

---

## 13. Versioning and Compatibility

### Versioning Principles

* Interfaces are versioned
* Backward compatibility within major versions
* Breaking changes require coordinated migration
* Version negotiation during handshake

### Compatibility Rules

* Platform must support N-1 interface versions
* New features require new interface versions
* Deprecation period before removal
* Migration guides for breaking changes

---

## 14. Observability

### Integration Monitoring

All integrations must be monitored for:

* Availability
* Latency
* Error rates
* Throughput
* Provider health

### Integration Logging

All integrations must log:

* Request/response (sanitized)
* Errors and exceptions
* Performance metrics
* Tenant context (where applicable)

### Integration Metrics

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| Availability | Uptime percentage | < 99.9% |
| Latency | Response time | > 500ms |
| Error rate | Error percentage | > 1% |
| Throughput | Requests per second | > capacity |

---

## 15. Vendor Replacement Principles

### Replacement Readiness

* All providers must be replaceable
* Replacement must not contaminate business domains
* Replacement must maintain customer continuity
* Replacement must be tested in staging first

### Replacement Process

1. **Evaluate** — Assess replacement provider
2. **Design** — Ensure replacement implements boundary interface
3. **Test** — Validate in staging environment
4. **Plan** — Migration plan with rollback
5. **Execute** — Controlled migration
6. **Monitor** — Post-migration monitoring
7. **Decommission** — Remove old provider

### Vendor Lock-in Prevention

* Business logic must not depend on provider-specific objects
* Data formats must be portable
* Configuration must be provider-agnostic
* APIs must be abstracted behind stable interfaces

---

## 16. Data Mapping

### Data Mapping Principles

* Data mapping must be explicit and documented
* Data transformation must be bidirectional
* Data validation must occur at boundaries
* Data format changes must be versioned

### Mapping Categories

| Category | From | To | Direction |
|----------|------|----|-----------|
| Knowledge | Platform | Engine | Platform → Engine |
| Persona | Platform | Engine | Platform → Engine |
| Transcription | Engine | Platform | Engine → Platform |
| Response | Engine | Platform | Engine → Platform |
| Customer | Platform | Stripe | Platform → Stripe |
| Payment | Stripe | Platform | Stripe → Platform |

---

## Rules for Future Updates

- Integration changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Integration updates may require corresponding updates to ARCHITECTURE.md and SYSTEM_MAP.md
- Voice Engine integration is the primary external dependency
- Future StoreVoice product builds must use the approved Voice Engine as their canonical reference
- Any change to the Voice Engine integration pattern is an architectural decision
- Clearly distinguish CURRENT VERIFIED INTEGRATION from TARGET ARCHITECTURAL INTEGRATION

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004C — Architecture Design