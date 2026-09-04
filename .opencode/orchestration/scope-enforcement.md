# Scope Enforcement Specification

## Purpose

This document defines the scope enforcement system for the StoreVoice orchestration system. Every task must have an explicit scope, and agents must not modify files outside their authorized scope.

## Scope Types

```
SOURCE_OF_TRUTH_ONLY
ORCHESTRATION_ONLY
PLATFORM_IMPLEMENTATION
VOICE_ENGINE (FROZEN - DO NOT MODIFY)
WEBSITE
COMMERCIAL
DESIGN
SECURITY
```

## Scope Definitions

### SOURCE_OF_TRUTH_ONLY
- Repository: StoreVoice Source of Truth
- Allowed: Documentation, specifications, decisions
- Forbidden: Implementation code, configuration

### ORCHESTRATION_ONLY
- Repository: OpenCode orchestration configuration
- Allowed: Agent definitions, orchestration configuration
- Forbidden: Product implementation, Source of Truth content

### PLATFORM_IMPLEMENTATION
- Repository: StoreVoice platform
- Allowed: Platform code, tests, configuration
- Forbidden: Voice Engine, Source of Truth content

### VOICE_ENGINE (FROZEN)
- Repository: StoreVoice Voice Engine
- Allowed: Nothing (FROZEN)
- Forbidden: All modifications

### WEBSITE
- Repository: StoreVoice website
- Allowed: Website code, content, configuration
- Forbidden: Platform implementation, Voice Engine

### COMMERCIAL
- Repository: Commercial assets
- Allowed: Commercial strategy, content, configuration
- Forbidden: Technical implementation, architecture

### DESIGN
- Repository: Design assets
- Allowed: Design artifacts, specifications, guidelines
- Forbidden: Implementation code, business rules

### SECURITY
- Repository: Security configuration
- Allowed: Security policies, configurations
- Forbidden: Application logic, business rules

## Scope Enforcement Rules

1. Every task must declare its scope
2. Agents must not modify files outside their authorized scope
3. Scope violations must be detected or blocked
4. Scope violations must be audited
5. Scope violations must be escalated if intentional

## Scope Validation

Before allowing an agent to modify a file, the system must:
1. Determine the file's repository
2. Check if the repository is within the agent's authorized scope
3. If not, block the modification
4. Record the scope violation attempt
5. Escalate if the violation appears intentional

## Scope Detection

The system must detect scope violations through:
- File path analysis
- Repository detection
- Branch detection
- Commit scope analysis

## Scope Violation Handling

If a scope violation is detected:
1. Block the modification
2. Record the violation attempt
3. Determine if violation is accidental or intentional
4. If accidental, provide guidance to agent
5. If intentional, escalate to Orchestrator
6. If Orchestrator cannot resolve, escalate to human

## Scope Audit

All scope violations must be recorded in the audit trail to enable:
- Scope compliance monitoring
- Agent behavior analysis
- Process improvement
- Security monitoring

## 005F Scope

For Change 005F itself:
- Scope: ORCHESTRATION_ONLY
- Allowed: Agent definitions, orchestration configuration, tests
- Forbidden: Product implementation, Source of Truth content modifications (except documentation updates)