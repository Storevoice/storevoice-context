# Human Escalation System Specification

## Purpose

This document defines the human escalation system for the StoreVoice orchestration system. This system ensures that decisions requiring human judgment are properly escalated.

## Mandatory Human Escalation

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

## Escalation Protocol

```
STOP → IDENTIFY → DOCUMENT → ESCALATE
```

The agent must NOT invent an answer to keep execution moving.

## Escalation Structure

```json
{
  "escalation_id": "string",
  "task_id": "string",
  "agent": "string",
  "escalation_reason": "string",
  "escalation_type": "string",
  "context": "string",
  "options": ["string"],
  "recommendation": "string",
  "constraints": ["string"],
  "timestamp": "string",
  "status": "string"
}
```

## Escalation Types

### Founder Decision Required
- Product direction
- Business model
- Pricing
- Brand direction
- Architecture approval
- Major scope changes

### Architectural Conflict
- Conflicting architectural decisions
- Architecture violation
- Major architecture changes

### Source of Truth Conflict
- Contradiction in approved truth
- Missing information in Source of Truth
- Ambiguity in approved decisions

### Security/Compliance Incident
- Security vulnerability
- Compliance violation
- Regulatory uncertainty
- Legal uncertainty

### Customer Incident
- Serious customer issue
- Service degradation
- Data breach concern

### Repeated Failure
- 3+ failures on same task
- Autonomous revision exhausted
- Systemic quality issue

## Escalation Handling

When an escalation occurs:
1. Stop the affected task
2. Record the escalation
3. Create escalation artifact
4. Enter safe waiting state
5. Wait for human decision
6. Record human decision
7. Resume or cancel based on decision

## Escalation Waiting State

While waiting for human decision:
- Task remains in ESCALATED state
- Dependent tasks are blocked
- Unrelated tasks continue where safe
- System preserves full context
- No autonomous decisions are made

## Escalation Resolution

When human decision is received:
1. Record the decision
2. Update task state
3. Resume or cancel task
4. Update dependent tasks
5. Record resolution in audit trail

## Escalation Audit

All escalations must be recorded in the audit trail to enable:
- Escalation pattern analysis
- Process improvement
- Decision documentation
- Accountability tracking