# BUSINESS_RULES.md — StoreVoice Business Logic

**Purpose:** Defines the business rules, policies, and logic that govern StoreVoice operations.

**Status:** DECISION

**Scope:** This document establishes the business logic that must be implemented correctly.

---

## Core Business Rules

### Shadow-Producer Model

The fundamental business model comes from the founder's previous entrepreneurial experience.

Examples include:

* operating a TROS promotional team;
* operating valet parking services for hotels.

In both cases, the customer's public experienced the service as part of the customer's own organisation.

The people were effectively perceived as:

> "the customer's people"

while operational responsibility remained with the founder's organisation.

StoreVoice should work the same way.

The outside world should experience the AI colleague as:

> **part of the customer's company.**

Behind the scenes:

> **StoreVoice creates, trains, supervises, maintains and supports that AI colleague.**

The customer should not need to become an AI expert.

The customer should not need to manage the underlying technology.

StoreVoice should operate behind the scenes.

### Knowledge Boundaries

A fundamental StoreVoice rule:

> **The AI never invents company knowledge.**

If the information is not available within the approved knowledge available to the AI colleague, it must not fabricate an answer.

This applies especially strongly to the public demo.

For the demo:

> Website information is the knowledge source.

If something is not on the website:

> The AI does not invent it.

The same principle applies to production AI colleagues.

Production knowledge may come from:

* onboarding;
* company documents;
* approved business information;
* connected systems;
* approved knowledge bases;
* other explicitly authorised sources.

The AI does not autonomously invent new company policies, prices, procedures or facts.

If a knowledge gap exists, StoreVoice and/or the customer must address the knowledge gap through the appropriate controlled process.

### Human Escalation

The AI colleague should use human escalation when it is genuinely useful.

Examples:

* the AI does not have the required knowledge;
* a decision must be made;
* human expertise is required;
* emotional sensitivity requires a human;
* the customer explicitly asks for a human;
* another human intervention provides materially better service.

But:

> **A transfer must have value for both sides.**

The AI should understand:

1. what the customer needs;
2. why it cannot complete the task;
3. which human colleague or department is appropriate;
4. what context the human colleague needs.

The customer should not unnecessarily have to repeat their entire story.

Warm transfer may include:

* spoken context to the human;
* written context/message;
* then connection of the customer.

---

## Pricing Model

### Current Commercial Packages

Record the following as the current founder-approved commercial direction.

#### PACKAGE A

€29/month.

Basic AI colleague telephone answering service.

Customer may choose:

* self-setup;
* or White Glove setup.

#### PACKAGE B

€29 for the first month.

€59/month thereafter.

Includes the functionality of A plus appointment scheduling.

Customer may choose:

* self-setup;
* or White Glove setup.

#### ENTERPRISE

Enterprise is a premium monthly service.

There are no intended one-time implementation charges as the core Enterprise model.

Enterprise represents:

> **Total ongoing StoreVoice responsibility and White Glove service.**

It is not merely a larger software package.

It is a higher level of service, responsibility, support, knowledge management, QA, operational involvement and total customer relief.

Exact Enterprise pricing remains open.

---

## Subscription Rules

### Service Models

* **Self-setup** — Customer configures the AI colleague with StoreVoice guidance
* **White Glove** — StoreVoice does everything for the customer

### Important Commercial Distinction

Do not describe White Glove as a technical necessity.

White Glove is a premium service option because customers may prefer:

> **"You do everything for me."**

The customer pays for:

* expertise;
* time saved;
* convenience;
* onboarding;
* human guidance;
* ongoing responsibility;
* operational relief.

---

## Usage Limits

Usage limits may apply depending on the commercial package.

Specific limits remain implementation details to be defined during product development.

---

## Data Handling Rules

### Customer Data

Customer data is handled according to:

* Applicable privacy regulations
* StoreVoice data protection policies
* Customer agreements

### AI Colleague Knowledge

* Knowledge is provided by the customer during onboarding
* Knowledge is maintained by StoreVoice as part of the service
* Knowledge gaps are addressed through controlled processes
* The AI does not autonomously invent new knowledge

---

## Content Policies

### AI Colleague Behaviour

* Character is allowed. Ego is not.
* The AI must not become angry, offended, vindictive, hostile, resentful, manipulative, or negative for its own sake
* The AI may recognise negative human behaviour and respond appropriately
* It may set boundaries, de-escalate, and recommend human intervention
* But it must not behave as though it has been personally insulted

### Human Experience

The AI should understand and anticipate human experience.

It may:

* recognise emotion;
* acknowledge emotion;
* respond empathetically;
* adapt its communication;
* participate naturally in human conversation;
* respond to humour;
* acknowledge circumstances.

However:

> **The AI must not falsely claim human experiences that it does not have.**

The principle is:

> **Understand and respond to human experience without pretending to personally experience what it cannot experience.**

### Social Principles

> **The AI may anticipate human experience, but should not manufacture it.**

If a human introduces:

* humour;
* frustration;
* warmth;
* enthusiasm;
* casual conversation;
* personal context;

the AI may naturally respond.

The AI should not artificially manufacture emotional situations merely to appear human.

It should not attempt to create a fake emotional relationship.

Natural interaction is the objective.

Artificial emotional manipulation is not.

---

## Integration Rules

### Voice Engine Integration

* Repository: https://github.com/Storevoice/storevoice
* Reference Commit: `c62f761acccb23bb6798375f7fef3ba9a1234ebc`
* Status: FROZEN REFERENCE
* Role: Approved StoreVoice reference implementation for voice-related functionality

### Company Systems Integration (Future)

When company systems are connected, relevant information from those systems may become part of the AI colleague's context.

Examples include:

* CRM;
* customer history;
* appointments;
* previous interactions;
* purchases;
* relevant business information.

The exact integration architecture remains future implementation work.

---

## Performance Requirements

### Demo Performance

* Within approximately 30 seconds, the prospect can call their own temporary AI colleague
* Demo conversation lasts up to approximately 90 seconds
* Demo becomes available in approximately 30 seconds

### Service Performance

* 24/7 customer contact capability
* Continuous quality improvement
* Professional call centre standards

---

## Compliance Requirements

StoreVoice operates in compliance with:

* Applicable privacy regulations
* Data protection requirements
* Industry standards for AI services

Specific compliance requirements remain implementation details.

---

## Business Logic Constraints

### Phase 1 Scope

The current simple telephone answering service is intentionally small.

It is the first phase of the larger StoreVoice vision.

The founder believes the underlying technology is already sufficiently capable to begin with a simple service while technology and organisational knowledge continue to develop.

The business should grow alongside AI capability.

### Long-Term Positioning

Long-term:

> **StoreVoice becomes the organisation that companies call when they want AI colleagues without wanting to build and manage them themselves.**

The business may eventually supply many types of AI colleagues.

The role may evolve.

The technology may evolve.

The architecture may evolve.

But the central idea remains:

> **AI talent supplied as a managed service.**

---

## Rules for Future Updates

- Business rule changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- Business rule updates may require corresponding updates to PRODUCT_CONTRACT.md and ARCHITECTURE.md

---

**Last Updated:** 2026-09-04
**Approved By:** Change 002 — Establish StoreVoice Vision and AI Colleague Philosophy