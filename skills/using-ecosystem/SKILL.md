---
name: using-ecosystem
description: Provides orientation to the workflow ecosystem's three-tier automation (skills, commands, agents) and skill invocation rules. Use when starting any conversation, when unsure which skill applies, or when needing to understand workflow phases and enforcement.
---

<EXTREMELY-IMPORTANT>
You have access to a comprehensive workflow ecosystem designed to optimize human-agent co-development.

IF A SKILL APPLIES TO YOUR TASK, YOU MUST USE IT. This is not optional.
</EXTREMELY-IMPORTANT>

## Ecosystem Overview

This ecosystem provides three tiers of automation:

| Tier | Component | Purpose | How to Access |
|------|-----------|---------|---------------|
| **1** | Skills | Core competencies and disciplines | `Skill` tool |
| **2** | Commands | User-invokable workflows | `/command-name` |
| **3** | Agents | Specialized subagents for delegation | `Task` tool |

## Available Skills

| Skill | Description |
|-------|-------------|
| `brainstorming` | Facilitates collaborative design through structured dialogue. Use before creative/implementation work. |
| `developing-backlogs` | Creates comprehensive backlogs with bite-sized tasks and TDD commands. Use when planning features. |
| `orchestrating-subagents` | Executes backlogs with fresh subagents and two-stage review. Use for multi-task implementation. |
| `verification` | Enforces evidence-before-claims discipline. Use before claiming completion or success. |
| `git-workflow` | Enforces feature branch workflow with atomic commits. Use for all version control operations. |

## Reference Skills

These skills provide techniques and standards for specific situations:

| Skill | When to Use |
|-------|-------------|
| `systematic-debugging` | When encountering bugs, test failures, or unexpected behavior. 4-phase root cause methodology. |
| `python-development` | When working on Python projects. Standards for uv, ruff, mypy, pytest, type hints. |
| `typescript-development` | When working with TypeScript. Strict mode, type patterns, error handling. |

## Available Commands

| Command | Purpose |
|---------|---------|
| `/brainstorm` | Explore requirements before implementation |
| `/backlog-development` | Create bite-sized backlog |
| `/implement` | Execute backlog with subagent orchestration |
| `/branch` | Create/switch feature branches with enforcement |
| `/verify` | Run pre-completion verification |
| `/workflow` | Manage enforcement state (skip/status/reset) |

## Available Agents

| Agent | Role | When to Dispatch |
|-------|------|------------------|
| `code-implementer` | Execute implementation tasks | Per task in backlog |
| `spec-reviewer` | Verify code matches requirements | After implementation |
| `quality-reviewer` | Assess code quality and style | After spec approval |

## The Core Workflow

```
User Request → /brainstorm → /branch → /backlog-development → /implement → /verify → PR
```

### Workflow Details

1. **Brainstorm First**: Before ANY implementation, explore requirements
   - One question at a time
   - Propose 2-3 approaches with tradeoffs
   - Validate design incrementally

2. **Branch Enforcement**: Always work on feature branches
   - Pattern: `feat/<issue>-<slug>` or `fix/<issue>-<slug>`
   - Never commit directly to main/master

3. **Develop Backlogs in Bite-Sized Tasks**: Each step is 2-5 minutes
   - Exact file paths
   - Complete code (not "add validation")
   - Test commands with expected output

4. **Implement with Subagents**: For each task:
   - Dispatch `code-implementer` (follows TDD)
   - Dispatch `spec-reviewer` (validates completeness)
   - Dispatch `quality-reviewer` (assesses quality)
   - Only proceed when all reviewers approve

5. **Verify Before Completion**: Evidence before claims
   - Run test command, see output, THEN claim pass
   - Never say "should work" or "probably fixed"

## Skill Invocation Rules

```dot
digraph ecosystem_flow {
    "User request" [shape=doublecircle];
    "Check for skills" [shape=diamond];
    "Invoke Skill tool" [shape=box];
    "Announce skill usage" [shape=box];
    "Follow skill exactly" [shape=box];
    "Respond" [shape=doublecircle];

    "User request" -> "Check for skills";
    "Check for skills" -> "Invoke Skill tool" [label="skill applies"];
    "Check for skills" -> "Respond" [label="no skill"];
    "Invoke Skill tool" -> "Announce skill usage";
    "Announce skill usage" -> "Follow skill exactly";
    "Follow skill exactly" -> "Respond";
}
```

## Red Flags - STOP and Check Skills

| Thought | Reality |
|---------|---------|
| "Let me just start coding" | Use `brainstorming` skill first |
| "I'll figure it out as I go" | Use `developing-backlogs` skill first |
| "This is a quick fix" | Even quick fixes need TDD |
| "Should work now" | Use `verification` skill first |
| "I'll test later" | TDD means test FIRST |
| "Let me commit to main" | Use `git-workflow` - feature branch required |
| "Let me try this fix" | Use `systematic-debugging` - investigate root cause first |

## Quality Disciplines

These disciplines are NON-NEGOTIABLE:

1. **TDD**: Write test → Watch fail → Implement → Watch pass
2. **Verification**: Run command → See output → THEN claim result
3. **Atomic Commits**: One logical change per commit
4. **Feature Branches**: Never commit to main directly

## Workflow Enforcement

The ecosystem **actively enforces** workflow discipline through blocking hooks:

### What Gets Blocked

| Action | Blocked When | How to Proceed |
|--------|--------------|----------------|
| Write/Edit code | On main/master branch | Run `/branch` first |
| Write/Edit code | In brainstorming phase | Complete `/branch` → `/backlog-development` |
| Write/Edit code | Branch created but no backlog | Run `/backlog-development` first |
| Git commit | Source files without tests staged | Stage test files or `/workflow skip` |

### Workflow Phases

```
idle → brainstorming → branched → backlog-ready → implementing → verifying → idle
       (blocks edits)   (blocks edits)   (allows edits)
```

### Escape Hatch

For experienced users who understand the risks:

```
/workflow skip    # Bypass enforcement for this session
/workflow status  # Check current phase
/workflow reset   # Re-enable enforcement
```

**Warning**: Skipping enforcement removes guardrails that prevent bugs and maintain quality.

## Subagent Orchestration Pattern

When using `/implement` or orchestrating subagents:

```
Parent Claude (Orchestrator):
├── Reads backlog once, extracts all tasks
├── Creates TodoWrite with all tasks
├── For each task:
│   ├── Prepare context packet
│   ├── Dispatch code-implementer
│   ├── Handle questions if any
│   ├── Dispatch spec-reviewer
│   ├── Fix gaps if any
│   ├── Dispatch quality-reviewer
│   ├── Fix issues if any
│   └── Mark complete
└── Final review after all tasks
```

**Key**: Parent maintains context, subagents receive curated context packets.

## Getting Help

- `/help` - Show available commands
- Invoke `Skill` tool with skill name to read skill content
- Check `docs/tutorials/getting-started.md` for walkthrough
