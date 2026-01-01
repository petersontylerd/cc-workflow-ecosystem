---
description: Explore requirements and design before implementation - asks questions one at a time to understand what you're building
argument-hint: "[topic or feature description]"
---

# /brainstorm Command

Start a collaborative exploration of requirements and design.

**IMPORTANT**: This command uses plan mode for exploration, then EXITS plan mode before writing the design.

## Workflow

1. Enter plan mode (shift+tab twice) - enables exploration subagents
2. Run `/brainstorm <topic>` - explores codebase, asks questions, designs
3. **Claude will EXIT plan mode** before writing the design document
4. Design is written to `docs/designs/YYYY-MM-DD-<topic>-design.md`
5. Command **STOPS** - user must run `/backlog-development` to continue

**WARNING**: Do NOT use "auto-accept edits" with this command. Wait for Claude to exit plan mode and write the design to `docs/designs/`.

## Usage

```
/brainstorm user authentication
/brainstorm add dark mode toggle
/brainstorm refactor the payment system
```

Use the **brainstorming** skill for the full exploration and design process.
