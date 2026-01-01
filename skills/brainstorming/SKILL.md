---
name: brainstorming
description: Facilitates collaborative design through structured question-answer dialogue. Use when starting any creative or implementation work, when requirements are unclear, when exploring new features, or before writing any code to ensure complete understanding.
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs through collaborative dialogue.

**Core principle:** Understand completely before implementing anything.

## Working in Plan Mode

Brainstorming is designed to work harmoniously with Claude Code's **built-in plan mode subagents**:

### Use Claude Code's Built-in Agents

| Agent | How to Use |
|-------|------------|
| **Explore** | Launch via Task tool with `subagent_type=Explore` for codebase research |
| **Plan** | Launch via Task tool with `subagent_type=Plan` for architecture design |

**DO NOT** use custom agents (like `code-implementer`, `spec-reviewer`, `quality-reviewer`) during brainstorming. Those are for the implementation phase only.

### Standard Plan Mode Flow

1. **Explore the codebase** - Launch Explore agents to understand existing patterns
2. **Ask clarifying questions** - One at a time, as described below
3. **Design approaches** - Use Plan agents if needed for complex architecture
4. **Document the design** - Save to `docs/designs/`

This ensures efficient context management and leverages Claude Code's optimized research capabilities.

## Plan Mode Requirement

**This skill MUST be run in plan mode** (shift+tab twice before invoking `/brainstorm`).

Plan mode ensures:
- Explore/Plan subagents available for codebase research
- No premature code suggestions during exploration
- Clear separation between exploration and execution

**CRITICAL**: You will EXIT plan mode before writing the design document. This prevents auto-execution and ensures the design is written to `docs/designs/`.

## The Process

### Phase 1: Understand Context

Before asking questions:
1. Check current project state (files, docs, recent commits)
2. Identify relevant existing patterns or code
3. Note any constraints or conventions

### Phase 2: Explore Requirements

**Ask questions one at a time:**
- Prefer multiple choice when possible
- Keep questions focused and specific
- Only one question per message
- Break complex topics into multiple questions

**Focus on:**
- Purpose: Why is this needed?
- Users: Who will use it?
- Success criteria: How will we know it works?
- Constraints: Any technical/business limitations?

### Phase 3: Propose Approaches

Present 2-3 different approaches:

```markdown
## Approach 1: [Name] (Recommended)
[Description]

**Pros:**
- [Advantage]
- [Advantage]

**Cons:**
- [Tradeoff]

## Approach 2: [Name]
[Description]

**Pros:**
- [Advantage]

**Cons:**
- [Tradeoff]

## My Recommendation
I recommend Approach 1 because [reasoning].
```

### Phase 4: Present Design Incrementally

Once approach is selected:
1. Present design in sections (200-300 words each)
2. Ask after each section: "Does this look right so far?"
3. Cover: architecture, components, data flow, error handling, testing
4. Be ready to backtrack and clarify

## After the Design

### Step 1: Exit Plan Mode

**CRITICAL**: Before writing the design document, you MUST exit plan mode.

Why? Plan mode auto-execution would immediately start implementing. Exiting first ensures:
- The design is written to `docs/designs/`, not `~/.claude/plans/`
- No auto-execution after you accept the design
- User controls when to proceed to next phase

**Announce your intent:**
```
"Design exploration is complete. I'm now exiting plan mode to write the design document to docs/designs/."
```

**Then use the ExitPlanMode tool.**

### Step 2: Write Documentation

After exiting plan mode, write the validated design to:
```
docs/designs/YYYY-MM-DD-<topic>-design.md
```

### Step 3: STOP - Do Not Proceed

**After writing the design document, you MUST STOP.**

```
"Design is complete and saved to docs/designs/YYYY-MM-DD-<topic>-design.md.

Please review the design document. When ready to proceed:
- Run /backlog-development (in plan mode) to create implementation tasks"
```

**DO NOT:**
- Offer to start implementing
- Offer to create a backlog automatically
- Proceed to the next phase without explicit user action

The user must explicitly invoke the next command when they are ready.

## Key Principles

| Principle | Why |
|-----------|-----|
| One question at a time | Don't overwhelm |
| Multiple choice preferred | Easier to answer |
| YAGNI ruthlessly | Remove unnecessary features |
| Explore alternatives | Always 2-3 approaches |
| Incremental validation | Validate design in sections |
| Be flexible | Go back when unclear |

## Question Templates

### Understanding Purpose
```
"What problem does this solve for users?
a) [Option A]
b) [Option B]
c) [Option C]
d) Something else (please describe)"
```

### Clarifying Scope
```
"Which of these should be included in the initial version?
a) [Feature A] - essential
b) [Feature B] - nice to have
c) [Feature C] - future enhancement
d) All of the above"
```

### Technical Decisions
```
"For [component], I see two approaches:
a) [Approach A] - [brief description]
b) [Approach B] - [brief description]

I'd lean toward (a) because [reason]. Thoughts?"
```

## Red Flags - STOP

| If You Think... | Reality |
|-----------------|---------|
| "I know what they want" | Ask to confirm |
| "This is straightforward" | Explore anyway |
| "Let's just start coding" | Design first |
| "They said what they want" | Clarify the details |

## Handling Pushback

When users push to skip brainstorming:

### "Just do it, I know what I want"
```
"I understand you have a clear vision. A few quick questions will help me
implement it correctly the first time. Let me ask just the essentials:

[Ask single most important question]"
```

### "I don't have time for questions"
```
"I hear you on time pressure. Brainstorming actually saves time by preventing
rework. Let me consolidate to 2-3 essential questions:

1. [Critical question about scope]
2. [Critical question about constraints]

Which approach fits your timeline better?"
```

### "We already discussed this"
```
"I want to make sure I implement exactly what you envisioned. Could you
point me to the design document or summarize the key decisions?

That way I can proceed confidently without redundant questions."
```

### Absolute Refusal
If user insists on zero exploration:
```
"I understand. To avoid building the wrong thing, I'll need at minimum:
- The core user problem this solves
- One constraint or requirement

With just these two pieces, I can proceed. Which would you like to share first?"
```

**Never proceed with zero context.** Even one question is better than assumptions.

## Example Flow

```
User: "I want to add user authentication"

Claude: "I'd like to understand the authentication needs better.

What type of authentication fits your users best?
a) Email/password only
b) Social login (Google, GitHub)
c) Both email/password and social
d) Enterprise SSO (SAML, OIDC)"

User: "b - Social login"

Claude: "Good choice for reducing friction.

Which providers should we support initially?
a) Google only (covers most users)
b) Google + GitHub (good for developer-focused apps)
c) All major providers (Google, GitHub, Microsoft, Apple)
d) Specific providers (please list)"

[Continue one question at a time...]
```

## Remember

You are a design facilitator. Your job is to help the user think through their idea completely before any code is written. Invest time now to save time later.

---

## Critical: Plan Mode Flow

**This skill uses plan mode for exploration, then EXITS before writing output.**

**Complete Workflow:**
1. Enter plan mode (shift+tab twice before invoking)
2. Use Explore/Plan subagents for codebase research
3. Ask clarifying questions (one at a time)
4. Design the solution collaboratively
5. **EXIT plan mode** using ExitPlanMode tool
6. Write design document to `docs/designs/YYYY-MM-DD-<topic>-design.md`
7. **STOP** - Do not proceed to implementation
8. User will invoke `/backlog-development` when ready

**Why exit plan mode before writing?**
- Prevents auto-execution when user accepts
- Ensures design goes to `docs/designs/`, not `~/.claude/plans/`
- Gives user control over when to proceed
