---
description: Execute an implementation plan using orchestrated subagents with two-stage review
argument-hint: "[plan file path or feature name]"
---

# /implement Command

Execute an implementation plan with automated subagent orchestration.

## Usage

```
/implement docs/plans/2024-01-15-auth-plan.md
/implement user-authentication
```

## Workflow

This command invokes the `orchestrating-subagents` skill.

### What Happens

For each task in the plan:

```
1. Prepare context packet for task
2. Dispatch code-implementer subagent
   → Implements with TDD
   → Self-reviews before handoff
   → Commits atomically
3. Handle any questions from implementer
4. Dispatch spec-reviewer subagent
   → Validates against requirements
   → If gaps: implementer fixes → re-review
5. Dispatch quality-reviewer subagent
   → Assesses code quality
   → If issues: implementer fixes → re-review
6. Mark task complete
7. Move to next task
```

After all tasks:
- Final holistic code review
- Ready for `/verify` and `/pr`

### Subagent Roles

| Agent | Role | Focus |
|-------|------|-------|
| `code-implementer` | Execute task | TDD, commits |
| `spec-reviewer` | Validate completeness | Requirements match |
| `quality-reviewer` | Assess quality | Code standards |

### Review Loop

```
Dispatch reviewer
     │
     ▼
Issues found?
  │     │
 yes    no
  │     │
  ▼     ▼
Fix → Re-review   APPROVED
```

Issues are never skipped. Fixes are always re-verified.

### Context Flow

- **You (orchestrator)**: Read plan once, maintain full context
- **Subagents**: Receive curated context packets, not raw plan

### Output

After completion:
- All tasks implemented and reviewed
- Atomic commits for each task
- Ready for final verification

## Key Principles

- **Fresh subagent per task** - No context pollution
- **Two-stage review** - Spec compliance, then quality
- **Review loops** - Issues found = fix = re-review
- **Sequential execution** - One task at a time

## Related Commands

- `/plan` - Create the implementation plan
- `/verify` - Run pre-completion verification
- `/pr` - Create pull request
