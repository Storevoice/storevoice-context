# IMPLEMENTATION_BLUEPRINT.md — StoreVoice Implementation Blueprint

**Purpose:** Transforms the approved and validated StoreVoice architecture into a concrete, implementation-ready engineering blueprint.

**Status:** DECISION

**Scope:** This document is the engineering execution layer beneath the approved architecture. It answers: "If we started building StoreVoice tomorrow, exactly what would we build, in what order, with which boundaries, contracts, data structures, tests, and ownership?"

**Important:** This is NOT a coding task. No application code is written. No Voice Engine is modified. No infrastructure is provisioned. This is the blueprint that future coding agents will execute.

---

## SECTION A — IMPLEMENTATION PRINCIPLES

### Architecture Authority

The architecture documented in `01_ARCHITECTURE/ARCHITECTURE.md` is authoritative. Coding agents execute the blueprint. They do not redesign the architecture unless explicitly authorized by the human founder.

```
HUMAN FOUNDER → APPROVED SOURCE OF TRUTH → APPROVED ARCHITECTURE → THIS BLUEPRINT → IMPLEMENTATION
```

### Source-of-Truth Usage

Before any implementation work, coding agents must consult this Source of Truth repository. The Source of Truth is the single source of business truth, architectural decisions, and design specifications. Implementation agents must not invent business rules, pricing, or Founder Decisions.

### Change Control

Every implementation change must be classified:

| Classification | Description | Process |
|---------------|-------------|---------|
| SMALL | Local, low-risk change | INSPECT → IMPLEMENT → TEST |
| MEDIUM | Potentially affects multiple components | INSPECT → IMPACT ANALYSIS → PLAN → IMPLEMENT → TEST → AUDIT |
| LARGE / ARCHITECTURAL | Changes architecture, product behavior, major UX, data model, integrations, or frozen components | INSPECT → IMPACT ANALYSIS → PROPOSAL → STOP → OWNER APPROVAL → IMPLEMENT → TEST → AUDIT |

### Frozen Component Policy

The Voice Engine at commit `c62f761acccb23bb6798375f7fef3ba9a1234ebc` is FROZEN. It must not be modified. The blueprint defines how the platform integrates with it through a stable boundary. The boundary is TARGET ARCHITECTURE — it does not currently exist as a public API.

### Tenant Isolation

Tenant isolation is structurally enforced at the database level. Every customer-specific entity has a `tenant_id` column. All data access is scoped to the current tenant. Cross-tenant queries are structurally impossible through normal data access patterns. Cache keys include tenant ID. Events carry tenant context. Background jobs receive tenant context.

### Provider Abstraction

Business domains depend on capabilities, not vendor-specific APIs. All external providers are abstracted behind stable interfaces. Provider replacement must not contaminate business domains. Current providers (Deepgram, OpenAI, Cartesia, Twilio, Stripe) are facts/references, not permanent architectural decisions.

### Observability

Every component produces structured telemetry. Telemetry includes tenant context where applicable. Observability supports incident investigation, QA metrics, provider performance monitoring, and customer health monitoring.

### Auditability

Every significant action produces an audit event. Audit events are immutable and append-only. The system can reconstruct: what the AI said, what knowledge was active, what configuration applied, what package/entitlements applied, what policy applied, what provider/version was used, what escalation occurred.

### Security

Authentication for all access. Authorization for all operations. Tenant isolation is structural. Secrets management for all credentials. Encryption at rest and in transit. Privileged access is audited. Administrative access is controlled.

### Compliance

Compliance rules are centrally governed. Mandatory regulatory changes cannot be refused by customers. Compliance rules are evaluated at session startup against customer jurisdiction. Compliance state is logged for audit.

### Backward Compatibility

Interfaces are versioned. Backward compatibility is maintained within major versions. Breaking changes require coordinated migration. Platform supports N-1 interface versions.

### Failure Handling

Safety and continuity take precedence over root-cause analysis. Failures degrade gracefully, not catastrophically. Every failure path has a defined customer experience. Active voice sessions are not terminated when the Control Plane is unavailable.

### Idempotency

All event handlers are idempotent. All external webhook handlers are idempotent. Duplicate events are detected and deduplicated. Dead-letter queues capture failed events. Event IDs are globally unique.

### Data Deletion

Customer-specific data is deleted after the defined retention period. Deletion is permanent and structural. Derived data (summaries, analytics) is deleted if traceable to specific customers. Anonymized aggregate patterns may be retained.

### Human Escalation

Human escalation is available when: a decision is required, emotion makes human involvement useful, the caller requests a human, the AI lacks knowledge, or a human can materially help. Transfer preserves context. The customer should not repeat their story.

### No Silent Architectural Drift

Coding agents must not introduce architectural changes without authorization. If a required business decision is genuinely missing, the agent must STOP and record it as a Founder Decision Candidate. Never convert recommendation → decision, assumption → fact, or technical preference → Founder Decision.

---

## SECTION B — SYSTEM BOUNDED CONTEXTS

### Control Plane Contexts

#### Identity & Tenant Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages customer identity, tenant creation, tenant isolation, and administrative access |
| **Owns** | Tenant, User, Role, Permission, TenantStatus, TenantConfiguration |
| **Reads** | Nothing (authoritative source) |
| **Writes** | Tenant, User, Role, Permission records |
| **APIs** | `POST /tenants`, `GET /tenants/:id`, `PUT /tenants/:id`, `POST /users`, `GET /users/:id`, `POST /roles` |
| **Events** | `TenantCreated`, `TenantUpdated`, `TenantSuspended`, `UserCreated`, `RoleAssigned` |
| **Dependencies** | None (foundational) |
| **Forbidden Dependencies** | Must not depend on Interaction Plane or Operations Plane |
| **Tenant Boundary** | Tenant data is the entity itself — isolation is structural |
| **Failure Behavior** | Tenant creation/update fails; existing tenants unaffected |

#### Customer Administration

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages customer-facing administration, localized to customer's country |
| **Owns** | Customer, CustomerProfile, Contact, CommunicationPreference |
| **Reads** | Tenant (for tenant context) |
| **Writes** | Customer, CustomerProfile, Contact records |
| **APIs** | `POST /customers`, `GET /customers/:id`, `PUT /customers/:id`, `GET /customers/:id/contacts` |
| **Events** | `CustomerCreated`, `CustomerUpdated`, `CustomerContactAdded` |
| **Dependencies** | Identity & Tenant Management |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | All customer data is scoped to tenant |
| **Failure Behavior** | Customer management fails; active conversations unaffected |

#### Package & Entitlement Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Defines commercial packages, feature entitlements, and package-based permissions |
| **Owns** | Package, PackageVersion, Entitlement, EntitlementDefinition, CustomerSubscription, CustomerEntitlement |
| **Reads** | Tenant, Customer |
| **Writes** | Package, PackageVersion, Entitlement, CustomerSubscription records |
| **APIs** | `GET /packages`, `GET /packages/:id`, `POST /subscriptions`, `PUT /subscriptions/:id`, `GET /customers/:id/entitlements` |
| **Events** | `PackageCreated`, `PackageUpdated`, `SubscriptionCreated`, `SubscriptionUpdated`, `EntitlementChanged` |
| **Dependencies** | Identity & Tenant Management, Customer Administration |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | Package definitions are global; customer subscriptions are tenant-scoped |
| **Failure Behavior** | Entitlement lookup fails → deny by default; session startup blocked |

#### Knowledge Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages lifecycle of customer knowledge from ingestion to deletion |
| **Owns** | KnowledgeSource, KnowledgeDocument, KnowledgeChunk, KnowledgeVersion, KnowledgeApproval, KnowledgeConflict |
| **Reads** | Tenant, Customer |
| **Writes** | KnowledgeSource, KnowledgeDocument, KnowledgeChunk, KnowledgeVersion records |
| **APIs** | `POST /knowledge/sources`, `GET /knowledge/documents`, `POST /knowledge/approve`, `GET /knowledge/versions` |
| **Events** | `KnowledgeIngested`, `KnowledgeValidated`, `KnowledgeApproved`, `KnowledgeRejected`, `KnowledgeBlocked`, `KnowledgeConflictDetected` |
| **Dependencies** | Identity & Tenant Management, Customer Administration |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | All knowledge data is strictly tenant-isolated |
| **Failure Behavior** | Knowledge retrieval fails → AI responds with "I don't have that information" |

#### AI Colleague Configuration

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages AI colleague persona, behavior policies, and configuration |
| **Owns** | AIColleague, Persona, BehaviorPolicy, CommunicationStyle |
| **Reads** | Tenant, Customer, Package (for entitlements) |
| **Writes** | AIColleague, Persona, BehaviorPolicy records |
| **APIs** | `POST /ai-colleagues`, `GET /ai-colleagues/:id`, `PUT /ai-colleagues/:id/persona`, `PUT /ai-colleagues/:id/behavior` |
| **Events** | `AIColleagueCreated`, `PersonaUpdated`, `BehaviorPolicyUpdated` |
| **Dependencies** | Identity & Tenant Management, Customer Administration, Package & Entitlement Management |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | All AI colleague configuration is tenant-scoped |
| **Failure Behavior** | Configuration lookup fails → session startup blocked |

#### Localization Configuration

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages country-aware localization across all customer-facing experiences |
| **Owns** | LocalizationProfile, LanguageConfig, CulturalConfig, FormalityConfig |
| **Reads** | Tenant |
| **Writes** | LocalizationProfile records |
| **APIs** | `GET /localization/:tenantId`, `PUT /localization/:tenantId` |
| **Events** | `LocalizationUpdated` |
| **Dependencies** | Identity & Tenant Management |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | Localization profiles are tenant-scoped |
| **Failure Behavior** | Falls back to English defaults |

#### Billing & Subscription Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages payment processing, subscriptions, and commercial operations |
| **Owns** | BillingState, BillingEvent, Subscription, PaymentMethod |
| **Reads** | Tenant, Customer, Package, CustomerSubscription |
| **Writes** | BillingState, BillingEvent, Subscription records |
| **APIs** | `POST /billing/subscriptions`, `GET /billing/state/:tenantId`, `POST /billing/webhook` |
| **Events** | `PaymentReceived`, `PaymentFailed`, `SubscriptionRenewed`, `SubscriptionCancelled`, `ProrationCalculated` |
| **Dependencies** | Identity & Tenant Management, Customer Administration, Package & Entitlement Management |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | All billing data is tenant-scoped |
| **Failure Behavior** | Payment processing continues with Stripe; reconciliation catches drift |

#### Compliance & Regulatory Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages regulatory compliance across jurisdictions |
| **Owns** | CompliancePolicy, Jurisdiction, ComplianceState, ComplianceRule |
| **Reads** | Tenant, Customer |
| **Writes** | CompliancePolicy, ComplianceState records |
| **APIs** | `GET /compliance/policies`, `GET /compliance/state/:tenantId`, `POST /compliance/evaluate` |
| **Events** | `CompliancePolicyCreated`, `CompliancePolicyUpdated`, `ComplianceStateChanged`, `MandatoryChangeApplied` |
| **Dependencies** | Identity & Tenant Management |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | Compliance policies are jurisdiction-scoped; compliance state is tenant-scoped |
| **Failure Behavior** | Default to strictest compliance; block session if evaluation fails |

#### Audit & Traceability

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Maintains ability to reconstruct relevant incidents |
| **Owns** | AuditEvent, AuditTrail, ConfigurationVersion |
| **Reads** | All domains (for audit context) |
| **Writes** | AuditEvent records (append-only) |
| **APIs** | `GET /audit/events`, `GET /audit/trail/:sessionId`, `GET /audit/reconstruct/:eventId` |
| **Events** | `AuditEventRecorded` (internal only) |
| **Dependencies** | All domains (read-only) |
| **Forbidden Dependencies** | Must not write to other domains |
| **Tenant Boundary** | Audit events are tenant-scoped |
| **Failure Behavior** | Audit write failure is logged; does not block operations |

#### Incident Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages incident detection, escalation, containment, and review |
| **Owns** | Incident, IncidentAction, PostIncidentReview |
| **Reads** | AuditEvent, Conversation, Tenant |
| **Writes** | Incident, IncidentAction, PostIncidentReview records |
| **APIs** | `POST /incidents`, `GET /incidents/:id`, `PUT /incidents/:id/actions`, `POST /incidents/:id/review` |
| **Events** | `IncidentCreated`, `IncidentEscalated`, `IncidentContained`, `IncidentResolved`, `AIColleagueShutdown` |
| **Dependencies** | Identity & Tenant Management, Audit & Traceability |
| **Forbidden Dependencies** | Must not depend on Interaction Plane (read-only access to events) |
| **Tenant Boundary** | Incidents are tenant-scoped |
| **Failure Behavior** | Incident detection continues via monitoring; manual reporting as fallback |

#### Onboarding Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages customer onboarding workflows |
| **Owns** | OnboardingWorkflow, OnboardingStep, OnboardingProgress |
| **Reads** | Tenant, Customer, Knowledge, AIColleague |
| **Writes** | OnboardingWorkflow, OnboardingStep, OnboardingProgress records |
| **APIs** | `POST /onboarding/start`, `GET /onboarding/:tenantId/progress`, `POST /onboarding/:tenantId/step` |
| **Events** | `OnboardingStarted`, `OnboardingStepCompleted`, `OnboardingReady`, `OnboardingActivated` |
| **Dependencies** | Identity & Tenant Management, Customer Administration, Knowledge Management, AI Colleague Configuration |
| **Forbidden Dependencies** | Must not depend on Interaction Plane |
| **Tenant Boundary** | Onboarding data is tenant-scoped |
| **Failure Behavior** | Onboarding progress is saved; resume on retry |

#### Demo Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages temporary demo instances |
| **Owns** | DemoInstance, DemoKnowledge, DemoLifecycle |
| **Reads** | Website (for scraping) |
| **Writes** | DemoInstance, DemoKnowledge records |
| **APIs** | `POST /demos`, `GET /demos/:id`, `DELETE /demos/:id` |
| **Events** | `DemoCreated`, `DemoExpired`, `DemoConverted`, `DemoDeleted` |
| **Dependencies** | Identity & Tenant Management (for demo tenant creation) |
| **Forbidden Dependencies** | Must not write to production knowledge stores |
| **Tenant Boundary** | Demo instances use special "demo" tenant type with TTL |
| **Failure Behavior** | Demo creation fails → retry or show error |

#### Provider Configuration

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages provider selection and configuration |
| **Owns** | ProviderConfiguration, ProviderCapability, ProviderHealth |
| **Reads** | Nothing (authoritative for provider config) |
| **Writes** | ProviderConfiguration records |
| **APIs** | `GET /providers`, `PUT /providers/:id`, `GET /providers/:id/health` |
| **Events** | `ProviderConfigured`, `ProviderHealthChanged`, `ProviderReplaced` |
| **Dependencies** | None |
| **Forbidden Dependencies** | Must not depend on business domains |
| **Tenant Boundary** | Provider configuration is global; provider credentials are secrets |
| **Failure Behavior** | Provider health monitoring continues; fallback to default provider |

### Interaction Plane Contexts

#### Channel Gateway

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages inbound/outbound channel connections |
| **Owns** | ChannelSession, ChannelMessage, ChannelState |
| **Reads** | Tenant, Customer, PhoneNumber |
| **Writes** | ChannelSession, ChannelMessage records |
| **APIs** | Internal only (receives from telephony provider) |
| **Events** | `ChannelSessionStarted`, `ChannelSessionEnded`, `ChannelMessageReceived`, `ChannelMessageSent` |
| **Dependencies** | Identity & Tenant Management (for tenant resolution), Telephony Provider |
| **Forbidden Dependencies** | Must not depend on Knowledge Management or AI Configuration directly |
| **Tenant Boundary** | Channel sessions are tenant-scoped |
| **Failure Behavior** | Channel unavailable → return error to provider; queue for retry |

#### Session Manager

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages conversation session lifecycle |
| **Owns** | Session, ConversationContext, ConversationMessage, ConversationState |
| **Reads** | Tenant, Customer, ChannelSession |
| **Writes** | Session, ConversationContext, ConversationMessage records |
| **APIs** | Internal only (manages session state) |
| **Events** | `SessionCreated`, `SessionStarted`, `SessionEnded`, `SessionTimeout` |
| **Dependencies** | Channel Gateway, Context Assembly, Voice Engine Adapter |
| **Forbidden Dependencies** | Must not depend on Knowledge Management directly (uses cached data) |
| **Tenant Boundary** | Sessions are tenant-scoped |
| **Failure Behavior** | Session creation fails → notify channel; active sessions continue |

#### Context Assembly

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Assembles runtime context for AI colleague from cached Control Plane data |
| **Owns** | RuntimeContext, ContextSnapshot |
| **Reads** | Cached: Knowledge, Persona, BehaviorPolicy, Entitlements, ComplianceRules, Localization |
| **Writes** | RuntimeContext (ephemeral, session-scoped) |
| **APIs** | Internal only (provides context to Session Manager) |
| **Events** | `ContextAssembled`, `ContextStale`, `ContextRefreshed` |
| **Dependencies** | Cache Layer (for Control Plane data) |
| **Forbidden Dependencies** | Must not make synchronous calls to Control Plane during session |
| **Tenant Boundary** | Context is assembled per-tenant from cached data |
| **Failure Behavior** | Cache miss → use stale data if available; block session if no data |

#### Knowledge Retrieval

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Retrieves approved knowledge for runtime use |
| **Owns** | KnowledgeQuery, KnowledgeResult |
| **Reads** | Cached: KnowledgeDocument, KnowledgeChunk |
| **Writes** | Nothing (read-only) |
| **APIs** | Internal only (provides knowledge to Context Assembly) |
| **Events** | `KnowledgeRetrieved`, `KnowledgeNotFound`, `KnowledgeConflict` |
| **Dependencies** | Cache Layer (for knowledge data) |
| **Forbidden Dependencies** | Must not write to Knowledge Management directly |
| **Tenant Boundary** | Knowledge retrieval is tenant-scoped |
| **Failure Behavior** | Knowledge unavailable → AI responds with "I don't have that information" |

#### Voice Engine Adapter

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Adapts Platform commands to Voice Engine boundary interface |
| **Owns** | EngineSession, EngineRequest, EngineResponse |
| **Reads** | RuntimeContext, Session, Entitlements |
| **Writes** | EngineSession (ephemeral) |
| **APIs** | Internal only (manages Voice Engine boundary) |
| **Events** | `EngineSessionStarted`, `EngineSessionEnded`, `EngineTranscription`, `EngineResponse`, `EngineEscalationTrigger`, `EngineTelemetry` |
| **Dependencies** | Voice Engine Boundary (stable interface) |
| **Forbidden Dependencies** | Must not depend on frozen Voice Engine internals |
| **Tenant Boundary** | Engine sessions are tenant-scoped (metadata only) |
| **Failure Behavior** | Engine unavailable → queue and retry; callback when restored |

#### Escalation Orchestration

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages escalation triggers, routing, and handoff |
| **Owns** | EscalationRequest, EscalationRoute, TransferRequest, CallbackRequest |
| **Reads** | Session, RuntimeContext, Tenant, Customer |
| **Writes** | EscalationRequest, EscalationRoute records |
| **APIs** | Internal only (manages escalation flow) |
| **Events** | `EscalationTriggered`, `EscalationRouted`, `TransferInitiated`, `TransferCompleted`, `TransferFailed`, `CallbackScheduled` |
| **Dependencies** | Session Manager, Context Assembly, Telephony Provider |
| **Forbidden Dependencies** | Must not depend on Knowledge Management directly |
| **Tenant Boundary** | Escalation data is tenant-scoped |
| **Failure Behavior** | Transfer fails → schedule callback; preserve context |

#### Tool Execution

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Executes tools within authorized boundaries |
| **Owns** | ToolDefinition, ToolRequest, ToolResponse |
| **Reads** | Entitlements, BehaviorPolicy, Session |
| **Writes** | ToolRequest, ToolResponse records |
| **APIs** | Internal only (provides tool execution to Voice Engine) |
| **Events** | `ToolRequested`, `ToolExecuted`, `ToolDenied`, `ToolFailed` |
| **Dependencies** | Package & Entitlement Management (for authorization) |
| **Forbidden Dependencies** | Must not depend on Knowledge Management directly |
| **Tenant Boundary** | Tool execution is tenant-scoped |
| **Failure Behavior** | Tool unavailable → AI responds that it cannot perform the action |

### Operations Plane Contexts

#### Quality Assurance

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Manages QA workflows, conversation review, and improvement |
| **Owns** | QAReview, QAFinding, QAImprovement |
| **Reads** | Conversation, AuditEvent, Knowledge |
| **Writes** | QAReview, QAFinding, QAImprovement records |
| **APIs** | `GET /qa/reviews`, `POST /qa/reviews`, `GET /qa/findings`, `POST /qa/improvements` |
| **Events** | `QAReviewCreated`, `QAFindingRecorded`, `QAImprovementProposed` |
| **Dependencies** | Audit & Traceability (read-only), Knowledge Management (read-only) |
| **Forbidden Dependencies** | Must not write to Knowledge Management or AI Configuration directly |
| **Tenant Boundary** | QA data is tenant-scoped |
| **Failure Behavior** | QA continues manually |

#### Reporting & Insight

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Provides customer insight and operational reporting |
| **Owns** | Report, ReportMetric, CustomerInsight |
| **Reads** | Conversation, AuditEvent, Billing, QA |
| **Writes** | Report, ReportMetric records |
| **APIs** | `GET /reports/:tenantId`, `GET /reports/metrics`, `GET /insights/:tenantId` |
| **Events** | `ReportGenerated`, `InsightRecorded` |
| **Dependencies** | All domains (read-only) |
| **Forbidden Dependencies** | Must not write to any domain |
| **Tenant Boundary** | Reports are tenant-scoped |
| **Failure Behavior** | Report generation fails → retry |

#### Human Escalation Management

| Aspect | Specification |
|--------|--------------|
| **Responsibility** | Provides human interface for escalation response |
| **Owns** | HumanAgent, AgentAvailability, EscalationQueue |
| **Reads** | EscalationRequest, Tenant, Customer |
| **Writes** | HumanAgent, AgentAvailability records |
| **APIs** | `GET /escalation/queue`, `POST /escalation/accept`, `POST /escalation/release` |
| **Events** | `AgentAvailable`, `AgentBusy`, `EscalationAccepted`, `EscalationCompleted` |
| **Dependencies** | Escalation Orchestration (read/write), Telephony Provider |
| **Forbidden Dependencies** | Must not depend on Knowledge Management |
| **Tenant Boundary** | Escalation management is tenant-scoped |
| **Failure Behavior** | No human available → schedule callback |

---

## SECTION C — DATA ARCHITECTURE

### Entity Definitions

#### Tenant

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | N/A (this IS the tenant entity) |
| **Important Fields** | `name`, `status` (active/suspended/deleted), `jurisdiction`, `created_at`, `updated_at` |
| **Ownership** | StoreVoice |
| **Lifecycle** | Created → Active → Suspended → Deleted |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `name`, `status`, `jurisdiction` |
| **Versioning** | Status changes are versioned |
| **Audit** | All changes audited |
| **Deletion** | Soft delete with 14-day recovery; hard delete after |
| **Tenant Isolation** | N/A (this IS the tenant boundary) |

#### User

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `email`, `name`, `role`, `status` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Active → Deactivated |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `email`, `name`, `role`, `status` |
| **Versioning** | Role changes are versioned |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after legal retention |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Customer

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `name`, `email`, `phone`, `status`, `lifecycle_state`, `created_at` |
| **Ownership** | Tenant |
| **Lifecycle** | Prospect → Demo → Customer → Onboarding → Active → Cancellation → Recovery → Deleted |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `name`, `email`, `phone`, `status`, `lifecycle_state` |
| **Versioning** | Lifecycle state changes are versioned |
| **Audit** | All changes audited |
| **Deletion** | Permanent deletion after 14-day recovery |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### CustomerMembership

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `customer_id`, `user_id`, `role` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Active → Removed |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `role` |
| **Versioning** | None |
| **Audit** | All changes audited |
| **Deletion** | Removed (soft delete) |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Subscription

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `customer_id`, `package_id`, `package_version_id`, `status`, `stripe_subscription_id`, `starts_at`, `ends_at` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Active → Paused → Cancelled → Expired |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `status`, `package_id`, `package_version_id`, `ends_at` |
| **Versioning** | Package changes create new subscription records |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after legal retention |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Package

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | N/A (global) |
| **Important Fields** | `name`, `description`, `status` (active/deprecated) |
| **Ownership** | StoreVoice |
| **Lifecycle** | Created → Active → Deprecated → Archived |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `name`, `description`, `status` |
| **Versioning** | Packages are versioned (Package A v1, v2, etc.) |
| **Audit** | All changes audited |
| **Deletion** | Never deleted; archived |
| **Tenant Isolation** | N/A (global entity) |

#### PackageVersion

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | N/A (global) |
| **Important Fields** | `package_id`, `version`, `price`, `status`, `effective_from`, `effective_until` |
| **Ownership** | StoreVoice |
| **Lifecycle** | Created → Active → Deprecated → Archived |
| **Immutable Fields** | `id`, `created_at`, `version` |
| **Mutable Fields** | `price`, `status`, `effective_until` |
| **Versioning** | Each version is immutable once active |
| **Audit** | All changes audited |
| **Deletion** | Never deleted; archived |
| **Tenant Isolation** | N/A (global entity) |

#### Entitlement

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | N/A (global) |
| **Important Fields** | `package_version_id`, `feature_key`, `enabled`, `config` (JSON) |
| **Ownership** | StoreVoice |
| **Lifecycle** | Created → Active → Deprecated |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `enabled`, `config` |
| **Versioning** | Entitlements are versioned with package version |
| **Audit** | All changes audited |
| **Deletion** | Never deleted; deprecated |
| **Tenant Isolation** | N/A (global entity) |

#### CustomerEntitlement

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `customer_id`, `subscription_id`, `entitlement_id`, `effective_from`, `effective_until` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Active → Expired |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `effective_until` |
| **Versioning** | Subscription changes create new entitlement records |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after legal retention |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### AIColleague

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `name`, `status` (online/offline/degraded), `persona_id`, `behavior_policy_id` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Configuring → Ready → Active → Degraded → Offline |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `name`, `status`, `persona_id`, `behavior_policy_id` |
| **Versioning** | Configuration changes are versioned |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after customer deletion |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Persona

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `ai_colleague_id`, `name`, `role`, `tone`, `formality`, `style_config` (JSON) |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Active → Updated |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `name`, `role`, `tone`, `formality`, `style_config` |
| **Versioning** | Persona changes are versioned |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after customer deletion |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### BehaviorPolicy

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `ai_colleague_id`, `rules` (JSON), `safety_config` (JSON), `autonomy_level` |
| **Ownership** | Tenant (within centrally governed boundaries) |
| **Lifecycle** | Created → Active → Updated |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `rules`, `safety_config`, `autonomy_level` |
| **Versioning** | Policy changes are versioned |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after customer deletion |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### KnowledgeSource

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `type` (onboarding/document/website/api), `name`, `status`, `customer_id` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Ingesting → Active → Archived |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `name`, `status` |
| **Versioning** | Source changes are tracked |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after customer deletion |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### KnowledgeDocument

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `source_id`, `title`, `content`, `status` (draft/pending/approved/rejected/blocked), `approved_by`, `approved_at` |
| **Ownership** | Tenant |
| **Lifecycle** | Draft → Pending → Approved/Rejected → Active → Updated/Blocked → Archived |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `title`, `content`, `status`, `approved_by`, `approved_at` |
| **Versioning** | Each approval creates a new version |
| **Audit** | All changes audited |
| **Deletion** | Soft delete; hard delete after customer deletion |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### KnowledgeChunk

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `document_id`, `content`, `embedding` (vector), `metadata` (JSON) |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Indexed → Active |
| **Immutable Fields** | `id`, `created_at`, `content` (once approved) |
| **Mutable Fields** | `embedding`, `metadata` |
| **Versioning** | Chunks are versioned with document |
| **Audit** | All changes audited |
| **Deletion** | Hard delete with document |
| **Tenant Isolation** | `tenant_id` column; vector store is tenant-partitioned |

#### KnowledgeVersion

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `document_id`, `version`, `content`, `approved_by`, `approved_at`, `status` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Active → Superseded → Archived |
| **Immutable Fields** | `id`, `created_at`, `version`, `content` |
| **Mutable Fields** | `status` |
| **Versioning** | Each version is immutable once created |
| **Audit** | All changes audited |
| **Deletion** | Never deleted; archived |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### KnowledgeApproval

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `document_id`, `version_id`, `action` (approve/reject/block), `approved_by`, `reason` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Recorded |
| **Immutable Fields** | `id`, `created_at`, `action`, `approved_by` |
| **Mutable Fields** | None (append-only) |
| **Versioning** | N/A (immutable record) |
| **Audit** | Append-only |
| **Deletion** | Never deleted |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Memory

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `customer_id`, `content`, `source` (conversation/approved), `confidence`, `status` (candidate/approved/rejected), `approved_by`, `retention_until` |
| **Ownership** | Tenant |
| **Lifecycle** | Candidate → Approved/Rejected → Active → Expired → Deleted |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `content`, `status`, `approved_by`, `retention_until` |
| **Versioning** | Memory changes are versioned |
| **Audit** | All changes audited |
| **Deletion** | Hard delete after customer deletion or retention expiry |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Conversation

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `customer_id`, `channel`, `started_at`, `ended_at`, `status`, `escalated` |
| **Ownership** | Tenant |
| **Lifecycle** | Started → Active → Ended → Archived |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `ended_at`, `status`, `escalated` |
| **Versioning** | N/A |
| **Audit** | All changes audited |
| **Deletion** | Hard delete after customer deletion |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### ConversationMessage

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `conversation_id`, `role` (user/ai), `content`, `timestamp`, `metadata` (JSON) |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Recorded |
| **Immutable Fields** | `id`, `created_at`, `content`, `timestamp` |
| **Mutable Fields** | `metadata` |
| **Versioning** | N/A |
| **Audit** | Append-only |
| **Deletion** | Hard delete with conversation |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Session

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `conversation_id`, `ai_colleague_id`, `channel`, `started_at`, `ended_at`, `status`, `entitlement_snapshot` (JSON) |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Active → Ended → Archived |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `ended_at`, `status` |
| **Versioning** | N/A |
| **Audit** | All changes audited |
| **Deletion** | Hard delete after customer deletion |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### Escalation

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `session_id`, `trigger` (requested/emotional/knowledge_gap/decision/safety), `type` (cold/warm/callback), `status`, `assigned_to`, `context_summary` |
| **Ownership** | Tenant |
| **Lifecycle** | Created → Routed → In Progress → Completed/Failed |
| **Immutable Fields** | `id`, `created_at` |
| **Mutable Fields** | `status`, `assigned_to` |
| **Versioning** | N/A |
| **Audit** | All changes audited |
| **Deletion** | Hard delete after legal retention |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### AuditEvent

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `event_type`, `aggregate_type`, `aggregate_id`, `actor`, `payload` (JSON), `timestamp`, `correlation_id` |
| **Ownership** | StoreVoice |
| **Lifecycle** | Created → Recorded |
| **Immutable Fields** | `id`, `created_at`, `event_type`, `payload`, `timestamp` |
| **Mutable Fields** | None (append-only) |
| **Versioning** | N/A |
| **Audit** | Append-only |
| **Deletion** | Never deleted (legal retention) |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

#### DomainEvent

| Property | Specification |
|----------|--------------|
| **Primary Key** | `id` (UUID) |
| **Tenant Key** | `tenant_id` |
| **Important Fields** | `event_type`, `aggregate_type`, `aggregate_id`, `payload` (JSON), `correlation_id`, `causation_id`, `timestamp`, `schema_version` |
| **Ownership** | StoreVoice |
| **Lifecycle** | Created → Published → Processed |
| **Immutable Fields** | `id`, `created_at`, `event_type`, `payload`, `timestamp` |
| **Mutable Fields** | `status` (pending/processed/failed) |
| **Versioning** | Schema version for event evolution |
| **Audit** | Append-only |
| **Deletion** | Retained per retention policy |
| **Tenant Isolation** | `tenant_id` column; all queries scoped to tenant |

### Database Schema Principles

1. Every customer-specific table has a `tenant_id` column (UUID, NOT NULL)
2. Foreign keys reference the primary key of the related table
3. All timestamps are UTC
4. Soft delete is used for entities with legal retention requirements
5. Hard delete is used for entities that must be permanently removed
6. Append-only tables (AuditEvent, KnowledgeApproval) have no UPDATE or DELETE triggers
7. Database-level constraints enforce tenant isolation
8. Row-level security policies enforce tenant scoping

---

## SECTION D — MULTI-TENANCY

### Tenant Isolation Mechanism

**Primary Mechanism:** Database-level row-level security (RLS) with `tenant_id` column on every customer-specific table.

**Enforcement Layers:**

| Layer | Mechanism | Enforcement |
|-------|-----------|-------------|
| Database | Row-Level Security (RLS) | Every query automatically filtered by `tenant_id` from connection context |
| Application | Tenant Context Middleware | Every request extracts `tenant_id` from JWT token and sets database connection context |
| API | Request Validation | API endpoints validate `tenant_id` matches JWT token tenant |
| Cache | Tenant-Scoped Keys | All cache keys prefixed with `tenant_id:` |
| Events | Tenant Context | All events carry `tenant_id` field; handlers validate before processing |
| Background Jobs | Tenant Context | All background jobs receive `tenant_id`; process one tenant at a time |
| Logs | Tenant Context | All log entries include `tenant_id` for debugging |
| Object Storage | Tenant Prefix | All object storage keys prefixed with `tenant_id/` |
| Vector Store | Tenant Partition | Vector/embedding storage is tenant-partitioned |
| Analytics | Tenant Scope | All analytics queries are tenant-scoped |

### How Cross-Tenant Bugs Are Made Difficult

1. **Database RLS:** Even if application code forgets `tenant_id`, the database rejects cross-tenant queries
2. **Connection Context:** Database connections have `tenant_id` set at connection time; cannot be changed by application code
3. **API Validation:** API middleware validates `tenant_id` in request matches JWT token
4. **Cache Prefixing:** Cache keys are `{tenant_id}:{key}`; collision is structurally impossible
5. **Event Validation:** Event handlers receive `tenant_id` in event payload; must validate before processing

### What Tests Detect Cross-Tenant Issues

1. **Tenant Isolation Test Suite:** Automated tests that attempt cross-tenant data access
2. **RLS Policy Tests:** Tests that verify RLS policies block cross-tenant queries
3. **Cache Isolation Tests:** Tests that verify cache keys are tenant-scoped
4. **Event Isolation Tests:** Tests that verify events carry and validate tenant context
5. **API Isolation Tests:** Tests that verify API endpoints reject cross-tenant requests

### Cross-Tenant Incident Containment

1. **Detection:** Monitoring detects cross-tenant data access attempts
2. **Containment:** Affected tenant is quarantined; data access blocked
3. **Investigation:** Audit trail reconstructed for affected tenant
4. **Communication:** Customer notified of incident and resolution
5. **Improvement:** Structural changes implemented to prevent recurrence

---

## SPEC-001: CONTROL PLANE CACHING STRATEGY

### Problem

During a live voice conversation, the Interaction Plane must retrieve approved knowledge, persona definition, behavior policies, package entitlements, compliance rules, and localization configuration from the Control Plane. If the Control Plane is unavailable, session startup is blocked.

### Solution

The Interaction Plane maintains a read-through cache of Control Plane data. Session startup uses cached data with a short TTL. Control Plane unavailability does not block active sessions.

### Cache Architecture

| Data Type | Cache Key Pattern | TTL | Invalidation Trigger |
|-----------|-------------------|-----|---------------------|
| Knowledge | `{tenant_id}:knowledge:{doc_id}:{version}` | 5 minutes | `KnowledgeApproved`, `KnowledgeBlocked` |
| Persona | `{tenant_id}:persona:{ai_colleague_id}` | 5 minutes | `PersonaUpdated` |
| Behavior Policy | `{tenant_id}:behavior:{ai_colleague_id}` | 5 minutes | `BehaviorPolicyUpdated` |
| Entitlements | `{tenant_id}:entitlements:{subscription_id}` | 5 minutes | `EntitlementChanged` |
| Compliance Rules | `{tenant_id}:compliance:{jurisdiction}` | 15 minutes | `CompliancePolicyUpdated` |
| Localization | `{tenant_id}:localization` | 30 minutes | `LocalizationUpdated` |
| Package Definition | `global:package:{package_id}:{version}` | 1 hour | `PackageUpdated` |

### Cache Invalidation Flow

```
Control Plane State Change
    ↓
Domain Event Published (e.g., KnowledgeApproved)
    ↓
Event Handler Receives Event
    ↓
Cache Invalidation: Delete cache keys matching pattern
    ↓
Next Session Startup: Cache miss → Re-fetch from Control Plane → Re-populate cache
```

### Stale Read Tolerance

| Data Type | Stale Read Allowed? | Rationale |
|-----------|---------------------|-----------|
| Knowledge | YES (5 min) | Slight delay in knowledge updates acceptable |
| Persona | YES (5 min) | Persona changes are not urgent |
| Behavior Policy | YES (5 min) | Policy changes take effect at next session |
| Entitlements | NO | Entitlement changes must be immediate |
| Compliance Rules | NO | Compliance changes must be immediate |
| Localization | YES (30 min) | Localization changes are not urgent |

### Failure Behavior

| Scenario | Behavior |
|----------|----------|
| Cache miss, Control Plane available | Fetch from Control Plane, populate cache |
| Cache miss, Control Plane unavailable | Use stale cache if available; block session if no data |
| Cache hit, data expired | Return stale data, trigger background refresh |
| Cache eviction under memory pressure | Evict oldest entries first; never evict entitlements or compliance |

### Cache Implementation

- **Technology:** Redis (or equivalent in-memory store with TTL support)
- **Data Format:** JSON serialization of domain objects
- **Connection Pool:** Per-region connection pool to Redis
- **Fallback:** In-memory LRU cache as fallback if Redis unavailable

---

## SPEC-002: VOICE ENGINE BOUNDARY ADAPTER LAYER

### Problem

The frozen Voice Engine constructs its own system prompt internally. The Platform must inject knowledge, persona, and policies without modifying the Engine. The boundary interface is TARGET ARCHITECTURE, not currently implemented.

### Solution

The Platform constructs a complete system prompt that includes knowledge, persona, and policies, and passes it to the Engine via configuration. The Engine receives the constructed prompt and uses it directly.

### Adapter Architecture

```
┌─────────────────────────────────────────┐
│         STOREVOICE PLATFORM             │
│                                         │
│  Context Assembly                       │
│  ├── Knowledge Retrieval                │
│  ├── Persona Assembly                   │
│  ├── Policy Assembly                    │
│  ├── Compliance Assembly                │
│  └── System Prompt Construction         │
│                                         │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│       VOICE ENGINE ADAPTER              │
│       (Platform Component)              │
│                                         │
│  Translate Platform context to          │
│  Engine-native configuration:           │
│  ├── System prompt (constructed)        │
│  ├── Language setting                   │
│  ├── Voice ID selection                 │
│  ├── Temperature settings               │
│  └── Channel metadata                   │
│                                         │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│       VOICE ENGINE BOUNDARY             │
│       (Stable Interface)                │
│                                         │
│  Input:                                 │
│  - System prompt (with knowledge/policy)│
│  - Language                             │
│  - Voice ID                             │
│  - Channel parameters                   │
│                                         │
│  Output:                                │
│  - Transcription                        │
│  - AI response                          │
│  - Conversation events                  │
│  - Telemetry                            │
│                                         │
└────────────────────┬────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────┐
│         FROZEN VOICE ENGINE             │
│         (External Component)            │
│                                         │
│  Receives system prompt via config      │
│  Uses prompt directly                   │
│  No modification required               │
│                                         │
└─────────────────────────────────────────┘
```

### System Prompt Construction

The Platform constructs the system prompt as follows:

```
{persona_section}
{knowledge_section}
{behavior_section}
{compliance_section}
{localization_section}
{channel_section}
```

**Persona Section:**
```
You are {name}, the {role} for {company_name}.
Your tone is {tone}. Your formality level is {formality}.
{additional_persona_instructions}
```

**Knowledge Section:**
```
KNOWLEDGE:
{knowledge_item_1}
{knowledge_item_2}
...
```

**Behavior Section:**
```
BEHAVIOR RULES:
{behavior_rule_1}
{behavior_rule_2}
...
```

**Compliance Section:**
```
COMPLIANCE:
{compliance_rule_1}
{compliance_rule_2}
...
```

**Localization Section:**
```
LANGUAGE: {language}
FORMALITY: {formality}
CULTURAL NOTES: {cultural_notes}
```

### What Remains Inside the Engine

- Speech-to-text conversion (Deepgram)
- Language model inference (OpenAI)
- Text-to-speech synthesis (Cartesia)
- Voice Activity Detection (Silero)
- Turn detection
- Interruption handling
- Real-time audio processing

### What Remains Outside the Engine (Platform)

- Knowledge retrieval and approval
- Persona configuration
- Behavior policy enforcement
- Package entitlement enforcement
- Compliance rule evaluation
- Channel management
- Escalation orchestration
- Audit logging
- Tenant isolation
- Memory management
- Tool execution

### Engine Replaceability

The adapter layer ensures the Engine remains replaceable. A new Engine must:
1. Accept a system prompt via configuration
2. Process audio and produce text
3. Emit conversation events
4. Support interruption handling

The Platform does not depend on Engine internals.

---

## SPEC-003: EVENT IDEMPOTENCY CONTRACTS

### Problem

Event-driven systems produce duplicate events. Without idempotency, duplicate events cause: double billing, double escalation, duplicate audit entries, inconsistent state.

### Solution

All events carry unique event IDs. Event handlers are idempotent. The event store supports deduplication.

### Event Structure

```json
{
  "id": "uuid-v4",
  "type": "KnowledgeApproved",
  "tenant_id": "uuid",
  "aggregate_type": "KnowledgeDocument",
  "aggregate_id": "uuid",
  "correlation_id": "uuid",
  "causation_id": "uuid",
  "schema_version": "1.0",
  "timestamp": "2026-09-04T12:00:00Z",
  "actor": "user:uuid",
  "source": "knowledge-management",
  "idempotency_key": "knowledge-approved:{document_id}:{version}",
  "payload": {
    "document_id": "uuid",
    "version": 3,
    "approved_by": "user:uuid"
  }
}
```

### Idempotency Rules

| Event Type | Idempotency Key Pattern | Deduplication Window |
|-----------|------------------------|---------------------|
| KnowledgeApproved | `knowledge-approved:{doc_id}:{version}` | 24 hours |
| EntitlementChanged | `entitlement-changed:{subscription_id}:{entitlement_id}` | 24 hours |
| PaymentReceived | `payment-received:{stripe_payment_id}` | 7 days |
| SubscriptionCreated | `subscription-created:{subscription_id}` | 24 hours |
| SubscriptionCancelled | `subscription-cancelled:{subscription_id}` | 24 hours |
| EscalationTriggered | `escalation-triggered:{session_id}:{trigger_id}` | 1 hour |
| AuditEventRecorded | `audit-{event_id}` | 30 days |

### Event Handler Idempotency

Every event handler must:

1. **Check deduplication store** before processing
2. **Process event** if not duplicate
3. **Record in deduplication store** after processing
4. **Skip processing** if duplicate detected

```python
async def handle_event(event: DomainEvent) -> None:
    if await is_duplicate(event.idempotency_key):
        logger.info(f"Skipping duplicate event: {event.id}")
        return
    
    await process_event(event)
    await record_processed(event.idempotency_key)
```

### Dead-Letter Queue

Failed events are placed in a dead-letter queue after 3 retries with exponential backoff. Dead-letter events are:

1. Monitored and alerted
2. Manually reviewed
3. Retried or discarded based on investigation

### Event Ordering

Events are processed in order within an aggregate (per `aggregate_id`). Events across aggregates may be processed out of order. Event handlers must not depend on cross-aggregate ordering.

### Correlation and Causation

- **Correlation ID:** Groups related events (e.g., all events in a session)
- **Causation ID:** Links event to its cause (e.g., `KnowledgeApproved` caused by `UserApprovedKnowledge`)

---

## SPEC-004: BILLING-ENTITLEMENT SYNCHRONIZATION

### Problem

Billing state (from Stripe) and entitlement state (in Platform) must stay synchronized. Webhooks can be delayed, duplicated, or missing. Billing and entitlements can drift.

### Solution

Stripe webhook updates billing state. Billing state change triggers entitlement update. Entitlement state is authoritative for service access. Daily reconciliation catches drift.

### Synchronization Flow

```
Stripe Payment Event
    ↓
Webhook Received
    ↓
Idempotency Check (deduplicate)
    ↓
Event Verification (verify signature)
    ↓
Billing State Updated
    ↓
Entitlement State Updated
    ↓
Domain Event Published: EntitlementChanged
    ↓
Cache Invalidated
    ↓
Next Session: Uses new entitlements
```

### Webhook Processing

| Stripe Event | Platform Action | Entitlement Impact |
|-------------|-----------------|-------------------|
| `invoice.paid` | Update billing state | Renew subscription entitlements |
| `invoice.payment_failed` | Update billing state | Mark subscription as past-due |
| `customer.subscription.created` | Create subscription | Activate entitlements |
| `customer.subscription.updated` | Update subscription | Update entitlements |
| `customer.subscription.deleted` | Cancel subscription | Deactivate entitlements |
| `customer.subscription.trial_will_end` | Notify customer | No entitlement change |

### Reconciliation

Daily reconciliation job:

1. Fetch all active subscriptions from Stripe
2. Compare with Platform subscription state
3. Identify drift (billing state ≠ entitlement state)
4. Correct drift (Platform follows Stripe as source of truth for payment)
5. Log reconciliation results
6. Alert on significant drift

### Failure Scenarios

| Scenario | Behavior |
|----------|----------|
| Webhook delayed | Entitlements update when webhook arrives; service continues |
| Webhook duplicated | Idempotency check prevents double processing |
| Webhook missing | Daily reconciliation catches and corrects |
| Payment failed | Entitlements marked as past-due; service continues for grace period |
| Customer upgrades | Stripe webhook triggers immediate proration; entitlements update immediately |
| Customer downgrades | Stripe webhook triggers end-of-month downgrade; entitlements update at month end |
| Customer cancels | Stripe webhook triggers cancellation; entitlements continue through paid period |
| Stripe unavailable | Active service continues; reconciliation catches when Stripe recovers |
| Platform database unavailable | Stripe continues processing; Platform reconciles when database recovers |

---

## SPEC-005: PACKAGE VERSIONING MECHANISM

### Problem

Package evolution requires versioning. Material changes must be versioned and communicated. Existing customers retain commitments. Different customers may be on different package versions simultaneously.

### Solution

Packages are versioned (Package A v1, Package A v2). Each version has its own entitlements. Existing customers retain their version until migration. Migration is controlled and communicated.

### Versioning Model

```
Package (e.g., "Package A")
    ↓
PackageVersion (e.g., "v1", "v2")
    ↓
Entitlement (per version)
    ↓
CustomerSubscription (references specific version)
    ↓
CustomerEntitlement (derived from subscription + version)
```

### Material Change Definition

A material change is:

- Feature addition or removal
- Price change
- Service level change
- Entitlement change

Non-material changes (bug fixes, documentation updates) do not trigger versioning.

### Version Lifecycle

```
PackageVersion Created
    ↓
PackageVersion Active (new customers get this version)
    ↓
PackageVersion Deprecated (existing customers retain; new customers get next version)
    ↓
PackageVersion Archived (all customers migrated to newer version)
```

### Migration Process

1. **Announce:** Customer notified of upcoming change (30 days minimum)
2. **Create new version:** New PackageVersion with updated entitlements
3. **Assign existing customers:** Existing customers retain current version
4. **Migrate customers:** Customer moves to new version at next renewal or when customer requests
5. **Deprecate old version:** Old version marked deprecated
6. **Archive old version:** All customers migrated; old version archived

### Grandfathering

Existing customers retain their agreed package functionality and commercial commitments for the applicable paid or committed period. Grandfathering is time-limited and controlled.

### Regulatory Override

Mandatory regulatory or safety changes override package versioning. These changes are applied centrally and cannot be refused by customers.

---

## SECTION E — RUNTIME AI COLLEAGUE CONTEXT

### Context Assembly Pipeline

The runtime context assembly pipeline executes at session startup:

```
1. IDENTIFY TENANT
   Input: Session metadata
   Output: tenant_id
   Latency: < 10ms
   Failure: Block session

2. IDENTIFY CUSTOMER (where possible)
   Input: Phone number, caller ID, account ID
   Output: customer_id (or null)
   Latency: < 50ms
   Failure: Continue without customer identity

3. LOAD CUSTOMER CONFIGURATION
   Input: customer_id, tenant_id
   Output: Customer profile, preferences
   Source: Cache (TTL 5 min)
   Latency: < 10ms
   Failure: Use cached data if available

4. LOAD PACKAGE ENTITLEMENTS
   Input: customer_id, tenant_id
   Output: Entitlement list
   Source: Cache (TTL 5 min)
   Latency: < 10ms
   Failure: Block session (entitlements required)

5. LOAD COMPLIANCE RULES
   Input: jurisdiction, tenant_id
   Output: Compliance rules
   Source: Cache (TTL 15 min)
   Latency: < 10ms
   Failure: Use strictest compliance defaults

6. LOAD APPROVED KNOWLEDGE
   Input: tenant_id
   Output: Knowledge document list
   Source: Cache (TTL 5 min)
   Latency: < 50ms
   Failure: AI responds with "I don't have that information"

7. LOAD PERSONA DEFINITION
   Input: ai_colleague_id, tenant_id
   Output: Persona configuration
   Source: Cache (TTL 5 min)
   Latency: < 10ms
   Failure: Block session (persona required)

8. LOAD COMMUNICATION STYLE
   Input: locale, tenant_id
   Output: Style configuration
   Source: Cache (TTL 30 min)
   Latency: < 10ms
   Failure: Use English defaults

9. LOAD PERMITTED LONG-TERM MEMORY
   Input: customer_id, tenant_id
   Output: Memory items
   Source: Cache (TTL 5 min)
   Latency: < 50ms
   Failure: Continue without memory

10. LOAD RELEVANT CONVERSATION HISTORY
    Input: customer_id, tenant_id
    Output: Recent conversation summaries
    Source: Cache (TTL 5 min)
    Latency: < 50ms
    Failure: Continue without history

11. LOAD CURRENT SESSION STATE
    Input: session_id
    Output: Session context
    Source: Session store
    Latency: < 10ms
    Failure: Create new session state

12. LOAD BEHAVIORAL POLICIES
    Input: ai_colleague_id, tenant_id
    Output: Behavior policy rules
    Source: Cache (TTL 5 min)
    Latency: < 10ms
    Failure: Block session (policies required)

13. ASSEMBLE RUNTIME CONTEXT
    Input: All loaded data
    Output: RuntimeContext object
    Latency: < 100ms total
    Failure: Block session if critical data missing

14. SEND CONTEXT TO VOICE ENGINE
    Input: RuntimeContext
    Output: Engine session started
    Latency: < 500ms
    Failure: Queue and retry; callback if persistent

15. RECEIVE RESPONSES/EVENTS
    Input: Engine output
    Output: Conversation events
    Latency: Real-time
    Failure: Handle gracefully; do not drop events

16. CAPTURE NEW INFORMATION
    Input: Conversation content
    Output: Memory candidates
    Latency: Asynchronous
    Failure: Log and retry

17. EVALUATE MEMORY CANDIDATES
    Input: Memory candidates
    Output: Approved/rejected memories
    Latency: Asynchronous
    Failure: Log and retry

18. APPLY MEMORY POLICY
    Input: Approved memories
    Output: Persisted memories
    Latency: Asynchronous
    Failure: Log and retry

19. PERSIST APPROVED MEMORY/CONTEXT
    Input: Memories, context
    Output: Persisted data
    Latency: Asynchronous
    Failure: Log and retry

20. EMIT AUDIT/QA EVENTS
    Input: Session events
    Output: Audit events
    Latency: Asynchronous
    Failure: Log and retry
```

### Context Priority Hierarchy

When information conflicts, the following priority applies:

| Priority | Source | Example |
|----------|--------|---------|
| 1 (Highest) | System Safety Rules | "Never disclose confidential information" |
| 2 | Compliance Rules | "GDPR requires data minimization" |
| 3 | Package Entitlements | "Package A does not include appointment scheduling" |
| 4 | Behavior Policies | "Do not make promises about pricing" |
| 5 | Approved Knowledge | "Opening hours are 09:00–17:00" |
| 6 | Customer Memory | "Mr. Smith prefers email follow-up" |
| 7 | Persona | "Tone is warm and professional" |
| 8 (Lowest) | Communication Style | "Use formal Dutch" |

### What Can Influence the AI

- System safety rules (centrally governed)
- Compliance rules (centrally governed)
- Package entitlements (configuration-driven)
- Behavior policies (customer-configurable within bounds)
- Approved knowledge (customer-provided, StoreVoice-approved)
- Customer memory (customer-approved)
- Persona definition (customer-configurable within bounds)
- Communication style (customer-configurable within bounds)
- Conversation context (real-time)
- Channel context (real-time)

### What Cannot Influence the AI

- Unapproved knowledge
- AI-invented information
- Other customers' data
- Provider-specific business logic
- Unapproved tool execution
- Actions outside package entitlements

---

## SECTION F — MEMORY ARCHITECTURE

### Memory as First-Class Subsystem

Memory enables the AI colleague to:
- Remember relevant people
- Remember preferences
- Recognize recurring callers
- Remember prior conversations where permitted
- Use previous context appropriately
- Build continuity
- Adapt communication style
- Develop a recognizable persona through accumulated context

### Memory Model

| Component | Description |
|-----------|-------------|
| **Memory Candidate** | Potential memory extracted from conversation |
| **Memory Extraction** | Process of identifying memory candidates from conversation |
| **Confidence** | How certain the system is that this is a valid memory |
| **Source** | Where the memory came from (conversation, customer-approved) |
| **Approval State** | Whether the memory is approved for use |
| **Sensitivity Classification** | How sensitive the memory is (public, private, confidential) |
| **Retention** | How long the memory is retained |
| **Relevance** | How relevant the memory is to current conversations |
| **Contradiction Handling** | How contradictions with existing memories are resolved |
| **Correction** | How incorrect memories are corrected |
| **Deletion** | How memories are permanently removed |
| **Audit Trail** | Complete history of memory changes |

### Memory Lifecycle

```
Conversation Content
    ↓
Memory Candidate Extraction (automated)
    ↓
Confidence Scoring
    ↓
Approval State: Proposed
    ↓
Customer Review (via dashboard)
    ↓
Approval State: Approved / Rejected
    ↓
Memory Active (used in conversations)
    ↓
Memory Updated (if new information contradicts)
    ↓
Memory Expired (after retention period)
    ↓
Memory Deleted (permanent, structural)
```

### Memory Safety Rules

1. **NEVER invent memories.** Only extract from actual conversations or customer-approved sources.
2. **NEVER infer that something happened** merely because it would be convenient.
3. **NEVER expose another customer's memory.** Tenant isolation is absolute.
4. **NEVER retain customer-specific memory** after the defined deletion deadline.
5. **NEVER let AI-generated statements become durable truth** without customer approval.
6. **NEVER modify knowledge directly from conversation.** Only through approval workflow.

### Memory Approval Model

| Memory Type | Approval Required? | Rationale |
|-------------|-------------------|-----------|
| Customer name preference | Customer approves | Personal preference |
| Caller identification | Auto-approved | Factual, low sensitivity |
| Conversation summary | Auto-approved | Factual, low sensitivity |
| Preference (e.g., email) | Customer approves | Personal preference |
| Sensitive information | Customer approves | High sensitivity |
| Knowledge correction | Customer approves | Impacts knowledge base |

### Memory Conflict Resolution

When a new memory contradicts an existing memory:

1. **Detect conflict** (semantic similarity with contradictory assertions)
2. **Present conflict to customer** (dashboard notification)
3. **Last approved memory remains authoritative** during resolution
4. **Customer decides** which memory is correct
5. **Update memory** based on customer decision
6. **Retain previous memory** in audit history

### Memory Deletion

Memory deletion is permanent and structural:

1. **Customer requests deletion** (via dashboard)
2. **Memory marked for deletion** (soft delete)
3. **Deletion verified** (no pending operations)
4. **Memory permanently deleted** (hard delete)
5. **Deletion recorded** in audit trail
6. **Related cache entries invalidated**

---

## SECTION G — KNOWLEDGE ARCHITECTURE

### Knowledge Lifecycle

```
SOURCE
  ↓
INGEST (normalize, extract)
  ↓
VALIDATE (format, completeness)
  ↓
REVIEW (customer/StoreVoice review)
  ↓
APPROVE (customer approval)
  ↓
VERSION (create immutable version)
  ↓
INDEX (chunk, embed, store)
  ↓
ACTIVE KNOWLEDGE (available to AI)
  ↓
UPDATE / REPLACE / BLOCK
  ↓
AUDIT HISTORY (immutable record)
```

### Knowledge Types

| Type | Source | Approval | Deletion |
|------|--------|----------|----------|
| Customer Knowledge | Customer-provided | Customer approves | Deleted after termination |
| General StoreVoice Knowledge | StoreVoice-owned | StoreVoice approves | Retained |
| Aggregated Learning | Anonymized patterns | StoreVoice approves | Retained |
| System Policy | Centrally governed | Founder approves | Never deleted |

### Knowledge Precedence

When knowledge types conflict:

| Priority | Source | Example |
|----------|--------|---------|
| 1 (Highest) | System Policy | "Never disclose confidential information" |
| 2 | Customer Knowledge | "Opening hours are 09:00–17:00" |
| 3 | General StoreVoice Knowledge | "Best practice for greeting callers" |
| 4 (Lowest) | Aggregated Learning | "Most callers ask about opening hours" |

### Stale Knowledge Handling

1. **Detection:** Knowledge with effective dates past their end date
2. **Flagging:** Stale knowledge flagged in customer dashboard
3. **Customer action:** Customer reviews and updates or confirms
4. **AI behavior:** AI continues using stale knowledge until customer updates
5. **Escalation:** If knowledge is critical and stale, escalate to customer

### Conflicting Customer Information

When customer submits information that conflicts with existing approved knowledge:

1. **Conflict detected** (semantic similarity with contradictory assertions)
2. **Conflict presented to customer** (dashboard notification)
3. **Last approved information remains authoritative** during resolution
4. **AI continues using safe approved information** while conflict is unresolved
5. **Customer decides** which information is correct
6. **New information approved** and versioned
7. **Previous version retained** in audit history

---

## SECTION H — PERSONA / CHARACTER / HUMOR

### Persona Definition

The persona is the initial configuration that defines how the AI colleague presents itself:

| Element | Description | Example |
|---------|-------------|---------|
| **Name** | AI colleague's name | "Emma" |
| **Role** | AI colleague's role | "Receptionist" |
| **Tone** | Communication tone | "Warm", "Professional", "Friendly" |
| **Formality** | Formality level | "Formal" (DE: Sie), "Informal" (NL: je) |
| **Style** | Communication style | "Concise", "Detailed", "Casual" |
| **Cultural Expression** | Country-specific norms | Dutch directness, German formality |
| **Humor Level** | Humor appropriateness | "None", "Light", "Contextual" |
| **Empathy Level** | Empathy expression | "Professional", "Warm", "Neutral" |

### Character Without Ego

- **Character is allowed.** The AI may have a distinct personality.
- **Ego is not.** The AI must not become angry, offended, vindictive, hostile, resentful, manipulative, or negative for its own sake.

### Emotion Handling

The AI may:
- Recognize emotion in the caller's voice and words
- Acknowledge emotion appropriately
- Respond empathetically
- Adapt its communication style
- De-escalate emotional situations
- Recommend human intervention when emotion requires it

The AI must not:
- Falsely claim human emotions it does not have
- Manufacture emotional situations to appear human
- Create fake emotional relationships
- Attempt to manipulate emotions

### Humor Policy

Humor must:
- Be contextually appropriate
- Match the caller's tone
- Be culturally sensitive
- Never undermine professionalism
- Never be at the caller's expense

Humor must not:
- Be random model behavior
- Be inappropriate for the context
- Undermine the AI's credibility
- Create discomfort

### Policy Precedence

| Priority | Source |
|----------|--------|
| 1 (Highest) | System Safety Rules |
| 2 | Compliance Rules |
| 3 | Behavior Policies |
| 4 | Persona Definition |
| 5 (Lowest) | Communication Style |

---

## SECTION I — VOICE ENGINE BOUNDARY

### Request Contract (Platform → Engine)

```json
{
  "session_id": "uuid",
  "tenant_id": "uuid",
  "customer_id": "uuid (nullable)",
  "channel": "phone|whatsapp|email|sms",
  "language": "en|nl|fr|de",
  "system_prompt": "string (constructed by Platform)",
  "voice_id": "string (Cartesia voice UUID)",
  "temperature": 0.8,
  "max_completion_tokens": 300,
  "entitlements": ["feature_1", "feature_2"],
  "channel_metadata": {
    "caller_id": "+31612345678",
    "called_number": "+31201234567"
  }
}
```

### Response Contract (Engine → Platform)

```json
{
  "session_id": "uuid",
  "event_type": "transcription|response|escalation|telemetry|error",
  "timestamp": "ISO8601",
  "data": {
    "transcription": "string (what user said)",
    "response": "string (what AI said)",
    "escalation_reason": "string (if escalation triggered)",
    "latency_ms": {
      "stt": 150,
      "llm": 800,
      "tts": 200,
      "total": 1150
    },
    "error": {
      "code": "string",
      "message": "string"
    }
  }
}
```

### Streaming Contract

The Engine streams events to the Platform in real-time:

| Event | Frequency | Required |
|-------|-----------|----------|
| Transcription | Per utterance | Yes |
| Response | Per AI turn | Yes |
| Interruption | Per interruption | Yes |
| Telemetry | Per turn | Yes |
| Escalation | On trigger | Conditional |
| Error | On error | Yes |

### Session Lifecycle

```
PLATFORM: Create session
    ↓
PLATFORM: Configure (persona, knowledge, context, policies)
    ↓
BOUNDARY: Start session (send configuration)
    ↓
ENGINE: Initialize (apply configuration)
    ↓
ENGINE: Process conversation (stream events)
    ↓
BOUNDARY: Receive events
    ↓
PLATFORM: Handle events (audit, escalation, context update)
    ↓
BOUNDARY: End session
    ↓
PLATFORM: Record session, update audit
```

### Authentication

| Direction | Mechanism |
|-----------|-----------|
| Platform → Engine | API key or JWT token (configured per deployment) |
| Engine → Platform | Webhook signature verification |

### Correlation and Conversation IDs

- **Correlation ID:** Groups all events in a session
- **Conversation ID:** Links to the Platform's conversation record
- **Session ID:** Unique identifier for the Engine session

---

## SECTION J — REALTIME CALL PATH

### Complete Call Path

```
INCOMING CALL
    ↓
TELEPHONY PROVIDER (Twilio)
    ↓
CHANNEL GATEWAY
    ├── Number resolution (phone number → tenant)
    ├── Tenant resolution (tenant_id)
    ├── Contact identification (caller ID → customer_id)
    └── Channel session creation
    ↓
SESSION MANAGER
    ├── Session creation
    ├── Entitlement check
    ├── Compliance policy evaluation
    └── Session state initialization
    ↓
CONTEXT ASSEMBLY
    ├── Knowledge retrieval (from cache)
    ├── Persona assembly (from cache)
    ├── Memory retrieval (from cache)
    ├── Behavior policy loading (from cache)
    ├── Compliance rule loading (from cache)
    ├── Localization loading (from cache)
    └── Runtime context assembly
    ↓
VOICE ENGINE ADAPTER
    ├── System prompt construction
    ├── Configuration translation
    └── Engine session start
    ↓
VOICE ENGINE (frozen)
    ├── Audio processing (STT)
    ├── Language model inference (LLM)
    ├── Speech synthesis (TTS)
    ├── Turn detection
    ├── Interruption handling
    └── Stream events to Platform
    ↓
PLATFORM EVENT PROCESSING
    ├── Transcription recording
    ├── Response recording
    ├── Tool execution (if triggered)
    ├── Escalation evaluation (if triggered)
    ├── Audit event emission
    └── Context update
    ↓
CONVERSATION COMPLETION
    ├── Session end
    ├── Post-call processing
    ├── Memory candidate extraction
    ├── QA event emission
    ├── Reporting event emission
    └── Audit finalization
```

### Step Details

| Step | Synchronous/Async | Latency Sensitivity | Timeout | Retry | Failure Behavior | Idempotency |
|------|-------------------|---------------------|---------|-------|------------------|-------------|
| Number resolution | Sync | High | 100ms | 0 | Reject call | N/A |
| Tenant resolution | Sync | High | 100ms | 0 | Reject call | N/A |
| Contact identification | Sync | Medium | 200ms | 0 | Continue without customer | N/A |
| Session creation | Sync | High | 200ms | 0 | Reject call | N/A |
| Entitlement check | Sync | High | 100ms | 0 | Block session | N/A |
| Compliance evaluation | Sync | High | 100ms | 0 | Use strictest compliance | N/A |
| Knowledge retrieval | Sync | High | 500ms | 1 | Use cache | N/A |
| Persona assembly | Sync | High | 100ms | 1 | Block session | N/A |
| Memory retrieval | Sync | Medium | 500ms | 1 | Continue without memory | N/A |
| Context assembly | Sync | High | 1000ms total | 0 | Block session | N/A |
| Engine session start | Sync | High | 2000ms | 1 | Queue and retry | N/A |
| Transcription recording | Async | Low | N/A | 3 | Log and retry | Yes |
| Response recording | Async | Low | N/A | 3 | Log and retry | Yes |
| Tool execution | Sync | Medium | 5000ms | 1 | AI responds unable | Yes |
| Escalation evaluation | Sync | Medium | 200ms | 0 | Continue without escalation | N/A |
| Audit event emission | Async | Low | N/A | 3 | Log and retry | Yes |
| Memory candidate extraction | Async | Low | N/A | 3 | Log and retry | Yes |
| QA event emission | Async | Low | N/A | 3 | Log and retry | Yes |
| Reporting event emission | Async | Low | N/A | 3 | Log and retry | Yes |

---

## SECTION K — CHANNEL ARCHITECTURE

### Supported Channels

| Channel | Provider | Status | Notes |
|---------|----------|--------|-------|
| Phone | Twilio | MVP | Primary channel |
| WhatsApp | TBD | Future | Requires integration |
| Email | TBD | Future | Requires integration |
| SMS | Twilio | Future | Follow-up sequencing |

### Identity Resolution

Customer identity is resolved before session creation:

| Priority | Method | Accuracy |
|----------|--------|----------|
| 1 | Customer account ID (if known) | High |
| 2 | Phone number matching | High |
| 3 | Email matching | Medium |
| 4 | Manual linking | High |

### Context Synchronization

Customer context is unified across channels:

- Same customer identified across channels
- Conversation history accessible across channels
- Escalation state shared across channels
- Knowledge and configuration shared across channels

### Channel-Specific Behavior

| Channel | Behavior | Limitations |
|---------|----------|-------------|
| Phone | Real-time voice conversation | Audio only |
| WhatsApp | Text/voice messages | Message-based |
| Email | Text-based conversation | Delayed response |
| SMS | Short text messages | Character limits |

---

## SECTION L — HUMAN ESCALATION

### Escalation Triggers

| Trigger | Type | Action |
|---------|------|--------|
| Customer requests human | Explicit | Immediate escalation |
| Emotional situation detected | Implicit | Warm transfer if available |
| Knowledge gap | Implicit | AI acknowledges, offers callback |
| Decision required | Implicit | Transfer to appropriate person |
| Safety concern | Implicit | Immediate escalation |
| Confidence threshold low | Implicit | Offer human assistance |
| Business rule trigger | Explicit | Follow rule definition |

### Transfer Types

**Cold Transfer:**
1. AI generates context summary
2. AI transfers call with context attached
3. Human receives call + context
4. Customer does not repeat story

**Warm Transfer:**
1. AI whispers context to human
2. Human acknowledges
3. AI introduces human to customer
4. AI steps out of conversation
5. Human continues with customer

**Callback:**
1. AI captures customer contact information
2. AI captures reason for callback
3. AI captures urgency level
4. AI schedules callback
5. Human receives callback request with context
6. Human calls customer back

### Fallback When No Human Available

1. AI acknowledges limitation
2. AI captures complete context
3. AI schedules callback
4. AI provides estimated callback time
5. AI thanks customer for patience

---

## SECTION M — PACKAGE / ENTITLEMENT SYSTEM

### Package Model

```
Package
    ↓
PackageVersion
    ↓
Entitlement (per version)
    ↓
CustomerSubscription (references specific version)
    ↓
CustomerEntitlement (derived)
```

### Entitlement Enforcement

**Location:** Entitlements are evaluated at session startup and cached for the session duration.

**Mechanism:**
1. Session startup: Load customer entitlements from cache
2. Entitlements passed to Voice Engine as part of session configuration
3. Engine respects entitlements for tool execution
4. Platform enforces entitlements for API access

**Mid-Session Changes:** Entitlement changes take effect at next session, not during active session.

### Upgrade/Downgrade/Cancellation

| Operation | Timing | Proration | Entitlement Impact |
|-----------|--------|-----------|-------------------|
| Upgrade | Immediate | Prorated | Immediate |
| Downgrade | End of month | None | End of month |
| Cancellation | End of paid period | None | End of paid period |
| Reactivation | Immediate | New subscription | Immediate |

---

## SECTION N — BILLING SYNCHRONIZATION

### Synchronization Mechanism

**SPEC-004** defines the billing-entitlement synchronization mechanism (see Section above).

Key principles:
1. Stripe webhook updates billing state
2. Billing state change triggers entitlement update
3. Entitlement state is authoritative for service access
4. Daily reconciliation catches drift
5. Webhook deduplication prevents double processing

---

## SECTION O — EVENT ARCHITECTURE

### Event Structure

**SPEC-003** defines event idempotency contracts (see Section above).

Key principles:
1. All events carry unique event IDs
2. Event handlers are idempotent
3. Event store supports deduplication
4. Dead-letter queue for failed events
5. Correlation IDs for tracing

---

## SECTION P — CONTROL PLANE CACHING

**SPEC-001** defines the Control Plane caching strategy (see Section above).

Key principles:
1. Read-through cache with TTL
2. Cache invalidation on state changes
3. Stale read tolerance for non-critical data
4. Immediate update for entitlements and compliance
5. Redis with in-memory LRU fallback

---

## SECTION Q — DEMO SYSTEM

### Demo Architecture

```
WEBSITE
    ↓
SCRAPE (extract content)
    ↓
TEMPORARY KNOWLEDGE (stored in demo namespace)
    ↓
DEMO TENANT (special tenant type with TTL)
    ↓
DEMO AI COLLEAGUE (configured with scraped knowledge)
    ↓
DEMO PHONE NUMBER (temporary Twilio number)
    ↓
DEMO SESSION (~90 seconds)
    ↓
FOLLOW-UP (SMS + email sequencing)
    ↓
EXPIRATION (~48 hours)
    ↓
DELETION (demo tenant and all data)
```

### Demo Isolation

| Aspect | Mechanism |
|--------|-----------|
| Tenant | Special "demo" tenant type with `expires_at` timestamp |
| Knowledge | Stored in demo namespace; never enters production knowledge stores |
| Conversations | Logged separately; never enters production audit trails |
| Phone number | Temporary Twilio number; released after expiry |
| Data | All data tagged with `is_demo: true` |

### Demo Expiry Enforcement

**Background job** runs every hour:
1. Query all demo tenants with `expires_at < now()`
2. For each expired demo:
   - Release phone number
   - Delete demo knowledge
   - Delete demo conversations
   - Delete demo tenant
   - Log deletion in audit trail

### Demo Abuse Prevention

- Rate limiting: 1 demo per IP per 24 hours
- CAPTCHA on demo request form
- Phone number verification before demo
- Maximum 3 demos per email address

---

## SECTION R — LOCALIZATION

### Localization Dimensions

| Dimension | Scope | Configuration |
|-----------|-------|--------------|
| Language | EN, NL, FR, DE (expanding) | `language` field |
| Locale | Country-specific formatting | `locale` field |
| Communication Style | Formal/informal | `formality` field |
| Cultural Expression | Country-specific norms | `cultural_config` JSON |
| Formality | Formal/informal register | `formality` field |
| Customer-Facing Documentation | Localized UI, emails | Template system |
| Invoices | Localized invoice format | Template system |
| Reports | Localized reporting | Template system |
| AI Behavior | Country-specific AI behavior | `behavior_config` JSON |

### Language Rollout Strategy

1. Architecture supports all European languages
2. Individual languages rolled out progressively
3. Current Voice Engine supports: EN, NL, FR, DE
4. Future expansion requires no architectural changes
5. Platform must be capable of supporting languages beyond current 4

### Internal vs. Customer-Facing

- **Internal StoreVoice language:** English
- **Customer-facing experience:** Localized to customer's country
- **AI colleague behavior:** Adapted to customer's cultural context

---

## SECTION S — COMPLIANCE / JURISDICTION

### Compliance Model

```
JURISDICTION
    ↓
APPLICABLE REGULATION
    ↓
SERVICE APPLICABILITY
    ↓
COMPLIANCE RULES (versioned, with effective dates)
    ↓
RUNTIME EVALUATION (at session startup)
    ↓
AUDIT (compliance state logged)
```

### Compliance Rule Storage

- **Storage:** Versioned configuration store (database table)
- **Versioning:** Each rule version is immutable once effective
- **Effective Dates:** Rules have `effective_from` and `effective_until`
- **Jurisdiction Matching:** Rules matched to customer jurisdiction at session startup

### Mandatory Changes

Mandatory regulatory changes:
1. **Cannot be refused** by customers
2. **Applied centrally** across all affected customers
3. **Communicated** to affected customers
4. **Logged** in audit trail
5. **Enforced** at session startup

---

## SECTION T — AUDIT / RECONSTRUCTION

### Audit Capabilities

StoreVoice can reconstruct:

| Element | Source |
|---------|--------|
| What the AI said | ConversationMessage |
| What knowledge was active | KnowledgeVersion |
| What configuration applied | AIColleague version |
| What package/entitlements applied | CustomerEntitlement |
| What policy applied | BehaviorPolicy version |
| What provider/version was used | ProviderConfiguration |
| What escalation occurred | Escalation |
| What human intervention occurred | HumanInteraction |
| Relevant timestamps | AuditEvent |

### Audit Approach

- **Immutable audit events** (append-only)
- **Knowledge versioning** (point-in-time reconstruction)
- **Configuration versioning** (point-in-time reconstruction)
- **Conversation logging** (context reconstruction)
- **Action logging** (AI behavior reconstruction)

---

## SECTION U — INCIDENT / SAFETY

### Incident Detection

| Method | Description |
|--------|-------------|
| Monitoring-based | Automated detection via metrics |
| Threshold-based | Alerting on metric thresholds |
| Customer-reported | Customer initiates incident |
| Operational anomaly | Unusual patterns detected |

### Incident Response Flow

```
DETECTION
    ↓
CLASSIFICATION (severity: low/medium/high/critical)
    ↓
CONTAINMENT (operational response)
    ↓
ESCALATION (human involvement)
    ↓
RESOLUTION (fix applied)
    ↓
POST-INCIDENT REVIEW (human review)
    ↓
STRUCTURAL IMPROVEMENTS (centrally implemented)
```

### Emergency Shutdown

1. **Control Plane operation** sets tenant status to "offline"
2. **Active calls** continue to completion
3. **No new sessions** start for affected tenant
4. **Customer notified** via email/SMS
5. **Reactivation** requires human approval
6. **Authority:** StoreVoice operations team

---

## SECTION V — PROVIDER ABSTRACTION

### Provider Interfaces

| Category | Interface | Current Provider | Replaceable |
|----------|-----------|-----------------|-------------|
| STT | `STTProvider` | Deepgram Nova-3 | YES |
| LLM | `LLMProvider` | OpenAI GPT-4.1 | YES |
| TTS | `TTSProvider` | Cartesia Sonic-3 | YES |
| Telephony | `TelephonyProvider` | Twilio | YES |
| Payments | `PaymentProvider` | Stripe | YES |
| Cloud | `CloudProvider` | TBD | YES |
| Observability | `ObservabilityProvider` | TBD | YES |

### Provider Health Monitoring

Each provider has:
- Health check endpoint
- Latency monitoring
- Error rate tracking
- Availability tracking

### Fallback Strategy

| Provider | Fallback | Degradation |
|----------|----------|-------------|
| STT | Alternative provider | Reduced quality |
| LLM | Alternative provider | Reduced capability |
| TTS | Alternative provider | Reduced quality |
| Telephony | Alternative provider | Channel unavailable |
| Payments | Manual processing | Service continues |

---

## SECTION W — DEPLOYMENT ARCHITECTURE

### MVP Deployment

| Component | Technology | Notes |
|-----------|-----------|-------|
| Application Runtime | Docker containers | Single region initially |
| Database | PostgreSQL | With row-level security |
| Cache | Redis | With TTL support |
| Queue | Redis Streams | For async processing |
| Object Storage | S3-compatible | For knowledge documents |
| Vector Store | pgvector | For knowledge embeddings |
| Secrets | Vault or cloud secrets | Centralized management |
| Observability | TBD | To be determined |
| CI/CD | GitHub Actions | Automated deployment |

### Future Scale Deployment

| Component | Technology | Notes |
|-----------|-----------|-------|
| Application Runtime | Kubernetes | Multi-region |
| Database | PostgreSQL with read replicas | Per region |
| Cache | Redis Cluster | Per region |
| Queue | Kafka or equivalent | Event streaming |
| Object Storage | S3 | Multi-region |
| Vector Store | pgvector or dedicated | Per region |
| Secrets | Vault | Centralized |
| Observability | TBD | Centralized |
| CI/CD | GitHub Actions | Multi-environment |

---

## SECTION X — SECURITY MODEL

### Security Controls

| Domain | Control |
|--------|---------|
| Authentication | JWT tokens with tenant context |
| Authorization | Role-based access control (RBAC) |
| Tenant Isolation | Row-level security (RLS) |
| Secrets | Centralized secrets management |
| Encryption | At rest and in transit |
| Privileged Access | Controlled and audited |
| API Security | Rate limiting, input validation |
| Service-to-Service | Mutual TLS or service mesh |
| PII Handling | Data minimization, encryption |
| Logging | Structured, tenant-scoped |
| Support Access | Read-only, tenant-scoped |
| Admin Access | Controlled, audited |
| Break-Glass | Emergency access with audit |
| Rate Limiting | Per-tenant, configurable |
| Abuse Protection | CAPTCHA, rate limiting |
| Prompt Injection | Input validation, output filtering |
| Tool Authorization | Entitlement-based, policy-based |

---

## SECTION Y — TESTING ARCHITECTURE

### Test Layers

| Layer | Scope | Automation |
|-------|-------|------------|
| Unit | Individual functions/methods | 100% automated |
| Integration | Component interactions | 100% automated |
| Contract | API contracts | 100% automated |
| Database Isolation | Tenant isolation at DB level | 100% automated |
| Security | Authentication, authorization | 100% automated |
| Tenant Isolation | Cross-tenant data access | 100% automated |
| Event/Idempotency | Event processing, deduplication | 100% automated |
| Realtime | Voice conversation flow | 80% automated |
| Voice Engine Boundary | Platform ↔ Engine interface | 100% automated |
| Knowledge Retrieval | Knowledge accuracy, latency | 100% automated |
| Memory | Memory extraction, approval | 100% automated |
| Escalation | Escalation triggers, handoff | 100% automated |
| Billing | Payment processing, sync | 100% automated |
| Package Entitlement | Entitlement enforcement | 100% automated |
| Localization | Language, cultural adaptation | 100% automated |
| Compliance | Rule evaluation, enforcement | 100% automated |
| Deletion | Data deletion, audit | 100% automated |
| Incident Recovery | Incident detection, response | 100% automated |
| End-to-End | Complete user journeys | 80% automated |
| Load/Concurrency | Performance under load | 80% automated |

---

## SECTION Z — IMPLEMENTATION PHASES

### Phase 0: Repository / Governance / CI

| Aspect | Specification |
|--------|--------------|
| **Objective** | Establish development infrastructure and governance |
| **Prerequisites** | None |
| **Deliverables** | Application repository, CI/CD pipeline, development environment, governance documents |
| **Database Changes** | None |
| **APIs** | None |
| **Events** | None |
| **Tests** | CI pipeline tests |
| **Acceptance Criteria** | Repository exists, CI passes, development environment works |
| **Risks** | None |
| **Rollback** | Delete repository |

### Phase 1: Core Platform Foundation

| Aspect | Specification |
|--------|--------------|
| **Objective** | Establish core platform structure, database, authentication |
| **Prerequisites** | Phase 0 |
| **Deliverables** | Database schema, authentication, tenant context middleware, basic API framework |
| **Database Changes** | All core tables (Tenant, User, Customer, etc.) |
| **APIs** | `POST /tenants`, `POST /users`, `POST /customers` |
| **Events** | `TenantCreated`, `UserCreated`, `CustomerCreated` |
| **Tests** | Unit, integration, database isolation |
| **Acceptance Criteria** | Can create tenant, user, customer with tenant isolation |
| **Risks** | Database schema design errors |
| **Rollback** | Database migration rollback |

### Phase 2: Package / Entitlement System

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement package definitions, entitlements, subscriptions |
| **Prerequisites** | Phase 1 |
| **Deliverables** | Package management, entitlement engine, subscription management |
| **Database Changes** | Package, PackageVersion, Entitlement, CustomerSubscription tables |
| **APIs** | `GET /packages`, `POST /subscriptions`, `GET /customers/:id/entitlements` |
| **Events** | `PackageCreated`, `SubscriptionCreated`, `EntitlementChanged` |
| **Tests** | Unit, integration, entitlement enforcement |
| **Acceptance Criteria** | Can create package, assign subscription, enforce entitlements |
| **Risks** | Entitlement enforcement gaps |
| **Rollback** | Database migration rollback |

### Phase 3: Knowledge Management

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement knowledge lifecycle, approval, versioning |
| **Prerequisites** | Phase 1 |
| **Deliverables** | Knowledge ingestion, validation, approval, versioning, retrieval |
| **Database Changes** | KnowledgeSource, KnowledgeDocument, KnowledgeChunk, KnowledgeVersion tables |
| **APIs** | `POST /knowledge/sources`, `POST /knowledge/approve`, `GET /knowledge/documents` |
| **Events** | `KnowledgeIngested`, `KnowledgeApproved`, `KnowledgeBlocked` |
| **Tests** | Unit, integration, knowledge retrieval |
| **Acceptance Criteria** | Can ingest, approve, version, retrieve knowledge |
| **Risks** | Knowledge versioning complexity |
| **Rollback** | Database migration rollback |

### Phase 4: AI Colleague Configuration

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement persona, behavior policies, AI colleague management |
| **Prerequisites** | Phases 1, 2, 3 |
| **Deliverables** | Persona configuration, behavior policies, AI colleague management |
| **Database Changes** | AIColleague, Persona, BehaviorPolicy tables |
| **APIs** | `POST /ai-colleagues`, `PUT /ai-colleagues/:id/persona`, `PUT /ai-colleagues/:id/behavior` |
| **Events** | `AIColleagueCreated`, `PersonaUpdated`, `BehaviorPolicyUpdated` |
| **Tests** | Unit, integration |
| **Acceptance Criteria** | Can create AI colleague with persona and behavior policies |
| **Risks** | Behavior policy complexity |
| **Rollback** | Database migration rollback |

### Phase 5: Caching Layer

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement SPEC-001: Control Plane caching strategy |
| **Prerequisites** | Phases 1-4 |
| **Deliverables** | Redis cache, cache invalidation, cache-aside pattern |
| **Database Changes** | None |
| **APIs** | None |
| **Events** | Cache invalidation events |
| **Tests** | Unit, integration, cache isolation |
| **Acceptance Criteria** | Cache works correctly, invalidation works, tenant isolation maintained |
| **Risks** | Cache contamination across tenants |
| **Rollback** | Disable cache, fallback to direct queries |

### Phase 6: Voice Engine Adapter

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement SPEC-002: Voice Engine boundary adapter layer |
| **Prerequisites** | Phases 1-5 |
| **Deliverables** | System prompt construction, adapter layer, boundary interface |
| **Database Changes** | None |
| **APIs** | Internal adapter API |
| **Events** | `EngineSessionStarted`, `EngineSessionEnded`, `EngineTranscription`, `EngineResponse` |
| **Tests** | Unit, integration, contract |
| **Acceptance Criteria** | Can construct system prompt, start engine session, receive events |
| **Risks** | Engine compatibility issues |
| **Rollback** | Revert to direct engine integration |

### Phase 7: Event Architecture

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement SPEC-003: Event idempotency contracts |
| **Prerequisites** | Phases 1-6 |
| **Deliverables** | Event store, event processing, idempotency, dead-letter queue |
| **Database Changes** | DomainEvent table |
| **APIs** | Internal event API |
| **Events** | All domain events |
| **Tests** | Unit, integration, idempotency |
| **Acceptance Criteria** | Events are idempotent, deduplication works, dead-letter queue works |
| **Risks** | Event ordering issues |
| **Rollback** | Disable event processing, fallback to synchronous |

### Phase 8: Realtime Phone Path

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement complete call path from incoming call to conversation |
| **Prerequisites** | Phases 1-7 |
| **Deliverables** | Channel gateway, session manager, context assembly, voice engine adapter, event processing |
| **Database Changes** | ChannelSession, Session, ConversationMessage tables |
| **APIs** | Internal session API |
| **Events** | `ChannelSessionStarted`, `SessionCreated`, `ConversationMessageRecorded` |
| **Tests** | Integration, end-to-end |
| **Acceptance Criteria** | Complete call path works end-to-end |
| **Risks** | Real-time latency issues |
| **Rollback** | Revert to direct engine integration |

### Phase 9: Memory / Context

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement memory extraction, approval, persistence |
| **Prerequisites** | Phases 1-8 |
| **Deliverables** | Memory candidate extraction, approval workflow, memory persistence |
| **Database Changes** | Memory table |
| **APIs** | `GET /memory/:customerId`, `POST /memory/approve` |
| **Events** | `MemoryCandidateExtracted`, `MemoryApproved`, `MemoryRejected` |
| **Tests** | Unit, integration |
| **Acceptance Criteria** | Memory extraction works, approval works, persistence works |
| **Risks** | Memory accuracy issues |
| **Rollback** | Disable memory extraction |

### Phase 10: Human Escalation

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement escalation triggers, routing, transfer, callback |
| **Prerequisites** | Phases 1-9 |
| **Deliverables** | Escalation orchestration, transfer mechanism, callback scheduling |
| **Database Changes** | Escalation table |
| **APIs** | `POST /escalation`, `GET /escalation/:id` |
| **Events** | `EscalationTriggered`, `TransferInitiated`, `CallbackScheduled` |
| **Tests** | Unit, integration |
| **Acceptance Criteria** | Escalation works, transfer works, callback works |
| **Risks** | Transfer mechanism complexity |
| **Rollback** | Disable escalation, continue with AI |

### Phase 11: Billing Integration

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement SPEC-004: Billing-entitlement synchronization |
| **Prerequisites** | Phases 1-10 |
| **Deliverables** | Stripe integration, webhook handling, reconciliation |
| **Database Changes** | BillingState, BillingEvent tables |
| **APIs** | `POST /billing/webhook`, `GET /billing/state/:tenantId` |
| **Events** | `PaymentReceived`, `SubscriptionRenewed`, `EntitlementChanged` |
| **Tests** | Unit, integration, idempotency |
| **Acceptance Criteria** | Billing syncs correctly, reconciliation works |
| **Risks** | Stripe integration complexity |
| **Rollback** | Disable Stripe integration, manual billing |

### Phase 12: Demo System

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement demo creation, isolation, expiry |
| **Prerequisites** | Phases 1-11 |
| **Deliverables** | Website scraping, demo tenant creation, demo isolation, expiry |
| **Database Changes** | DemoInstance table |
| **APIs** | `POST /demos`, `GET /demos/:id` |
| **Events** | `DemoCreated`, `DemoExpired`, `DemoConverted` |
| **Tests** | Unit, integration |
| **Acceptance Criteria** | Demo creation works, isolation works, expiry works |
| **Risks** | Website scraping reliability |
| **Rollback** | Disable demo creation |

### Phase 13: Operations / QA

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement QA workflows, reporting, operational tooling |
| **Prerequisites** | Phases 1-12 |
| **Deliverables** | QA review, reporting, operational dashboards |
| **Database Changes** | QAReview, Report tables |
| **APIs** | `GET /qa/reviews`, `GET /reports/:tenantId` |
| **Events** | `QAReviewCreated`, `ReportGenerated` |
| **Tests** | Unit, integration |
| **Acceptance Criteria** | QA workflows work, reporting works |
| **Risks** | Reporting complexity |
| **Rollback** | Disable automated QA |

### Phase 14: Compliance / Localization

| Aspect | Specification |
|--------|--------------|
| **Objective** | Implement compliance rules, localization configuration |
| **Prerequisites** | Phases 1-13 |
| **Deliverables** | Compliance rule storage, evaluation, localization configuration |
| **Database Changes** | CompliancePolicy, LocalizationProfile tables |
| **APIs** | `GET /compliance/policies`, `GET /localization/:tenantId` |
| **Events** | `CompliancePolicyCreated`, `LocalizationUpdated` |
| **Tests** | Unit, integration |
| **Acceptance Criteria** | Compliance evaluation works, localization works |
| **Risks** | Compliance rule complexity |
| **Rollback** | Disable compliance evaluation |

### Phase 15: Production Hardening

| Aspect | Specification |
|--------|--------------|
| **Objective** | Security hardening, performance optimization, monitoring |
| **Prerequisites** | Phases 1-14 |
| **Deliverables** | Security audit, performance testing, monitoring, alerting |
| **Database Changes** | None |
| **APIs** | None |
| **Events** | None |
| **Tests** | Security, performance, load |
| **Acceptance Criteria** | Security audit passes, performance meets requirements |
| **Risks** | Security vulnerabilities |
| **Rollback** | Revert to previous version |

---

## SECTION AA — DEPENDENCY GRAPH

### Phase Dependencies

```
Phase 0 (Repository/Governance/CI)
    ↓
Phase 1 (Core Platform Foundation)
    ↓
Phase 2 (Package/Entitlement) ← Phase 1
Phase 3 (Knowledge Management) ← Phase 1
    ↓
Phase 4 (AI Colleague Config) ← Phases 1, 2, 3
Phase 5 (Caching Layer) ← Phases 1-4
    ↓
Phase 6 (Voice Engine Adapter) ← Phases 1-5
Phase 7 (Event Architecture) ← Phases 1-6
    ↓
Phase 8 (Realtime Phone Path) ← Phases 1-7
    ↓
Phase 9 (Memory/Context) ← Phases 1-8
Phase 10 (Human Escalation) ← Phases 1-9
    ↓
Phase 11 (Billing Integration) ← Phases 1-10
Phase 12 (Demo System) ← Phases 1-11
    ↓
Phase 13 (Operations/QA) ← Phases 1-12
Phase 14 (Compliance/Localization) ← Phases 1-13
    ↓
Phase 15 (Production Hardening) ← Phases 1-14
```

### Parallel Execution Opportunities

| Can Run In Parallel | Reason |
|--------------------|--------|
| Phase 2 + Phase 3 | Independent domains |
| Phase 9 + Phase 10 | Independent features |
| Phase 11 + Phase 12 | Independent features |
| Phase 13 + Phase 14 | Independent features |

### Critical Path

```
Phase 0 → Phase 1 → Phase 5 → Phase 6 → Phase 7 → Phase 8 → Phase 15
```

---

## SECTION AB — AGENT TOPOLOGY & ORCHESTRATION SPECIFICATION

### Topology Overview

Change 005D defined 40 capabilities/roles. Change 005E determines the **actual agent topology** — the smallest coherent multi-agent organization that provides complete capability coverage.

**005E Result: 31 agents across 10 layers.**

The topology groups related capabilities where:

* shared context is high
* authority boundaries align
* grouping does not compromise independence
* specialization is preserved where failure impact is high

### Organizational Layers

```text
LAYER 0 — FOUNDER
LAYER 1 — ORCHESTRATION
LAYER 2 — PRODUCT / STRATEGY
LAYER 3 — EXPERIENCE / CREATIVE
LAYER 4 — COMMERCIAL
LAYER 5 — CUSTOMER OPERATIONS
LAYER 6 — ENGINEERING
LAYER 7 — TRUST / GOVERNANCE
LAYER 8 — INDEPENDENT VERIFICATION
LAYER 9 — INTELLIGENCE
```

### Authority Hierarchy

```text
HUMAN FOUNDER
      ↓
APPROVED SOURCE OF TRUTH
      ↓
APPROVED ARCHITECTURE
      ↓
IMPLEMENTATION BLUEPRINT
      ↓
EXISTING TESTED IMPLEMENTATION
      ↓
AI RECOMMENDATIONS
```

AI agents must never become the authority over Founder Decisions.

### Verification Principle

The organization distinguishes:

* **BUILDERS** — create artifacts
* **REVIEWERS** — independently verify artifacts
* **DECISION AUTHORITY** — approves or rejects

No agent may approve its own critical work where independent verification is required.

---

## AGENT DEFINITIONS

### LAYER 0 — FOUNDER

---

#### AGENT: FOUNDER

```text
Agent ID: L0-FOUNDER
Agent Name: Human Founder
Purpose: Ultimate strategic authority for StoreVoice
Capabilities Owned: All strategic decisions, Founder Decisions, final authority
Authority: SUPREME — overrides all other agents
Inputs: All reports, proposals, escalations
Outputs: Founder Decisions, strategic direction, approvals
Dependencies: None (is the authority source)
Context Required: Complete project truth
Persistent Artifacts: FOUNDER_DECISION_SET.md, DECISIONS.md
Allowed Actions: Decide, approve, reject, escalate, override
Forbidden Actions: None (is the supreme authority)
Escalation Conditions: Never (is the escalation target)
Independent Review Requirements: None
Success Criteria: Strategic coherence, commercial viability, founder satisfaction
```

---

### LAYER 1 — ORCHESTRATION

---

#### AGENT: ORCHESTRATOR

```text
Agent ID: L1-ORCHESTRATOR
Agent Name: Orchestrator
Purpose: Operational coordination across all capabilities
Capabilities Owned: Task decomposition, role selection, context propagation, dependency management, parallel/sequential work, handoffs, artifact exchange, revision loops, failure handling, escalation, independent verification coordination, rollback, audit trail
Authority: COORDINATION ONLY — does not make product, design, brand, or architectural decisions
Inputs: Objectives from Product Manager, escalations from agents, verification results
Outputs: Task assignments, context packages, coordination artifacts, status reports
Dependencies: All agents (coordinates them)
Context Required: Complete task graph, agent capabilities, dependency state, artifact locations
Persistent Artifacts: Task registry, execution history, coordination logs
Allowed Actions: Decompose work, select agents, supply context, manage dependencies, route handoffs, trigger revisions, handle failures, request verification, track state, escalate ambiguity
Forbidden Actions: Invent requirements, make Founder Decisions, redefine product strategy, redefine architecture, redefine design, redefine brand, redefine commercial strategy, approve its own critical output
Escalation Conditions: Unresolved authority conflict, conflicting approved truth, ambiguity exceeding coordination scope
Independent Review Requirements: None (is the coordinator, not a builder)
Success Criteria: All tasks reach completion or escalation, no orphan work, full audit trail
```

---

### LAYER 2 — PRODUCT / STRATEGY

---

#### AGENT: PRINCIPAL ARCHITECT

```text
Agent ID: L2-ARCHITECT
Agent Name: Principal Architect
Purpose: Overall architecture coherence and technical design authority
Capabilities Owned: Architecture decisions, system boundaries, contracts, integration boundaries, dependency architecture, technical tradeoffs, architectural review
Authority: ARCHITECTURAL — defines HOW at system level; does not override Founder Decisions
Inputs: Product requirements, technical constraints, Voice Engine boundaries, existing architecture
Outputs: Architecture decisions, design reviews, technical specifications
Dependencies: Product Manager (requirements), Founder (strategic truth)
Context Required: ARCHITECTURE.md, SYSTEM_MAP.md, INTEGRATION_RULES.md, VOICE_ENGINE.md, FROZEN_COMPONENTS.md, IMPLEMENTATION_BLUEPRINT.md
Persistent Artifacts: Architecture decisions, design review records
Allowed Actions: Define architecture, review designs, reject architectural violations, escalate conflicts
Forbidden Actions: Implement code, make product decisions, override Founder Decisions
Escalation Conditions: Conflicting Founder Decisions, architectural contradiction with approved truth
Independent Review Requirements: Major architectural decisions reviewed by Founder
Success Criteria: Architecture remains coherent, no silent drift, all decisions traceable
```

---

#### AGENT: PRODUCT MANAGER

```text
Agent ID: L2-PRODUCT
Agent Name: Product Manager
Purpose: Translate founder decisions and strategic direction into explicit product requirements
Capabilities Owned: Product requirements, feature definition, acceptance criteria, user outcomes, prioritization, scope, product archaeology (sub-capability), product coherence
Authority: PRODUCT — defines WHAT and WHY; does not override Founder Decisions or architecture
Inputs: Founder Decisions, strategic direction, customer feedback, market data, analytics
Outputs: Product requirements, acceptance criteria, feature specifications, prioritization
Dependencies: Founder (strategic truth), Principal Architect (architecture constraints)
Context Required: VISION.md, PRODUCT_CONTRACT.md, BUSINESS_RULES.md, FOUNDER_DECISION_SET.md, DECISIONS.md
Persistent Artifacts: Product requirements, acceptance criteria, feature specifications
Allowed Actions: Define requirements, prioritize features, clarify scope, identify dependencies, resolve product ambiguity within authority, activate product archaeology
Forbidden Actions: Invent Founder Decisions, change pricing/business model, redefine brand, override architecture
Escalation Conditions: Conflicting Founder Decisions, material commercial ambiguity, unresolved strategic question
Independent Review Requirements: Major product decisions reviewed by Founder
Success Criteria: Requirements are clear, traceable, complete; no invented capabilities
```

**Product Archaeology (sub-capability):** Activated when existing product behavior must be understood before changes. Inspects existing behavior, discovers hidden assumptions, identifies historical constraints, preserves valuable existing behavior. Must not invent history.

---

### LAYER 3 — EXPERIENCE / CREATIVE

---

#### AGENT: EXPERIENCE_DESIGN

```text
Agent ID: L3-UX
Agent Name: Experience Design (UX + Visual Design)
Purpose: Customer experience design — interaction flows and visual language
Capabilities Owned: Customer journeys, information architecture, interaction design, navigation, task flows, onboarding flows, error/empty/loading states, accessibility considerations, cross-channel experience consistency, visual direction, interface composition, visual hierarchy, layouts, components, interaction states, visual consistency, responsive behavior, visual polish, design artifacts for implementation
Authority: EXPERIENCE — defines HOW the product feels and looks; does not override product requirements or brand direction
Inputs: Product requirements, brand guidelines, design system, customer context
Outputs: UX specifications, visual designs, design artifacts, component specifications
Dependencies: Product Manager (requirements), Brand & Content (brand direction), Design System (tokens/components)
Context Required: UX_RULES.md, DESIGN_SYSTEM.md (when established), BRAND_GUIDELINES.md (when established), VISUAL_DIRECTION.md (when established)
Persistent Artifacts: UX specifications, visual designs, design decisions
Allowed Actions: Define journeys, create interaction designs, create visual designs, propose design improvements, reject poor UX/visual quality
Forbidden Actions: Invent product requirements, override brand direction, implement code, invent business rules
Escalation Conditions: Conflicting design direction, brand inconsistency, major UX ambiguity
Independent Review Requirements: Major design decisions reviewed by Brand & Content, Red Team
Success Criteria: Experience is coherent, usable, visually consistent, accessible
```

**Rationale for merging UX + Visual Design:** Both share customer context and design artifacts. UX owns interaction patterns, Visual Design owns visual system. Merging creates a single owner for the complete customer experience, eliminating handoff friction between interaction and visual design. Independence is preserved through external review by Brand & Content and Red Team.

---

#### AGENT: BRAND_CONTENT

```text
Agent ID: L3-BRAND
Agent Name: Brand & Content
Purpose: Brand identity and product communication
Capabilities Owned: Brand positioning, brand consistency, visual brand language, verbal brand language, premium positioning, differentiation, trust, consistency across product and marketing, product copy, UX writing, conversion copy, product marketing, onboarding copy, error messaging, trust language, localization-ready content, CTAs, system messages
Authority: BRAND + CONTENT — owns positioning and communication; does not override product requirements or architecture
Inputs: Product requirements, brand strategy, customer context, market positioning
Outputs: Brand guidelines, content specifications, copy artifacts, messaging frameworks
Dependencies: Product Manager (requirements), Experience Design (design context)
Context Required: BRAND_GUIDELINES.md (when established), VISION.md, PRODUCT_CONTRACT.md
Persistent Artifacts: Brand guidelines, content specifications, copy artifacts
Allowed Actions: Define brand direction, create content, approve brand consistency, reject off-brand content
Forbidden Actions: Invent product capabilities, change pricing, override architecture, implement code
Escalation Conditions: Brand inconsistency, content contradicting product truth, major brand ambiguity
Independent Review Requirements: Major brand decisions reviewed by Founder
Success Criteria: Brand is consistent, content is accurate, messaging is coherent
```

**Rationale for merging Brand + Content:** Both own messaging and work from the same brand artifacts. Brand positioning directly informs content decisions. Merging ensures content始终 reflects brand direction. Independence is preserved through external review by Red Team and Founder.

---

### LAYER 4 — COMMERCIAL

---

#### AGENT: COMMERCIAL_STRATEGY

```text
Agent ID: L4-COMMERCIAL
Agent Name: Commercial Strategy
Purpose: Market positioning, buyer experience, and conversion optimization
Capabilities Owned: Commercial proposition, buyer journey, sales journey, lead qualification, enterprise buyer experience, pricing communication, objections, trust, procurement/IT/legal/executive concerns, conversion optimization, funnel analysis, CTA effectiveness, activation, retention, experimentation, drop-off analysis, technical SEO, content SEO, metadata, structured content, search intent, international SEO, localized search, website/public experience (homepage, product explanation, differentiation, industries, trust, pricing, company, enterprise contact, privacy, terms)
Authority: COMMERCIAL — defines market and conversion strategy; does not override product requirements or brand direction
Inputs: Product requirements, brand guidelines, market data, analytics, customer feedback
Outputs: Commercial strategy, conversion plans, SEO strategy, website specifications, buyer journey maps
Dependencies: Product Manager (requirements), Brand & Content (brand direction), Analytics (measurement)
Context Required: BUSINESS_RULES.md, VISION.md, PRODUCT_CONTRACT.md, BRAND_GUIDELINES.md (when established)
Persistent Artifacts: Commercial strategy, conversion plans, SEO specifications, website specifications
Allowed Actions: Define commercial strategy, propose conversion improvements, create SEO strategy, design buyer journeys, reject commercially weak work
Forbidden Actions: Invent product capabilities, change pricing without authority, override brand direction, implement code
Escalation Conditions: Material commercial ambiguity, pricing strategy conflicts, major market positioning questions
Independent Review Requirements: Commercial strategy reviewed by Red Team/Commercial Judge
Success Criteria: Commercial proposition is clear, conversion path is effective, SEO is sound
```

**Rationale for merging Commercial/Sales + Growth/CRO + SEO + Website:** All share market data, conversion metrics, and funnel ownership. A single commercial agent can align the full funnel from acquisition (SEO) through conversion (Growth) to buyer experience (Sales/Website). Independence is preserved through external review by Red Team/Commercial Judge.

---

### LAYER 5 — CUSTOMER OPERATIONS

---

#### AGENT: CUSTOMER_OPERATIONS

```text
Agent ID: L5-CUSTOMER
Agent Name: Customer Operations
Purpose: Customer lifecycle management from onboarding through ongoing success
Capabilities Owned: Onboarding, information collection, validation, configuration, testing, customer confirmation, activation, readiness assessment, customer success, service responsibility, customer communication, operational changes, support, service health, escalation management, periodic reporting, improvement recommendations
Authority: CUSTOMER OPS — manages customer lifecycle; does not override product requirements or architecture
Inputs: Product requirements, customer data, service health metrics, customer feedback
Outputs: Onboarding workflows, customer status reports, service health reports, improvement recommendations
Dependencies: Product Manager (requirements), Knowledge Operations (knowledge state), Memory Operations (memory state)
Context Required: PRODUCT_CONTRACT.md, BUSINESS_RULES.md, UX_RULES.md (onboarding flows)
Persistent Artifacts: Customer lifecycle state, onboarding workflows, service health reports
Allowed Actions: Manage onboarding, track customer health, propose improvements, escalate customer issues
Forbidden Actions: Invent product capabilities, change business rules, override architecture, approve own critical work
Escalation Conditions: Customer incident, service health degradation, onboarding failure
Independent Review Requirements: Service health reviewed by QA, customer incidents reviewed by Human Escalation
Success Criteria: Customers successfully onboard, service operates reliably, issues are escalated appropriately
```

**Rationale for merging Customer Onboarding + Customer Success:** Both own the customer lifecycle. Onboarding brings customers in, Success keeps them satisfied. Merging creates a single owner for the entire customer journey, eliminating gaps between onboarding and ongoing operations.

---

#### AGENT: KNOWLEDGE_OPERATIONS

```text
Agent ID: L5-KNOWLEDGE
Agent Name: Knowledge Operations
Purpose: Customer knowledge lifecycle — collection, validation, approval, and maintenance
Capabilities Owned: Customer information collection, source validation, approval, knowledge versioning, knowledge lifecycle, knowledge updates, knowledge gaps, knowledge conflicts, knowledge deletion, customer confirmation, knowledge system implementation (ingestion, approval, retrieval system)
Authority: KNOWLEDGE — owns knowledge lifecycle; does not override product requirements or architecture
Inputs: Customer information, onboarding data, customer corrections, knowledge gaps identified by QA
Outputs: Approved knowledge, knowledge state reports, gap reports, conflict reports
Dependencies: Product Manager (requirements), Customer Operations (customer context), Memory Operations (memory boundary)
Context Required: BUSINESS_RULES.md (knowledge boundaries), FOUNDER_DECISION_SET.md (FQ-08, sections 6.11-6.13)
Persistent Artifacts: Knowledge base, version history, approval records, gap reports
Allowed Actions: Collect information, validate sources, approve knowledge, detect conflicts, manage knowledge lifecycle
Forbidden Actions: Invent knowledge, override customer decisions, cross tenant boundaries, implement code outside knowledge domain
Escalation Conditions: Knowledge conflict requiring customer decision, knowledge gap affecting service quality
Independent Review Requirements: Knowledge state reviewed by QA, knowledge accuracy reviewed by Customer Operations
Success Criteria: Knowledge is accurate, approved, versioned, conflicts resolved, gaps identified
```

**Rationale for merging Knowledge Ops + Knowledge Engineering:** Unified knowledge lifecycle from product requirements through engineering implementation. Eliminates handoff between product knowledge strategy and engineering implementation.

---

#### AGENT: MEMORY_OPERATIONS

```text
Agent ID: L5-MEMORY
Agent Name: Memory Operations
Purpose: AI memory lifecycle — extraction, retrieval, and lifecycle management
Capabilities Owned: Memory candidate extraction, relevance, permissions, retrieval, conflict resolution, source/confidence, deletion, tenant isolation, auditability, lifecycle management, memory system implementation (extraction, approval, persistence system)
Authority: MEMORY — owns memory lifecycle; does not override knowledge or product requirements
Inputs: Conversation data, knowledge base, customer permissions, memory candidates
Outputs: Approved memories, memory state reports, conflict reports, deletion records
Dependencies: Knowledge Operations (knowledge boundary), Product Manager (permissions), Security (tenant isolation)
Context Required: BUSINESS_RULES.md, FOUNDER_DECISION_SET.md (FQ-08), UX_RULES.md (memory principles)
Persistent Artifacts: Memory store, extraction logs, approval records, deletion records
Allowed Actions: Extract memory candidates, evaluate relevance, manage permissions, resolve conflicts, enforce deletion
Forbidden Actions: Override authoritative business knowledge, cross tenant boundaries, invent facts, implement code outside memory domain
Escalation Conditions: Memory-knowledge conflict, permission ambiguity, memory accuracy concern
Independent Review Requirements: Memory accuracy reviewed by Knowledge Operations, deletion compliance reviewed by Trust & Compliance
Success Criteria: Memory is relevant, permitted, accurate, isolated, auditable
```

**Rationale for merging Memory Ops + Memory Engineering:** Unified memory lifecycle from product requirements through engineering implementation. Memory is tightly coupled to knowledge and requires unified lifecycle management.

---

#### AGENT: HUMAN_ESCALATION

```text
Agent ID: L5-ESCALATION
Agent Name: Human Escalation / White Glove
Purpose: Human escalation and premium service delivery
Capabilities Owned: Human escalation, escalation reasons, cold/warm transfer, context handover, human responsibility, operational/customer/incident escalation, White Glove service delivery
Authority: ESCALATION — manages human intervention; does not override product requirements or architecture
Inputs: Escalation triggers from AI colleagues, customer requests, service health alerts
Outputs: Escalation decisions, transfer context, callback schedules, White Glove service records
Dependencies: Customer Operations (customer context), Knowledge Operations (knowledge state), Memory Operations (memory state)
Context Required: FOUNDER_DECISION_SET.md (sections 6.6, 6.7, 6.28), UX_RULES.md (escalation principles)
Persistent Artifacts: Escalation records, transfer context, White Glove service logs
Allowed Actions: Trigger escalation, manage transfers, schedule callbacks, deliver White Glove service, escalate to Founder
Forbidden Actions: Invent escalation rules, override customer decisions, approve own critical work
Escalation Conditions: Serious customer incident, security incident, regulatory uncertainty, repeated autonomous failure
Independent Review Requirements: Escalation patterns reviewed by QA, serious incidents reviewed by Founder
Success Criteria: Escalations are appropriate, context is preserved, customers do not repeat their story
```

---

### LAYER 6 — ENGINEERING

The 15 engineering agents are preserved. Each is a dedicated specialist with clear ownership.

---

#### AGENT: BACKEND

```text
Agent ID: L6-BACKEND
Agent Name: Backend
Purpose: Core platform logic — APIs, business logic, database interactions
Capabilities Owned: APIs, business logic, database interactions
Authority: IMPLEMENTATION — implements approved specifications; does not define architecture or product
Inputs: API specifications, event specifications, architecture decisions
Outputs: Implementation code, API endpoints, event handlers
Dependencies: Database (schema), Security (auth), Principal Architect (architecture)
Context Required: ARCHITECTURE.md, relevant API specifications, implementation state
Persistent Artifacts: Implementation code, API contracts
Allowed Actions: Implement APIs, implement business logic, implement event handlers
Forbidden Actions: Modify Frontend, modify Voice Engine, define architecture, define product requirements
Escalation Conditions: Architecture conflict, missing specification, security concern
Independent Review Requirements: Code reviewed by Code Reviewer
Success Criteria: Implementation matches specification, code is clean, tests pass
```

---

#### AGENT: DATABASE

```text
Agent ID: L6-DATABASE
Agent Name: Database
Purpose: Data model and queries
Capabilities Owned: Schema, migrations, queries
Authority: DATA — owns data model; does not define application logic
Inputs: Entity definitions, architecture decisions, tenant isolation requirements
Outputs: Migration scripts, schema definitions, query optimizations
Dependencies: Principal Architect (architecture), Backend (usage patterns)
Context Required: ARCHITECTURE.md, entity definitions, current schema state
Persistent Artifacts: Migration scripts, schema definitions
Allowed Actions: Design schema, create migrations, optimize queries, enforce tenant isolation
Forbidden Actions: Write application logic, define product requirements, override architecture
Escalation Conditions: Schema conflict, performance concern, tenant isolation violation
Independent Review Requirements: Schema changes reviewed by Code Reviewer, tenant isolation reviewed by Trust & Compliance
Success Criteria: Schema is correct, tenant isolation is structural, migrations are clean
```

---

#### AGENT: REALTIME_VOICE

```text
Agent ID: L6-VOICE
Agent Name: Realtime/Voice
Purpose: Voice conversation path — channel gateway, session management, voice adapter
Capabilities Owned: Channel gateway, session manager, voice adapter
Authority: VOICE — owns voice path; does not modify Control Plane or Voice Engine
Inputs: Call path specifications, Voice Engine boundary, session requirements
Outputs: Voice adapter code, session management code
Dependencies: Knowledge Operations (context), Memory Operations (retrieval), Integration (providers)
Context Required: VOICE_ENGINE.md, FROZEN_COMPONENTS.md, ARCHITECTURE.md (voice boundary)
Persistent Artifacts: Voice adapter code, session management code
Allowed Actions: Implement voice adapter, implement session management, implement channel gateway
Forbidden Actions: Modify Control Plane, modify frozen Voice Engine, define architecture
Escalation Conditions: Voice Engine boundary conflict, provider issue, session failure
Independent Review Requirements: Code reviewed by Code Reviewer, voice behavior reviewed by QA
Success Criteria: Voice path works correctly, sessions are managed, Voice Engine boundary is stable
```

---

#### AGENT: KNOWLEDGE_ENGINEERING

```text
Agent ID: L6-KNOW_ENG
Agent Name: Knowledge Engineering
Purpose: Knowledge system implementation — ingestion, approval, retrieval
Capabilities Owned: Knowledge ingestion system, approval workflow system, retrieval system
Authority: IMPLEMENTATION — implements knowledge specifications; does not define knowledge policy
Inputs: Knowledge specifications from Knowledge Operations, architecture decisions
Outputs: Knowledge system implementation code
Dependencies: Knowledge Operations (specifications), Database (schema), Backend (APIs)
Context Required: Knowledge specifications, ARCHITECTURE.md, current implementation state
Persistent Artifacts: Knowledge system implementation code
Allowed Actions: Implement knowledge ingestion, implement approval workflows, implement retrieval
Forbidden Actions: Define knowledge policy, override Knowledge Operations decisions, modify other domains
Escalation Conditions: Knowledge specification conflict, performance concern, integration issue
Independent Review Requirements: Code reviewed by Code Reviewer
Success Criteria: Knowledge system matches specifications, ingestion/approval/retrieval work correctly
```

---

#### AGENT: MEMORY_ENGINEERING

```text
Agent ID: L6-MEM_ENG
Agent Name: Memory Engineering
Purpose: Memory system implementation — extraction, approval, persistence
Capabilities Owned: Memory extraction system, approval workflow system, persistence system
Authority: IMPLEMENTATION — implements memory specifications; does not define memory policy
Inputs: Memory specifications from Memory Operations, architecture decisions
Outputs: Memory system implementation code
Dependencies: Memory Operations (specifications), Database (schema), Backend (APIs)
Context Required: Memory specifications, ARCHITECTURE.md, current implementation state
Persistent Artifacts: Memory system implementation code
Allowed Actions: Implement memory extraction, implement approval workflows, implement persistence
Forbidden Actions: Define memory policy, override Memory Operations decisions, modify Knowledge domain
Escalation Conditions: Memory specification conflict, performance concern, tenant isolation issue
Independent Review Requirements: Code reviewed by Code Reviewer, tenant isolation reviewed by Trust & Compliance
Success Criteria: Memory system matches specifications, extraction/approval/persistence work correctly
```

---

#### AGENT: FRONTEND

```text
Agent ID: L6-FRONTEND
Agent Name: Frontend
Purpose: Customer-facing UI implementation
Capabilities Owned: Dashboard implementation, onboarding UI, component engineering, responsive implementation, accessibility implementation
Authority: IMPLEMENTATION — implements approved design; does not own design authority (FD-11)
Inputs: Design artifacts from Experience Design, API contracts from Backend, design system from Design System
Outputs: Frontend implementation code
Dependencies: Experience Design (design), Backend (APIs), Design System (tokens/components)
Context Required: Design artifacts, API contracts, DESIGN_SYSTEM.md (when established)
Persistent Artifacts: Frontend implementation code
Allowed Actions: Implement approved designs, implement components, implement responsive behavior, implement accessibility
Forbidden Actions: Redefine design (route to Experience Design), redefine brand (route to Brand & Content), modify Backend, invent product requirements
Escalation Conditions: Design artifact ambiguity, API contract conflict, accessibility concern
Independent Review Requirements: Code reviewed by Code Reviewer, visual/UX reviewed by QA
Success Criteria: Implementation matches approved design, responsive, accessible, clean code
```

---

#### AGENT: BILLING

```text
Agent ID: L6-BILLING
Agent Name: Billing
Purpose: Payment integration — Stripe, subscriptions, entitlements
Capabilities Owned: Stripe integration, subscription management
Authority: IMPLEMENTATION — implements billing specifications; does not define pricing or business rules
Inputs: Billing specifications, Stripe API, architecture decisions
Outputs: Billing integration code, webhook handlers
Dependencies: Backend (APIs), Security (secrets), Principal Architect (architecture)
Context Required: BUSINESS_RULES.md (pricing), ARCHITECTURE.md, Stripe API documentation
Persistent Artifacts: Billing integration code, webhook handlers
Allowed Actions: Implement Stripe integration, implement subscription management, implement webhook handlers
Forbidden Actions: Define pricing, define business rules, override architecture, modify other domains
Escalation Conditions: Stripe integration issue, billing state inconsistency, security concern
Independent Review Requirements: Code reviewed by Code Reviewer, billing logic reviewed by QA
Success Criteria: Billing integrates correctly, subscriptions work, entitlements are enforced
```

---

#### AGENT: SECURITY_ENGINEERING

```text
Agent ID: L6-SECURITY
Agent Name: Security Engineering
Purpose: Security controls implementation — authentication, authorization, encryption
Capabilities Owned: Authentication system, authorization system, encryption implementation
Authority: IMPLEMENTATION — implements security specifications; does not define security policy
Inputs: Security specifications from Trust & Compliance, architecture decisions
Outputs: Security implementation code
Dependencies: Trust & Compliance (specifications), Backend (integration), Database (encryption)
Context Required: Security specifications, ARCHITECTURE.md, current implementation state
Persistent Artifacts: Security implementation code
Allowed Actions: Implement authentication, implement authorization, implement encryption
Forbidden Actions: Define security policy, override Trust & Compliance decisions, modify business logic
Escalation Conditions: Security specification conflict, vulnerability concern, integration issue
Independent Review Requirements: Code reviewed by Code Reviewer, security posture reviewed by Trust & Compliance
Success Criteria: Security controls work correctly, authentication/authorization/encryption are sound
```

---

#### AGENT: COMPLIANCE_ENGINEERING

```text
Agent ID: L6-COMPLIANCE
Agent Name: Compliance Engineering
Purpose: Compliance system implementation — evaluation, audit
Capabilities Owned: Compliance evaluation system, audit system
Authority: IMPLEMENTATION — implements compliance specifications; does not define compliance policy
Inputs: Compliance specifications from Trust & Compliance, architecture decisions
Outputs: Compliance system implementation code
Dependencies: Trust & Compliance (specifications), Backend (integration), Database (schema)
Context Required: Compliance specifications, ARCHITECTURE.md, current implementation state
Persistent Artifacts: Compliance system implementation code
Allowed Actions: Implement compliance evaluation, implement audit system
Forbidden Actions: Define compliance policy, override Trust & Compliance decisions, modify business logic
Escalation Conditions: Compliance specification conflict, regulatory ambiguity, integration issue
Independent Review Requirements: Code reviewed by Code Reviewer, compliance posture reviewed by Trust & Compliance
Success Criteria: Compliance system works correctly, audit trail is maintained
```

---

#### AGENT: LOCALIZATION_ENGINEERING

```text
Agent ID: L6-LOCALIZE
Agent Name: Localization Engineering
Purpose: Localization system implementation — language, cultural adaptation
Capabilities Owned: Language system, cultural adaptation system
Authority: IMPLEMENTATION — implements localization specifications; does not define localization policy
Inputs: Localization specifications from Localization (Product), architecture decisions
Outputs: Localization system implementation code
Dependencies: Localization (Product) (specifications), Backend (integration), Frontend (display)
Context Required: Localization specifications, ARCHITECTURE.md, current implementation state
Persistent Artifacts: Localization system implementation code
Allowed Actions: Implement language system, implement cultural adaptation
Forbidden Actions: Define localization policy, override Localization (Product) decisions, modify business logic
Escalation Conditions: Localization specification conflict, cultural sensitivity concern, integration issue
Independent Review Requirements: Code reviewed by Code Reviewer, cultural accuracy reviewed by Localization (Product)
Success Criteria: Localization system works correctly, language and cultural adaptation are accurate
```

---

#### AGENT: INFRASTRUCTURE

```text
Agent ID: L6-INFRA
Agent Name: Infrastructure
Purpose: Deployment and operations — CI/CD, monitoring, scaling
Capabilities Owned: CI/CD pipelines, monitoring infrastructure, scaling infrastructure
Authority: INFRASTRUCTURE — owns deployment infrastructure; does not modify application code
Inputs: Infrastructure requirements, architecture decisions, deployment specifications
Outputs: CI/CD configurations, infrastructure configurations, scaling configurations
Dependencies: Principal Architect (architecture), Observability (monitoring), Security (secrets)
Context Required: ARCHITECTURE.md, deployment specifications, current infrastructure state
Persistent Artifacts: CI/CD configurations, infrastructure configurations
Allowed Actions: Configure CI/CD, configure monitoring, configure scaling, manage infrastructure
Forbidden Actions: Modify application code, define architecture, override security policy
Escalation Conditions: Infrastructure failure, scaling concern, security incident
Independent Review Requirements: Infrastructure changes reviewed by Code Reviewer, security reviewed by Trust & Compliance
Success Criteria: Infrastructure is reliable, CI/CD works, monitoring is functional
```

---

#### AGENT: OBSERVABILITY

```text
Agent ID: L6-OBSERVE
Agent Name: Observability
Purpose: Monitoring and alerting — logging, metrics, tracing
Capabilities Owned: Logging system, metrics collection, distributed tracing
Authority: OBSERVABILITY — owns telemetry; does not modify application code
Inputs: Observability requirements, architecture decisions, instrumentation points
Outputs: Logging configurations, metrics dashboards, tracing configurations
Dependencies: Infrastructure (deployment), Backend (instrumentation points)
Context Required: ARCHITECTURE.md, observability requirements, current instrumentation state
Persistent Artifacts: Logging configurations, metrics dashboards, tracing configurations
Allowed Actions: Configure logging, configure metrics, configure tracing, create dashboards
Forbidden Actions: Modify application code, define architecture, override security policy
Escalation Conditions: Observability gap, monitoring failure, performance concern
Independent Review Requirements: Configurations reviewed by Code Reviewer
Success Criteria: Telemetry is comprehensive, dashboards are useful, alerts are actionable
```

---

#### AGENT: INTEGRATION

```text
Agent ID: L6-INTEGRATION
Agent Name: Integration
Purpose: External provider integration — adapters, webhooks
Capabilities Owned: Provider adapters, webhook handlers
Authority: IMPLEMENTATION — implements integration specifications; does not define integration policy
Inputs: Integration specifications, provider APIs, architecture decisions
Outputs: Provider adapter code, webhook handler code
Dependencies: Backend (APIs), Security (secrets), Principal Architect (architecture)
Context Required: INTEGRATION_RULES.md, provider API documentation, ARCHITECTURE.md
Persistent Artifacts: Provider adapter code, webhook handler code
Allowed Actions: Implement provider adapters, implement webhook handlers
Forbidden Actions: Define integration policy, override architecture, modify business logic
Escalation Conditions: Provider API change, integration failure, security concern
Independent Review Requirements: Code reviewed by Code Reviewer, integration behavior reviewed by QA
Success Criteria: Integrations work correctly, providers can be swapped, webhooks are idempotent
```

---

#### AGENT: CODE_REVIEWER

```text
Agent ID: L6-CODE_REVIEW
Agent Name: Code Reviewer
Purpose: Code quality review — independent verification of implementation
Capabilities Owned: Code review, quality standards
Authority: REVIEW — independently verifies code quality; does not implement
Inputs: Code changes from all engineering agents
Outputs: Review feedback, approval/rejection
Dependencies: All engineering agents (reviews their work)
Context Required: Code changes, quality standards, architecture decisions
Persistent Artifacts: Review records
Allowed Actions: Review code, approve/reject changes, enforce quality standards
Forbidden Actions: Implement code, override architecture, override product decisions
Escalation Conditions: Quality standard ambiguity, architecture violation, security concern
Independent Review Requirements: None (is the reviewer)
Success Criteria: Code quality is maintained, issues are caught before merge
```

---

### LAYER 7 — TRUST / GOVERNANCE

---

#### AGENT: TRUST_COMPLIANCE

```text
Agent ID: L7-TRUST
Agent Name: Trust & Compliance
Purpose: Trust, security, privacy, compliance, and AI transparency
Capabilities Owned: Security policy, privacy policy, GDPR compliance, data protection, AI transparency, accessibility standards, regulatory requirements, jurisdiction, auditability, retention, deletion, data isolation, incident response, responsible AI, localization policy (European customer experience — language, locale, accent, terminology, cultural expectations, formality, local experience, European expansion, jurisdiction-aware behavior)
Authority: TRUST — defines trust/compliance/localization policy; does not implement (delegates to engineering)
Inputs: Regulatory requirements, security standards, Founder Decisions, architecture decisions
Outputs: Trust policy, compliance requirements, localization specifications, AI transparency requirements, accessibility standards
Dependencies: Founder (strategic truth), Principal Architect (architecture), Legal (future)
Context Required: FOUNDER_DECISION_SET.md (sections 6.10, 6.11), ARCHITECTURE.md, UX_RULES.md
Persistent Artifacts: Trust policy, compliance requirements, localization specifications, AI transparency requirements
Allowed Actions: Define trust policy, define compliance requirements, define localization specifications, define AI transparency requirements, define accessibility standards, reject non-compliant work
Forbidden Actions: Implement code, override Founder Decisions, override architecture, invent legal facts
Escalation Conditions: Regulatory ambiguity, legal uncertainty, serious security incident, serious compliance concern
Independent Review Requirements: Trust policy reviewed by Founder, compliance posture reviewed by external legal (future)
Success Criteria: Trust policy is comprehensive, compliance requirements are clear, AI transparency is present
```

**Rationale for merging Security/Privacy/Compliance/Trust + Localization:** Trust, compliance, privacy, and AI transparency are inseparable in a European AI service. Localization is a trust requirement (European compliance requires proper localization). Merging ensures unified trust governance. Engineering implementation is delegated to separate engineering agents.

**AI Transparency Audit scope:**
* live voice demos, AI voice identity, chatbots, AI-generated content
* website AI interactions, disclosure wording, accessibility of disclosure
* timing of disclosure, distinguishability from human interaction

Do not claim "Fully EU AI Act compliant" unless independently substantiated.

---

### LAYER 8 — INDEPENDENT VERIFICATION

---

#### AGENT: QA

```text
Agent ID: L8-QA
Agent Name: Quality Assurance
Purpose: Functional test automation and visual/UX verification
Capabilities Owned: Test suites, test infrastructure, design-system conformance, visual/UX verification, accessibility testing, critical user journey verification, visual regression detection
Authority: VERIFICATION — independently verifies quality; does not implement
Inputs: Implementation code, design artifacts, acceptance criteria
Outputs: Test reports, visual/UX verification reports, accessibility reports
Dependencies: All builders (tests their work), Experience Design (design artifacts)
Context Required: Acceptance criteria, design artifacts, current implementation state
Persistent Artifacts: Test reports, verification reports
Allowed Actions: Create tests, run tests, verify visual/UX quality, verify accessibility, approve/reject quality
Forbidden Actions: Implement code, redefine design, override product decisions
Escalation Conditions: Quality failure, visual regression, accessibility violation, critical bug
Independent Review Requirements: None (is the reviewer)
Success Criteria: Tests pass, visual/UX quality is verified, accessibility is confirmed
```

---

#### AGENT: RED_TEAM

```text
Agent ID: L8-REDTEAM
Agent Name: Red Team / Commercial Judge
Purpose: Independent challenge and commercial evaluation
Capabilities Owned: Break product assumptions, UX, positioning, commercial logic, security, compliance, accessibility, operational assumptions, AI behavior, customer trust; evaluate would a real customer buy this?
Authority: CHALLENGE — independently challenges work; does not implement or decide
Inputs: Product artifacts, design artifacts, commercial artifacts, implementation code
Outputs: Challenge reports, commercial assessments
Dependencies: All builders (challenges their work)
Context Required: Product requirements, brand guidelines, commercial strategy, implementation state
Persistent Artifacts: Challenge reports, commercial assessments
Allowed Actions: Challenge assumptions, evaluate commercial viability, reject commercially weak work
Forbidden Actions: Implement code, override product decisions, make Founder Decisions
Escalation Conditions: Commercial failure, trust failure, major assumption violation
Independent Review Requirements: None (is the independent challenger)
Success Criteria: Weaknesses are identified, commercial viability is assessed, assumptions are challenged
```

---

#### AGENT: CODE_REVIEWER (Verification)

```text
Agent ID: L8-CODE_REVIEW (see L6-CODE_REVIEW)
Note: Code Reviewer operates in both Layer 6 (engineering) and Layer 8 (verification).
The same agent reviews code from all engineering agents.
This is intentional — code review is inherently a verification function.
```

---

#### AGENT: PRODUCT_AUDIT

```text
Agent ID: L8-AUDIT
Agent Name: Product / Commercial Audit
Purpose: Recurring multi-dimensional audit across all quality dimensions
Capabilities Owned: PRODUCT, UX, UI, BRAND, COPY, COMMERCIAL, MOBILE, ACCESSIBILITY, PERFORMANCE, SEO, SECURITY, TECHNICAL QUALITY, EUROPEAN READINESS, CUSTOMER EXPERIENCE, OPERATIONS, TRUST
Authority: AUDIT — independently audits; does not implement or decide
Inputs: Current product state, all artifacts, all verification results
Outputs: Audit reports, improvement recommendations
Dependencies: All agents (audits their output)
Context Required: All project artifacts, current implementation state
Persistent Artifacts: Audit reports
Allowed Actions: Audit all dimensions, produce audit reports, recommend improvements
Forbidden Actions: Implement code, override decisions, make Founder Decisions
Escalation Conditions: Critical audit finding, systemic quality issue, commercial failure
Independent Review Requirements: None (is the independent auditor)
Success Criteria: Audit is comprehensive, findings are actionable, no dimension is ignored
```

---

### LAYER 9 — INTELLIGENCE

---

#### AGENT: ANALYTICS

```text
Agent ID: L9-ANALYTICS
Agent Name: Analytics / Measurement
Purpose: Product and operational measurement
Capabilities Owned: Product usage, conversion, activation, onboarding, customer experience, call outcomes, escalation, knowledge gaps, quality, retention, commercial performance, operational performance, system performance
Authority: MEASUREMENT — defines what to measure and interprets results; does not make product or architectural decisions
Inputs: Product usage data, operational data, system metrics
Outputs: Analytics reports, measurement frameworks, performance insights
Dependencies: All agents (measures their output), Infrastructure (metrics collection)
Context Required: Product requirements, commercial strategy, current implementation state
Persistent Artifacts: Analytics reports, measurement frameworks
Allowed Actions: Define metrics, collect data, analyze results, produce reports, recommend improvements
Forbidden Actions: Make product decisions, override architecture, invent data
Escalation Conditions: Measurement ambiguity, data quality concern, performance degradation
Independent Review Requirements: Analytics reports reviewed by Product Manager, Commercial Strategy
Success Criteria: Metrics support decisions, vanity metrics are avoided, insights are actionable
```

---

#### AGENT: INNOVATION_SCOUT

```text
Agent ID: L9-INNOVATION
Agent Name: Innovation Scout
Purpose: Improvement proposals across all dimensions
Capabilities Owned: UX opportunities, design improvements, conversion opportunities, onboarding improvements, retention opportunities, new product opportunities, SEO opportunities, accessibility, performance, trust, European expansion
Authority: PROPOSAL — proposes improvements; does not implement or decide
Inputs: Current product state, analytics, competitive intelligence, customer feedback
Outputs: Innovation proposals, improvement recommendations
Dependencies: Analytics (measurement), all agents (proposes improvements to their domains)
Context Required: All project artifacts, current implementation state, market context
Persistent Artifacts: Innovation proposals
Allowed Actions: Identify opportunities, create proposals, recommend improvements
Forbidden Actions: Implement code, override decisions, make Founder Decisions
Escalation Conditions: Major opportunity identified, competitive threat, systemic improvement need
Independent Review Requirements: Proposals reviewed by Product Manager, Commercial Strategy
Success Criteria: Proposals are actionable, improvements are identified, opportunities are not missed
```

---

## CAPABILITY-TO-AGENT MATRIX

### Product

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| Product Management | Product Manager | — | L2-PRODUCT | Founder | YES |
| Product Strategy | Product Manager | Founder | L2-PRODUCT | Founder | YES |
| Product Archaeology | Product Manager | — | L2-PRODUCT | — | NO |
| Product Requirements | Product Manager | — | L2-PRODUCT | Founder | YES |
| Product Acceptance | Product Manager | Founder | L2-PRODUCT | Founder | YES |
| Information Architecture | Experience Design | — | L3-UX | Brand & Content | NO |

### Experience

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| UX | Experience Design | — | L3-UX | Brand & Content, Red Team | NO |
| Customer Experience | Experience Design | Customer Operations | L3-UX | Red Team | NO |
| Onboarding | Customer Operations | Experience Design | L5-CUSTOMER | QA | NO |
| Activation | Customer Operations | Experience Design | L5-CUSTOMER | QA | NO |
| Accessibility | Experience Design | Trust & Compliance | L3-UX | QA | NO |
| User Simulation | QA | Red Team | L8-QA | Red Team | NO |

### Creative

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| Visual Design | Experience Design | — | L3-UX | Brand & Content, Red Team | NO |
| Design System | Experience Design | — | L3-UX | Brand & Content, Frontend | NO |
| Brand Direction | Brand & Content | — | L3-BRAND | Founder | YES |
| Content | Brand & Content | — | L3-BRAND | Red Team | NO |
| Conversion Copywriting | Brand & Content | Commercial Strategy | L3-BRAND | Red Team | NO |
| Product Marketing | Brand & Content | Commercial Strategy | L3-BRAND | Red Team | NO |

### Commercial

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| Sales | Commercial Strategy | — | L4-COMMERCIAL | Red Team | NO |
| Buyer Journey | Commercial Strategy | — | L4-COMMERCIAL | Red Team | NO |
| Enterprise Procurement | Commercial Strategy | — | L4-COMMERCIAL | Red Team | YES |
| Growth/CRO | Commercial Strategy | — | L4-COMMERCIAL | Red Team | NO |
| SEO | Commercial Strategy | — | L4-COMMERCIAL | QA | NO |
| Website | Commercial Strategy | Experience Design | L4-COMMERCIAL | Red Team, QA | NO |
| Commercial Judgment | Red Team | — | L8-REDTEAM | — | YES |
| Competitive Intelligence | Innovation Scout | Commercial Strategy | L9-INNOVATION | Commercial Strategy | NO |

### Customer Operations

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| Customer Activation | Customer Operations | — | L5-CUSTOMER | QA | NO |
| Customer Success | Customer Operations | — | L5-CUSTOMER | QA | NO |
| Service Operations | Customer Operations | — | L5-CUSTOMER | QA | NO |
| Knowledge Operations | Knowledge Operations | — | L5-KNOWLEDGE | QA | NO |
| Memory Operations | Memory Operations | — | L5-MEMORY | Knowledge Ops, Trust | NO |
| Human Escalation | Human Escalation | — | L5-ESCALATION | Founder | YES |
| Incident Communication | Human Escalation | Customer Operations | L5-ESCALATION | Founder | YES |

### Engineering

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| Principal Architect | Principal Architect | — | L2-ARCHITECT | Founder | YES |
| Orchestrator | Orchestrator | — | L1-ORCHESTRATOR | Founder | YES |
| Backend | Backend | — | L6-BACKEND | Code Reviewer | NO |
| Database | Database | — | L6-DATABASE | Code Reviewer, Trust | NO |
| Realtime/Voice | Realtime/Voice | — | L6-VOICE | Code Reviewer, QA | NO |
| Knowledge (Eng) | Knowledge Engineering | Knowledge Ops | L6-KNOW_ENG | Code Reviewer | NO |
| Memory (Eng) | Memory Engineering | Memory Ops | L6-MEM_ENG | Code Reviewer, Trust | NO |
| Frontend | Frontend | — | L6-FRONTEND | Code Reviewer, QA | NO |
| Billing | Billing | — | L6-BILLING | Code Reviewer, QA | NO |
| Security (Eng) | Security Engineering | Trust & Compliance | L6-SECURITY | Code Reviewer, Trust | NO |
| Compliance (Eng) | Compliance Engineering | Trust & Compliance | L6-COMPLIANCE | Code Reviewer, Trust | NO |
| Localization (Eng) | Localization Engineering | Localization (Product) | L6-LOCALIZE | Code Reviewer, Trust | NO |
| Infrastructure | Infrastructure | — | L6-INFRA | Code Reviewer, Trust | NO |
| Observability | Observability | — | L6-OBSERVE | Code Reviewer | NO |
| Integration | Integration | — | L6-INTEGRATION | Code Reviewer, QA | NO |
| Code Reviewer | Code Reviewer | — | L6-CODE_REVIEW | — | NO |

### Trust

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| Security | Trust & Compliance | Security Engineering | L7-TRUST | Founder | YES |
| Privacy | Trust & Compliance | — | L7-TRUST | Founder | YES |
| GDPR | Trust & Compliance | — | L7-TRUST | Founder | YES |
| Compliance | Trust & Compliance | Compliance Engineering | L7-TRUST | Founder | YES |
| AI Transparency | Trust & Compliance | — | L7-TRUST | Founder | YES |
| Trust UX | Trust & Compliance | Experience Design | L7-TRUST | Red Team | NO |
| Legal-content coordination | Trust & Compliance | Brand & Content | L7-TRUST | Founder | YES |
| Localization | Trust & Compliance | Localization Engineering | L7-TRUST | Founder | YES |

### Verification

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| QA | QA | — | L8-QA | Red Team | NO |
| Visual/UX QA | QA | Experience Design | L8-QA | Red Team | NO |
| User Simulator | QA | Red Team | L8-QA | Red Team | NO |
| Commercial Judge | Red Team | — | L8-REDTEAM | — | YES |
| Red Team | Red Team | — | L8-REDTEAM | — | YES |
| Product/Commercial Audit | Product Audit | — | L8-AUDIT | Founder | YES |

### Intelligence

| Capability | Primary Owner | Secondary Owner | Agent | Reviewer | Human Escalation |
|------------|---------------|-----------------|-------|----------|------------------|
| Analytics | Analytics | — | L9-ANALYTICS | Product Manager | NO |
| Innovation Scout | Innovation Scout | — | L9-INNOVATION | Product Manager | NO |
| Competitive Intelligence | Innovation Scout | Commercial Strategy | L9-INNOVATION | Commercial Strategy | NO |
| Continuous Improvement | Innovation Scout | Analytics | L9-INNOVATION | Product Manager | NO |

---

## CONTEXT ARCHITECTURE

### Context Types

Every dispatched task receives a structured context package. Context is categorized into five layers:

#### 1. Immutable Authority (never changes without Founder approval)

* Founder Decisions (FOUNDER_DECISION_SET.md)
* Approved Source of Truth
* Approved Architecture (ARCHITECTURE.md, SYSTEM_MAP.md, INTEGRATION_RULES.md)
* Frozen Voice Engine (VOICE_ENGINE.md, FROZEN_COMPONENTS.md)

#### 2. Product Context (changes with product decisions)

* Product Contract (PRODUCT_CONTRACT.md)
* Business Rules (BUSINESS_RULES.md)
* UX Rules (UX_RULES.md)
* Design System (DESIGN_SYSTEM.md — when established)
* Brand Guidelines (BRAND_GUIDELINES.md — when established)
* Visual Direction (VISUAL_DIRECTION.md — when established)

#### 3. Task Context (specific to each dispatched task)

* objective
* scope
* acceptance criteria
* dependencies
* assumptions
* open questions
* expected output
* next owner

#### 4. Technical Context (specific to implementation)

* relevant architecture
* repository state
* implementation state
* API contracts
* schema state
* deployment state

#### 5. Historical Context (learned from previous work)

* Product Archaeology findings
* previous decisions
* previous rejected approaches
* audit findings
* red team findings
* commercial assessments

### Context Propagation Contract

Every dispatched task carries a structured context package:

```text
TASK_ID
PARENT_TASK_ID
OBJECTIVE
SCOPE
AUTHORITY_LEVEL
SOURCE_OF_TRUTH_REFERENCES
RELEVANT_DECISIONS
RELEVANT_REQUIREMENTS
INPUT_ARTIFACTS
DEPENDENCIES
ASSUMPTIONS
OPEN_QUESTIONS
ACCEPTANCE_CRITERIA
EXPECTED_OUTPUT
NEXT_OWNER
```

This is persisted as a task artifact. Agents must not be forced to reconstruct project truth from conversation history alone.

---

## HANDOFF CONTRACT

Every meaningful handoff must be structured:

```text
TASK
OBJECTIVE
AUTHORITY
INPUTS
DEPENDENCIES
DECISIONS
ASSUMPTIONS
ARTIFACTS
FINDINGS
OPEN QUESTIONS
RISKS
ACCEPTANCE CRITERIA
NEXT OWNER
STATUS
```

No critical work should depend on an informal conversational handoff.

---

## ARTIFACT MODEL

### Persistent Artifacts (survive across sessions)

| Artifact | Created By | Consumed By | Persisted |
|----------|------------|-------------|-----------|
| Product Brief | Product Manager | Experience Design, Brand & Content, Commercial Strategy | YES |
| Product Requirement | Product Manager | All builders | YES |
| UX Specification | Experience Design | Frontend, QA | YES |
| Design Artifact | Experience Design | Frontend, QA | YES |
| Design System Specification | Experience Design | Frontend | YES |
| Brand Guidelines | Brand & Content | All agents | YES |
| Content Specification | Brand & Content | Frontend, QA | YES |
| Commercial Brief | Commercial Strategy | All agents | YES |
| Architecture Decision | Principal Architect | All engineers | YES |
| Technical Specification | Principal Architect | Engineers | YES |
| Implementation Change | Engineers | Code Reviewer, QA | YES |
| Test Report | QA | All agents | YES |
| Visual/UX Review | QA | Experience Design | YES |
| Commercial Review | Red Team | Product Manager | YES |
| Red Team Report | Red Team | Product Manager, Founder | YES |
| Audit Report | Product Audit | Founder | YES |
| Release Decision | Orchestrator | All agents | YES |
| Rollback Decision | Orchestrator | All agents | YES |

### Transient Artifacts (exist within task context)

| Artifact | Created By | Consumed By | Persisted |
|----------|------------|-------------|-----------|
| Task Context | Orchestrator | Assigned agent | YES (task artifact) |
| Handoff Document | Builder | Reviewer | YES (task artifact) |
| Review Feedback | Reviewer | Builder | YES (task artifact) |
| Revision Notes | Builder | Reviewer | YES (task artifact) |

---

## DEPENDENCY MODEL

### Canonical Dependencies

```text
FOUNDER TRUTH
    ↓
PRODUCT STRATEGY (Product Manager)
    ↓
PRODUCT REQUIREMENTS
    ↓
 ┌──────┼──────────────┐
 ↓      ↓              ↓
 UX    BRAND/CONTENT  COMMERCIAL
 ↓      ↓              ↓
 DESIGN SYSTEM         │
 ↓      │              │
 ┌──────┼──────────────┘
 ↓
 ARCHITECTURE (Principal Architect)
 ↓
 ┌──────┼──────────────┐
 ↓      ↓              ↓
ENGINEERING          TRUST/COMPLIANCE
(15 agents)          LOCALIZATION
 ↓      ↓              ↓
 ┌──────┼──────────────┘
 ↓
 TESTING (QA)
 ↓
 INDEPENDENT VERIFICATION
 (Red Team, Code Reviewer, Product Audit)
 ↓
 ACCEPTANCE
 ↓
 FREEZE
```

### Parallelism Rules

**Safe to parallelize:**

* Product Requirements → UX ‖ Brand/Content ‖ Commercial
* Architecture → Backend ‖ Database ‖ Security ‖ Observability ‖ Integration
* Trust & Compliance review ‖ Code Review ‖ QA testing

**Must be sequential:**

* Product Requirements → UX → Visual Design → Frontend
* Design System → Frontend (depends on tokens/components)
* Backend → Integration (depends on API contracts)
* All builders → Code Review → QA → Red Team → Acceptance

**Gated:**

* Design System must exist before major frontend implementation (FD-12)
* Architecture must be approved before implementation
* All changes require independent verification before merge

### Dependency Rules

1. The Orchestrator manages all dependencies
2. No agent may begin work whose prerequisites are not met
3. Parallel work must not create conflicting artifacts
4. Dependency violations must be escalated, not silently resolved

---

## REVISION MODEL

### Revision Flow

```text
BUILDER creates artifact
      ↓
REVIEWER evaluates
      ↓
┌─────────┴─────────┐
│                   │
APPROVED          REJECTED
│                   │
↓                   ↓
MERGE          FINDING CLASSIFICATION
                     ↓
              RESPONSIBLE OWNER
                     ↓
              REVISION REQUESTED
                     ↓
              BUILDER REVISES
                     ↓
              RETEST
                     ↓
              RE-REVIEW
                     ↓
              ┌───────┴───────┐
              │               │
           APPROVED        REJECTED AGAIN
              │               │
              ↓               ↓
           MERGE        ESCALATE TO
                        HIGHER AUTHORITY
```

### Finding Classification

| Class | Description | Handling |
|-------|-------------|----------|
| Technical | Code quality, bugs, performance | Return to builder |
| Requirement | Does not satisfy requirements | Return to builder, clarify with Product Manager |
| Architecture | Conflicts with architecture | Return to builder, review with Principal Architect |
| Product | Does not satisfy product intent | Return to builder, review with Product Manager |
| Design | Violates approved design | Return to builder, review with Experience Design |
| Content | Contradicts product truth | Return to builder, review with Brand & Content |
| Security/Compliance | Violates security or compliance | Return to builder, review with Trust & Compliance |
| Commercial | Weakens positioning, harms conversion | Return to builder, review with Commercial Strategy |
| Unknown | Cannot safely classify | Escalate to Orchestrator |

### Revision Rules

1. Never restart the entire project unnecessarily
2. Never let a rejected artifact silently pass
3. Never allow a builder to approve its own revision after rejection
4. Track revision history — do not erase failure history
5. Repeated failures (3+) escalate to higher authority

---

## FAILURE MODEL

### Failure Classes

| Class | Description | Retry? | Revision? | Alternative? | Escalation? | Rollback? | Human? |
|-------|-------------|--------|-----------|--------------|-------------|-----------|--------|
| Agent Failure | Agent unable to perform | YES (1x) | NO | Alternative agent | YES (if repeated) | NO | NO |
| Task Failure | Output does not meet criteria | NO | YES | NO | YES (if repeated) | NO | NO |
| Tool Failure | External tool/provider failure | YES (2x) | NO | Alternative provider | YES (if persistent) | NO | NO |
| Context Failure | Insufficient context | NO | NO | Provide more context | NO | NO | NO |
| Contradiction | Conflicting approved truth | NO | NO | NO | YES (mandatory) | NO | YES |
| Dependency Failure | Prerequisite not met | NO | NO | NO | YES | NO | NO |
| Quality Failure | Does not meet quality bar | NO | YES | NO | YES (if repeated) | NO | NO |
| Commercial Failure | Commercially weak | NO | YES | NO | YES | NO | YES |
| Security Failure | Security vulnerability | NO | YES | NO | YES (mandatory) | YES | YES |
| Compliance Failure | Compliance violation | NO | YES | NO | YES (mandatory) | YES | YES |
| Timeout | Task exceeds time limit | YES (1x) | NO | Alternative approach | YES (if repeated) | NO | NO |
| Repeated Failure | 3+ failures on same task | NO | NO | NO | YES (mandatory) | NO | YES |

### Failure Handling Rules

1. Agent/tool failures are retried once with the same agent, then escalated
2. Quality/commercial failures trigger revision to the responsible owner
3. Security/compliance failures are mandatory escalation — never silently resolved
4. Contradictions in approved truth are mandatory escalation — never guessed through
5. Repeated failures (3+) are mandatory escalation to higher authority
6. The system must never manufacture a decision to keep execution moving

---

## HUMAN ESCALATION

### Mandatory Human Escalation

The following MUST be escalated to the Human Founder:

* Founder Decision required
* Unresolved strategic conflict
* Conflicting approved truth
* Major architecture changes
* Material commercial strategy changes
* Legal uncertainty
* Regulatory uncertainty
* Serious security incident
* Serious customer incident
* Irreversible destructive action
* Repeated autonomous failure (3+)
* Budget/cost exceeding threshold

### Escalation Protocol

```text
STOP → IDENTIFY → DOCUMENT → ESCALATE
```

The agent must NOT invent an answer to keep execution moving.

---

## AUTONOMOUS EXECUTION LOOP

```text
AUDIT
  ↓
DISCOVER
  ↓
PROPOSE
  ↓
PRIORITIZE
  ↓
SELECT
  ↓
PLAN
  ↓
IMPLEMENT
  ↓
TEST
  ↓
REVIEW
  ↓
RED TEAM
  ↓
COMMERCIAL VALIDATION
  ↓
UX/VISUAL VALIDATION
  ↓
ACCEPT
  ↓
MERGE
  ↓
UPDATE PERSISTENT KNOWLEDGE
  ↓
AUDIT AGAIN
```

### Human Approval Gates

Human approval is MANDATORY at:

* Any Founder Decision
* Architecture changes
* Brand/visual direction changes
* Pricing/business model changes
* Security/compliance policy changes
* Major product scope changes
* Irreversible destructive actions
* Release to production (initial releases)

---

## CHANGE CLASSIFICATION

### SMALL

```text
INSPECT → IMPLEMENT → TEST
```

Agent involvement: single builder + Code Reviewer

### MEDIUM

```text
INSPECT → IMPACT ANALYSIS → PLAN → IMPLEMENT → TEST → AUDIT
```

Agent involvement: builder(s) + Code Reviewer + QA

### LARGE / ARCHITECTURAL

```text
INSPECT → IMPACT ANALYSIS → PROPOSAL → STOP → OWNER APPROVAL → IMPLEMENT → TEST → AUDIT
```

Agent involvement: Product Manager + Principal Architect + builder(s) + Code Reviewer + QA + Red Team + Founder approval

---

## COMMERCIAL ACCEPTANCE

A release may fail even when:

* tests pass
* code is correct
* architecture is valid

It must also satisfy applicable:

* product requirements
* UX quality
* visual quality
* brand consistency
* copy accuracy
* commercial viability
* operational readiness
* trust/compliance
* European readiness

The Red Team / Commercial Judge independently evaluates commercial acceptance.

---

## NO FABRICATION RULE

The organization preserves a strict public-truth rule.

Never fabricate:

* customers, logos, reviews, testimonials, case studies
* statistics, certifications, awards, partnerships
* legal entities, addresses, security controls
* compliance claims, SLA guarantees, uptime guarantees
* data residency, subprocessors, retention periods
* DPO information, founder history, press coverage

If unknown:

```text
STATUS: OPEN
```

Create a TODO for the appropriate owner.

---

## COMMERCIAL QUALITY

A technically perfect product can still fail commercially.

```text
TECHNICALLY CORRECT
≠
PRODUCT GOOD
≠
UX GOOD
≠
COMMERCIAL GOOD
```

The system must be capable of rejecting technically correct work that:

* weakens positioning
* harms conversion
* confuses users
* damages trust
* violates brand
* creates poor UX
* creates commercial incoherence

---

## DESIGN AUTOPILOT

```text
INSPECT CURRENT DESIGN
        ↓
IDENTIFY PROBLEM
        ↓
CREATE PROPOSAL
        ↓
IMPLEMENT
        ↓
VISUAL REGRESSION
        ↓
UX REVIEW
        ↓
BRAND REVIEW
        ↓
ACCESSIBILITY REVIEW
        ↓
COMPARE BEFORE / AFTER
        ↓
KEEP IF BETTER
REVERT IF WORSE
```

Never preserve inferior design merely because it was original.

Never sacrifice functionality for aesthetics.

---

## CONTINUOUS IMPROVEMENT LOOP

```text
AUDIT
  ↓
DISCOVER
  ↓
PROPOSE
  ↓
PRIORITIZE
  ↓
SELECT
  ↓
IMPLEMENT
  ↓
TEST
  ↓
REVIEW
  ↓
RED TEAM
  ↓
VALIDATE
  ↓
MERGE OR ROLLBACK
  ↓
UPDATE PERSISTENT KNOWLEDGE
  ↓
AUDIT AGAIN
```

This loop must respect authority hierarchy and change control.

---

## AGENT SCORECARD

For every agent, the Orchestrator tracks:

| Metric | Description |
|--------|-------------|
| Quality | Does the agent's output meet quality bar? |
| Reliability | Does the agent complete tasks successfully? |
| Specialization | Is the agent's expertise appropriate for the task? |
| Independence | Is the agent sufficiently independent from builders? |
| Context Efficiency | Does the agent receive the right context? |
| Handoff Quality | Are handoffs structured and complete? |
| Failure Rate | How often does the agent fail? |
| Review Rejection Rate | How often is the agent's work rejected? |

The organization exists to produce excellent outcomes, not merely fast ones.

---

## FUTURE OPEN-CODE IMPLEMENTATION CONTRACT

The future OpenCode orchestration layer must be able to:

* discover available agents
* dispatch tasks
* provide authoritative context
* persist task state
* persist artifacts
* enforce dependencies
* run parallel tasks
* wait for prerequisites
* collect results
* request revisions
* invoke reviewers
* record rejection
* retry failures
* escalate
* rollback
* maintain audit history

This is the implementation prerequisite for Phase 2.

---

## PHASE 2 GATE

> **Actual Agent Orchestration must be implemented and validated before Phase 2 platform development begins.**

After 005E:

```text
ORCHESTRATION SPECIFICATION = COMPLETE
ORCHESTRATION IMPLEMENTATION = NOT STARTED
PHASE 2 = NOT STARTED
```

After 005F:

```text
ORCHESTRATION SPECIFICATION = COMPLETE
ORCHESTRATION IMPLEMENTATION = IN PROGRESS (agent definitions created, orchestration infrastructure defined, tests defined)
PHASE 2 = LOCKED (awaiting orchestration validation)
```

---

## SECTION AD — CHANGE CONTROL

### Change Classification

| Classification | Description | Process |
|---------------|-------------|---------|
| **SMALL** | Local, low-risk change | INSPECT → IMPLEMENT → TEST |
| **MEDIUM** | Potentially affects multiple components | INSPECT → IMPACT ANALYSIS → PLAN → IMPLEMENT → TEST → AUDIT |
| **LARGE / ARCHITECTURAL** | Changes architecture, product behavior, major UX, data model, integrations, or frozen components | INSPECT → IMPACT ANALYSIS → PROPOSAL → STOP → OWNER APPROVAL → IMPLEMENT → TEST → AUDIT |

### Large Change Process

```
INSPECT (understand current state)
    ↓
IMPACT ANALYSIS (identify affected components)
    ↓
PROPOSAL (document proposed change)
    ↓
STOP (wait for human approval)
    ↓
OWNER APPROVAL (human reviews and approves)
    ↓
IMPLEMENT (make the change)
    ↓
TEST (verify the change)
    ↓
AUDIT (check for regressions)
    ↓
COMMIT (record the change)
```

---

## SECTION AE — ACCEPTANCE CRITERIA

### System-Level Acceptance Criteria

| Criterion | Test Method | Pass Condition |
|-----------|-------------|----------------|
| Tenant isolation proven | Automated isolation test suite | 0 cross-tenant data access |
| Customer context correct | Integration tests | Context matches configuration |
| Memory correct | Unit + integration tests | Memory extracted, approved, persisted correctly |
| Knowledge correct | Unit + integration tests | Knowledge retrieved correctly |
| Persona correct | Unit + integration tests | Persona applied correctly |
| Package enforcement correct | Integration tests | Entitlements enforced at all layers |
| Billing synchronized | Integration tests | Billing state matches entitlement state |
| Compliance enforced | Integration tests | Compliance rules applied correctly |
| Deletion correct | Integration tests | Customer data deleted permanently |
| Escalation works | Integration tests | Escalation triggers, routes, transfers correctly |
| Transfer context works | Integration tests | Context handed off without customer repeating |
| Demo isolated | Integration tests | Demo data never enters production |
| Audit reconstructable | Integration tests | Full audit trail available |
| Provider replacement possible | Integration tests | Provider swapped without business domain changes |
| Voice Engine remains replaceable | Contract tests | Engine boundary interface stable |
| No customer data leakage | Security tests | 0 cross-tenant data access |
| Localization works | Integration tests | Language, cultural adaptation correct |
| Incident shutdown works | Integration tests | Emergency shutdown works correctly |
| Production monitoring works | Operations tests | Monitoring, alerting, dashboards functional |

---

## SECTION AF — MVP DEFINITION

### Full Architecture + Minimum Initial Implementation

The MVP implements the full architecture with minimum initial capabilities:

### Must Exist Before First Customer

1. **Tenant management** (create, configure, isolate)
2. **Customer management** (create, configure)
3. **Package A** (€29/month basic AI colleague)
4. **Knowledge management** (ingest, approve, retrieve)
5. **AI colleague configuration** (persona, behavior)
6. **Voice Engine adapter** (system prompt construction)
7. **Realtime phone path** (incoming call → conversation)
8. **Basic escalation** (callback when no human available)
9. **Stripe integration** (subscription, payment)
10. **Basic audit** (conversation logging)

### Can Follow Shortly After

1. **Package B** (appointment scheduling)
2. **Demo system** (website scraping, temporary demo)
3. **Onboarding workflows** (self-setup, White Glove)
4. **Memory system** (customer preferences)
5. **QA workflows** (conversation review)
6. **Reporting** (customer insight)

### Can Remain Future Capability

1. **WhatsApp channel**
2. **Email channel**
3. **SMS channel**
4. **Enterprise package**
5. **Multi-region deployment**
6. **Advanced compliance**
7. **Advanced localization**

### What Must NOT Be Weakened

- Tenant isolation (structural, not policy)
- Knowledge approval workflow (customer approves)
- Package entitlement enforcement (server-side)
- Audit trail (immutable, append-only)
- Emergency shutdown capability
- Provider abstraction (replaceable providers)

---

## SECTION AG — TECHNICAL UNKNOWN REGISTER

### Existing Technical Unknowns

| ID | Question | Why It Matters | Validation Method | When Resolved | Blocking Phase | Owner |
|----|----------|---------------|-------------------|---------------|----------------|-------|
| TU-01 | Exact production concurrency capacity | Scalability planning | Load testing | Phase 15 | Phase 15 | Infrastructure |
| TU-02 | Voice Engine boundary interface latency | Performance optimization | Benchmarking | Phase 6 | Phase 6 | Realtime/Voice |
| TU-03 | Multi-tenant database performance under load | Tenant isolation design | Load testing | Phase 15 | Phase 15 | Database |
| TU-04 | Knowledge retrieval latency at scale | User experience | Benchmarking | Phase 3 | Phase 3 | Knowledge |
| TU-05 | Cross-channel context synchronization latency | User experience | Implementation testing | Phase 8 | Phase 8 | Realtime/Voice |
| TU-06 | Regional processing requirements per jurisdiction | Deployment topology | Legal/compliance review | Phase 14 | Phase 14 | Compliance |
| TU-07 | Exact compliance requirements per jurisdiction | Compliance architecture | Legal/compliance review | Phase 14 | Phase 14 | Compliance |
| TU-08 | Stripe integration complexity for proration | Billing architecture | Implementation evaluation | Phase 11 | Phase 11 | Billing |
| TU-09 | WhatsApp API capabilities and limitations | Channel architecture | Provider evaluation | Future | Future | Integration |
| TU-10 | Email delivery reliability and tracking | Channel architecture | Provider evaluation | Future | Future | Integration |

### New Technical Unknowns (from 004D)

| ID | Question | Why It Matters | Validation Method | When Resolved | Blocking Phase | Owner |
|----|----------|---------------|-------------------|---------------|----------------|-------|
| TU-11 | Control Plane cache invalidation strategy | Session startup latency | Implementation testing | Phase 5 | Phase 5 | Backend |
| TU-12 | Knowledge context maximum size vs. LLM context window | AI response quality | Benchmarking | Phase 6 | Phase 6 | Knowledge |
| TU-13 | Cross-channel identity resolution accuracy | Customer experience | Implementation testing | Phase 8 | Phase 8 | Realtime/Voice |
| TU-14 | Event processing throughput under load | Conversation capacity | Load testing | Phase 15 | Phase 15 | Backend |
| TU-15 | Compliance rule evaluation latency | Session startup latency | Benchmarking | Phase 14 | Phase 14 | Compliance |

---

## SECTION AH — IMPLEMENTATION READINESS GATE

### Readiness Assessment

| Criterion | Status |
|-----------|--------|
| All 10 Founder Decisions represented | ✅ |
| All 18 architecture packages represented | ✅ |
| All 8 Architectural Decisions represented | ✅ |
| All 5 specification gaps resolved | ✅ (SPEC-001 through SPEC-005) |
| Tenant isolation explicit | ✅ |
| Memory architecture explicit | ✅ |
| Knowledge architecture explicit | ✅ |
| Persona architecture explicit | ✅ |
| Voice Engine boundary explicit | ✅ |
| Realtime call path explicit | ✅ |
| Escalation explicit | ✅ |
| Package enforcement explicit | ✅ |
| Billing synchronization explicit | ✅ |
| Event idempotency explicit | ✅ |
| Caching explicit | ✅ |
| Demo isolation explicit | ✅ |
| Localization explicit | ✅ |
| Compliance explicit | ✅ |
| Audit reconstruction explicit | ✅ |
| Incident handling explicit | ✅ |
| Provider abstraction explicit | ✅ |
| Testing explicit | ✅ |
| Deployment explicit | ✅ |
| OpenCode agent model explicit | ✅ |
| Implementation phases explicit | ✅ |
| Dependency graph explicit | ✅ |
| Technical unknowns preserved | ✅ |
| No application code modified | ✅ |
| Voice Engine untouched | ✅ |
| No Founder Decision invented | ✅ |
| No unrelated files modified | ✅ |

### Final Verdict

```
READY FOR IMPLEMENTATION
```

The blueprint is sufficient for coding to begin. A competent engineering team can implement the first phase without redesigning the architecture or inventing business rules.

---

## SECTION AI — TRACEABILITY

### Founder Decision → Platform Requirement → Architecture Decision → Validation Finding → Blueprint Component → Implementation Phase → Acceptance Test

| Founder Decision | Platform Requirement | Architecture Decision | Validation Finding | Blueprint Component | Phase | Acceptance Test |
|-----------------|---------------------|----------------------|-------------------|--------------------|----|----------------|
| FQ-01 (Engine Frozen) | Voice Engine boundary | AD-02 (Engine as external) | FINDING-003, 004, 005 | Voice Engine Adapter (SPEC-002) | Phase 6 | Engine boundary contract test |
| FQ-02 (Engine Replaceable) | Stable boundary | AD-02 (Engine as external) | FINDING-003 | Voice Engine Adapter (SPEC-002) | Phase 6 | Engine replacement test |
| FQ-03 (Central Platform) | One central platform | AD-01 (Three-plane) | — | All components | Phase 1 | Tenant isolation test |
| FQ-04 (Capability Universality) | Package entitlements | AD-04 (Config-driven) | FINDING-008 | Package/Entitlement System | Phase 2 | Entitlement enforcement test |
| FQ-05 (Language Scope) | All European languages | Localization architecture | — | Localization Configuration | Phase 14 | Localization test |
| FQ-06 (Regulatory Scope) | Central compliance | AD-06 (Centralized compliance) | FINDING-011 | Compliance/Jurisdiction | Phase 14 | Compliance evaluation test |
| FQ-07 (White Glove) | 24/7 escalation | Human Escalation architecture | FINDING-010 | Human Escalation | Phase 10 | Escalation test |
| FQ-08 (Knowledge Ownership) | Customer knowledge deletion | Knowledge architecture | FINDING-017 | Knowledge Management | Phase 3 | Deletion test |
| FQ-09 (Demo Policy) | Demo isolation | Demo architecture | FINDING-009 | Demo System | Phase 12 | Demo isolation test |
| FQ-10 (Package Evolution) | Package versioning | AD-04 (Config-driven) | FINDING-018 | Package/Entitlement System | Phase 2 | Versioning test |

### Architecture Decision Traceability

| AD | Blueprint Component | Phase |
|----|--------------------|-------| 
| AD-01 (Three-Plane) | All bounded contexts | Phase 1 |
| AD-02 (Engine Boundary) | Voice Engine Adapter (SPEC-002) | Phase 6 |
| AD-03 (Tenant Isolation) | Multi-Tenancy (Section D) | Phase 1 |
| AD-04 (Config-Driven Entitlements) | Package/Entitlement System | Phase 2 |
| AD-05 (Structured Knowledge) | Knowledge Architecture | Phase 3 |
| AD-06 (Centralized Compliance) | Compliance/Jurisdiction | Phase 14 |
| AD-07 (Event-Driven) | Event Architecture (SPEC-003) | Phase 7 |
| AD-08 (Platform Context/Memory) | Memory Architecture | Phase 9 |

### Specification Gap Resolution

| Spec Gap | Resolution | Phase |
|----------|-----------|-------| 
| SPEC-001 (Control Plane Caching) | Redis cache with TTL, invalidation, tenant scoping | Phase 5 |
| SPEC-002 (Voice Engine Adapter) | System prompt construction, adapter layer | Phase 6 |
| SPEC-003 (Event Idempotency) | Unique event IDs, idempotent handlers, dead-letter queue | Phase 7 |
| SPEC-004 (Billing Synchronization) | Stripe webhook → billing state → entitlement update, reconciliation | Phase 11 |
| SPEC-005 (Package Versioning) | Package → PackageVersion → Entitlement, migration process | Phase 2 |

### Architecture Package Traceability

| Package | Blueprint Section | Phase |
|---------|------------------|-------| 
| 01 Platform Boundary | Section A (Implementation Principles) | Phase 1 |
| 02 Voice Engine Boundary | Section I, SPEC-002 | Phase 6 |
| 03 Tenant and Identity | Section D (Multi-Tenancy) | Phase 1 |
| 04 Knowledge and Memory | Section F, G | Phase 3, 9 |
| 05 AI Colleague Policy | Section H | Phase 4 |
| 06 Localization | Section R | Phase 14 |
| 07 Channels and Conversation | Section K | Phase 8 |
| 08 Human Escalation | Section L | Phase 10 |
| 09 Customer Lifecycle | Section Z (Phase 8) | Phase 8 |
| 10 Packages and Entitlements | Section M | Phase 2 |
| 11 Demo | Section Q | Phase 12 |
| 12 Billing and Commercial | Section N, SPEC-004 | Phase 11 |
| 13 Compliance and Governance | Section S | Phase 14 |
| 14 Audit and Traceability | Section T | Phase 1 |
| 15 Incident and Safety | Section U | Phase 15 |
| 16 Data Boundaries and Learning | Section D (Multi-Tenancy) | Phase 1 |
| 17 Provider Abstraction | Section V | Phase 1 |
| 18 Operating Model | Section AB, AC | Phase 0 |

---

## Rules for Future Updates

- This blueprint is the engineering execution layer beneath the approved architecture
- Coding agents execute this blueprint; they do not redesign the architecture
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- This blueprint may be updated as implementation progresses
- Architectural changes require human owner approval

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004E — Implementation Blueprint
