# Artifact Model Specification

## Purpose

This document defines the artifact model for the StoreVoice orchestration system. Every meaningful agent result must become a persistent artifact.

## Artifact Structure

Every artifact must have enough metadata to establish:

```
artifact_id: Unique artifact identifier
task_id: Task that produced this artifact
agent: Agent that produced this artifact
agent_role: Role of the agent
timestamp: When the artifact was produced
input_context: Context that was provided to the agent
source_of_truth_reference: Relevant Source of Truth sections
status: Current status of the artifact
content/location: Where the artifact content is stored
dependencies: Other artifacts this depends on
review_status: Current review status
```

## Persistent Artifacts

These artifacts survive across sessions:

| Artifact | Created By | Consumed By | Persisted |
|----------|------------|-------------|-----------|
| Product Brief | Product Manager | Experience Design, Brand & Content, Commercial Strategy | YES |
| Product Requirement | Product Manager | All builders | YES |
| UX Specification | Experience Design | Frontend, QA | YES |
| Design Artifact | Experience Design | Frontend, QA | YES |
| Design System Specification | Experience Design | Frontend | YES |
| Brand Guidelines | Brand & Content | All agents | YES |
| Content Specification | Brand & Content | Frontend, QA | YES |
| Commercial Brief | Commercial Strategy | All agents | YES |
| Architecture Decision | Principal Architect | All engineers | YES |
| Technical Specification | Principal Architect | Engineers | YES |
| Implementation Change | Engineers | Code Reviewer, QA | YES |
| Test Report | QA | All agents | YES |
| Visual/UX Review | QA | Experience Design | YES |
| Commercial Review | Red Team | Product Manager | YES |
| Red Team Report | Red Team | Product Manager, Founder | YES |
| Audit Report | Product Audit | Founder | YES |
| Release Decision | Orchestrator | All agents | YES |
| Rollback Decision | Orchestrator | All agents | YES |

## Transient Artifacts

These artifacts exist within task context:

| Artifact | Created By | Consumed By | Persisted |
|----------|------------|-------------|-----------|
| Task Context | Orchestrator | Assigned agent | YES (task artifact) |
| Handoff Document | Builder | Reviewer | YES (task artifact) |
| Review Feedback | Reviewer | Builder | YES (task artifact) |
| Revision Notes | Builder | Reviewer | YES (task artifact) |

## Artifact Storage

Artifacts are stored in the `.opencode/artifacts/` directory with the following structure:

```
.opencode/artifacts/
  {task_id}/
    {artifact_id}.json
    {artifact_id}.md (or other appropriate extension)
```

## Artifact Validation

Before accepting an artifact, the Orchestrator must validate:
- All required metadata fields are present
- Artifact content matches expected format
- Artifact dependencies are satisfied
- Artifact is within authorized scope

## Artifact Versioning

Artifacts are versioned when they are revised:
- Original artifact remains in place
- Revised artifact gets a new version number
- Version history is maintained

## Artifact Audit

All artifact creation, modification, and review must be recorded in the audit trail.