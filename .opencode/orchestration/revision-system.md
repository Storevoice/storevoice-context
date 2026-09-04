# Revision and Review System Specification

## Purpose

This document defines the revision and review system for the StoreVoice orchestration system. This system ensures quality through independent verification and manages rejected work through revision loops.

## Review Architecture

```
OWNER
   ↓
REVIEWER
   ↓
ACCEPT / REJECT
```

And where applicable:

```
IMPLEMENTATION
      ↓
TECHNICAL REVIEW
      ↓
QA
      ↓
RED TEAM
      ↓
PRODUCT AUDIT
      ↓
COMMERCIAL ACCEPTANCE
```

## Review Types

### Code Review
- Reviewer: Code Reviewer
- Scope: All code changes
- Criteria: Code quality, standards, architecture compliance

### QA Review
- Reviewer: QA
- Scope: All implementation
- Criteria: Functionality, visual/UX quality, accessibility

### Red Team Review
- Reviewer: Red Team
- Scope: All product artifacts
- Criteria: Commercial viability, assumption challenge

### Product Audit
- Reviewer: Product Audit
- Scope: All product state
- Criteria: Multi-dimensional quality audit

### Trust & Compliance Review
- Reviewer: Trust & Compliance
- Scope: Security, compliance, localization
- Criteria: Trust, security, privacy, compliance

## Revision Flow

```
BUILDER creates artifact
      ↓
REVIEWER evaluates
      ↓
┌─────────┴─────────┐
│                   │
APPROVED          REJECTED
│                   │
↓                   ↓
MERGE          FINDING CLASSIFICATION
                    ↓
             RESPONSIBLE OWNER
                    ↓
             REVISION REQUESTED
                    ↓
             BUILDER REVISES
                    ↓
             RETEST
                    ↓
             RE-REVIEW
                    ↓
             ┌───────┴───────┐
             │               │
          APPROVED        REJECTED AGAIN
             │               │
             ↓               ↓
          MERGE        ESCALATE TO
                       HIGHER AUTHORITY
```

## Finding Classification

| Class | Description | Handling |
|-------|-------------|----------|
| Technical | Code quality, bugs, performance | Return to builder |
| Requirement | Does not satisfy requirements | Return to builder, clarify with Product Manager |
| Architecture | Conflicts with architecture | Return to builder, review with Principal Architect |
| Product | Does not satisfy product intent | Return to builder, review with Product Manager |
| Design | Violates approved design | Return to builder, review with Experience Design |
| Content | Contradicts product truth | Return to builder, review with Brand & Content |
| Security/Compliance | Violates security or compliance | Return to builder, review with Trust & Compliance |
| Commercial | Weakens positioning, harms conversion | Return to builder, review with Commercial Strategy |
| Unknown | Cannot safely classify | Escalate to Orchestrator |

## Revision Rules

1. Never restart the entire project unnecessarily
2. Never let a rejected artifact silently pass
3. Never allow a builder to approve its own revision after rejection
4. Track revision history — do not erase failure history
5. Repeated failures (3+) escalate to higher authority

## Revision Request Structure

```json
{
  "revision_id": "string",
  "original_artifact_id": "string",
  "reviewer": "string",
  "rejection_reason": "string",
  "failed_acceptance_criteria": ["string"],
  "findings": [
    {
      "class": "string",
      "description": "string",
      "severity": "string",
      "recommendation": "string"
    }
  ],
  "required_corrections": ["string"],
  "previous_artifact": "string",
  "timestamp": "string"
}
```

## Revision Tracking

All revisions must be tracked to enable:
- Revision history reconstruction
- Quality trend analysis
- Builder performance assessment
- Process improvement identification

## Independent Verification

No agent may approve its own critical work where independent verification is required. The system must enforce this rule through:
- Reviewer assignment based on artifact type
- Conflict of interest detection
- Independent review verification