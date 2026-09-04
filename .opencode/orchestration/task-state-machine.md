# Task State Machine Specification

## Purpose

This document defines the task state machine for the StoreVoice orchestration system. Every task must progress through defined states with traceable transitions.

## Task States

```
CREATED
CONTEXT_LOADING
PLANNING
READY
RUNNING
WAITING
REVIEW
REVISION_REQUIRED
RETRYING
ESCALATED
BLOCKED
ACCEPTED
REJECTED
FAILED
ROLLED_BACK
CANCELLED
```

## State Definitions

### CREATED
- Task has been created
- No work has begun
- Context has not been loaded

### CONTEXT_LOADING
- Orchestrator is loading authoritative context
- Context package is being constructed
- Source of Truth references are being identified

### PLANNING
- Orchestrator is planning execution
- Agent selection is occurring
- Dependencies are being determined
- Execution graph is being constructed

### READY
- Task is ready to execute
- All prerequisites are satisfied
- Context package is complete
- Agent has been selected

### RUNNING
- Agent is actively working on the task
- Work is in progress
- Artifacts are being produced

### WAITING
- Task is waiting for external input
- Waiting for dependency completion
- Waiting for human decision
- Waiting for resource availability

### REVIEW
- Work is complete
- Independent verification is in progress
- Reviewer is evaluating artifacts

### REVISION_REQUIRED
- Reviewer has rejected work
- Revision request has been created
- Work must be revised

### RETRYING
- Task is being retried after failure
- Attempt number is being tracked
- Previous failure is recorded

### ESCALATED
- Task has been escalated to human
- Waiting for human decision
- Escalation record has been created

### BLOCKED
- Task cannot proceed
- Blocking condition exists
- No autonomous resolution possible

### ACCEPTED
- Work has been accepted
- All quality criteria are met
- Ready for merge/integration

### REJECTED
- Work has been permanently rejected
- Cannot be revised further
- Must be escalated or cancelled

### FAILED
- Task has failed
- Cannot be completed
- Failure record has been created

### ROLLED_BACK
- Task has been rolled back
- Changes have been reverted
- System state restored

### CANCELLED
- Task has been cancelled
- No further work will be done
- Resources released

## State Transitions

### Normal Flow
```
CREATED → CONTEXT_LOADING → PLANNING → READY → RUNNING → REVIEW → ACCEPTED
```

### Revision Flow
```
REVIEW → REVISION_REQUIRED → RUNNING → REVIEW → ACCEPTED
```

### Retry Flow
```
RUNNING → FAILED → RETRYING → RUNNING → REVIEW → ACCEPTED
```

### Escalation Flow
```
RUNNING → ESCALATED → WAITING → RUNNING → REVIEW → ACCEPTED
```

### Failure Flow
```
RUNNING → FAILED → BLOCKED → ESCALATED → WAITING → RUNNING → REVIEW → ACCEPTED
```

### Rollback Flow
```
ACCEPTED → ROLLED_BACK → CREATED → CONTEXT_LOADING → PLANNING → READY → RUNNING → REVIEW → ACCEPTED
```

### Cancellation Flow
```
CREATED → CANCELLED
CONTEXT_LOADING → CANCELLED
PLANNING → CANCELLED
READY → CANCELLED
RUNNING → CANCELLED
WAITING → CANCELLED
```

## State Transition Rules

1. Every state transition must be recorded with timestamp and reason
2. No silent state changes
3. State transitions must be validated against allowed transitions
4. Invalid state transitions must be escalated
5. State history must be preserved for audit

## State Persistence

All task states must be persisted to enable:
- Audit trail reconstruction
- Fresh-context execution
- State recovery after system failure
- Progress tracking

## State Validation

Before each state transition, the Orchestrator must validate:
- Transition is allowed from current state
- All required preconditions are met
- Required artifacts are present
- Dependencies are satisfied

## State Recovery

If the system fails during execution:
1. Load last persisted state
2. Validate current state against reality
3. Determine if task can continue
4. Either resume or escalate