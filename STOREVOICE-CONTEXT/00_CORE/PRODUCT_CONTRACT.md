# PRODUCT_CONTRACT.md — StoreVoice Product Specification

**Purpose:** Defines the explicit product scope, features, and boundaries for StoreVoice.

**Status:** DECISION

**Scope:** This document serves as the binding contract for what StoreVoice is and is not.

---

## Product Definition

StoreVoice is:

> **A total-solution employment agency for AI colleagues.**

StoreVoice specifically focuses on:

> **developing, delivering, supporting and supervising AI colleagues.**

Technology is the means.

The AI colleague is the delivered capability.

The value is:

> **total relief / complete outsourcing.**

The customer buys the outcome, not the technology.

---

## Core Features

### AI Colleague Service

* Development and delivery of AI colleagues
* Training and instruction of AI colleagues
* Ongoing support and maintenance
* Quality assurance and operational supervision
* Customer insight and reporting
* 24/7 customer contact capability

### Service Models

* **Self-setup** — Customer configures the AI colleague with StoreVoice guidance
* **White Glove** — StoreVoice does everything for the customer

### Commercial Packages

See `BUSINESS_RULES.md` for current pricing and package details.

---

## Explicitly Excluded Features

StoreVoice is NOT:

* a generic AI consultancy
* a generic automation company
* a technology company selling AI tooling
* a provider of unrelated AI systems such as warehouse logistics automation

StoreVoice does NOT:

* sell AI technology directly
* require customers to become AI experts
* expect customers to manage underlying technology

---

## User Roles

### Customer

* Business owner or representative
* Provides company information and cooperation
* Approves AI colleague behaviour and knowledge
* Receives customer insight and reporting

### StoreVoice Team

* Onboarding specialists
* AI colleague trainers
* Quality assurance analysts
* Operational support staff
* Customer success managers

---

## User Stories

### Customer Onboarding

As a business owner, I want StoreVoice to create an AI colleague for my business so that I can provide continuous customer contact without becoming an AI expert.

### Daily Operation

As a business owner, I want my AI colleague to handle customer inquiries professionally so that I can focus on my core business.

### Quality Assurance

As a business owner, I want StoreVoice to continuously improve my AI colleague based on customer interactions so that service quality improves over time.

### Customer Insight

As a business owner, I want to understand what my customers are experiencing so that I can improve my business.

---

## Acceptance Criteria

### AI Colleague Quality

* Understands its assigned role
* Knows the company and relevant products/services
* Communicates naturally
* Conducts meaningful conversations
* Understands customer context
* Remembers relevant information when permitted
* Works with human colleagues
* Knows its own knowledge boundaries
* Escalates when appropriate
* Remains positive and professional

### Service Quality

* Operates 24/7 for first-line customer contact
* Provides continuous quality improvement
* Delivers meaningful customer insight
* Maintains professional call centre standards

---

## Constraints

### Knowledge Boundaries

* The AI never invents company knowledge
* If information is not available within approved knowledge, the AI must not fabricate an answer
* Knowledge gaps must be addressed through controlled processes

### Human Escalation

* A transfer must have value for both sides
* The AI should understand what the customer needs, why it cannot complete the task, and which human colleague is appropriate
* The customer should not unnecessarily have to repeat their entire story

### Character Without Ego

* Character is allowed. Ego is not.
* The AI must not become angry, offended, vindictive, hostile, resentful, manipulative, or negative for its own sake
* The AI may recognise negative human behaviour and respond appropriately
* It may set boundaries, de-escalate, and recommend human intervention
* But it must not behave as though it has been personally insulted

---

## Dependencies

### Voice Engine

* Repository: https://github.com/Storevoice/storevoice
* Reference Commit: `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
* Status: FROZEN REFERENCE
* Role: Approved StoreVoice reference implementation for voice-related functionality

### Company Systems (Future)

* CRM integration
* Customer history
* Appointments
* Previous interactions
* Purchases
* Relevant business information

The exact integration architecture remains future implementation work.

---

## Version History

| Version | Date | Description | Approved By |
|---------|------|-------------|-------------|
| 1.0 | 2026-09-04 | Initial product specification based on founder-approved vision | Change 002 |

---

## Rules for Future Updates

- Product scope changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Feature additions require corresponding updates to BUSINESS_RULES.md and ARCHITECTURE.md

---

**Last Updated:** 2026-09-04
**Approved By:** Change 002 — Establish StoreVoice Vision and AI Colleague Philosophy