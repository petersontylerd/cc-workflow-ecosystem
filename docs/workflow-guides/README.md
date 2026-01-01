# Workflow Ecosystem Usage Patterns

This directory contains visual, file-by-file illustrations of how the workflow ecosystem plugin works at different user experience levels.

## Quick Links

| Document | Description |
|----------|-------------|
| [Intermediate Pattern](./intermediate-pattern.md) | Full automation with subagent orchestration |
| [Expert Pattern](./expert-pattern.md) | Power user customization and escape hatches |
| [File Reference Matrix](./file-reference-matrix.md) | Complete inventory of all files and their roles |

---

## Workflow State Machine

The plugin enforces a state machine that guides users through a disciplined development workflow:

```mermaid
stateDiagram-v2
    [*] --> idle : Session Start
    idle --> branched : /branch
    branched --> brainstorming : /brainstorm (plan mode)
    brainstorming --> backlog_ready : /backlog-development (plan mode)
    backlog_ready --> implementing : /implement
    implementing --> verifying : /verify
    verifying --> [*] : PR merged

    note right of branched : Write/Edit BLOCKED
    note right of brainstorming : Write/Edit BLOCKED
    note right of backlog_ready : Write/Edit ALLOWED
```

---

## Three-Tier Automation

The ecosystem provides three tiers of automation, each building on the previous:

```
┌─────────────────────────────────────────────────────────────────────┐
│  TIER 1: SKILLS                                                     │
│  ─────────────────                                                  │
│  Core competencies and disciplines                                  │
│  Invoked via: Skill tool                                           │
│  Files: skills/<name>/SKILL.md                                     │
└─────────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Skills define HOW
                              │
┌─────────────────────────────────────────────────────────────────────┐
│  TIER 2: COMMANDS                                                   │
│  ─────────────────                                                  │
│  User-invokable workflow entry points                               │
│  Invoked via: /command-name                                         │
│  Files: commands/<name>.md                                          │
└─────────────────────────────────────────────────────────────────────┘
                              ▲
                              │ Commands orchestrate WHAT
                              │
┌─────────────────────────────────────────────────────────────────────┐
│  TIER 3: AGENTS                                                     │
│  ─────────────────                                                  │
│  Specialized subagents for task execution                           │
│  Invoked via: Task tool                                             │
│  Files: agents/<name>.md                                            │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Quick Reference: All Components

### Commands (8)

| Command | Purpose | Invokes Skill |
|---------|---------|---------------|
| `/brainstorm` | Explore requirements before implementation | `brainstorming` |
| `/branch` | Create/switch feature branches | `git-workflow` |
| `/backlog-development` | Create bite-sized backlog | `developing-backlogs` |
| `/implement` | Execute backlog with subagents | `orchestrating-subagents` |
| `/verify` | Run pre-completion verification | `verification` |
| `/commit` | Create atomic commit | `git-workflow` |
| `/pr` | Create pull request | `git-workflow` |
| `/workflow` | Manage enforcement state | `workflow-management` |

### Skills (12)

| Skill | Purpose | Auto-triggered? |
|-------|---------|-----------------|
| `using-ecosystem` | Ecosystem orientation | Yes (SessionStart) |
| `brainstorming` | Requirements exploration | Via /brainstorm |
| `developing-backlogs` | Backlog creation | Via /backlog-development |
| `orchestrating-subagents` | Subagent dispatch | Via /implement |
| `verification` | Evidence-based completion | Via /verify |
| `git-workflow` | Branch/commit/PR workflow | Via /branch, /commit, /pr |
| `workflow-management` | State management | Via /workflow |
| `subagent-state-management` | Subagent patterns | Referenced by agents |
| `systematic-debugging` | Debugging methodology | Referenced by agents |
| `python-development` | Python standards | Referenced when applicable |
| `typescript-development` | TypeScript patterns | Referenced when applicable |
| `angular-development` | Angular patterns | Referenced when applicable |

### Agents (3)

| Agent | Role | Dispatched By |
|-------|------|---------------|
| `code-implementer` | TDD implementation | `/implement` orchestrator |
| `spec-reviewer` | Requirements compliance | `/implement` orchestrator |
| `quality-reviewer` | Code quality assessment | `/implement` orchestrator |

### Hooks (17 scripts + 1 config)

| Hook Script | Type | Purpose |
|-------------|------|---------|
| `hooks.json` | Config | Defines all hook triggers |
| `session-start.sh` | SessionStart | Injects `using-ecosystem` skill, auto-detects feature branch |
| `main-branch-protection.sh` | PreToolUse | **BLOCKS** edits on main/master |
| `workflow-phase-check.sh` | PreToolUse | **BLOCKS** edits before backlog-ready phase |
| `tdd-precommit-check.sh` | PreToolUse | **BLOCKS** commits without tests, detects trivial tests |
| `verify-before-commit.sh` | PreToolUse | Reminds about verification |
| `validate-task-description.sh` | PreToolUse | Validates subagent task descriptions |
| `backlog-task-counter.sh` | PreToolUse | Counts backlog tasks, warns on large backlogs |
| `verify-task-count.sh` | PreToolUse | Compares completed vs expected tasks |
| `brainstorm-phase-start.sh` | PreToolUse | Sets phase when brainstorming starts |
| `phase-transition.sh` | PostToolUse | Updates workflow phase, resets state on /branch |
| `workflow-skip-set.sh` | PostToolUse | Sets enforcement skip |
| `brainstorm-exit-plan-mode.sh` | PostToolUse | Phase transition after ExitPlanMode |
| `subagent-dispatch-tracker.sh` | PostToolUse | Tracks subagent dispatches, detects fix cycles |
| `subagent-review-check.sh` | PostToolUse | **WARNS** if task completed without reviewers or re-review |
| `backlog-lint.sh` | PostToolUse | Scans backlogs for placeholders |
| `implementer-evidence-check.sh` | PostToolUse | Validates completion evidence |
| `run-hook.cmd` | Wrapper | Cross-platform execution |

---

## Session State Files

The plugin tracks workflow state using files in `$CLAUDE_SESSION_DIR`:

| File | Purpose | Created By | Read By |
|------|---------|------------|---------|
| `.workflow_phase` | Current phase | `phase-transition.sh`, `session-start.sh` | `workflow-phase-check.sh`, `subagent-dispatch-tracker.sh`, `subagent-review-check.sh` |
| `.workflow_skip` | Bypass enforcement | `workflow-skip-set.sh` | All blocking hooks |
| `.backlog_path` | Current backlog | `backlog-task-counter.sh` | Skills, agents, `verify-task-count.sh` |
| `.subagent_dispatch` | Tracks dispatched agents per task | `subagent-dispatch-tracker.sh` | `subagent-review-check.sh` |
| `.expected_task_count` | Expected number of tasks from backlog | `backlog-task-counter.sh` | `verify-task-count.sh` |
| `.needs_refix` | Flag for fix cycle re-review | `subagent-dispatch-tracker.sh` | `subagent-review-check.sh` |

---

## Enforcement Summary

### What Gets BLOCKED

| Action | Condition | Hook |
|--------|-----------|------|
| Write/Edit | On main/master branch | `main-branch-protection.sh` |
| Write/Edit | In `branched` phase (before /brainstorm) | `workflow-phase-check.sh` |
| Write/Edit | In `brainstorming` phase (before /backlog-development) | `workflow-phase-check.sh` |
| Git commit | Source files without tests | `tdd-precommit-check.sh` |

### Escape Hatch

```bash
/workflow skip    # Bypass ALL enforcement for this session
/workflow status  # Check current phase and skip state
/workflow reset   # Re-enable enforcement
```

---

## Plugin Structure

```
.claude-plugin/
├── plugin.json          # Plugin manifest
└── marketplace.json     # Marketplace metadata

commands/                # User-invokable commands
├── brainstorm.md
├── branch.md
├── backlog-development.md
├── implement.md
├── verify.md
├── commit.md
├── pr.md
└── workflow.md

skills/                  # Core competencies
├── using-ecosystem/SKILL.md
├── brainstorming/SKILL.md
├── developing-backlogs/SKILL.md
├── orchestrating-subagents/SKILL.md
├── verification/SKILL.md
├── git-workflow/SKILL.md
├── workflow-management/SKILL.md
├── subagent-state-management/SKILL.md
├── systematic-debugging/SKILL.md
├── python-development/SKILL.md
├── typescript-development/SKILL.md
└── angular-development/SKILL.md

agents/                  # Subagent prompts
├── code-implementer.md
├── spec-reviewer.md
└── quality-reviewer.md

hooks/                   # Enforcement scripts
├── hooks.json
├── run-hook.cmd
├── session-start.sh
├── main-branch-protection.sh
├── workflow-phase-check.sh
├── tdd-precommit-check.sh
├── verify-before-commit.sh
├── validate-task-description.sh
├── backlog-task-counter.sh
├── verify-task-count.sh
├── brainstorm-phase-start.sh
├── phase-transition.sh
├── workflow-skip-set.sh
├── brainstorm-exit-plan-mode.sh
├── subagent-dispatch-tracker.sh
├── subagent-review-check.sh
├── backlog-lint.sh
└── implementer-evidence-check.sh
```

---

## How to Read These Guides

Each pattern document follows this structure:

1. **Scenario Overview** - Abstract description of the user journey
2. **Command Sequence** - What the user types
3. **Under the Hood** - File-by-file trace with:
   - Which file is activated
   - What the file does (with line number references)
   - What triggers next (hooks, skill invocations)
   - Mermaid sequence diagrams for complex flows
   - ASCII diagrams for simple inline traces
4. **Files Referenced** - Summary of all files touched in the pattern

Start with [Intermediate Pattern](./intermediate-pattern.md) to understand the full automation workflow, then progress to [Expert](./expert-pattern.md) for power user customization.
