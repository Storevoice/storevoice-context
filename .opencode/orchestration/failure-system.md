# Failure Handling and Retry System Specification

## Purpose

This document defines the failure handling and retry system for the StoreVoice orchestration system. This system distinguishes between different failure types and handles them appropriately.

## Failure Classes

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

## Failure Handling Rules

1. Agent/tool failures are retried once with the same agent, then escalated
2. Quality/commercial failures trigger revision to the responsible owner
3. Security/compliance failures are mandatory escalation — never silently resolved
4. Contradictions in approved truth are mandatory escalation — never guessed through
5. Repeated failures (3+) are mandatory escalation to higher authority
6. The system must never manufacture a decision to keep execution moving

## Retry Policy

Retries must be bounded. Do not create infinite autonomous loops.

### Retry Limits
- Agent Failure: 1 retry
- Tool Failure: 2 retries
- Timeout: 1 retry
- Quality Failure: 2 revisions
- Commercial Failure: 2 revisions

### Retry Recording
Every retry must record:
```json
{
  "attempt_number": "number",
  "reason": "string",
  "previous_failure": "string",
  "new_context": "string",
  "result": "string"
}
```

### After Retry Threshold Exceeded
**ESCALATE or FAIL** according to the failure class.

## Failure Detection

The Orchestrator must detect failures through:
- Task state monitoring
- Artifact validation
- Review feedback
- Time limits
- Agent reports

## Failure Isolation

When a failure occurs:
1. Stop the failing task
2. Record the failure
3. Determine impact on dependent tasks
4. Isolate the failure if possible
5. Continue unrelated work where safe

## Failure Recovery

### Recoverable Failure
- Retry with same agent
- Provide additional context
- Try alternative approach
- If still failing, escalate

### Correctable Failure
- Send through revision
- Provide clear feedback
- Track revision history
- If still failing after 2 revisions, escalate

### Blocking Failure
- Pause the graph
- Record the blocking condition
- Determine if blocking condition can be resolved
- If not, escalate

### Human Decision Required
- Escalate immediately
- Record escalation
- Wait for human decision
- Do not invent answer

### Systemic Failure
- Stop affected execution
- Preserve diagnostics
- Record systemic failure
- Escalate immediately

## Failure Reporting

All failures must be reported with:
- Failure class
- Failure description
- Impact assessment
- Recovery action taken
- Current state
- Required human action (if any)

## Failure Audit

All failures must be recorded in the audit trail to enable:
- Failure pattern analysis
- Process improvement
- Builder performance assessment
- System reliability measurement