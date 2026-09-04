# Revision Test

## Purpose

This test intentionally creates an insufficient artifact, has a reviewer reject it, and verifies the system handles the revision correctly.

## Test Scenario

Simulate a Frontend agent creating an incomplete implementation that is rejected by QA, then revised and accepted.

## Test Steps

### Step 1: Create Initial Task

Create a task for Frontend agent:
```json
{
  "task_id": "TASK-REV-001",
  "objective": "Implement a login form with email and password fields",
  "scope": "PLATFORM_IMPLEMENTATION",
  "authority_level": "IMPLEMENTATION",
  "acceptance_criteria": [
    "Login form has email field",
    "Login form has password field",
    "Login form has submit button",
    "Login form validates input",
    "Login form shows error messages",
    "Login form is accessible",
    "Login form is responsive"
  ]
}
```

### Step 2: Dispatch to Frontend Agent

Dispatch task to Frontend agent with complete context package.

### Step 3: Agent Produces Incomplete Artifact

Frontend agent produces implementation that:
- Has email field ✓
- Has password field ✓
- Has submit button ✓
- Does NOT validate input ✗
- Does NOT show error messages ✗
- Is NOT accessible ✗
- Is responsive ✓

### Step 4: QA Review

QA reviews the implementation and rejects it:
```json
{
  "review_id": "REVIEW-001",
  "task_id": "TASK-REV-001",
  "reviewer": "QA",
  "outcome": "REJECTED",
  "findings": [
    {
      "class": "Requirement",
      "description": "Login form does not validate input",
      "severity": "HIGH",
      "recommendation": "Add client-side validation for email format and password strength"
    },
    {
      "class": "Requirement",
      "description": "Login form does not show error messages",
      "severity": "HIGH",
      "recommendation": "Add error message display for validation failures"
    },
    {
      "class": "Accessibility",
      "description": "Login form is not accessible",
      "severity": "MEDIUM",
      "recommendation": "Add ARIA labels, keyboard navigation, and screen reader support"
    }
  ],
  "failed_acceptance_criteria": [
    "Login form validates input",
    "Login form shows error messages",
    "Login form is accessible"
  ]
}
```

### Step 5: Create Revision Request

Orchestrator creates revision request:
```json
{
  "revision_id": "REV-001",
  "original_task_id": "TASK-REV-001",
  "reviewer": "QA",
  "rejection_reason": "Implementation does not meet acceptance criteria",
  "failed_acceptance_criteria": [
    "Login form validates input",
    "Login form shows error messages",
    "Login form is accessible"
  ],
  "findings": [
    {
      "class": "Requirement",
      "description": "Login form does not validate input",
      "severity": "HIGH",
      "recommendation": "Add client-side validation for email format and password strength"
    },
    {
      "class": "Requirement",
      "description": "Login form does not show error messages",
      "severity": "HIGH",
      "recommendation": "Add error message display for validation failures"
    },
    {
      "class": "Accessibility",
      "description": "Login form is not accessible",
      "severity": "MEDIUM",
      "recommendation": "Add ARIA labels, keyboard navigation, and screen reader support"
    }
  ],
  "required_corrections": [
    "Add input validation",
    "Add error message display",
    "Add accessibility features"
  ],
  "previous_artifact": "TASK-REV-001-implementation"
}
```

### Step 6: Return to Frontend Agent

Orchestrator returns revision request to Frontend agent with:
1. Original context package
2. Revision request
3. Previous implementation
4. Clear instructions for correction

### Step 7: Agent Revises Implementation

Frontend agent revises implementation:
- Adds input validation ✓
- Adds error message display ✓
- Adds accessibility features ✓

### Step 8: Re-Review

QA reviews revised implementation and accepts it.

### Step 9: Record Audit Trail

Record complete audit trail:
1. Original task creation
2. Initial implementation
3. QA review (rejected)
4. Revision request
5. Revised implementation
6. QA review (accepted)

## Expected Artifacts

1. Original task context
2. Initial implementation
3. QA review report (rejected)
4. Revision request
5. Revised implementation
6. QA review report (accepted)
7. Complete audit trail

## Success Criteria

- Initial implementation is rejected with clear reasons
- Revision request is created with specific corrections
- Frontend agent receives revision request
- Frontend agent revises implementation
- Revised implementation meets all acceptance criteria
- QA accepts revised implementation
- Complete audit trail is preserved
- Both attempts are recorded