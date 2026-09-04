# OPEN_DECISIONS.md — Unresolved StoreVoice Decisions

**Purpose:** Records genuinely unresolved decisions that become visible from the Founder Decision Set.

**Status:** OPEN

**Scope:** This document captures decisions that remain unresolved and require future determination.

**Important:** Do not fill in these decisions yourself. They require explicit founder or authorized approval.

---

## Technical Architecture Decisions

**Cross-reference:** See `ARCHITECTURE_DECISION_PACKAGES.md` for organized decision packages.

### Platform Architecture
* Exact technical architecture for `storevoice.ai` platform → **PACKAGE 01: PB-01, PB-02, PB-03**
* Cloud provider and infrastructure architecture → Deferred to implementation
* Deployment architecture → Deferred to implementation
* Scaling architecture → Deferred to implementation
* Observability architecture → Deferred to implementation

### Data Architecture
* Exact data model for customer data, knowledge, and configurations → **PACKAGE 03: TI-01 through TI-05, CI-01, CI-02**
* Database technology and schema design → Deferred to implementation
* Data retention and archival strategies → **PACKAGE 13: CG-03**
* Backup and disaster recovery architecture → Deferred to implementation

### AI Architecture
* Exact AI model selection and abstraction layer → **PACKAGE 17: PA-01, PA-02, PA-03**
* AI provider abstraction architecture → **PACKAGE 17: PA-01, PA-02, PA-03**
* AI model versioning and upgrade strategy → **PACKAGE 02: VE-01**
* AI performance monitoring and optimization → Deferred to implementation

### Integration Architecture
* Exact integration patterns for phone, WhatsApp, email, SMS → **PACKAGE 07: CH-01, CH-02, CH-03**
* Telecom abstraction architecture → **PACKAGE 17: PA-04**
* Payment integration architecture → **PACKAGE 12: BC-01**
* Third-party service integration architecture → **PACKAGE 17: PA-04, PA-05**

---

## Compliance Architecture Decisions

**Cross-reference:** See `ARCHITECTURE_DECISION_PACKAGES.md` PACKAGE 13.

### Legal Compliance
* Exact legal validity of Greek-based operation model → **FQ-05: OPEN — LEGAL REQUIRED**
* Specific compliance mechanisms for European AI regulations → **PACKAGE 13: CG-01, CG-02**
* Data protection implementation architecture → **PACKAGE 13: CG-02**
* Legal retention requirements and implementation → **PACKAGE 13: CG-03**

### Regulatory Monitoring
* Exact process for monitoring European AI regulatory developments → **PACKAGE 13: CG-04**
* Compliance change management architecture → **PACKAGE 13: CG-04**
* Customer notification mechanisms for compliance changes → **PACKAGE 13: CG-04**

---

## Localization Architecture Decisions

**Cross-reference:** See `ARCHITECTURE_DECISION_PACKAGES.md` PACKAGE 06.

### Localization Implementation
* Exact localization architecture for multi-country support → **PACKAGE 06: LA-01, LA-02**
* AI behavior localization mechanisms → **PACKAGE 06: LA-03**
* Documentation localization architecture → **PACKAGE 06: LA-04**
* Invoice and report localization architecture → **PACKAGE 06: LA-04**

### Cultural Adaptation
* Exact process for cultural expression adaptation → **PACKAGE 06: LA-03**
* Communication style localization mechanisms → **PACKAGE 06: LA-03**
* Regional nuance handling architecture → **PACKAGE 06: LA-03**

---

## Operational Architecture Decisions

**Cross-reference:** See `ARCHITECTURE_DECISION_PACKAGES.md` PACKAGES 09, 18.

### Customer Administration
* Exact customer administration architecture → **PACKAGE 03: CI-01, CI-02**
* Onboarding workflow architecture → **PACKAGE 09: CL-01, CL-02, CL-03, CL-04**
* White Glove service operations architecture → **PACKAGE 18: FQ-07**
* Customer lifecycle management architecture → **PACKAGE 09: CL-05, CL-06, CL-07, CL-08**

### Knowledge Management
* Exact knowledge versioning and approval architecture → **PACKAGE 04: KA-01, KA-02, KA-03**
* Conflict detection and resolution architecture → **PACKAGE 04: KA-04**
* Knowledge audit trail architecture → **PACKAGE 14: AR-01, AR-02, AR-03, AR-04**
* Knowledge export and deletion architecture → **PACKAGE 04: KA-05, KA-06**

### Incident Management
* Exact incident detection and escalation architecture → **PACKAGE 15: IS-01, IS-02**
* AI colleague offline capability architecture → **PACKAGE 15: IS-03**
* Post-incident review architecture → **PACKAGE 15: IS-05**
* Structural improvement deployment architecture → **PACKAGE 15: IS-04**

---

## Commercial Architecture Decisions

**Cross-reference:** See `ARCHITECTURE_DECISION_PACKAGES.md` PACKAGES 10, 11, 12.

### Package Management
* Exact package feature gating architecture → **PACKAGE 10: PE-01, PE-02**
* Upgrade/downgrade workflow architecture → **PACKAGE 09: CL-05**
* Proration calculation architecture → **PACKAGE 12: BC-03**
* Package boundary enforcement architecture → **PACKAGE 10: PE-02**

### Demo Architecture
* Exact demo creation architecture → **PACKAGE 11: DM-01, DM-02**
* Website scraping architecture → **PACKAGE 11: DM-01**
* Temporary demo instance management → **PACKAGE 11: DM-02**
* Follow-up sequencing architecture → **PACKAGE 11: DM-04**

---

## Service Architecture Decisions

**Cross-reference:** See `ARCHITECTURE_DECISION_PACKAGES.md` PACKAGES 08, 15.

### Human Escalation
* Exact human escalation workflow architecture → **PACKAGE 08: HE-01, HE-02**
* Transfer to human agent architecture → **PACKAGE 08: HE-03**
* Callback scheduling architecture → **PACKAGE 08: HE-04**
* 24/7 human assistance architecture → **PACKAGE 08: HE-05**

### Quality Assurance
* Exact QA workflow architecture → **PACKAGE 18: Operating Model**
* Reporting architecture → Deferred to implementation
* Continuous improvement architecture → **PACKAGE 15: IS-05**
* Learning across customers architecture → **PACKAGE 16: DL-02, DL-03**

---

## Multi-Tenant Architecture Decisions

**Cross-reference:** See `ARCHITECTURE_DECISION_PACKAGES.md` PACKAGE 03.

### Tenant Isolation
* Exact tenant isolation architecture → **PACKAGE 03: TI-01, TI-02, TI-03, TI-04, TI-05**
* Data separation mechanisms → **PACKAGE 03: TI-01**
* Configuration separation mechanisms → **PACKAGE 03: TI-02**
* Knowledge separation mechanisms → **PACKAGE 03: TI-03**

### Shared Infrastructure
* Exact shared infrastructure architecture → Deferred to implementation
* Resource allocation architecture → Deferred to implementation
* Performance isolation architecture → Deferred to implementation
* Security isolation architecture → **PACKAGE 03: TI-01**

---

## Rules for Future Updates

- Only genuinely unresolved decisions should be listed here
- Decisions must be traced back to specific Founder Decision Set sections
- When a decision is made, it must be removed from this document and recorded in `DECISIONS.md`
- All modifications must be recorded in `CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`

---

**Last Updated:** 2026-09-04
**Approved By:** Change 003A — Founder Decision Set Consolidation