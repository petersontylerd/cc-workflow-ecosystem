---
name: developing-backlogs
description: Creates comprehensive backlog documents with bite-sized tasks (2-5 min each), exact file paths, complete code, and TDD test commands. Use when spec or requirements exist for a multi-step task, before touching code, or when planning feature implementation.
---

# Developing Backlogs

## Overview

Write comprehensive backlogs assuming the engineer has zero codebase context. Document everything needed: files to touch, exact code, test commands, expected outputs.

**Core principle:** Each step is one action (2-5 minutes). Complete, precise, executable.

## Plan Mode Requirement

**This skill MUST be run in plan mode** (shift+tab twice before invoking `/backlog-development`).

Plan mode ensures:
- Thorough codebase exploration before defining tasks
- Complete code in each task (no placeholders)
- No premature implementation

**CRITICAL**: You will EXIT plan mode before writing the backlog document. This prevents auto-execution and ensures the backlog is written to `docs/backlogs/`.

## Backlog Document Structure

Every backlog MUST start with this header:

```markdown
# [Feature Name] Backlog

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

**Prerequisites:**
- [ ] Design document reviewed and approved
- [ ] Feature branch created
- [ ] Development environment ready

---
```

## Task Structure

Each task follows the TDD cycle:

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

**Step 1: Write the failing test**

\`\`\`python
def test_specific_behavior():
    result = function(input)
    assert result == expected
\`\`\`

**Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

**Step 3: Write minimal implementation**

\`\`\`python
def function(input):
    return expected
\`\`\`

**Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

**Step 5: Commit**

\`\`\`bash
git add tests/path/test.py src/path/file.py
git commit -m "feat(scope): add specific feature"
\`\`\`
```

## Bite-Sized Granularity

**Each step is ONE action (2-5 minutes):**

| Type | Example |
|------|---------|
| Write test | "Write the failing test for email validation" |
| Run test | "Run test to confirm it fails" |
| Implement | "Implement minimal code to pass the test" |
| Verify | "Run test to confirm it passes" |
| Commit | "Commit the email validation feature" |

**NOT:**
- "Write tests and implement the feature" (too big)
- "Set up the entire authentication system" (way too big)
- "Add validation" (too vague)

## Required Elements

### Exact File Paths
```
OK  Create: src/components/LoginForm.tsx
BAD Create: a login form component
```

### Complete Code
```
OK  export function validateEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

BAD add email validation logic here
```

### Exact Commands with Expected Output
```
OK  Run: npm test src/utils/validation.test.ts
  Expected: PASS - 3 tests passed

BAD Run the tests
```

## Backlog Template

```markdown
# [Feature] Backlog

**Goal:** [One sentence]

**Architecture:** [2-3 sentences]

**Tech Stack:** [Technologies]

---

## Task 1: [First Component]

**Files:**
- Create: `path/to/new/file`
- Test: `tests/path/to/test`

**Step 1: Write failing test**
[Complete test code]

**Step 2: Verify failure**
Run: [exact command]
Expected: [exact output]

**Step 3: Implement**
[Complete implementation code]

**Step 4: Verify success**
Run: [exact command]
Expected: [exact output]

**Step 5: Commit**
[Exact git commands]

---

## Task 2: [Second Component]
[Same structure...]

---

## Final Verification

**Run all tests:**
\`\`\`bash
[test command]
\`\`\`
Expected: All tests pass

**Run linter:**
\`\`\`bash
[lint command]
\`\`\`
Expected: No errors

**Run type checker:**
\`\`\`bash
[type check command]
\`\`\`
Expected: No errors
```

## After Creating the Backlog

### Step 1: Exit Plan Mode

**CRITICAL**: Before writing the backlog document, you MUST exit plan mode.

Why? Plan mode auto-execution would immediately start implementing. Exiting first ensures:
- The backlog is written to `docs/backlogs/`, not `~/.claude/plans/`
- No auto-execution after you accept the backlog
- User controls when to proceed to implementation

**Announce your intent:**
```
"Backlog creation is complete. I'm now exiting plan mode to write the backlog document to docs/backlogs/."
```

**Then use the ExitPlanMode tool.**

### Step 2: Write the Backlog

After exiting plan mode, save the backlog to:
```
docs/backlogs/YYYY-MM-DD-<feature-name>-backlog.md
```

### Step 3: STOP - Do Not Proceed

**After writing the backlog document, you MUST STOP.**

```
"Backlog complete and saved to docs/backlogs/YYYY-MM-DD-<feature-name>-backlog.md.

Please review the backlog document. When ready to proceed:
- Run /implement for subagent orchestration
- Or implement manually following the backlog steps"
```

**DO NOT:**
- Offer to start implementing immediately
- Automatically dispatch subagents
- Proceed to the next phase without explicit user action

The user must explicitly invoke the next command when they are ready.

## Checklist Before Completing Backlog

- [ ] Every task is 2-5 minutes
- [ ] All file paths are exact
- [ ] All code is complete (no placeholders)
- [ ] All commands have expected output
- [ ] TDD cycle is followed (test -> fail -> implement -> pass -> commit)
- [ ] Final verification steps included
- [ ] Prerequisites listed
- [ ] Backlog saved to docs/backlogs/

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Add validation logic" | Write the actual code |
| "Create component" | Specify exact file path |
| "Run tests" | Include exact command and expected output |
| One huge task | Break into 2-5 minute steps |
| Skip test step | TDD is mandatory |

## Backlog Updates

If a backlog needs modification during execution:

1. **STOP** current task
2. **Document** what changed and why in the backlog file
3. **Mark** affected tasks with status:
   - `[COMPLETED]` - Done before change
   - `[OBSOLETE]` - No longer needed
   - `[MODIFIED]` - Updated requirements
   - `[NEW]` - Added tasks
4. **Re-extract** tasks from updated backlog
5. **Update** TodoWrite to reflect new task list
6. **Continue** from next incomplete task

### Backlog Update Example

```markdown
## Task 3: Login validation [MODIFIED]

**Original:** Email-only validation
**Updated:** Email + phone validation (per user feedback)

**Reason:** User requested phone as alternate login method
```

## Remember

Backlogs are written for an engineer who:
- Has never seen this codebase
- Will execute tasks exactly as written
- Cannot fill in gaps or make assumptions

Every detail matters. Lack of specificity indicates insufficient understanding of the task.

---

## Critical: Plan Mode Flow

**This skill uses plan mode for exploration, then EXITS before writing output.**

**Complete Workflow:**
1. Enter plan mode (shift+tab twice before invoking)
2. Use Explore/Plan subagents for codebase research
3. Create detailed task definitions with complete code
4. **EXIT plan mode** using ExitPlanMode tool
5. Write backlog document to `docs/backlogs/YYYY-MM-DD-<feature>-backlog.md`
6. **STOP** - Do not proceed to implementation
7. User will invoke `/implement` when ready

**Why exit plan mode before writing?**
- Prevents auto-execution when user accepts
- Ensures backlog goes to `docs/backlogs/`, not `~/.claude/plans/`
- Gives user control over when to proceed
