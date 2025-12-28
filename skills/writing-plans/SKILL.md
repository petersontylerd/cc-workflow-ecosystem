---
name: writing-plans
description: "Use when you have a spec or requirements for a multi-step task - creates bite-sized implementation plans with exact file paths, complete code, and test commands"
---

# Writing Implementation Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero codebase context. Document everything needed: files to touch, exact code, test commands, expected outputs.

**Core principle:** Each step is one action (2-5 minutes). Complete, precise, executable.

## Plan Document Structure

Every plan MUST start with this header:

```markdown
# [Feature Name] Implementation Plan

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
✓ Create: src/components/LoginForm.tsx
✗ Create: a login form component
```

### Complete Code
```
✓ export function validateEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

✗ add email validation logic here
```

### Exact Commands with Expected Output
```
✓ Run: npm test src/utils/validation.test.ts
  Expected: PASS - 3 tests passed

✗ Run the tests
```

## Plan Template

```markdown
# [Feature] Implementation Plan

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

## After Writing the Plan

Save the plan to:
```
docs/plans/YYYY-MM-DD-<feature-name>-plan.md
```

Offer execution options:
```
"Plan complete and saved. How would you like to proceed?

1. **Subagent Execution** - I'll orchestrate code-implementer, spec-reviewer,
   and quality-reviewer for each task

2. **Manual Execution** - Follow the plan step by step yourself

3. **Review First** - Let's walk through the plan together before starting"
```

## Checklist Before Completing Plan

- [ ] Every task is 2-5 minutes
- [ ] All file paths are exact
- [ ] All code is complete (no placeholders)
- [ ] All commands have expected output
- [ ] TDD cycle is followed (test → fail → implement → pass → commit)
- [ ] Final verification steps included
- [ ] Prerequisites listed
- [ ] Plan saved to docs/plans/

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| "Add validation logic" | Write the actual code |
| "Create component" | Specify exact file path |
| "Run tests" | Include exact command and expected output |
| One huge task | Break into 2-5 minute steps |
| Skip test step | TDD is mandatory |

## Remember

You are writing for an engineer who:
- Has never seen this codebase
- Will execute tasks exactly as written
- Cannot fill in gaps or make assumptions

Every detail matters. If you can't be specific, you don't understand the task well enough.
