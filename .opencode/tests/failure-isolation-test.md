# Failure Isolation Test

## Purpose

This test causes one controlled agent failure and verifies that failure is recorded, unrelated tasks continue where safe, dependent tasks wait, retry occurs if appropriate, escalation occurs if retry fails, and final state is truthful.

## Test Scenario

Simulate a Database agent failing due to a schema conflict, while other unrelated tasks continue.

## Test Steps

### Step 1: Create Multiple Tasks

Create several tasks with different dependencies:
1. Database Schema Task (depends on nothing)
2. Backend API Task (depends on Database Schema Task)
3. Frontend UI Task (depends on Backend API Task)
4. Infrastructure Task (depends on nothing)
5. Observability Task (depends on nothing)

### Step 2: Dispatch Tasks

Dispatch all tasks in parallel where dependencies allow:
- Database Schema Task: RUNNING
- Infrastructure Task: RUNNING
- Observability Task: RUNNING
- Backend API Task: WAITING (depends on Database Schema Task)
- Frontend UI Task: WAITING (depends on Backend API Task)

### Step 3: Cause Database Agent Failure

Database agent fails due to schema conflict:
```json
{
  "failure_id": "FAILURE-001",
  "task_id": "TASK-DB-001",
  "agent": "Database",
  "failure_class": "Task Failure",
  "failure_description": "Schema conflict detected - cannot create table 'tenants' because it already exists",
  "impact_assessment": "Database schema task failed, blocking Backend API task",
  "recovery_action": "Retry with schema inspection first"
}
```

### Step 4: Verify Failure Recording

Verify that:
1. Failure is recorded in audit trail
2. Database Schema Task state changes to FAILED
3. Dependent Backend API Task remains WAITING
4. Independent Infrastructure Task continues RUNNING
5. Independent Observability Task continues RUNNING

### Step 5: Retry Database Agent

Orchestrator retries Database agent with additional context:
```json
{
  "retry_id": "RETRY-001",
  "task_id": "TASK-DB-001",
  "attempt_number": 1,
  "reason": "Schema conflict - retry with schema inspection",
  "new_context": "Inspect existing schema before creating new tables"
}
```

### Step 6: Verify Retry Behavior

Verify that:
1. Retry is recorded in audit trail
2. Database Schema Task state changes to RETRYING
3. Retry attempt number is tracked
4. Previous failure is recorded
5. New context is provided

### Step 7: Database Agent Succeeds on Retry

Database agent succeeds on retry by inspecting schema first and creating table with IF NOT EXISTS.

### Step 8: Verify Recovery

Verify that:
1. Database Schema Task state changes to ACCEPTED
2. Backend API Task state changes to RUNNING
3. Frontend UI Task remains WAITING
4. Infrastructure Task continues RUNNING
5. Observability Task continues RUNNING

### Step 9: Verify Final State

Verify that:
1. All tasks reach final state (ACCEPTED or RUNNING)
2. No tasks are in inconsistent state
3. Complete audit trail exists
4. All failures and retries are recorded
5. All dependencies are properly handled

## Expected Artifacts

1. Initial task contexts
2. Failure record
3. Retry record
4. Successful completion record
5. Complete audit trail showing:
   - Task creation
   - Task dispatch
   - Failure detection
   - Failure recording
   - Retry initiation
   - Retry completion
   - Task acceptance
   - Dependency resolution

## Success Criteria

- Failure is properly recorded
- Failure is properly isolated
- Unrelated tasks continue where safe
- Dependent tasks wait appropriately
- Retry occurs with bounded attempts
- Recovery is successful
- Final state is truthful
- Complete audit trail exists
- No inconsistent states
- No orphan tasks