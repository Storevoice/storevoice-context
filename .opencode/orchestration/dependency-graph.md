# Dependency Execution Graph Specification

## Purpose

This document defines the dependency execution graph for the StoreVoice orchestration system. The graph determines which tasks can run in parallel and which must be sequential.

## Canonical Dependencies

```
FOUNDER TRUTH
    ↓
PRODUCT STRATEGY (Product Manager)
    ↓
PRODUCT REQUIREMENTS
    ↓
 ┌──────┼──────────────┐
 ↓      ↓              ↓
 UX    BRAND/CONTENT  COMMERCIAL
 ↓      ↓              ↓
 DESIGN SYSTEM         │
 ↓      │              │
 ┌──────┼──────────────┘
 ↓
 ARCHITECTURE (Principal Architect)
 ↓
 ┌──────┼──────────────┐
 ↓      ↓              ↓
ENGINEERING          TRUST/COMPLIANCE
(15 agents)          LOCALIZATION
 ↓      ↓              ↓
 ┌──────┼──────────────┘
 ↓
 TESTING (QA)
 ↓
INDEPENDENT VERIFICATION
(Red Team, Code Reviewer, Product Audit)
 ↓
ACCEPTANCE
 ↓
FREEZE
```

## Parallelism Rules

### Safe to Parallelize

- Product Requirements → UX ‖ Brand/Content ‖ Commercial
- Architecture → Backend ‖ Database ‖ Security ‖ Observability ‖ Integration
- Trust & Compliance review ‖ Code Review ‖ QA testing

### Must Be Sequential

- Product Requirements → UX → Visual Design → Frontend
- Design System → Frontend (depends on tokens/components)
- Backend → Integration (depends on API contracts)
- All builders → Code Review → QA → Red Team → Acceptance

### Gated

- Design System must exist before major frontend implementation (FD-12)
- Architecture must be approved before implementation
- All changes require independent verification before merge

## Dependency Rules

1. The Orchestrator manages all dependencies
2. No agent may begin work whose prerequisites are not met
3. Parallel work must not create conflicting artifacts
4. Dependency violations must be escalated, not silently resolved

## Dependency Declaration

Each task must declare its dependencies:

```json
{
  "task_id": "string",
  "dependencies": [
    {
      "task_id": "string",
      "dependency_type": "blocking | non-blocking",
      "description": "string"
    }
  ]
}
```

## Dependency Types

### Blocking Dependency
- Task cannot begin until dependency is complete
- Dependency must be ACCEPTED before dependent task can start

### Non-Blocking Dependency
- Task can begin but may need to wait for dependency result
- Dependency result is needed for task completion

## Dependency Resolution

The Orchestrator must:
1. Build dependency graph from all tasks
2. Detect cycles (must be escalated)
3. Determine execution order
4. Identify parallelizable work
5. Dispatch tasks in correct order
6. Wait for dependencies before dispatching dependent tasks

## Dependency Validation

Before dispatching a task, the Orchestrator must validate:
- All blocking dependencies are ACCEPTED
- All required input artifacts are available
- No dependency conflicts exist
- Resource conflicts are resolved

## Dependency Violations

If a dependency violation is detected:
1. Stop the violating task
2. Record the violation
3. Determine if violation is resolvable
4. If resolvable, create revision task
5. If not resolvable, escalate to human

## Dependency Tracking

All dependencies must be tracked to enable:
- Progress visualization
- Bottleneck identification
- Critical path analysis
- Audit trail reconstruction