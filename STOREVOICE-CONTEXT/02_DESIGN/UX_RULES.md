# UX_RULES.md — StoreVoice User Experience Rules

**Purpose:** Defines user experience principles, patterns, and rules for StoreVoice.

**Status:** DECISION

**Scope:** This document establishes how users interact with StoreVoice.

---

## UX Principles

### AI Colleague Experience

A StoreVoice AI colleague should feel like a genuine colleague within the customer's organisation.

The colleague should:

* understand its assigned role;
* know the company;
* know the relevant products/services;
* communicate naturally;
* conduct meaningful conversations;
* understand customer context;
* remember relevant information when permitted and available;
* work with human colleagues;
* know its own knowledge boundaries;
* escalate when appropriate;
* remain positive and professional.

The exact technical implementation may evolve as AI technology evolves.

Do NOT freeze the future into today's technical limitations.

The constant is:

> **The AI colleague concept.**

### Character Without Ego

A StoreVoice AI colleague may have:

* personality;
* character;
* communication style;
* warmth;
* humour;
* contextual behaviour;
* relationship continuity.

However:

> **Character is allowed. Ego is not.**

The AI must not become:

* angry;
* offended;
* vindictive;
* hostile;
* resentful;
* manipulative;
* negative for its own sake.

The AI may recognise negative human behaviour and respond appropriately.

It may set boundaries.

It may de-escalate.

It may recommend human intervention.

But it must not behave as though it has been personally insulted.

### Human Experience and Empathy

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

Example:

A human says:

> "It is incredibly hot today."

The AI may naturally acknowledge the situation.

It must not falsely claim:

> "I am hot too."

because the AI does not physically experience temperature.

Likewise:

Acceptable:

> "I understand that this is frustrating."

Not acceptable:

> "I feel exactly what you feel."

The principle is:

> **Understand and respond to human experience without pretending to personally experience what it cannot experience.**

### Anticipate, Do Not Initiate

A particularly important social principle:

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

### Memory and Context

Relevant memory is an important part of becoming a genuine AI colleague.

When appropriate and permitted, the AI should be able to remember relevant information from previous interactions.

Example:

A customer previously mentions that their daughter is getting married.

At a later interaction, the AI may appropriately remember and acknowledge that context.

The objective is not to pretend that the AI has human feelings.

The objective is:

> **A good colleague remembers relevant things about people they work with.**

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

## Navigation Patterns

### Customer Experience

The customer should eventually stop thinking about StoreVoice.

Not because StoreVoice becomes irrelevant.

Because the service simply works.

The customer should think:

> **"My AI colleagues are taken care of."**

StoreVoice should be the organisation behind the scenes.

The customer should be able to focus on their own business.

### Demo Experience

The StoreVoice demo should demonstrate the future AI colleague experience rather than simply explaining AI technology.

The prospect enters the URL of their company website.

StoreVoice uses the public website information to create a temporary demo AI colleague.

Target experience:

> **Within approximately 30 seconds, the prospect can call their own temporary AI colleague.**

The AI may introduce itself using the company's identity.

Example:

> "Hello, I'm the AI assistant of Bakkerij Hansen. How can I help you?"

The AI uses information available from the company's website.

It must not invent information that is not available.

---

## Interaction Patterns

### AI Colleague Interaction

* Natural conversation
* Contextual understanding
* Professional communication
* Appropriate emotional intelligence
* Knowledge boundary awareness
* Smooth escalation to humans

### Customer-StoreVoice Interaction

* White Glove service
* Ongoing support
* Quality assurance
* Customer insight reporting
* Continuous improvement

---

## Form Design

### Demo Flow

1. Prospect enters company website URL
2. StoreVoice gathers public website information
3. Temporary demo AI colleague is created
4. Demo becomes available in approximately 30 seconds
5. Prospect calls the demo
6. Demo conversation lasts up to approximately 90 seconds
7. Demo ends
8. Prospect receives an SMS
9. Approximately one day later, prospect receives an email containing a conversation summary
10. A final sales message follows
11. Prospect can share the demo with another decision-maker using a colleague/partner sharing mechanism
12. If the prospect takes no action, the temporary demo is removed after approximately 48 hours

---

## Feedback Mechanisms

### Customer Insight

StoreVoice should periodically provide customers with meaningful insight into customer experience.

This may include:

* customer experience;
* recurring questions;
* recurring problems;
* reasons for escalation;
* customer friction;
* important patterns;
* operational observations;
* potential improvements.

The exact reporting format and frequency may evolve.

The important principle is:

> **StoreVoice should tell the company what its customers are experiencing.**

The AI colleague can therefore become an important source of customer intelligence.

### QA and Continuous Improvement

StoreVoice should operate with the mindset of a professional call centre.

Conversations are not merely transactions.

They are also sources of operational learning.

QA and AI-assisted analysis may identify:

* recurring customer problems;
* recurring questions;
* escalation causes;
* knowledge gaps;
* customer experience issues;
* operational problems;
* areas where company processes could improve.

StoreVoice should use this information to improve the AI colleague where appropriate.

AI may assist StoreVoice QA processes.

The AI is therefore not merely an answering machine.

It becomes part of a continuously supervised service operation.

---

## Error States

### Knowledge Gaps

If the AI does not have the required knowledge:

1. Acknowledge the limitation honestly
2. Explain what information is available
3. Offer to connect with a human colleague who can help
4. Ensure the customer does not need to repeat their story

### System Issues

If technical issues prevent normal operation:

1. Acknowledge the issue professionally
2. Offer alternative contact methods
3. Escalate to human support as appropriate

---

## Loading States

### Demo Creation

* Show clear progress during the approximately 30-second setup
* Provide estimated time remaining
* Confirm when the demo is ready

### AI Processing

* Natural conversation pacing
* Appropriate response timing
* Clear indication when the AI is processing complex requests

---

## Empty States

### No Knowledge Available

If the AI has no relevant knowledge for a request:

1. Acknowledge the limitation
2. Explain what information sources are available
3. Offer to connect with appropriate human support

### No Previous Context

If this is the first interaction:

1. Welcome the customer professionally
2. Introduce itself appropriately
3. Begin building the relationship naturally

---

## User Flows

### Customer Onboarding Flow

1. StoreVoice interviews the customer
2. StoreVoice understands the company
3. StoreVoice understands the required role
4. StoreVoice explains what information is required
5. StoreVoice collects documents and relevant information
6. StoreVoice builds the knowledge basis
7. StoreVoice trains/instructs the AI colleague
8. StoreVoice tests the AI colleague
9. StoreVoice refines the AI colleague
10. StoreVoice puts the AI colleague into production

Target onboarding time: approximately 5–7 days depending on complexity.

### AI Colleague Daily Operation Flow

1. Customer contacts the business
2. AI colleague handles the initial contact
3. AI colleague understands the customer's needs
4. AI colleague provides appropriate information or service
5. If needed, AI colleague escalates to human colleague
6. AI colleague ensures smooth handoff with context
7. StoreVoice QA reviews the interaction
8. StoreVoice improves the AI colleague based on learning

---

## Usability Testing

### Customer Experience Testing

* Measure customer satisfaction with AI colleague interactions
* Track escalation rates and reasons
* Monitor knowledge gap identification
* Assess overall service quality

### Demo Effectiveness Testing

* Measure prospect engagement with demo
* Track conversion from demo to customer
* Assess emotional/commercial reaction ("WOW" factor)
* Monitor demo sharing and referral rates

---

## Rules for Future Updates

- UX changes require human owner approval
- All modifications must be recorded in `05_DECISIONS/CHANGELOG.md`
- Changes must follow the governance workflow in `AGENTS.md`
- UX updates may require corresponding updates to DESIGN_SYSTEM.md and VISUAL_DIRECTION.md

---

**Last Updated:** 2026-09-04
**Approved By:** Change 002 — Establish StoreVoice Vision and AI Colleague Philosophy