---
name: subagent-state-management
description: Provides foundational patterns for subagent operations including session startup rituals, progress documentation, state recovery, handoff protocols, and context efficiency. Use when operating as a subagent to ensure consistent, recoverable, and well-documented execution.
---

# Subagent State Management

## Overview

This skill provides foundational patterns for subagent operations. All subagents (code-implementer, spec-reviewer, quality-reviewer) should reference these patterns for consistent, recoverable, and well-documented execution.

**Core principle:** Subagents must be able to understand state on fresh context, document progress for recovery, and hand off cleanly to the next agent.

## Session Startup Ritual

When you begin a task, perform this startup sequence:

### 1. Environment Verification

Before implementing anything, verify the environment is healthy:

```bash
# Quick environment check
git status              # Working tree should be clean or expected
git log -3 --oneline    # Understand recent context
```

If environment verification commands are provided in your task description, run those first:

```bash
# Example: Run quick smoke test
pytest tests/ -x -q --tb=short  # Fail fast on first broken test
```

**If environment is broken:** STOP. Report the issue to the orchestrator before proceeding.

### 2. Context Orientation

Understand your position in the workflow:

1. **Task position**: Which task number is this? What came before?
2. **Dependencies**: What must be true for this task to succeed?
3. **Purpose**: WHY does this task matter? What problem does it solve?

Read the Context and Purpose sections of your task description carefully.

### 3. Scope Confirmation

Before starting work, confirm you understand:

- [ ] What you're implementing (Requirements)
- [ ] What files you're touching (Files section)
- [ ] How to know you're done (Success Criteria)
- [ ] What could go wrong (Failure Modes)

If anything is unclear, ask the orchestrator BEFORE starting.

## Progress Documentation

Document progress after each significant action to enable recovery and handoff.

### After Each Commit

```bash
# Good commit message pattern
git commit -m "feat(auth): add password validation

- Added validatePassword function
- Added test for min length requirement
- Next: add special character validation"
```

Include in commit message:
- What was done (summary line)
- Specific changes (body)
- What comes next (if multi-step)

### Progress Notes Format

If you need to document progress beyond commits:

```markdown
## Progress: [Task Name]

### Completed
- [x] Step 1: Description
- [x] Step 2: Description

### In Progress
- [ ] Step 3: Description (current)

### Remaining
- [ ] Step 4: Description
- [ ] Step 5: Description

### Blockers
None / [Description of blocker]
```

### When to Document

Document progress when:
- Making a commit (via commit message)
- Encountering a decision point
- Finding something unexpected
- Completing a logical sub-step
- Hitting a blocker

## State Recovery

If you start with fresh context or resume interrupted work, use these patterns to understand state.

### Git-Based State Recovery

```bash
# Understand what happened
git log -10 --oneline

# See recent changes
git diff HEAD~3 --stat

# Check current state
git status
```

### Recovery Checklist

1. **Read git log**: What commits were made? What's the story?
2. **Check uncommitted changes**: Is there work in progress?
3. **Verify tests pass**: Is the codebase healthy?
4. **Re-read task description**: What was the original task?
5. **Identify current position**: Where in the task are we?

### Resuming Interrupted Work

```markdown
## State Assessment

### Last Known State
[Git log summary, last commit, any uncommitted changes]

### Environment Status
[Test results, build status]

### Remaining Work
[What still needs to be done]

### Recommended Action
[Continue with X / Roll back to Y / Ask orchestrator about Z]
```

## Handoff Protocols

Clear handoffs between agents prevent confusion and wasted work.

### Implementation Complete Handoff

When code-implementer finishes, provide:

```markdown
## Task Completed: [Task Name]

### Purpose Fulfilled
[How this implementation serves the stated purpose]

### What Was Implemented
- [Bullet list of changes]

### Files Changed
- `path/to/file.ts` - [Description of change]
- `path/to/test.ts` - [Description of test]

### Tests Added
- [List of test cases with names]

### Commits Made
- `abc1234` - [Commit message summary]
- `def5678` - [Commit message summary]

### Environment State
- Tests: [Passing / X failures]
- Build: [Passing / Failing]
- Lint: [Clean / X warnings]

### Verification Evidence
```
[Actual test output showing pass/fail]
```

### For Spec Reviewer
- Requirements verified: [List which ones you believe you met]
- Potential gaps: [Any areas you're unsure about]

### Notes
- [Any observations or recommendations]
```

### Spec Review Handoff

When spec-reviewer finishes, provide:

```markdown
## Spec Review: [APPROVED | GAPS FOUND | OVER-IMPLEMENTATION]

### Requirements Status
- [x] Requirement 1: [Evidence of verification]
- [ ] Requirement 2: [What's missing]

### For Quality Reviewer
- Scope verified: [Yes - all requirements met / No - gaps listed above]
- Focus areas: [Specific files or patterns worth extra attention]
- Already checked: [What quality-reviewer should NOT re-check]

### For Implementer (if gaps found)
- [Specific actionable fixes needed]
```

### Quality Review Handoff

When quality-reviewer finishes, provide:

```markdown
## Quality Review: [APPROVED | ISSUES FOUND]

### Assessment Summary
- Critical issues: [0 / List]
- Important issues: [0 / List]
- Minor suggestions: [0 / List]

### For Implementer (if issues found)
- [Specific actionable fixes with file:line references]

### For Orchestrator
- Code quality: [Assessment]
- Ready to merge: [Yes / No - requires fixes]
- Technical debt introduced: [None / List]
```

## Context Efficiency

Subagents must be efficient with context to maximize performance.

### What to Include in Reports

**Essential (always include):**
- Task completion status
- Files changed with descriptions
- Verification evidence (actual output)
- Clear next-agent instructions

**Important (include when relevant):**
- Decisions made and rationale
- Blockers encountered
- Recommendations

**Avoid (do not include):**
- Full file contents (reference paths instead)
- Redundant information
- Implementation details the next agent doesn't need
- Long debug logs (summarize instead)

### Task Description Consumption

When you receive a task description:

1. **Read fully first**: Don't skim
2. **Extract key info**: Requirements, success criteria, conventions
3. **Note failure modes**: What could go wrong
4. **Identify skills**: Which skills should you consult
5. **Plan before acting**: Don't start coding immediately

### Efficient Git Diff Usage

```bash
# Focused diff for specific files
git diff HEAD~1 -- path/to/file.ts

# Stats only (see what changed)
git diff HEAD~1 --stat

# Ignore whitespace
git diff HEAD~1 -w

# Show function context
git diff HEAD~1 -U5  # 5 lines of context
```

## Red Flags - STOP and Check

| If You Notice... | Then... |
|------------------|---------|
| Task description missing sections | Ask orchestrator for complete context |
| Environment verification fails | Report immediately, don't proceed |
| Requirements are ambiguous | Ask for clarification, don't assume |
| Unsure about scope | Ask, don't expand |
| About to claim completion without evidence | Run verification first |
| Handoff report is vague | Add specific details |

## Integration with Other Skills

Reference these skills as needed:

| Situation | Skill to Consult |
|-----------|------------------|
| Stuck on error | `systematic-debugging` |
| Python implementation | `python-development` |
| TypeScript implementation | `typescript-development` |
| Before claiming completion | `verification` |

## Remember

1. **Fresh context is normal** - use git to recover state
2. **Document as you go** - future you (or next agent) will thank you
3. **Handoffs should be self-contained** - next agent shouldn't need to ask
4. **Evidence over claims** - show output, don't just assert success
5. **Ask early** - unclear requirements get worse, not better
