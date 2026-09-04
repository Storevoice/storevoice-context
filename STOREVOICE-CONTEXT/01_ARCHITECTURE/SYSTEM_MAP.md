# SYSTEM_MAP.md — StoreVoice System Components Map

**Purpose:** Visual and textual map of all system components and their relationships.

**Status:** DECISION

**Scope:** This document provides a comprehensive view of the StoreVoice system structure, including control plane, interaction plane, data boundaries, regional processing, and the Voice Engine boundary.

**Important:** This is TARGET ARCHITECTURE. Diagrams represent the designed system, not currently implemented components. The Voice Engine boundary is a TARGET architecture, not a currently existing public API.

---

## 1. High-Level System Map

```mermaid
graph TB
    subgraph "External"
        Customer["Customer<br/>(Phone / WhatsApp / Email / SMS)"]
    end

    subgraph "StoreVoice Platform"
        subgraph "Control Plane"
            Identity["Identity & Tenant Management"]
            CustomerAdmin["Customer Administration"]
            Packages["Package & Entitlement Management"]
            KnowledgeMgmt["Knowledge Management"]
            Config["AI Colleague Configuration"]
            Localization["Localization Configuration"]
            Billing["Billing & Subscription"]
            Compliance["Compliance & Regulatory"]
            Audit["Audit & Traceability"]
            Incidents["Incident Management"]
            Onboarding["Onboarding Management"]
            Demo["Demo Management"]
            Providers["Provider Configuration"]
        end

        subgraph "Interaction Plane"
            Channels["Channel Management"]
            Sessions["Session Management"]
            AIRuntime["AI Colleague Runtime"]
            KnowledgeRetrieval["Knowledge Retrieval"]
            Context["Context Management"]
            Escalation["Escalation Orchestration"]
            Tools["Tool Execution"]
            Events["Real-time Event Processing"]
        end

        subgraph "Operations Plane"
            QA["Quality Assurance"]
            Reporting["Reporting & Insight"]
            HumanEsc["Human Escalation Management"]
            WhiteGlove["White Glove Operations"]
        end
    end

    subgraph "Voice Engine Boundary"
        Boundary["Stable Interface"]
    end

    subgraph "External Systems"
        VoiceEngine["Frozen Voice Engine<br/>(LiveKit Agents / Deepgram / OpenAI / Cartesia)"]
        Twilio["Twilio<br/>(Telephony)"]
        Stripe["Stripe<br/>(Payments)"]
        Cloud["Cloud Infrastructure"]
    end

    Customer --> Channels
    Channels --> Sessions
    Sessions --> AIRuntime
    AIRuntime --> Boundary
    Boundary --> VoiceEngine
    Channels --> Twilio
    Billing --> Stripe
    Identity --> Cloud
    AIRuntime --> KnowledgeRetrieval
    AIRuntime --> Context
    AIRuntime --> Escalation
    AIRuntime --> Tools
    Sessions --> Events
    KnowledgeMgmt --> KnowledgeRetrieval
    Config --> AIRuntime
    Compliance --> AIRuntime
    Audit --> Events
    Incidents --> Events
    QA --> Reporting
    HumanEsc --> Escalation
    WhiteGlove --> HumanEsc
```

---

## 2. Control Plane Detail

```mermaid
graph TB
    subgraph "Control Plane"
        subgraph "Identity & Access"
            Identity["Identity Service"]
            Tenants["Tenant Management"]
            Auth["Authorization"]
        end

        subgraph "Customer Management"
            CustomerAdmin["Customer Administration"]
            Contacts["Contact Management"]
            Profiles["Customer Profiles"]
        end

        subgraph "Package & Entitlement"
            Packages["Package Definitions"]
            Entitlements["Entitlement Engine"]
            Versions["Package Versioning"]
        end

        subgraph "Knowledge Management"
            KnowledgeIngest["Knowledge Ingestion"]
            KnowledgeValidation["Knowledge Validation"]
            KnowledgeApproval["Knowledge Approval"]
            KnowledgeVersioning["Knowledge Versioning"]
            KnowledgeActive["Active Knowledge Store"]
        end

        subgraph "Configuration"
            AIConfig["AI Colleague Config"]
            PersonaConfig["Persona Configuration"]
            BehaviorConfig["Behavior Policy Config"]
        end

        subgraph "Localization"
            LocaleConfig["Locale Configuration"]
            LanguageConfig["Language Configuration"]
            CulturalConfig["Cultural Adaptation"]
        end

        subgraph "Compliance"
            Jurisdiction["Jurisdiction Awareness"]
            RegRules["Regulatory Rules"]
            ComplianceState["Compliance State"]
        end

        subgraph "Billing"
            Subscriptions["Subscription Management"]
            Payments["Payment Processing"]
            Proration["Proration Logic"]
        end

        subgraph "Audit & Incidents"
            AuditLog["Audit Logging"]
            IncidentMgmt["Incident Management"]
            PostIncident["Post-Incident Review"]
        end

        subgraph "Onboarding & Demo"
            OnboardingWF["Onboarding Workflows"]
            DemoMgmt["Demo Lifecycle"]
            Progress["Progress Tracking"]
        end
    end

    Identity --> Tenants
    Identity --> Auth
    Tenants --> CustomerAdmin
    CustomerAdmin --> Contacts
    CustomerAdmin --> Profiles
    Packages --> Entitlements
    Packages --> Versions
    KnowledgeIngest --> KnowledgeValidation
    KnowledgeValidation --> KnowledgeApproval
    KnowledgeApproval --> KnowledgeVersioning
    KnowledgeVersioning --> KnowledgeActive
    AIConfig --> PersonaConfig
    AIConfig --> BehaviorConfig
    LocaleConfig --> LanguageConfig
    LocaleConfig --> CulturalConfig
    Jurisdiction --> RegRules
    RegRules --> ComplianceState
    Subscriptions --> Payments
    Subscriptions --> Proration
    AuditLog --> IncidentMgmt
    IncidentMgmt --> PostIncident
    OnboardingWF --> Progress
    DemoMgmt --> OnboardingWF
```

---

## 3. Interaction Plane Detail

```mermaid
graph TB
    subgraph "Interaction Plane"
        subgraph "Channel Management"
            PhoneChannel["Phone Channel"]
            WhatsAppChannel["WhatsApp Channel"]
            EmailChannel["Email Channel"]
            SMSChannel["SMS Channel"]
        end

        subgraph "Session Management"
            SessionMgr["Session Manager"]
            ConversationCtx["Conversation Context"]
            TurnMgr["Turn Management"]
        end

        subgraph "AI Colleague Runtime"
            Persona["Persona Engine"]
            Behavior["Behavior Policy Engine"]
            KnowledgeAccess["Knowledge Access"]
            EmotionEngine["Emotion Handling"]
            SafetyEngine["Safety Engine"]
        end

        subgraph "Context & Memory"
            CurrentCtx["Current Conversation Context"]
            SessionCtx["Session Context"]
            DurableCtx["Durable Customer Context"]
            Memory["Memory Store"]
        end

        subgraph "Escalation"
            EscTrigger["Escalation Trigger"]
            EscRouting["Escalation Routing"]
            Transfer["Transfer Management"]
            Callback["Callback Scheduling"]
            ContextHandoff["Context Handoff"]
        end

        subgraph "Tool Execution"
            ToolRegistry["Tool Registry"]
            ToolExec["Tool Executor"]
            ToolAuth["Tool Authorization"]
        end

        subgraph "Real-time Events"
            EventProcessor["Event Processor"]
            EventRouter["Event Router"]
            EventStore["Event Store"]
        end
    end

    PhoneChannel --> SessionMgr
    WhatsAppChannel --> SessionMgr
    EmailChannel --> SessionMgr
    SMSChannel --> SessionMgr

    SessionMgr --> ConversationCtx
    SessionMgr --> TurnMgr

    ConversationCtx --> Persona
    ConversationCtx --> Behavior
    ConversationCtx --> KnowledgeAccess
    ConversationCtx --> EmotionEngine
    ConversationCtx --> SafetyEngine

    ConversationCtx --> CurrentCtx
    ConversationCtx --> SessionCtx
    SessionCtx --> DurableCtx
    DurableCtx --> Memory

    Persona --> EscTrigger
    Behavior --> EscTrigger
    SafetyEngine --> EscTrigger
    EscTrigger --> EscRouting
    EscRouting --> Transfer
    EscRouting --> Callback
    EscRouting --> ContextHandoff

    Persona --> ToolRegistry
    ToolRegistry --> ToolExec
    ToolExec --> ToolAuth

    SessionMgr --> EventProcessor
    EventProcessor --> EventRouter
    EventRouter --> EventStore
```

---

## 4. Data Boundaries

```mermaid
graph TB
    subgraph "StoreVoice Platform"
        subgraph "Tenant Data (Per-Customer, Isolated)"
            TenantIdentity["Tenant Identity"]
            TenantConfig["Tenant Configuration"]
            TenantKnowledge["Tenant Knowledge"]
            TenantConversations["Tenant Conversations"]
            TenantContext["Tenant Context"]
            TenantMemory["Tenant Memory"]
            TenantAudit["Tenant Audit Data"]
        end

        subgraph "StoreVoice General (Shared)"
            GeneralKnowledge["General Knowledge"]
            GeneralQA["General QA Findings"]
            GeneralPatterns["Aggregated Patterns"]
            GeneralImprovements["General Improvements"]
            PlatformConfig["Platform Configuration"]
        end
    end

    subgraph "External Providers"
        STTProvider["STT Provider"]
        LLMProvider["LLM Provider"]
        TTSProvider["TTS Provider"]
        TelephonyProvider["Telephony Provider"]
        PaymentProvider["Payment Provider"]
    end

    TenantIdentity -.->|"ISOLATED"| TenantConfig
    TenantConfig -.->|"ISOLATED"| TenantKnowledge
    TenantKnowledge -.->|"ISOLATED"| TenantConversations
    TenantConversations -.->|"ISOLATED"| TenantContext
    TenantContext -.->|"ISOLATED"| TenantMemory
    TenantMemory -.->|"ISOLATED"| TenantAudit

    TenantKnowledge -->|"ANONYMIZE & AGGREGATE"| GeneralPatterns
    GeneralPatterns --> GeneralImprovements

    TenantConversations -->|"ANONYMIZE"| GeneralQA

    STTProvider -->|"PROVIDER BOUNDARY"| TenantConversations
    LLMProvider -->|"PROVIDER BOUNDARY"| TenantConversations
    TTSProvider -->|"PROVIDER BOUNDARY"| TenantConversations
    TelephonyProvider -->|"PROVIDER BOUNDARY"| TenantConversations
    PaymentProvider -->|"PROVIDER BOUNDARY"| TenantConfig
```

### Data Isolation Rules

| Data Type | Isolation | Cross-Tenant Access | Deletion |
|-----------|-----------|---------------------|----------|
| Tenant Identity | Strict | NEVER | After legal retention |
| Tenant Configuration | Strict | NEVER | After legal retention |
| Tenant Knowledge | Strict | NEVER | After termination + 14 days |
| Tenant Conversations | Strict | NEVER | After termination + 14 days |
| Tenant Context | Strict | NEVER | After termination + 14 days |
| Tenant Memory | Strict | NEVER | After termination + 14 days |
| Tenant Audit | Strict | NEVER | After legal retention |
| General Knowledge | Shared | By design | N/A |
| General QA | Shared (anonymized) | By design | N/A |
| General Patterns | Shared (anonymized) | By design | N/A |

---

## 5. Regional Processing

```mermaid
graph TB
    subgraph "Central Control Plane (Greece)"
        Identity["Identity Service"]
        TenantMgmt["Tenant Management"]
        KnowledgeMgmt["Knowledge Management"]
        Compliance["Compliance Service"]
        Billing["Billing Service"]
        Audit["Audit Service"]
        Config["Configuration Service"]
    end

    subgraph "Region: EU-West"
        ChannelGW1["Channel Gateway"]
        SessionMgr1["Session Manager"]
        AIRuntime1["AI Colleague Runtime"]
        VoiceEngine1["Voice Engine Instance"]
    end

    subgraph "Region: EU-Central"
        ChannelGW2["Channel Gateway"]
        SessionMgr2["Session Manager"]
        AIRuntime2["AI Colleague Runtime"]
        VoiceEngine2["Voice Engine Instance"]
    end

    subgraph "Region: EU-East (Future)"
        ChannelGW3["Channel Gateway"]
        SessionMgr3["Session Manager"]
        AIRuntime3["AI Colleague Runtime"]
        VoiceEngine3["Voice Engine Instance"]
    end

    Identity --> TenantMgmt
    TenantMgmt --> KnowledgeMgmt
    KnowledgeMgmt --> Compliance
    Compliance --> Billing
    Billing --> Audit
    Audit --> Config

    Config --> ChannelGW1
    Config --> ChannelGW2
    Config --> ChannelGW3

    ChannelGW1 --> SessionMgr1
    SessionMgr1 --> AIRuntime1
    AIRuntime1 --> VoiceEngine1

    ChannelGW2 --> SessionMgr2
    SessionMgr2 --> AIRuntime2
    AIRuntime2 --> VoiceEngine2

    ChannelGW3 --> SessionMgr3
    SessionMgr3 --> AIRuntime3
    AIRuntime3 --> VoiceEngine3
```

### Regional Processing Triggers

| Trigger | Reason | Example |
|---------|--------|---------|
| Compliance | Data residency requirements | EU data protection |
| Latency | Voice processing proximity | Real-time conversation |
| Resilience | Geographic distribution | Disaster recovery |
| Capacity | Load distribution | Peak hours |
| Provider Availability | Provider regional presence | Provider outage |

### Regional Processing Rules

* Central control plane is the authoritative source
* Regional processing remains subordinate to the central platform
* Regional processing does NOT create independent national platforms
* Regional processing does NOT create independent product standards
* Configuration is centrally managed; regional execution is distributed

---

## 6. Voice Engine Boundary

```mermaid
graph TB
    subgraph "StoreVoice Platform"
        subgraph "Control Plane"
            KnowledgeMgmt["Knowledge Management"]
            AIConfig["AI Configuration"]
            BehaviorPolicy["Behavior Policy"]
            TenantCtx["Tenant Context"]
            Entitlements["Package Entitlements"]
        end

        subgraph "Interaction Plane"
            SessionMgr["Session Manager"]
            ConversationCtx["Conversation Context"]
            Escalation["Escalation Orchestrator"]
        end
    end

    subgraph "Voice Engine Boundary (TARGET Architecture)"
        Boundary["Stable Interface<br/>─────────────<br/>Input: Config, Knowledge, Persona, Policies<br/>Output: Events, Transcription, Responses, Telemetry"]
    end

    subgraph "Frozen Voice Engine (External)"
        LiveKit["LiveKit Agents SDK"]
        STT["Deepgram Nova-3 STT"]
        LLM["OpenAI GPT-4.1 LLM"]
        TTS["Cartesia Sonic-3 TTS"]
        VAD["Silero VAD"]
    end

    KnowledgeMgmt -->|"Knowledge Context"| Boundary
    AIConfig -->|"Persona Definition"| Boundary
    BehaviorPolicy -->|"Behavior Policies"| Boundary
    TenantCtx -->|"Tenant Context"| Boundary
    Entitlements -->|"Entitlement State"| Boundary

    SessionMgr -->|"Session Control"| Boundary
    ConversationCtx -->|"Context Updates"| Boundary

    Boundary -->|"Transcription"| SessionMgr
    Boundary -->|"AI Response"| SessionMgr
    Boundary -->|"Escalation Trigger"| Escalation
    Boundary -->|"Telemetry"| SessionMgr

    Boundary --> LiveKit
    LiveKit --> STT
    LiveKit --> LLM
    LiveKit --> TTS
    LiveKit --> VAD
```

### Boundary Interface Specification

#### Inputs (Platform → Engine)

| Input | Type | Description | Required |
|-------|------|-------------|----------|
| Session Configuration | Object | Channel, language, tenant ID | Yes |
| Knowledge Context | Array | Approved knowledge items for this tenant | Yes |
| Persona Definition | Object | Name, role, personality, style | Yes |
| Behavior Policies | Array | What AI may/may not do | Yes |
| System Prompt | String | Base prompt with knowledge and policies | Yes |
| Channel Parameters | Object | Phone number, caller info, etc. | Yes |
| Entitlement State | Object | Package capabilities available | Yes |

#### Outputs (Engine → Platform)

| Output | Type | Description | Required |
|--------|------|-------------|----------|
| Transcription | String | What the user said | Yes |
| AI Response | String | What the AI said | Yes |
| Conversation Events | Array | Turn, interruption, pause, etc. | Yes |
| Escalation Trigger | Object | When escalation is needed | Conditional |
| Telemetry | Object | Latency, errors, metrics | Yes |
| Error Events | Object | When something goes wrong | Yes |

### Boundary Versioning

| Version | Status | Compatibility |
|---------|--------|---------------|
| v1.0 | TARGET | Initial design |
| Future | TBD | Backward compatible within major versions |

### Boundary Replacement

The boundary must support:

```
Current Engine → Adapter → Future Engine
```

Without reconstructing the StoreVoice platform.

---

## 7. Customer Lifecycle State Machine

```mermaid
stateDiagram-v2
    [*] --> PROSPECT
    PROSPECT --> DEMO: Request demo
    DEMO --> EXPIRED: ~48 hours elapsed
    DEMO --> CONVERSION: Customer signs up
    CONVERSION --> CUSTOMER: Account created
    CUSTOMER --> ONBOARDING: Subscription starts
    ONBOARDING --> READY: 100% readiness
    READY --> ACTIVE: Go live
    ACTIVE --> UPGRADE_PENDING: Upgrade requested
    UPGRADE_PENDING --> ACTIVE: Upgrade processed
    ACTIVE --> DOWNGRADE_PENDING: Downgrade requested
    DOWNGRADE_PENDING --> ACTIVE: End of month
    ACTIVE --> CANCELLATION_PENDING: Customer cancels
    CANCELLATION_PENDING --> PAID_PERIOD: Cancellation processed
    PAID_PERIOD --> RECOVERY: Paid period ends
    RECOVERY --> ACTIVE: Customer reactivates
    RECOVERY --> DELETED: 14 days elapsed
    DELETED --> [*]
    EXPIRED --> [*]
```

---

## 8. Knowledge Lifecycle

```mermaid
graph TB
    Source["Source<br/>(Customer, Documents, Onboarding)"]
    Ingest["Ingest"]
    Validate["Validate"]
    Review["Review"]
    Approve["Approve"]
    Version["Version"]
    Active["Active Knowledge"]
    Update["Update"]
    Replace["Replace"]
    Block["Block"]
    Audit["Audit History"]
    Delete["Delete"]

    Source --> Ingest
    Ingest --> Validate
    Validate --> Review
    Review --> Approve
    Approve --> Version
    Version --> Active
    Active --> Update
    Active --> Replace
    Active --> Block
    Active --> Delete
    Update --> Version
    Replace --> Version
    Block --> Audit
    Delete --> Audit
    Version --> Audit
```

---

## 9. Escalation Flow

```mermaid
graph TB
    AIRuntime["AI Colleague Runtime"]
    EscTrigger{"Escalation<br/>Trigger?"}
    HumanAvail{"Human<br/>Available?"}
    WarmTransfer["Warm Transfer"]
    ColdTransfer["Cold Transfer"]
    Callback["Callback Scheduling"]
    ContextHandoff["Context Handoff"]
    HumanAgent["Human Agent"]
    Customer["Customer"]

    AIRuntime --> EscTrigger
    EscTrigger -->|"Yes"| HumanAvail
    EscTrigger -->|"No"| AIRuntime

    HumanAvail -->|"Yes"| WarmTransfer
    HumanAvail -->|"No"| Callback

    WarmTransfer --> ContextHandoff
    ColdTransfer --> ContextHandoff
    Callback --> ContextHandoff

    ContextHandoff --> HumanAgent
    HumanAgent --> Customer
```

---

## 10. Provider Abstraction Map

```mermaid
graph TB
    subgraph "StoreVoice Platform"
        subgraph "Provider Abstraction Layer"
            STTInterface["STT Interface"]
            LLMInterface["LLM Interface"]
            TTSInterface["TTS Interface"]
            TelephonyInterface["Telephony Interface"]
            PaymentInterface["Payment Interface"]
        end
    end

    subgraph "External Providers"
        Deepgram["Deepgram Nova-3"]
        OpenAI["OpenAI GPT-4.1"]
        Cartesia["Cartesia Sonic-3"]
        Twilio["Twilio"]
        Stripe["Stripe"]
    end

    subgraph "Future Providers (Replaceable)"
        FutureSTT["Future STT"]
        FutureLLM["Future LLM"]
        FutureTTS["Future TTS"]
        FutureTelephony["Future Telephony"]
        FuturePayment["Future Payment"]
    end

    STTInterface --> Deepgram
    LLMInterface --> OpenAI
    TTSInterface --> Cartesia
    TelephonyInterface --> Twilio
    PaymentInterface --> Stripe

    STTInterface -.->|"REPLACEABLE"| FutureSTT
    LLMInterface -.->|"REPLACEABLE"| FutureLLM
    TTSInterface -.->|"REPLACEABLE"| FutureTTS
    TelephonyInterface -.->|"REPLACEABLE"| FutureTelephony
    PaymentInterface -.->|"REPLACEABLE"| FuturePayment
```

---

## 11. Deployment Topology

```mermaid
graph TB
    subgraph "Environments"
        Dev["Development"]
        Staging["Staging"]
        Production["Production"]
    end

    subgraph "Production Topology"
        subgraph "Control Plane"
            Identity["Identity Service"]
            TenantSvc["Tenant Service"]
            KnowledgeSvc["Knowledge Service"]
            ConfigSvc["Configuration Service"]
            BillingSvc["Billing Service"]
            ComplianceSvc["Compliance Service"]
            AuditSvc["Audit Service"]
            IncidentSvc["Incident Service"]
        end

        subgraph "Interaction Plane (Region-Aware)"
            ChannelGW["Channel Gateways"]
            SessionMgr["Session Managers"]
            AIRuntimes["AI Colleague Runtimes"]
            EscOrch["Escalation Orchestrators"]
        end

        subgraph "Data Layer"
            PrimaryDB["Primary Database"]
            ReadReplicas["Read Replicas"]
            Cache["Cache Layer"]
            EventStore["Event Store"]
        end

        subgraph "External"
            VoiceEngine["Voice Engine"]
            Providers["External Providers"]
        end
    end

    Dev --> Staging
    Staging --> Production

    Identity --> PrimaryDB
    TenantSvc --> PrimaryDB
    KnowledgeSvc --> PrimaryDB
    ConfigSvc --> PrimaryDB
    BillingSvc --> PrimaryDB
    ComplianceSvc --> PrimaryDB
    AuditSvc --> EventStore
    IncidentSvc --> EventStore

    PrimaryDB --> ReadReplicas
    PrimaryDB --> Cache

    ChannelGW --> SessionMgr
    SessionMgr --> AIRuntimes
    AIRuntimes --> EscOrch
    AIRuntimes --> VoiceEngine
    ChannelGW --> Providers
```

---

## 12. Security Architecture Map

```mermaid
graph TB
    subgraph "Security Domains"
        AuthN["Authentication"]
        AuthZ["Authorization"]
        TenantIsolation["Tenant Isolation"]
        Secrets["Secrets Management"]
        Encryption["Encryption"]
        PrivAccess["Privileged Access"]
        Audit["Audit"]
        AdminAccess["Administrative Access"]
    end

    subgraph "Identity Service"
        Users["Users"]
        Roles["Roles"]
        Permissions["Permissions"]
        Tokens["Tokens"]
    end

    subgraph "Tenant Isolation"
        DBIsolation["Database Isolation"]
        AppIsolation["Application Isolation"]
        APIIsolation["API Isolation"]
    end

    AuthN --> Users
    AuthN --> Tokens
    AuthZ --> Roles
    AuthZ --> Permissions
    TenantIsolation --> DBIsolation
    TenantIsolation --> AppIsolation
    TenantIsolation --> APIIsolation
    PrivAccess --> AdminAccess
    Audit --> AdminAccess
```

---

## Component Interaction Summary

| Component | Interacts With | Direction | Purpose |
|-----------|---------------|-----------|---------|
| Customer | Channel Gateway | Inbound | Customer initiates contact |
| Channel Gateway | Session Manager | Inbound | Route to session |
| Session Manager | AI Colleague Runtime | Bidirectional | Manage conversation |
| AI Colleague Runtime | Voice Engine Boundary | Outbound | Start voice session |
| Voice Engine Boundary | Frozen Voice Engine | Outbound | Execute voice processing |
| AI Colleague Runtime | Knowledge Retrieval | Outbound | Get approved knowledge |
| AI Colleague Runtime | Context Management | Bidirectional | Read/write context |
| AI Colleague Runtime | Escalation Orchestrator | Outbound | Trigger escalation |
| Escalation Orchestrator | Human Agent | Outbound | Connect to human |
| Control Plane | Interaction Plane | Bidirectional | Configure and monitor |
| Control Plane | External Providers | Outbound | Manage integrations |
| Audit Service | Event Store | Inbound | Record audit events |
| Incident Service | Event Store | Inbound | Record incidents |

---

## Rules for Future Updates

- Component changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Component updates may require corresponding updates to ARCHITECTURE.md
- Diagrams must remain logically consistent with ARCHITECTURE.md
- Future APIs are clearly marked as TARGET architecture where they do not currently exist

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004C — Architecture Design