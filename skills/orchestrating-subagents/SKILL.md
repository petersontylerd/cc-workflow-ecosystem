---
name: orchestrating-subagents
description: Executes backlogs by dispatching fresh subagents per task with two-stage review (spec compliance then code quality). Use when executing backlogs with multiple independent tasks, when implementing with Task tool delegation, or when quality gates between tasks are needed.
---

# Orchestrating Subagents

## Overview

Execute backlogs by dispatching fresh subagents per task with two-stage review: spec compliance first, then code quality.

**Core principle:** Fresh subagent per task + two-stage review = high quality, no context pollution.

## The Iron Law of Subagent Dispatch

```
NO TASK COMPLETION WITHOUT THREE-STAGE REVIEW
```

Skipping spec-reviewer or quality-reviewer is not optimization - it is negligence.
A task "completed" without review is a task where bugs were invited.

**Core principle:** Claiming task completion without dispatching all three subagents is dishonesty, not efficiency.

For every task, you MUST dispatch:
1. **code-implementer** - Execute the implementation
2. **spec-reviewer** - Verify requirements are met
3. **quality-reviewer** - Assess code quality

There are no exceptions. "Simple" tasks still have bugs. "Quick" fixes still need review.

## The Orchestration Pattern

```
PARENT CLAUDE (Orchestrator)
├── Reads backlog ONCE, extracts ALL tasks with full text
├── Creates TodoWrite with all tasks
├── For each task:
│   ├── STEP 1: Prepare task description (with Purpose, Failure Modes, Skills)
│   │   ├── Purpose (WHY this task matters)
│   │   ├── Task text (from backlog)
│   │   ├── Relevant file paths
│   │   ├── Scene-setting context
│   │   ├── Success criteria
│   │   ├── Environment verification commands
│   │   ├── Potential failure modes
│   │   └── Required skills to consult
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

## Testing Tiers

The workflow uses a three-tier testing strategy to minimize test execution time while maintaining quality:

### Tier 1: Environment Smoke Test (Once per /implement)
- **Run by:** Orchestrator at /implement startup
- **Command:** `pytest tests/ -x -q --tb=short` or equivalent
- **Purpose:** Verify environment is healthy before dispatching any subagents
- **Frequency:** Once, before the first task

### Tier 2: Targeted TDD Tests (Per Task)
- **Run by:** code-implementer during TDD cycle
- **Command:** Specific test file/function from task description
- **Purpose:** Red-green verification for the specific feature
- **Frequency:** 2x per task (red phase, green phase)

### Tier 3: Full Suite Verification (Once per Feature)
- **Run by:** /verify command before PR
- **Command:** Full test suite, lint, type check, build
- **Purpose:** Final validation before merge
- **Frequency:** Once, at end of /implement

### Time Savings

For a 10-task backlog with 20-minute test suite:
- **Old approach:** ~600 minutes in testing (full suite per task × 3 agents)
- **New approach:** ~30 minutes in testing (smoke + targeted + final verify)

### Reviewer Testing Policy

**Reviewers DO NOT run tests.** They trust implementer evidence:
- **spec-reviewer:** Verifies test output covers requirements (doesn't re-run)
- **quality-reviewer:** Assesses test code quality (doesn't re-run)

## When to Use

Use this skill when:
- You have a backlog with multiple tasks
- Tasks are mostly independent
- You want automated quality gates between tasks

## Subagent Roles

| Agent | Role | Focus | Key Skill Reference |
|-------|------|-------|---------------------|
| `code-implementer` | Execute task | TDD, atomic commits | `subagent-state-management` |
| `spec-reviewer` | Validate completeness | Requirements match | `verification` |
| `quality-reviewer` | Assess quality | Code standards | `verification` |

Each agent is dispatched fresh per task to avoid context pollution between tasks.

## The Process

### Step 1: Prepare

1. Read the backlog file ONCE
2. Extract ALL tasks with their full text
3. Note any shared context (architecture, conventions)
4. Create TodoWrite with all tasks
5. **Identify environment verification commands** (test suite, build, etc.)
6. **Identify required skills for each task** (language skills, debugging, etc.)

**Important:** You read the backlog. Subagents receive curated context, NOT the backlog file.

### Step 2: For Each Task

#### Dispatch code-implementer

Provide a complete task description (see format below).

#### Handle Questions

If implementer asks questions:
1. Answer clearly and completely
2. Provide additional context if needed
3. Re-dispatch with answer

#### Dispatch spec-reviewer

After implementation, dispatch spec-reviewer with:
- Original task requirements
- Purpose of the task
- Implementer's completion report
- Reference to git diff

If spec-reviewer finds gaps:
1. Dispatch implementer to fix gaps
2. Re-dispatch spec-reviewer
3. Repeat until approved

#### Dispatch quality-reviewer

After spec approval, dispatch quality-reviewer with:
- Git diff of changes
- Project conventions
- Spec-reviewer's handoff notes

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

## Task Description Format

The task description is the primary way you communicate with subagents. A complete task description ensures subagent success.

```markdown
## Task: [Name]

### Purpose
[WHY this task matters. What problem does it solve? What value does it enable?
This helps the implementer make good decisions when facing trade-offs.]

### Context
This is task [N] of [Total] in implementing [Feature].
Previous tasks completed: [List]
This task builds on: [Dependencies]

### Requirements
[FULL task text - not summarized. Copy verbatim from backlog.]

### Environment Verification (Orchestrator Handles Full Suite)
The orchestrator runs the smoke test at /implement startup. For subagents, provide targeted checks only:
```bash
# Good: Targeted checks for subagent
python -c "import required_module"    # Verify dependency available
ls src/expected/file.py               # Verify file exists

# Bad: Full suite (orchestrator already did this)
pytest tests/ -v                      # DO NOT include this
```

### Files
Create: [list]
Modify: [list]
Test: [list]

### Success Criteria
- [Specific, measurable criterion 1]
- [Specific, measurable criterion 2]
- [Specific, measurable criterion 3]

### Potential Failure Modes
[What could go wrong? Common pitfalls? Edge cases to watch for?]
- [Failure mode 1]: [How to detect/prevent]
- [Failure mode 2]: [How to detect/prevent]

### Required Skills
[Skills the agent should consult for this task]
- `python-development` - Python patterns and tooling
- `systematic-debugging` - If blocked on errors
- `verification` - Before claiming completion

### Conventions
[Relevant patterns to follow from the codebase]
- [Convention 1]
- [Convention 2]

---
This is a fresh task context. Previous task context does not apply.
```

## Task Description Checklist

Before dispatching any subagent, verify your task description includes:

**Core Sections (Required):**
- [ ] **Task header** (`## Task: [Name]`)
- [ ] **Purpose** (WHY this task matters) ← NEW
- [ ] **Context** (where this fits, dependencies)
- [ ] **Requirements** (FULL task text, not summarized)
- [ ] **Files to touch** (create, modify, test)
- [ ] **Success criteria** (specific, measurable)

**Enhanced Sections (Recommended):**
- [ ] **Environment verification** (commands to check health) ← NEW
- [ ] **Potential failure modes** (what could go wrong) ← NEW
- [ ] **Required skills** (which skills to consult) ← NEW
- [ ] **Conventions** (coding style, patterns if applicable)
- [ ] **Fresh task marker** ("This is a fresh task context.")

**Incomplete task description = poor subagent performance.**

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
| Omit Purpose section | Implementer makes poor trade-offs |
| Omit Failure Modes | Preventable errors occur |
| Omit Required Skills | Agent doesn't use available guidance |

### Trigger Phrases - STOP IMMEDIATELY

If you notice yourself thinking or saying:
- "This task is straightforward, no review needed"
- "I'll skip this review and catch it later"
- "The implementer report shows everything passed"
- "Just this one task..."
- "I'm confident the implementation is correct"
- "Reviews would just slow us down"
- "I'll be more thorough on the next task"
- "Time is short, let me skip to the next task"

**STOP.** These are rationalizations. Dispatch the reviewers.

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "This task is simple, no review needed" | Simple tasks still have bugs. Reviews catch what you missed. |
| "The code-implementer already verified" | Implementers implement; reviewers verify. Different perspectives catch different issues. |
| "I'll review it myself" | You are the orchestrator, not the reviewer. Dispatch the subagent. |
| "Time is short" | Time on reviews < time on bug fixes. Reviews are investment, not cost. |
| "Spec review is redundant with quality review" | Spec catches requirement gaps; quality catches code issues. Both are required. |
| "I'll be more thorough on the next task" | This task is incomplete. Complete it now. |
| "The backlog has too many tasks" | Each task deserves full review. Rushing creates debt. |

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

## Re-Review Requirement (NON-NEGOTIABLE)

When a reviewer finds issues and you dispatch the implementer to fix them, you MUST dispatch **fresh reviews** after the fix. Reviews done before the fix are stale and do not count.

### The Fix Cycle

```
1. spec-reviewer finds gaps
2. Dispatch code-implementer to fix
3. RE-DISPATCH spec-reviewer  ← Required, not optional
4. If approved, THEN dispatch quality-reviewer
5. quality-reviewer finds issues
6. Dispatch code-implementer to fix
7. RE-DISPATCH quality-reviewer  ← Required, not optional
8. Only mark complete when BOTH approve AFTER all fixes
```

### Why Fresh Reviews Are Required

Reviews done BEFORE a fix are invalidated BY the fix. The reviewer verified code that no longer exists. You don't know if:
- The fix introduced new bugs
- The fix broke something that was previously correct
- The fix actually resolved the issue

**A task marked complete without post-fix reviews is not actually verified.**

### Anti-Pattern: The Silent Fix

```
❌ WRONG:
Spec-reviewer: "Missing validation"
Orchestrator: *dispatches implementer*
Implementer: "Added validation"
Orchestrator: *marks task complete*  ← NO! Spec-reviewer didn't verify fix!

✅ CORRECT:
Spec-reviewer: "Missing validation"
Orchestrator: *dispatches implementer*
Implementer: "Added validation"
Orchestrator: *re-dispatches spec-reviewer*
Spec-reviewer: "✅ Validation looks correct now"
Orchestrator: *dispatches quality-reviewer*
Quality-reviewer: "✅ Approved"
Orchestrator: *marks task complete*
```

### Tracker Enforcement

A hook tracks your dispatches. If you mark a task complete after the implementer was re-dispatched but without fresh reviews, you'll receive a warning:

> "RE-REVIEW WARNING: Task marked complete but issues were found in previous review and implementer was re-dispatched. Reviewers dispatched before the fix don't count as fresh reviews."

This is not a suggestion. Re-dispatch the reviewers.

## Example Execution

```
Orchestrator: I'm executing the authentication backlog.

[Read backlog: docs/backlogs/2024-01-15-auth-backlog.md]
[Extract 4 tasks with full text]
[Create TodoWrite: Task 1, Task 2, Task 3, Task 4]

Task 1: User model with password hashing
[Mark in_progress in TodoWrite]
[Prepare task description with Purpose, Failure Modes, Skills]
[Dispatch code-implementer]

Implementer: "Should I use bcrypt or argon2 for hashing?"

Orchestrator: "Use argon2 - it's already in our dependencies."

[Re-dispatch implementer with answer]

Implementer: "Completed. Created User model, added tests, committed."

[Dispatch spec-reviewer with requirements + implementer report]

Spec-reviewer: "✅ Matches spec. All requirements met."

[Dispatch quality-reviewer with spec-reviewer handoff]

Quality-reviewer: "✅ Approved. Good patterns, clean code."

[Mark Task 1 complete]

Task 2: Login endpoint
[Mark in_progress]
[Dispatch code-implementer with full task description]

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
4. **Purpose-driven** - Every task explains WHY, not just WHAT
5. **Failure-aware** - Anticipate problems, provide guidance
6. **Skill-enabled** - Point agents to relevant skills
7. **Two-stage review** - Spec compliance before code quality
8. **Review loops** - Issues found = fix = re-review
9. **Sequential execution** - One task at a time, avoid conflicts

## Automatic Task Tracking (TODO:BACKLOG)

The workflow automatically tracks task progress via code markers:

### How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│ You dispatch code-implementer                                    │
│     ↓                                                           │
│ Hook injects: # TODO:BACKLOG[task-N]: See backlog for requirements │
│     ↓                                                           │
│ Marker appears in test file (line 2)                            │
│     ↓                                                           │
│ Subagent sees marker during startup ritual                      │
│     ↓                                                           │
│ Subagent removes marker as part of completing task              │
│     ↓                                                           │
│ At /verify: sweep checks for remaining markers                  │
└─────────────────────────────────────────────────────────────────┘
```

### What You'll See

When you dispatch code-implementer, you may see a hook message:
```
TODO:BACKLOG[task-3] injected into tests/test_auth.py. Remove this marker as you implement the task.
```

This is informational - the system is creating a persistent anchor in the code.

### Why This Matters

| Benefit | Explanation |
|---------|-------------|
| **Prevents task drift** | Marker anchors the subagent to the correct file |
| **Survives context loss** | Even if subagent loses context, marker remains in code |
| **Catches incomplete work** | `/verify` sweep warns about remaining markers |
| **Creates audit trail** | Git history shows marker addition/removal |

### Your Responsibilities

1. **Understand the messages** - Hook messages about injection are normal, not errors
2. **Reinforce in handoffs** - Mention that markers should be removed if needed
3. **Check sweep results** - At `/verify`, remaining markers indicate incomplete tasks

### Code-Implementer Behavior

The code-implementer agent is instructed to:
1. Check for `TODO:BACKLOG[task-N]` markers during startup
2. Confirm they're working on the correct file
3. Remove the marker as part of completing the task

If markers remain after implementation, it may indicate:
- Subagent didn't complete the task
- Subagent forgot to remove the marker
- Test file wasn't the one specified in the task

### Sweep at /verify

When you run `/verify`, a hook sweeps the codebase for remaining markers:

```
TODO:BACKLOG WARNING: 2 task marker(s) remain in codebase. These indicate
incomplete tasks: ./tests/test_auth.py:2: TODO:BACKLOG[task-3];
./tests/test_api.py:2: TODO:BACKLOG[task-5]. Review implementations and
ensure markers are removed before claiming verification complete.
```

**Action:** Investigate why markers remain. Either complete the tasks or manually remove markers if they're false positives.

## Mandatory Task Tool Usage (NON-NEGOTIABLE)

You MUST use the Task tool to dispatch each subagent. This is not optional.

### Three-Stage Dispatch Requirement

For EVERY task in the backlog, you are REQUIRED to dispatch ALL THREE subagents:

```
code-implementer → spec-reviewer → quality-reviewer
```

Skipping any stage means the task is NOT complete, regardless of implementation status.

### Dispatch Checklist (NON-NEGOTIABLE)

For each task, you MUST verify:
- [ ] Dispatched **code-implementer** via Task tool with complete task description
- [ ] Received and reviewed completion report (with verification evidence)
- [ ] Dispatched **spec-reviewer** via Task tool with requirements + implementer report
- [ ] Received approval OR fixed gaps and re-dispatched until approved
- [ ] Dispatched **quality-reviewer** via Task tool with spec-reviewer handoff
- [ ] Received approval OR fixed issues and re-dispatched until approved
- [ ] Updated TodoWrite to mark task complete ONLY after all three stages approve

**Consequences of skipping:**
- Missing spec-reviewer = requirements may not be met, bugs shipped
- Missing quality-reviewer = code quality issues accumulate, technical debt grows
- Both missing = negligent delivery, workflow violation

**Violation:** Implementing code yourself instead of dispatching code-implementer is a workflow violation. The orchestrator orchestrates; subagents implement.

## Handoff Quality

Good handoffs between agents prevent wasted work and confusion.

### Implementer → Spec-Reviewer

Provide:
- Original requirements (from task description)
- Implementer's completion report
- Reference to changes (git diff)

### Spec-Reviewer → Quality-Reviewer

Spec-reviewer should include in their report:
- What was verified
- Focus areas for quality review
- What NOT to re-check

### Quality-Reviewer → Orchestrator

Quality-reviewer should include:
- Approval status
- Technical debt assessment
- Any recommendations

## Integration

After orchestration completes:
- **REQUIRED:** Use `verification` skill for pre-completion checks
- Use `/verify` command for final validation
- Use `/pr` command to create pull request

**REQUIRED BACKGROUND:**
- Understand `developing-backlogs` for backlog format
- Understand `using-ecosystem` for workflow context
- Understand `subagent-state-management` for agent operational patterns
