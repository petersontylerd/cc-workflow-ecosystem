---
description: Execute a backlog using orchestrated subagents with two-stage review
argument-hint: "[backlog file path or feature name]"
---

# /implement Command

Execute a backlog with automated subagent orchestration.

## Usage

```
/implement docs/backlogs/2024-01-15-auth-backlog.md
/implement user-authentication
```

## Before You Start

### Environment Verification

Before dispatching any subagents, verify the environment is healthy:

```bash
# Check git status
git status

# Run quick test suite
pytest tests/ -x -q --tb=short
# or: npm test -- --passWithNoTests

# Verify build works
npm run build  # or equivalent
```

**If environment is unhealthy:** Fix issues before proceeding. Subagents building on a broken foundation will fail.

### Task Description Preparation

For each task, prepare a complete task description. Use the **orchestrating-subagents** skill for the full format.

Required sections:
- **Purpose**: WHY this task matters
- **Context**: Where this fits in the project
- **Requirements**: FULL task text (not summarized)
- **Files**: Create, modify, test lists
- **Success Criteria**: Specific, measurable outcomes

Recommended sections:
- **Environment Verification**: Commands to run before starting
- **Potential Failure Modes**: What could go wrong
- **Required Skills**: Skills the agent should consult
- **Conventions**: Patterns to follow

### Skill Invocation

Ensure subagents know which skills to consult:

| Task Type | Required Skills |
|-----------|-----------------|
| Any implementation | `subagent-state-management`, `verification` |
| Python code | `python-development` |
| TypeScript code | `typescript-development` |
| Debugging issues | `systematic-debugging` |

## Execution Flow

Use the **orchestrating-subagents** skill for the full implementation process.

The flow is:
1. Read backlog once, extract all tasks
2. Create TodoWrite with all tasks
3. For each task:
   - Prepare complete task description
   - Dispatch `code-implementer`
   - Dispatch `spec-reviewer`
   - Dispatch `quality-reviewer`
   - Fix issues and re-review as needed
   - Mark task complete
4. Run `/verify` for final validation
5. Create PR via `/pr`

## Key Reminders

- **Purpose in every task description**: Helps agents make good trade-off decisions
- **Failure modes**: Anticipate problems, guide agents to avoid them
- **Skills references**: Point agents to available guidance
- **Evidence-based completion**: Require verification output, not assertions
- **Clear handoffs**: Each agent's report should enable the next agent
- **Re-review after fixes**: Never skip verification of fixes
