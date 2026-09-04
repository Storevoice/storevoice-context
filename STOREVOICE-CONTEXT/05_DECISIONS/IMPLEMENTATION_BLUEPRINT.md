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

## SECTION AB — COMMERCIAL PRODUCT AGENT ORGANIZATION

### Organization Overview

StoreVoice is not merely a software engineering project. It is a product, customer experience, commercial proposition, brand, service operation, AI system, managed-service business, European business, compliance-sensitive product, and continuously improving commercial system.

The agent organization covers the **entire product lifecycle**:

```text
DISCOVER
  ↓
DEFINE
  ↓
DESIGN
  ↓
BUILD
  ↓
VERIFY
  ↓
LAUNCH
  ↓
ACTIVATE
  ↓
OPERATE
  ↓
MEASURE
  ↓
LEARN
  ↓
IMPROVE
  ↓
VERIFY AGAIN
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

### Agent Roles — Complete Commercial Product Organization

#### Verification Principle

The organization distinguishes:

* **BUILDERS** — create artifacts
* **REVIEWERS** — independently verify artifacts
* **DECISION AUTHORITY** — approves or rejects

No agent may approve its own critical work where independent verification is required.

---

### STRATEGIC CAPABILITIES

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 1 | **Principal Architect** | Overall architecture coherence | Architecture decisions, system boundaries, contracts, integration boundaries, dependency architecture, technical tradeoffs, architectural review | Implementation code, product decisions |
| 2 | **Product Manager** | Translate founder decisions into product requirements | Product requirements, feature definition, acceptance criteria, user outcomes, prioritization, scope, product archaeology, product coherence | Founder Decisions, architecture, pricing, brand |
| 3 | **Product Archaeology** | Reconstruct why existing functionality exists | Inspect existing behavior, discover hidden assumptions, identify historical constraints, preserve valuable existing behavior | Inventing history, modifying implementation |

**Note:** Product Archaeology is a sub-capability of Product Manager. It is activated when existing product behavior must be understood before changes.

---

### CREATIVE CAPABILITIES

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 4 | **UX / Product Experience** | Customer journeys, interaction flows, usability | Customer journeys, information architecture, interaction design, navigation, task flows, onboarding flows, error/empty/loading states, accessibility considerations, cross-channel experience consistency | Business rules, visual design authority, content authority |
| 5 | **Visual / Product Design** | Visual language, interface composition, design-system application | Visual direction, interface composition, visual hierarchy, layouts, components, interaction states, visual consistency, responsive behavior, visual polish, design artifacts for implementation | Business rules, content authority, implementation |
| 6 | **Design System** | Design tokens, typography, spacing, component principles | Design tokens, typography, spacing, color, grid, elevation, iconography, component principles, component states, interaction states, responsive rules, accessibility requirements, motion principles | Business rules, content authority, implementation |
| 7 | **Brand Direction** | Brand positioning, brand consistency, trust | Brand positioning, brand consistency, visual brand language, verbal brand language, premium positioning, differentiation, trust, consistency across product and marketing | Business rules, implementation |
| 8 | **Content / Product Copy** | Product language, UX writing, customer-facing copy | Product copy, UX writing, conversion copy, product marketing, onboarding copy, error messaging, trust language, localization-ready content, CTAs, system messages | Business rules, capabilities, pricing, compliance claims |

**Design Pipeline:**

```text
PRODUCT REQUIREMENT
        ↓
UX / PRODUCT EXPERIENCE
        ↓
VISUAL / PRODUCT DESIGN
        ↓
DESIGN SYSTEM
        ↓
CONTENT
        ↓
IMPLEMENTATION CONTRACT
        ↓
FRONTEND / BACKEND
```

---

### COMMERCIAL CAPABILITIES

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 9 | **Commercial / Sales** | Commercial proposition, buyer experience | Commercial proposition, buyer journey, sales journey, lead qualification, enterprise buyer experience, pricing communication, objections, trust, procurement/IT/legal/executive concerns | Product strategy, architecture |
| 10 | **Growth / CRO** | Conversion optimization, funnel analysis | Conversion optimization, funnel analysis, CTA effectiveness, activation, retention, experimentation, drop-off analysis | Product strategy, brand |
| 11 | **SEO / Discoverability** | Search discoverability, information architecture for findability | Technical SEO, content SEO, metadata, structured content, search intent, international SEO, localized search | Product UX, brand positioning |
| 12 | **Website / Public Experience** | Public commercial experience as a product surface | Homepage, product/system explanation, differentiation, industries/use cases, trust/security, investment/pricing, company, enterprise contact, privacy, terms, AI transparency, accessibility | Product strategy, architecture |

---

### CUSTOMER CAPABILITIES

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 13 | **Customer Onboarding / Activation** | Customer lifecycle from new to active | Onboarding, information collection, validation, configuration, testing, customer confirmation, activation, readiness assessment | Product strategy, architecture |
| 14 | **Customer Success / Service Operations** | Ongoing customer service delivery | Customer success, service responsibility, customer communication, operational changes, support, service health, escalation management, periodic reporting, improvement recommendations | Product strategy, architecture |
| 15 | **Knowledge Operations** | Customer knowledge lifecycle | Customer information collection, source validation, approval, knowledge versioning, knowledge lifecycle, knowledge updates, knowledge gaps, knowledge conflicts, knowledge deletion, customer confirmation | Other domains |
| 16 | **Memory Operations** | AI memory lifecycle | Memory candidate extraction, relevance, permissions, retrieval, conflict resolution, source/confidence, deletion, tenant isolation, auditability, lifecycle management | Knowledge, other domains |
| 17 | **Human Escalation / White Glove** | Escalation and premium service delivery | Human escalation, escalation reasons, cold/warm transfer, context handover, human responsibility, operational/customer/incident escalation, White Glove service delivery | Product strategy, architecture |

**Customer Lifecycle:**

```text
NEW CUSTOMER
    ↓
ONBOARDING
    ↓
INFORMATION COLLECTION
    ↓
VALIDATION
    ↓
CONFIGURATION
    ↓
TEST
    ↓
CUSTOMER CONFIRMATION
    ↓
ACTIVATION
    ↓
OPERATION
    ↓
MEASUREMENT
    ↓
IMPROVEMENT
```

Required states: DRAFT → REVIEW REQUIRED → CUSTOMER CONFIRMED → ACTIVE

Important settings must NOT silently activate.

---

### TECHNICAL CAPABILITIES — ENGINEERING

The existing 17 engineering roles are preserved. Do NOT remove them.

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 18 | **Orchestrator** | Task dispatch and coordination | Task management, agent coordination, dependency resolution, context propagation, handoffs, artifact exchange, parallel/sequential execution, failure detection, revision loops, escalation, completion criteria, status reporting, traceability, auditability | Implementation code, product decisions, design authority, brand authority |
| 19 | **Backend** | Core platform logic | APIs, business logic, database | Frontend, Voice Engine |
| 20 | **Database** | Data model and queries | Schema, migrations, queries | Application logic |
| 21 | **Realtime/Voice** | Voice conversation path | Channel gateway, session manager, voice adapter | Control Plane |
| 22 | **Knowledge** (Engineering) | Knowledge system implementation | Knowledge ingestion, approval, retrieval system | Other domains |
| 23 | **Memory** (Engineering) | Memory system implementation | Memory extraction, approval, persistence system | Knowledge |
| 24 | **Frontend** | Customer-facing UI implementation | Dashboard, onboarding UI, component engineering, responsive implementation | Backend, design authority |
| 25 | **Billing** | Payment integration | Stripe integration, subscription management | Other domains |
| 26 | **Security** (Engineering) | Security controls implementation | Authentication, authorization, encryption | Business logic |
| 27 | **Compliance** (Engineering) | Compliance system implementation | Compliance evaluation, audit system | Business logic |
| 28 | **Localization** (Engineering) | Localization system implementation | Language, cultural adaptation system | Business logic |
| 29 | **Infrastructure** | Deployment and operations | CI/CD, monitoring, scaling | Application code |
| 30 | **Observability** | Monitoring and alerting | Logging, metrics, tracing | Application code |
| 31 | **Integration** | External provider integration | Provider adapters, webhooks | Business logic |
| 32 | **Code Reviewer** | Code quality review | Code review, quality standards | Implementation |

---

### TRUST / COMPLIANCE CAPABILITIES

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 33 | **Security / Privacy / Compliance / Trust** | Trust, compliance, privacy, AI transparency | Security, privacy, GDPR, data protection, AI transparency, accessibility, regulatory requirements, jurisdiction, auditability, retention, deletion, data isolation, incident response, responsible AI | Product strategy, business rules |

**Note:** This capability covers trust, compliance, privacy, and AI transparency as a unified concern because they are inseparable in a European AI service. Separate specialist functions may be activated within this capability as needed.

**AI Transparency Audit:**

* live voice demos
* AI voice identity
* chatbots
* AI-generated content
* website AI interactions
* disclosure wording
* accessibility of disclosure
* timing of disclosure
* distinguishability from human interaction

Do not claim "Fully EU AI Act compliant" unless independently substantiated.

---

### LOCALIZATION CAPABILITY

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 34 | **Localization** (Product) | European customer experience | Language, locale, accent, terminology, cultural expectations, formality, local customer experience, local website, local sales experience, European expansion, jurisdiction-aware behavior | Business rules, architecture |

Internal company language remains English. Do not create unnecessary country-specific architectures.

---

### ANALYTICS CAPABILITY

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 35 | **Analytics / Measurement** | Product and operational measurement | Product usage, conversion, activation, onboarding, customer experience, call outcomes, escalation, knowledge gaps, quality, retention, commercial performance, operational performance, system performance | Product strategy, architecture |

Metrics must support decisions. Avoid vanity metrics.

---

### VERIFICATION CAPABILITIES

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 36 | **QA** | Functional test automation, visual/UX verification | Test suites, test infrastructure, design-system conformance, visual/UX verification, accessibility testing, critical user journey verification, visual regression detection | Implementation |
| 37 | **Red Team / Commercial Judge** | Independent challenge and commercial evaluation | Break product assumptions, UX, positioning, commercial logic, security, compliance, accessibility, operational assumptions, AI behavior, customer trust; evaluate would a real customer buy this? | Implementation, product authority |
| 38 | **Innovation Scout** | Improvement proposals | UX opportunities, design improvements, conversion opportunities, onboarding improvements, retention opportunities, new product opportunities, SEO opportunities, accessibility, performance, trust, European expansion | Implementation, product authority |
| 39 | **Product / Commercial Audit** | Recurring multi-dimensional audit | PRODUCT, UX, UI, BRAND, COPY, COMMERCIAL, MOBILE, ACCESSIBILITY, PERFORMANCE, SEO, SECURITY, TECHNICAL QUALITY, EUROPEAN READINESS, CUSTOMER EXPERIENCE, OPERATIONS, TRUST | Implementation |

**Independent Verification Model:**

```text
BUILDERS create artifacts
      ↓
REVIEWERS independently verify:
  - QA (functional + visual/UX)
  - Red Team (challenge assumptions)
  - Commercial Judge (would a customer buy this?)
  - Code Reviewer (code quality)
      ↓
DECISION AUTHORITY approves or rejects
      ↓
FOUNDER resolves strategic conflicts
```

Reviewers must be empowered to reject work.

---

### ORCHESTRATION CAPABILITY

| # | Agent | Mission | Owned Areas | Forbidden Areas |
|---|-------|---------|-------------|-----------------|
| 40 | **Orchestrator** | Operational coordination across all capabilities | Task decomposition, role selection, context propagation, dependency management, parallel/sequential work, handoffs, artifact exchange, revision loops, failure handling, escalation, independent verification coordination, rollback, audit trail | Implementation code, product decisions, design authority, brand authority |

The Orchestrator coordinates.

It does not govern.

---

### Agent Access Rules

1. **Least-privilege access:** Each agent has access only to its owned areas
2. **Read-only for non-owned:** Agents can read but not write to non-owned areas
3. **Escalation required:** Changes to non-owned areas require escalation
4. **Review required:** All changes require independent verification before merge
5. **Design authority:** Visual/Product Design owns design authority; Frontend implements approved design (FD-11)
6. **Content authority:** Content owns product copy; agents must not invent product truth (FD-13)
7. **Product authority:** Product Manager owns product requirements; agents must not invent requirements (FD-14)
8. **No self-approval:** No agent may approve its own critical work where independent verification is required

### Role Relationships

```text
FOUNDER / SOURCE OF TRUTH
          ↓
     ORCHESTRATOR
          ↓
 PRODUCT MANAGER
          ↓
   ┌──────┼──────────┬──────────┐
   ↓      ↓          ↓          ↓
  UX    DESIGN    CONTENT   COMMERCIAL
   ↓      ↓          ↓          ↓
 VISUAL   │          │       GROWTH/SEO
   ↓      │          │          ↓
 DESIGN SYSTEM       │       WEBSITE
   ↓      │          │          ↓
 FRONTEND ←──────────┘──────────┘
          ↓
   CUSTOMER ONBOARDING / SUCCESS
          ↓
   KNOWLEDGE / MEMORY OPS
          ↓
         QA
          ↓
   RED TEAM / COMMERCIAL JUDGE
          ↓
    CODE REVIEWER
          ↓
    ACCEPTANCE
          ↓
       FREEZE
```

### Authority Model

```text`
FOUNDER
   ↓
defines STRATEGIC TRUTH and BOUNDARIES

PRODUCT MANAGER
   ↓
defines WHAT and WHY

ARCHITECTURE (Principal Architect)
   ↓
defines HOW at system level

UX / DESIGN / BRAND / CONTENT
   ↓
define EXPERIENCE and COMMUNICATION

COMMERCIAL / GROWTH / SEO / WEBSITE
   ↓
define MARKET and CONVERSION

CUSTOMER OPS (Onboarding / Success / Knowledge / Memory / Escalation)
   ↓
define SERVICE DELIVERY

ENGINEERING (17 roles)
   ↓
implements

TRUST / COMPLIANCE / LOCALIZATION / ANALYTICS
   ↓
protects and measures

QA / RED TEAM / CODE REVIEWER
   ↓
independently verifies

FOUNDER
   ↓
resolves strategic conflicts
```

### Context Propagation Model

Every dispatched task must receive the minimum authoritative context required to perform the task correctly.

Context must include at minimum:

* Founder Decisions (from FOUNDER_DECISION_SET.md)
* Product Contract (from PRODUCT_CONTRACT.md)
* Business Rules (from BUSINESS_RULES.md)
* Architecture (from ARCHITECTURE.md)
* Design System (from DESIGN_SYSTEM.md — when established)
* UX Rules (from UX_RULES.md)
* Brand Guidelines (from BRAND_GUIDELINES.md — when established)
* Voice Engine constraints (from VOICE_ENGINE.md, FROZEN_COMPONENTS.md)
* Implementation Blueprint (this document)
* current task specification
* dependencies
* prior findings
* acceptance criteria
* known assumptions
* technical unknowns
* relevant artifacts
* prior agent outputs

Agents must not be forced to reconstruct project truth from conversation history alone.

Persistent project truth must come from repository artifacts.

### Handoff Model

A structured handoff must communicate, where relevant:

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

Do not allow informal prose-only handoffs to become the sole project memory.

### Dependency Model

Work may be:

**Sequential** — One output required before another agent begins.

Example:
```text
Product Requirements → UX → Visual Design → Frontend
```

**Parallel** — Independent workstreams operating simultaneously.

Example:
```text
Backend │ Database │ Security │ Observability
```

**Gated** — Downstream implementation waits for approval or validation.

Example:
```text
Design System → Design → Frontend → Visual QA
```

The Orchestrator must understand these dependency types.

### Revision Loop

When an agent's work fails validation:

```text
BUILD
 ↓
TEST
 ↓
AUDIT
 ↓
FAIL
 ↓
IDENTIFY FAILURE OWNER
 ↓
RETURN CONTEXT + FINDINGS
 ↓
REVISE
 ↓
RETEST
 ↓
RE-AUDIT
```

Do not restart unrelated work.

Do not erase the failure history.

Do not allow an agent to declare its own failed work complete.

### Failure Handling

Failure classes:

* **Technical Failure** — Agent/tool/code failure
* **Requirement Failure** — Output does not satisfy requirements
* **Architectural Failure** — Output conflicts with architecture
* **Product Failure** — Output does not satisfy product intent
* **Design Failure** — Output violates approved design direction
* **Content Failure** — Copy contradicts product truth or content standards
* **Security/Compliance Failure** — Output violates mandatory security or compliance requirements
* **Integration Failure** — Output conflicts with another system/component
* **Commercial Failure** — Output weakens positioning, harms conversion, confuses users, damages trust
* **Unknown** — Issue cannot safely be classified

Unknown or authority-conflicting failures must escalate rather than being guessed through.

### Authority Escalation

If an agent encounters:

* conflicting Founder Decisions
* missing Founder Decision
* conflicting business rules
* architectural contradiction
* unresolved product strategy
* material commercial ambiguity
* major design-direction ambiguity
* compliance uncertainty
* security uncertainty

the agent must NOT invent the answer.

Use:

**STOP → IDENTIFY → DOCUMENT → ESCALATE**

The Orchestrator must surface the issue to the correct authority.

### Traceability

Every major implementation task must eventually be traceable:

```text
FOUNDER DECISION
      ↓
PRODUCT REQUIREMENT
      ↓
UX REQUIREMENT
      ↓
DESIGN DECISION
      ↓
CONTENT DECISION
      ↓
ARCHITECTURE
      ↓
IMPLEMENTATION
      ↓
TEST
      ↓
QA / VISUAL UX QA
      ↓
RED TEAM / COMMERCIAL JUDGE
      ↓
CODE REVIEW
      ↓
ACCEPTANCE
```

Not every task will require every layer. The operating model must nevertheless preserve the ability to trace decisions through the system.

### No Fabrication Rule

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

### Commercial Quality Must Not Be Subordinate to Engineering

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

### Design Autopilot

Preserve the concept of an autonomous design improvement loop:

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

### Continuous Improvement Loop

Define the canonical autonomous loop:

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
UPDATE MEMORY
  ↓
AUDIT AGAIN
```

This loop must respect authority hierarchy and change control.

### Deterministic Task Dispatch

| Task Type | Agent | Input | Output |
|-----------|-------|-------|--------|
| Product requirement | Product Manager | Founder Decision / strategic direction | Product requirement, acceptance criteria |
| Customer journey | UX | Product requirement | Journey specification, interaction flow |
| Visual design | Visual Design | UX specification, design system | Design artifact, component specification |
| Content / copy | Content | Product requirement, brand guidelines | Copy artifact, content specification |
| Database schema | Database | Entity definition | Migration script |
| API endpoint | Backend | API specification | Implementation code |
| Event handler | Backend | Event specification | Handler code |
| Test case | QA | Acceptance criteria | Test code |
| Visual/UX QA | QA | Design artifact, implementation | Visual/UX verification report |
| Security control | Security | Security requirement | Implementation code |
| Knowledge feature | Knowledge | Knowledge specification | Implementation code |
| Voice path | Realtime/Voice | Call path specification | Implementation code |
| Billing feature | Billing | Billing specification | Implementation code |
| Commercial evaluation | Red Team / Commercial Judge | Product artifact | Commercial assessment |
| Innovation proposal | Innovation Scout | Current state | Improvement proposal |
| Product audit | Product / Commercial Audit | Current state | Audit report |

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
