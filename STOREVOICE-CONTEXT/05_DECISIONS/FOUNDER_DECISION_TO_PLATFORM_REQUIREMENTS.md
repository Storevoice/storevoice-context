# FOUNDER_DECISION_TO_PLATFORM_REQUIREMENTS.md — Derived Platform Requirements

**Purpose:** Translates explicit Founder Decisions into capabilities the future platform must eventually support.

**Status:** DECISION

**Scope:** This document derives required platform capabilities from the Founder Decision Set without designing technical architecture.

**Important:** This is NOT architecture. Architectural implications remain OPEN.

---

## 6.1 Company Identity

### Founder Decision
StoreVoice is a service company, not primarily a technology company. The delivered value is the AI colleague and the service surrounding it.

### Required Capability
The platform must support delivery and management of AI colleagues as a service, not just as technology.

### Architectural implication
OPEN.

---

## 6.2 European Company

### Founder Decision
StoreVoice is fundamentally Europe-oriented. Europe is treated as one strategic market. There is one central StoreVoice platform: `storevoice.ai`. StoreVoice does not create separate national StoreVoice products.

### Required Capability
The platform must support multi-country operation from a single central platform.

### Architectural implication
OPEN.

---

## 6.3 Central Platform

### Founder Decision
`storevoice.ai` remains the central platform from which StoreVoice services are launched.

### Required Capability
The platform must be accessible via `storevoice.ai` as the central entry point.

### Architectural implication
OPEN.

---

## 6.4 Local Customer Experience

### Founder Decision
StoreVoice must make the customer experience feel native to the customer's country. Localization is NOT merely translation. The experience should feel German for a German customer in language, wording, communicative behavior, cultural expression, AI behavior, customer-facing documentation, invoices, reports, and general service experience.

### Required Capability
The platform must support country-aware localization across all customer-facing experiences, including AI behavior, documentation, invoices, and reports.

### Architectural implication
OPEN.

### Frozen Founder Decision (Change 004B)
**FQ-05 — European Language Scope:** The architecture must be capable of supporting all European languages and localized customer experiences. Individual languages and markets may be rolled out progressively. This does NOT require every language to be commercially launched immediately. It DOES require the architecture to avoid artificial limitations that would prevent future European language and localization expansion. Localization includes more than translation. The architecture must allow country-specific language, wording, communication style, formality, cultural behavior, and customer-facing experience while maintaining the central StoreVoice platform.

---

## 6.5 AI Colleague Philosophy

### Founder Decision
AI is a colleague, not merely a tool. AI should feel natural, helpful and trustworthy. StoreVoice does not hide that the customer is interacting with AI. The AI may have a persona. Context and experience can develop that persona into a colleague-like experience. AI can recognize human emotion and respond appropriately. AI does not pretend to personally experience human emotions. AI may anticipate human needs but must not manufacture emotional situations. AI must not invent information.

### Required Capability
The platform must support AI colleague personas, emotional recognition and appropriate response, context-aware interaction, and strict knowledge boundaries.

### Architectural implication
OPEN.

### Frozen Founder Decision (Change 004B)
**FQ-01 — Engine Modification Policy:** The Voice Engine remains frozen by default. Modification is permitted only through an explicit human-approved architectural change when the required capability cannot reasonably be implemented outside the engine without compromising correctness, performance, maintainability, or product requirements. This decision affects how AI colleague personas, emotional recognition, and context-aware interaction can be implemented — either within the engine (if modification is approved) or at the platform level (if the capability can be reasonably implemented outside the engine).

---

## 6.6 Human Responsibility

### Founder Decision
There is always human responsibility behind the AI colleague. AI may operate autonomously within human-defined boundaries. Important decisions remain human decisions. Technology replacement remains a human decision.

### Required Capability
The platform must support human oversight, authorization controls for important decisions, and human-in-the-loop processes.

### Architectural implication
OPEN.

---

## 6.7 Human Escalation

### Founder Decision
Human escalation is appropriate when: a decision is required, emotion makes human involvement materially useful, the caller explicitly requests a human, the AI lacks required knowledge, or a human can materially help. For White Glove customers: human assistance is available 24/7, a call can be transferred to a human, outside human working hours, a callback can occur.

### Required Capability
The platform must support human escalation workflows, including transfer to human agents and callback scheduling.

### Architectural implication
OPEN.

### Frozen Founder Decision (Change 004B)
**FQ-07 — White Glove Service Scope:** White Glove provides 24/7 human responsibility and escalation. This does NOT mean StoreVoice must maintain an immediately available live human operator every minute of every day. When immediate human intervention is required and a human is available, the customer/caller may be transferred. When immediate human intervention is required outside human availability, the AI must handle the situation safely, preserve the relevant context, and arrange appropriate human follow-up/callback. The principle is: HUMAN RESPONSIBILITY 24/7. Not: 24/7 staffed call-centre obligation.

---

## 6.8 Autonomous Operation

### Founder Decision
AI should operate as autonomously as reasonably possible. Autonomous actions are allowed only where included in the customer's package and within StoreVoice rules. Technical capability does not automatically imply business authorization.

### Required Capability
The platform must support configurable autonomy levels per customer package, with business rule enforcement.

### Architectural implication
OPEN.

---

## 6.9 Technology Evolution

### Founder Decision
StoreVoice should actively improve its technology. Better technology may replace existing technology. The decision to replace production technology is ALWAYS human. AI may test, compare and advise. AI may NOT autonomously decide to replace production technology. Existing customer continuity has priority over immediately adopting new technology.

### Required Capability
The platform must support technology versioning, controlled rollouts, and human authorization for production changes.

### Architectural implication
OPEN.

### Frozen Founder Decisions (Change 004B)
**FQ-01 — Engine Modification Policy:** The Voice Engine remains frozen by default. Modification is permitted only through an explicit human-approved architectural change when the required capability cannot reasonably be implemented outside the engine without compromising correctness, performance, maintainability, or product requirements.

**FQ-02 — Engine Replacement Policy:** The Voice Engine is replaceable, but the StoreVoice platform contract is not. The architecture must maintain a clean Voice Engine boundary/interface so that the underlying engine can eventually be replaced without requiring reconstruction of the StoreVoice platform. Replacement requires explicit human approval and must consider capability, reliability, latency, compliance, quality, operational implications, migration risk, and customer continuity. Existing customer continuity takes precedence over adopting newer technology merely because it exists.

---

## 6.10 European Compliance

### Founder Decision
StoreVoice intends to operate according to applicable European rules and regulations governing AI and its use. Compliance with European rules is a major differentiator. StoreVoice monitors relevant European AI regulatory developments. When applicable European rules change, StoreVoice adapts the service as necessary. Customers do not have an option to refuse changes that are necessary for regulatory compliance.

### Required Capability
The platform must support compliance monitoring, service adaptation for regulatory changes, and centralized compliance management.

### Architectural implication
OPEN.

---

## 6.11 Customer Data and Information

### Founder Decision
The customer decides what business information and data to provide. StoreVoice checks whether the intended use fits applicable European rules. Information that cannot legitimately be used is not accepted for the AI colleague. The customer remains responsible for the correctness and legality of information supplied by the customer. StoreVoice remains responsible for its processing within the StoreVoice service. StoreVoice proactively warns about potential compliance, privacy or safety risks.

### Required Capability
The platform must support data intake validation, compliance checking, risk warnings, and clear responsibility boundaries.

### Architectural implication
OPEN.

---

## 6.12 Conflicting Information

### Founder Decision
When customer information conflicts: StoreVoice does not allow the AI to arbitrarily select the truth. The conflict is presented to the customer. The customer decides which information is correct. The last approved information remains authoritative until the customer confirms the new information. The AI continues operating using safe, approved information while the conflict is unresolved.

### Required Capability
The platform must support conflict detection, approval state management, and versioned knowledge with authoritative state.

### Architectural implication
OPEN.

---

## 6.13 Knowledge Transparency

### Founder Decision
The customer can see the information currently approved as knowledge for the AI colleague. The customer can correct it. Changes, blocks and replacements are recorded. Knowledge history functions as an audit trail. StoreVoice must be able to reconstruct relevant information and context during an incident.

### Required Capability
The platform must support knowledge visibility, editing, version history, and audit trail capabilities.

### Architectural implication
OPEN.

---

## 6.14 Incident Management

### Founder Decision
StoreVoice takes human responsibility for serious customer problems. StoreVoice proactively investigates problems that could affect multiple customers. Safety and continuity come before complete root-cause analysis. In exceptional circumstances, an AI colleague may be taken offline to protect customers. Every serious incident receives a human post-incident review.

### Required Capability
The platform must support incident detection, escalation, AI colleague offline capability, and post-incident review processes.

### Architectural implication
OPEN.

---

## 6.15 Central Product Standard

### Founder Decision
StoreVoice maintains one central product standard. Product improvements generally apply to all relevant customers. Local or customer-specific deviations are exceptions. Every deviation must be explicitly recorded. Long-term technical divergence between customers should be avoided.

### Required Capability
The platform must support centralized product standards, deviation tracking, and controlled customer-specific exceptions.

### Architectural implication
OPEN.

---

## 6.16 Customer Fit

### Founder Decision
StoreVoice does NOT establish an automatic customer-selection mechanism as part of the business vision.

### Required Capability
No specific platform capability required.

### Architectural implication
OPEN.

---

## 6.17 Multi-Tenant Principle

### Founder Decision
StoreVoice is always multi-tenant. Each customer has a strictly separated account/tenant. Customer data, context, configuration and knowledge must not cross tenant boundaries. Central infrastructure may be shared, but customer information remains separated.

### Required Capability
The platform must support strict tenant isolation for customer data, context, configuration, and knowledge.

### Architectural implication
OPEN.

---

## 6.18 Learning Across Customers

### Founder Decision
StoreVoice may learn from general operational experience. StoreVoice may use anonymized and aggregated patterns to improve the general product. Individual customer data must not become another customer's AI knowledge. Confidential customer information must not flow between customers. StoreVoice does not sell or rent customer data.

### Required Capability
The platform must support anonymized and aggregated learning without cross-customer data leakage.

### Architectural implication
OPEN.

### Frozen Founder Decision (Change 004B)
**FQ-08 — Customer Knowledge Ownership:** Customer-specific knowledge is deleted after termination, subject to the established 14-day recovery/reactivation period and any legally required retention. StoreVoice may retain genuinely non-identifiable, aggregated/general insights for improvement of the central StoreVoice product. Examples include: recurring categories of questions, anonymized escalation patterns, aggregate QA findings, general knowledge gaps, and aggregate product-performance patterns. StoreVoice MUST NOT retain customer-identifiable or reconstructable customer-specific knowledge for this purpose. The architecture must maintain a hard distinction between: (1) tenant/customer data and knowledge, and (2) StoreVoice-owned general learning and improvement. Customer data must not cross tenant boundaries.

---

## 6.19 Ownership

### Founder Decision
Customer owns the business information the customer provides. StoreVoice owns its technology, platform, general methodologies, general operational knowledge, QA knowledge, general improvements, and general best practices.

### Required Capability
The platform must clearly distinguish customer-owned data from StoreVoice-owned general knowledge and improvements.

### Architectural implication
OPEN.

---

## 6.20 Customer Exit

### Founder Decision
Services are prepaid. Standard packages are monthly cancellable. Cancellation stops renewal. Service continues through the paid period. The account has a 14-day recovery period. After 14 days, customer-specific data and AI knowledge are permanently deleted, subject to legally required retention. A returning customer after permanent deletion is treated as a new customer.

### Required Capability
The platform must support customer lifecycle management, including cancellation, recovery periods, and compliant data deletion.

### Architectural implication
OPEN.

---

## 6.21 Central Customer Administration

### Founder Decision
StoreVoice operates one central European customer administration from Greece. There are not separate country-specific customer administrations. Customer-facing administration should nevertheless be localized to the customer's country where already decided.

### Required Capability
The platform must support centralized customer administration with localized customer-facing interfaces.

### Architectural implication
OPEN.

---

## 6.22 Commercial Packages

### Founder Decision
Package A: €29/month, basic AI colleague telephone answering, self-setup OR White Glove. Package B: €29 first month, €59/month thereafter, includes appointment scheduling, self-setup OR White Glove. Enterprise: high monthly fee, high-touch / total-service model, no one-time implementation fee as the core model, White Glove / full responsibility is inherent.

### Required Capability
The platform must support package-based feature gating, pricing tiers, and self-setup vs White Glove options.

### Architectural implication
OPEN.

---

## 6.23 Package Boundaries

### Founder Decision
Features are tied to packages. Customers cannot arbitrarily bolt on individual features outside their package. Upgrade is immediate and prorated through Stripe. Downgrade takes effect at the end of the current month.

### Required Capability
The platform must support package-based feature enforcement, immediate upgrades with proration, and end-of-month downgrades.

### Architectural implication
OPEN.

---

## 6.24 Payment and Administration

### Founder Decision
Stripe handles payments. Services are prepaid. Customer administration is centralized.

### Required Capability
The platform must integrate with Stripe for payment processing and support prepaid service models.

### Architectural implication
OPEN.

---

## 6.25 Channels

### Founder Decision
The AI is intended to be the first contact point through: phone, WhatsApp, email, SMS.

### Required Capability
The platform must support multi-channel AI interaction across phone, WhatsApp, email, and SMS.

### Architectural implication
OPEN.

---

## 6.26 Phone

### Founder Decision
StoreVoice uses Twilio for phone service. Customers receive a local number where possible. Local number provisioning is intended to be automatic. Where local telecom rules or number availability make this difficult, an alternative is offered.

### Required Capability
The platform must integrate with Twilio for phone services and support automatic local number provisioning.

### Architectural implication
OPEN.

---

## 6.27 Onboarding

### Founder Decision
White Glove onboarding is human-led. StoreVoice employees interview the customer and collect relevant information/documents. StoreVoice configures, trains/instructs, tests and refines the AI colleague. Target is approximately 5–7 days, but quality is the readiness gate. A/B onboarding can in principle be fully AI-driven based on documents and information. Customers can always add or correct relevant information. Onboarding progress should be visible to the customer. 100% means ready to go live.

### Required Capability
The platform must support onboarding workflows, progress tracking, knowledge intake, and AI colleague configuration.

### Architectural implication
OPEN.

---

## 6.28 White Glove

### Founder Decision
White Glove means StoreVoice takes responsibility for virtually everything required to operate the AI colleague while the subscription remains active. This includes: onboarding, knowledge collection, training/instruction, testing, QA, operations, reporting, improvements, knowledge updates, human escalation.

### Required Capability
The platform must support White Glove service operations, including knowledge management, QA, reporting, and escalation workflows.

### Architectural implication
OPEN.

---

## 6.29 Demo

### Founder Decision
Prospect enters the website. StoreVoice uses the prospect's website information to create a temporary demo agent. The demo uses only scraped website knowledge. It is a commercial experience, not a full trial. The intended experience is approximately 90 seconds. Demo agent can introduce itself as the company's AI assistant/colleague. Demo may support sharing with a colleague/partner. Follow-up includes immediate/near-immediate SMS and email sequencing. Demo expires after approximately 48 hours if no action is taken.

### Required Capability
The platform must support demo creation from website scraping, temporary demo instances, and follow-up sequencing.

### Architectural implication
OPEN.

### Frozen Founder Decision (Change 004B)
**FQ-09 — Demo Conversion Policy:** Demo instances are temporary by design. The normal demo retention period is approximately 48 hours when there is no customer action. The demo lifecycle must be measurable and configurable. The system should be capable of measuring events such as: demo creation, demo activation, demo call, demo completion, follow-up interaction, conversion, expiry, and reactivation/action. No assumed demo conversion rate becomes a hard architectural constraint. Conversion rate is a commercial metric that may change over time.

---

## 6.30 Service Philosophy

### Founder Decision
The customer runs their business. StoreVoice runs their AI colleagues. The desired customer reaction is: WOW.

### Required Capability
The platform must deliver a service experience that prioritizes customer outcomes over technology.

### Architectural implication
OPEN.

---

## Rules for Future Updates

- Derived requirements must trace back to specific Founder Decisions
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- This document is NOT architecture — it identifies required capabilities only

---

**Last Updated:** 2026-09-04
**Approved By:** Change 004B — Freeze Founder Architecture Decisions