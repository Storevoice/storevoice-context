# Fresh-Context Test

## Purpose

This test proves that a subagent can receive a fresh session and still execute correctly because its required context is persisted and passed. This is one of the most important acceptance criteria of 005F.

## Test Scenario

Simulate a task being dispatched to an agent with a complete context package, then verify the agent can execute correctly without any conversational memory.

## Test Steps

### Step 1: Create Context Package

Create a complete context package for a Backend agent task:

```json
{
  "task_id": "TASK-001",
  "parent_task_id": null,
  "objective": "Implement a health check endpoint for the StoreVoice platform",
  "scope": "PLATFORM_IMPLEMENTATION",
  "authority_level": "IMPLEMENTATION",
  "source_of_truth_references": [
    "01_ARCHITECTURE/ARCHITECTURE.md",
    "05_DECISIONS/IMPLEMENTATION_BLUEPRINT.md"
  ],
  "relevant_decisions": [
    "AD-01: Tenant Isolation Architecture",
    "AD-02: Knowledge Architecture"
  ],
  "relevant_requirements": [
    "Health check endpoint must return status of all services",
    "Health check must not expose sensitive information",
    "Health check must be fast (<100ms)"
  ],
  "input_artifacts": [
    "API specification for health check endpoint",
    "Architecture decision for health check pattern"
  ],
  "dependencies": [],
  "assumptions": [
    "PostgreSQL is available",
    "Redis is available",
    "Voice Engine is available"
  ],
  "open_questions": [],
  "acceptance_criteria": [
    "Health check endpoint returns 200 when all services are healthy",
    "Health check endpoint returns 503 when any service is unhealthy",
    "Health check endpoint responds in <100ms",
    "Health check endpoint does not expose sensitive information",
    "Health check endpoint is documented"
  ],
  "expected_output": [
    "Health check endpoint implementation",
    "Unit tests for health check endpoint",
    "API documentation for health check endpoint"
  ],
  "next_owner": "Code Reviewer",
  "review_requirements": [
    "Code review by Code Reviewer",
    "Security review by Trust & Compliance"
  ],
  "escalation_rules": [
    "Escalate if architecture conflict",
    "Escalate if security concern",
    "Escalate if missing specification"
  ]
}
```

### Step 2: Dispatch to Fresh Agent

Dispatch the task to a fresh Backend agent session with:
1. Complete context package
2. No conversational memory
3. No hidden context
4. No assumptions from other agents

### Step 3: Verify Agent Execution

Verify that the agent:
1. Reads and understands the context package
2. Follows the instructions in the context
3. Produces the expected artifacts
4. Respects authority boundaries
5. Does not invent requirements
6. Does not modify files outside scope

### Step 4: Verify Artifact Quality

Verify that the produced artifacts:
1. Match the expected output format
2. Satisfy the acceptance criteria
3. Are within the authorized scope
4. Reference the correct Source of Truth sections
5. Do not contradict approved decisions

### Step 5: Verify No Memory Dependence

Verify that the agent:
1. Did not rely on conversational memory
2. Did not assume context from previous interactions
3. Did not use hidden context
4. Did not invent requirements
5. Executed correctly with only the provided context

## Success Criteria

- Agent receives and understands fresh context
- Agent executes correctly without conversational memory
- Agent produces high-quality artifacts
- Agent respects all authority boundaries
- Agent does not invent requirements
- Agent stays within authorized scope
- All acceptance criteria are met
- All artifacts are persisted

## Critical Verification

This test must prove that the system does NOT depend on:
- Previous conversational memory
- Hidden context
- Assumptions from another agent
- The parent agent's private reasoning