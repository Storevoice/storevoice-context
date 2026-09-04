# Context Package Specification

## Purpose

This document defines the structure and requirements for context packages that are passed to agents during orchestration. OpenCode subagents receive fresh sessions/context, so the system MUST NOT rely on conversational memory.

## Context Package Structure

Every dispatched agent must receive a structured context package:

```
TASK_ID: Unique task identifier
PARENT_TASK_ID: Parent task (if subtask)
OBJECTIVE: What needs to be accomplished
SCOPE: Authorized scope
AUTHORITY_LEVEL: What this agent may decide
SOURCE_OF_TRUTH_REFERENCES: Relevant authoritative sections
RELEVANT_DECISIONS: Applicable Founder Decisions
RELEVANT_REQUIREMENTS: Applicable product requirements
INPUT_ARTIFACTS: Required input artifacts
DEPENDENCIES: Task dependencies
ASSUMPTIONS: Known assumptions
OPEN_QUESTIONS: Unresolved questions
ACCEPTANCE_CRITERIA: What constitutes completion
EXPECTED_OUTPUT: Required output artifacts
NEXT_OWNER: Who receives the output
REVIEW_REQUIREMENTS: Who reviews the work
ESCALATION_RULES: When to escalate
```

## Context Types

### 1. Immutable Authority (never changes without Founder approval)

* Founder Decisions (FOUNDER_DECISION_SET.md)
* Approved Source of Truth
* Approved Architecture (ARCHITECTURE.md, SYSTEM_MAP.md, INTEGRATION_RULES.md)
* Frozen Voice Engine (VOICE_ENGINE.md, FROZEN_COMPONENTS.md)

### 2. Product Context (changes with product decisions)

* Product Contract (PRODUCT_CONTRACT.md)
* Business Rules (BUSINESS_RULES.md)
* UX Rules (UX_RULES.md)
* Design System (DESIGN_SYSTEM.md — when established)
* Brand Guidelines (BRAND_GUIDELINES.md — when established)
* Visual Direction (VISUAL_DIRECTION.md — when established)

### 3. Task Context (specific to each dispatched task)

* objective
* scope
* acceptance criteria
* dependencies
* assumptions
* open questions
* expected output
* next owner

### 4. Technical Context (specific to implementation)

* relevant architecture
* repository state
* implementation state
* API contracts
* schema state
* deployment state

### 5. Historical Context (learned from previous work)

* Product Archaeology findings
* previous decisions
* previous rejected approaches
* audit findings
* red team findings
* commercial assessments

## Context Propagation Contract

Every dispatched task carries a structured context package:

```json
{
  "task_id": "string",
  "parent_task_id": "string | null",
  "objective": "string",
  "scope": "string",
  "authority_level": "string",
  "source_of_truth_references": ["string"],
  "relevant_decisions": ["string"],
  "relevant_requirements": ["string"],
  "input_artifacts": ["string"],
  "dependencies": ["string"],
  "assumptions": ["string"],
  "open_questions": ["string"],
  "acceptance_criteria": ["string"],
  "expected_output": ["string"],
  "next_owner": "string",
  "review_requirements": ["string"],
  "escalation_rules": ["string"]
}
```

## Context Loading Rules

1. The Orchestrator must load authoritative context before dispatching agents
2. Context must be explicit, not implicit
3. Agents must not be forced to reconstruct project truth from conversation history alone
4. Context must include all information required for safe execution
5. Context must not include information outside the agent's authorized scope

## Context Validation

Before dispatching an agent, the Orchestrator must validate:
- All required context fields are present
- Context references valid authoritative sources
- Context does not contain contradictions
- Context is appropriate for the agent's authority level

## Context Persistence

All context packages must be persisted as artifacts to enable:
- Audit trail reconstruction
- Fresh-context execution
- Context validation
- Context versioning