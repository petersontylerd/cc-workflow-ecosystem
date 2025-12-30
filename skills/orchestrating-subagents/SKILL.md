---
name: orchestrating-subagents
description: Use when executing backlogs with multiple independent tasks
---

# Orchestrating Subagents

## Overview

Execute backlogs by dispatching fresh subagents per task with two-stage review: spec compliance first, then code quality.

**Core principle:** Fresh subagent per task + two-stage review = high quality, no context pollution.

## The Orchestration Pattern

```
PARENT CLAUDE (Orchestrator)
├── Reads backlog ONCE, extracts ALL tasks with full text
├── Creates TodoWrite with all tasks
├── For each task:
│   ├── STEP 1: Prepare context packet
│   │   ├── Task text (from backlog)
│   │   ├── Relevant file paths
│   │   ├── Scene-setting context
│   │   └── Success criteria
│   │
│   ├── STEP 2: Dispatch code-implementer
│   │   └── Wait for completion or questions
│   │
│   ├── STEP 3: Handle questions (if any)
│   │   └── Answer → Re-dispatch implementer
│   │
│   ├── STEP 4: Dispatch spec-reviewer
│   │   └── Check: Does code match requirements?
│   │
│   ├── STEP 5: Fix spec gaps (if any)
│   │   └── Implementer fixes → Re-review
│   │
│   ├── STEP 6: Dispatch quality-reviewer
│   │   └── Check: Is code well-written?
│   │
│   ├── STEP 7: Fix quality issues (if any)
│   │   └── Implementer fixes → Re-review
│   │
│   └── STEP 8: Mark task complete
│       └── Update TodoWrite
│
└── After all tasks: Final holistic review
```

## When to Use

Use this skill when:
- You have a backlog with multiple tasks
- Tasks are mostly independent
- You want automated quality gates between tasks

## The Process

### Step 1: Prepare

1. Read the backlog file ONCE
2. Extract ALL tasks with their full text
3. Note any shared context (architecture, conventions)
4. Create TodoWrite with all tasks

**Important:** You read the backlog. Subagents receive curated context, NOT the backlog file.

### Step 2: For Each Task

#### Dispatch code-implementer

```markdown
## Task: [Task Name]

### Context
[Scene-setting: where this fits in the project]

### Requirements
[Full task text from backlog]

### Files to Touch
[List from backlog]

### Success Criteria
[How we know it's done]

### Notes
[Any relevant conventions or patterns]
```

#### Handle Questions

If implementer asks questions:
1. Answer clearly and completely
2. Provide additional context if needed
3. Re-dispatch with answer

#### Dispatch spec-reviewer

After implementation, dispatch spec-reviewer with:
- Original task requirements
- Git diff of changes

If spec-reviewer finds gaps:
1. Dispatch implementer to fix gaps
2. Re-dispatch spec-reviewer
3. Repeat until approved

#### Dispatch quality-reviewer

After spec approval, dispatch quality-reviewer with:
- Git diff of changes
- Project conventions

If quality-reviewer finds issues:
1. Dispatch implementer to fix issues
2. Re-dispatch quality-reviewer
3. Repeat until approved

#### Mark Complete

After both reviews approve:
1. Update TodoWrite (mark complete)
2. Move to next task

### Step 3: Final Review

After all tasks complete:
1. Dispatch quality-reviewer for holistic review
2. Address any cross-cutting issues
3. Proceed to /verify and /pr

## Context Packet Format

```markdown
## Task: [Name]

### Context
This is task [N] of [Total] in implementing [Feature].
Previous tasks completed: [List]
This task builds on: [Dependencies]

### Requirements
[FULL task text - not summarized]

### Files
Create: [list]
Modify: [list]
Test: [list]

### Success Criteria
- [Specific criterion 1]
- [Specific criterion 2]

### Conventions
[Relevant patterns to follow]
```

## Red Flags - STOP

| If You... | Then... |
|-----------|---------|
| Skip spec review | Code might not meet requirements |
| Skip quality review | Code quality suffers |
| Proceed with unfixed issues | Issues accumulate |
| Dispatch multiple implementers in parallel | Conflicts occur |
| Make subagent read backlog file | Provide full text instead |
| Ignore subagent questions | Implementation will be wrong |
| Accept "close enough" | Spec reviewer found issues = not done |
| Skip re-review after fixes | Don't know if fixes worked |

## Review Loop Pattern

```
┌─────────────────────────┐
│ Dispatch reviewer       │
└───────────┬─────────────┘
            │
            ▼
     ┌──────────────┐
     │ Issues found? │
     └──────┬───────┘
            │
     yes ───┼─── no
            │      │
            ▼      ▼
     ┌──────────┐  ┌──────────┐
     │Fix issues│  │ APPROVED │
     └────┬─────┘  └──────────┘
          │
          └──► Re-dispatch reviewer
```

**Never skip the re-review.** Fixes must be verified.

## Example Execution

```
Orchestrator: I'm executing the authentication backlog.

[Read backlog: docs/backlogs/2024-01-15-auth-backlog.md]
[Extract 4 tasks with full text]
[Create TodoWrite: Task 1, Task 2, Task 3, Task 4]

Task 1: User model with password hashing
[Mark in_progress in TodoWrite]
[Prepare context packet]
[Dispatch code-implementer]

Implementer: "Should I use bcrypt or argon2 for hashing?"

Orchestrator: "Use argon2 - it's already in our dependencies."

[Re-dispatch implementer with answer]

Implementer: "Completed. Created User model, added tests, committed."

[Dispatch spec-reviewer]

Spec-reviewer: "✅ Matches spec. All requirements met."

[Dispatch quality-reviewer]

Quality-reviewer: "✅ Approved. Good patterns, clean code."

[Mark Task 1 complete]

Task 2: Login endpoint
[Mark in_progress]
[Dispatch code-implementer with context]

Implementer: "Completed login endpoint implementation."

[Dispatch spec-reviewer]

Spec-reviewer: "❌ Missing: Rate limiting (spec says max 5 attempts/minute)"

[Dispatch implementer to fix]

Implementer: "Added rate limiting middleware."

[Re-dispatch spec-reviewer]

Spec-reviewer: "✅ Now matches spec."

[Dispatch quality-reviewer]

Quality-reviewer: "⚠️ Important: Magic number 5 should be constant"

[Dispatch implementer to fix]

Implementer: "Extracted MAX_LOGIN_ATTEMPTS constant."

[Re-dispatch quality-reviewer]

Quality-reviewer: "✅ Approved."

[Mark Task 2 complete]

[Continue with remaining tasks...]

[After all tasks: Final holistic review]
[Proceed to /verify]
```

## Key Principles

1. **You are the orchestrator** - You maintain context, subagents execute
2. **Fresh subagent per task** - No context pollution between tasks
3. **Curated context** - Subagents receive exactly what they need
4. **Two-stage review** - Spec compliance before code quality
5. **Review loops** - Issues found = fix = re-review
6. **Sequential execution** - One task at a time, avoid conflicts

## Mandatory Task Tool Usage

You MUST use the Task tool to dispatch each subagent. This is not optional.

### Dispatch Checklist

For each task, verify you have:
- [ ] Dispatched code-implementer via Task tool
- [ ] Received and reviewed completion report
- [ ] Dispatched spec-reviewer via Task tool
- [ ] Received approval OR fixed gaps and re-dispatched
- [ ] Dispatched quality-reviewer via Task tool
- [ ] Received approval OR fixed issues and re-dispatched
- [ ] Updated TodoWrite to mark task complete

**Violation:** Implementing code yourself instead of dispatching code-implementer is a workflow violation. The orchestrator orchestrates; subagents implement.

## Context Packet Checklist

Before dispatching any subagent, verify your context packet includes:

- [ ] **Task header** (`## Task: [Name]`)
- [ ] **Context section** (where this fits, dependencies)
- [ ] **Requirements** (FULL task text, not summarized)
- [ ] **Files to touch** (create, modify, test)
- [ ] **Success criteria** (specific, measurable)
- [ ] **Conventions** (coding style, patterns if applicable)
- [ ] **Fresh task marker** ("This is a fresh task context.")

**Incomplete context = poor subagent performance.**

## Integration

After orchestration completes:
- Use `verification` skill for pre-completion checks
- Use `/verify` command for final validation
- Use `/pr` command to create pull request
