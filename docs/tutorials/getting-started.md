# Getting Started with the Workflow Ecosystem

Welcome to the Claude Code Workflow Ecosystem! This guide will help you understand and use the tools available for structured, high-quality development.

## What is the Workflow Ecosystem?

The ecosystem provides a structured approach to development with:

- **Skills**: Core competencies and disciplines (brainstorming, backlog development, verification)
- **Commands**: User-invokable workflows (`/brainstorm`, `/backlog-development`, `/implement`, `/verify`)
- **Agents**: Specialized subagents for task delegation (code-implementer, spec-reviewer, quality-reviewer)

## The Core Workflow

Every feature follows this flow:

```
1. /brainstorm           →  Explore requirements and design
2. /branch               →  Create feature branch
3. /backlog-development  →  Create bite-sized backlog
4. /implement            →  Execute with subagent orchestration
5. /verify               →  Run pre-completion verification
6. /pr                   →  Create pull request
```

## Quick Start

### Starting a New Feature

When you have an idea for a feature:

```
User: "I want to add user authentication"

Claude: Uses /brainstorm to explore requirements
        - What type of authentication?
        - Which providers?
        - Session handling?

After design is complete:

Claude: Uses /branch to create feat/42-user-auth
        Uses /backlog-development to create detailed backlog
        Uses /implement to execute with subagent review
        Uses /verify to confirm everything works
```

### Key Commands

| Command | When to Use | What it Does |
|---------|-------------|--------------|
| `/brainstorm` | Starting ANY new work | Explores requirements through questions |
| `/branch` | Before coding | Creates properly named feature branch |
| `/backlog-development` | After design is complete | Creates bite-sized backlog |
| `/implement` | With a backlog ready | Orchestrates subagents for execution |
| `/verify` | Before claiming done | Runs verification checks |
| `/workflow` | Managing enforcement | Skip, check status, or reset workflow state |

## Understanding Skills

Skills are loaded automatically when relevant. You don't need to invoke them directly - Claude will use them when appropriate.

### Core Skills

| Skill | Purpose |
|-------|---------|
| `using-ecosystem` | Introduces the ecosystem (auto-loaded on session start) |
| `brainstorming` | Guides requirement exploration |
| `developing-backlogs` | Creates detailed backlogs |
| `orchestrating-subagents` | Coordinates subagent execution |
| `verification` | Ensures evidence-based completion |
| `git-workflow` | Enforces feature branch discipline |

## Understanding Agents

Agents are specialized subagents dispatched during `/implement`:

| Agent | Role | Dispatched When |
|-------|------|-----------------|
| `code-implementer` | Executes tasks with TDD | Per task in backlog |
| `spec-reviewer` | Verifies requirements are met | After implementation |
| `quality-reviewer` | Assesses code quality | After spec approval |

### The Review Cycle

For each task:
1. Implementer completes the task
2. Spec-reviewer checks if requirements are met
   - If gaps: Implementer fixes → Re-review
3. Quality-reviewer checks code quality
   - If issues: Implementer fixes → Re-review
4. Task marked complete

## Essential Disciplines

### 1. TDD (Test-Driven Development)

```
Write test → Watch fail → Implement → Watch pass → Refactor
```

Every feature starts with a failing test. No exceptions.

### 2. Verification Before Claims

```
Run command → See output → THEN make claim
```

Never say "should work" or "probably fixed". Run the verification first.

### 3. Feature Branch Workflow

```
git checkout -b feat/<issue>-<slug>
# Work happens here
# Never on main/master
```

All work happens on feature branches with proper naming.

### 4. Workflow Enforcement

The ecosystem **actively blocks** violations:

| Blocked Action | When | How to Proceed |
|----------------|------|----------------|
| Write/Edit code | On main/master | Run `/branch` first |
| Write/Edit code | During brainstorming | Complete `/branch` → `/backlog-development` |
| Write/Edit code | No backlog exists | Run `/backlog-development` first |
| Git commit | No test files staged | Stage tests with source |

**Escape hatch**: `/workflow skip` bypasses enforcement (use sparingly).

### 5. Atomic Commits

```
One logical change per commit
Clear commit message
All tests pass after commit
```

## Example: Adding a Feature

Let's walk through adding email validation:

### Step 1: Brainstorm
```
/brainstorm email validation for registration

Claude asks:
- "Where should validation run? Client-side, server-side, or both?"
- "What email formats should we accept?"
- "What error messages should users see?"

Design is documented in docs/designs/2024-01-15-email-validation-design.md
```

### Step 2: Create Branch
```
/branch feat/45-email-validation

Claude:
- Checks working tree is clean
- Creates branch from latest main
- Confirms: "Created and switched to branch feat/45-email-validation"
```

### Step 3: Create Backlog
```
/backlog-development email-validation

Claude creates:
- Task 1: Write failing test for valid email
- Task 2: Implement validation function
- Task 3: Write tests for invalid formats
- Task 4: Add error messages
- Task 5: Integrate with registration form

Each task has exact file paths, complete code, test commands.
```

### Step 4: Implement
```
/implement docs/backlogs/2024-01-15-email-validation-backlog.md

Claude orchestrates:
- Dispatches code-implementer for Task 1
- Spec-reviewer confirms requirements met
- Quality-reviewer approves code
- Repeats for each task
- Final holistic review
```

### Step 5: Verify
```
/verify

Claude runs:
- All tests: 47/47 passed
- Linter: 0 errors
- Type checker: 0 errors
- Requirements: All verified

"All verifications passed. Ready for PR."
```

### Step 6: Create PR
```
/pr

Claude:
- Creates PR with summary
- Links to issue #45
- Includes test plan
```

## Tips for Success

### Do:
- Use `/brainstorm` before implementing anything
- Break work into small, testable pieces
- Let the verification skill guide completion claims
- Follow the TDD cycle for every feature

### Don't:
- Skip brainstorming for "simple" features
- Commit directly to main
- Claim work is done without running verification
- Trust subagent success reports without checking

## Troubleshooting

### "Claude is blocking my edits"

The workflow enforcement hooks block edits in certain situations:

| Block Message | Cause | Solution |
|---------------|-------|----------|
| "Cannot edit on main/master" | You're on the main branch | Run `/branch feat/<issue>-<slug>` |
| "Still in brainstorming phase" | Brainstorming not complete | Run `/branch` then `/backlog-development` |
| "No backlog" | Branch exists but no backlog | Run `/backlog-development` |
| "TDD VIOLATION" | Committing source without tests | Stage test files too |

**Quick bypass**: `/workflow skip` disables all enforcement for the session.

### "Claude isn't using the skills"

Skills are invoked based on context. Try being explicit:
- "Let's brainstorm this feature first"
- "Can we create a backlog?"

### "Subagent reviews keep finding issues"

This is working as intended! The review loop ensures quality:
1. Issues found = implementation needs improvement
2. Fixes are applied
3. Re-review confirms fixes work
4. Only then does task complete

### "Verification is taking too long"

Each verification step is important. If you're tempted to skip:
- Consider: What could go wrong?
- The time spent verifying is less than debugging later

## Next Steps

1. Try the workflow on a small feature
2. Observe how skills are invoked automatically
3. Notice how subagents handle different aspects
4. Get comfortable with the verification discipline

The ecosystem is designed to help you build better software with confidence. Let it guide you!
