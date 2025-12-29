---
description: Explore requirements and design before implementation - asks questions one at a time to understand what you're building
argument-hint: "[topic or feature description]"
---

# /brainstorm Command

Start a collaborative exploration of requirements and design.

## Usage

```
/brainstorm user authentication
/brainstorm add dark mode toggle
/brainstorm refactor the payment system
```

## Workflow

This command invokes the `brainstorming` skill.

### Environment

This command activates **read-only mode**. Write/Edit tools are blocked until:
1. You save the design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
2. Or you invoke `/plan` to proceed to implementation planning

This prevents premature implementation during the exploration phase.

### What Happens

1. **Context Check**: Examine current project state (files, docs, recent commits)
2. **Question Phase**: Ask questions one at a time to understand:
   - Purpose: Why is this needed?
   - Users: Who will use it?
   - Constraints: Technical/business limitations?
   - Success criteria: How will we know it works?
3. **Approach Exploration**: Propose 2-3 approaches with tradeoffs
4. **Design Presentation**: Present design incrementally (200-300 words/section)
5. **Documentation**: Save design to `docs/plans/YYYY-MM-DD-<topic>-design.md`

### Output

At the end, you'll have:
- A validated design document
- Clear understanding of requirements
- Documented tradeoffs and decisions
- Path forward for implementation

### Next Steps

After brainstorming, you'll be offered:
- `/plan` - Create bite-sized implementation plan
- `/branch` - Create feature branch for development

## Key Principles

- **One question at a time** - Not overwhelming
- **Multiple choice preferred** - Easier to answer
- **YAGNI ruthlessly** - Remove unnecessary features
- **Explore alternatives** - Always consider 2-3 approaches

## Related Commands

- `/plan` - Create implementation plan from design
- `/branch` - Create feature branch
- `/implement` - Execute plan with subagent orchestration
