# Audit Trail System Specification

## Purpose

This document defines the audit trail system for the StoreVoice orchestration system. Every autonomous execution must be reconstructable from persistent state and artifacts.

## Audit Trail Requirements

The audit trail must answer:

1. What did the Founder ask?
2. What did the Orchestrator interpret?
3. Which agents were selected?
4. Why were they selected?
5. What context did each receive?
6. What did each produce?
7. Which dependencies existed?
8. Which reviewers evaluated the work?
9. What was rejected?
10. What was revised?
11. What was escalated?
12. What was accepted?
13. What repository changes occurred?
14. What commit resulted?
15. Why was the final outcome reached?

## Audit Record Structure

```json
{
  "audit_id": "string",
  "timestamp": "string",
  "event_type": "string",
  "task_id": "string",
  "agent": "string",
  "agent_role": "string",
  "event_description": "string",
  "context_snapshot": "string",
  "artifacts": ["string"],
  "dependencies": ["string"],
  "state_before": "string",
  "state_after": "string",
  "outcome": "string",
  "metadata": {}
}
```

## Audit Event Types

### Task Events
- task_created
- task_context_loaded
- task_planning
- task_ready
- task_running
- task_waiting
- task_review
- task_revision_required
- task_retrying
- task_escalated
- task_blocked
- task_accepted
- task_rejected
- task_failed
- task_rolled_back
- task_cancelled

### Agent Events
- agent_selected
- agent_dispatched
- agent_started
- agent_completed
- agent_failed
- agent_retried
- agent_escalated

### Artifact Events
- artifact_created
- artifact_updated
- artifact_reviewed
- artifact_accepted
- artifact_rejected
- artifact_revised

### Review Events
- review_started
- review_completed
- review_accepted
- review_rejected

### Escalation Events
- escalation_created
- escalation_sent
- escalation_received
- escalation_resolved

### Failure Events
- failure_detected
- failure_recorded
- failure_recovered
- failure_escalated

### Scope Events
- scope_violation_detected
- scope_violation_blocked
- scope_violation_escalated

## Audit Storage

Audit records are stored in the `.opencode/audit/` directory with the following structure:

```
.opencode/audit/
  {task_id}/
    {audit_id}.json
  index.json (task index)
```

## Audit Integrity

To ensure audit integrity:
1. Audit records are append-only
2. Audit records cannot be modified after creation
3. Audit records are cryptographically signed (future)
4. Audit records are backed up regularly

## Audit Reconstruction

Given a complete audit trail, the system must be able to reconstruct:
1. The complete execution history
2. All decisions made
3. All artifacts produced
4. All failures and recoveries
5. All escalations and resolutions
6. All repository changes

## Audit Query

The system must support querying the audit trail by:
- Task ID
- Agent
- Event type
- Time range
- Outcome

## Audit Reporting

The system must support generating audit reports for:
- Task completion analysis
- Failure pattern analysis
- Escalation pattern analysis
- Quality trend analysis
- Process improvement identification