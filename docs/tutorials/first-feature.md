# Your First Feature: End-to-End Walkthrough

This tutorial walks you through implementing a complete feature using the workflow ecosystem, from idea to merged PR.

## The Feature: Email Validation

We'll add email validation to a registration form. This is a complete example showing every step of the workflow.

## Prerequisites

- Git repository initialized
- Feature branch workflow enabled
- Issue tracker configured (any platform)

## Step 1: Create an Issue

Before any work, create an issue in your issue tracker to track the feature:

**Title:** `feat: Add email validation to registration`
**Label:** `feature`
**Body:**
```markdown
## Description
Add client-side email validation to the registration form.

## Acceptance Criteria
- [ ] Empty email shows 'Email is required' error
- [ ] Invalid format shows 'Please enter a valid email' error
- [ ] Valid email clears error and enables submit

## Technical Notes
- Use regex for format validation
- Integrate with existing form validation pattern
```

**Output:** Issue #45 created in your tracker.

## Step 2: Create Feature Branch

```
/branch feat/45-email-validation
```

Claude:
1. Checks working tree is clean
2. Pulls latest main
3. Creates branch `feat/45-email-validation`

**Output:** "Created and switched to branch feat/45-email-validation"

## Step 3: Brainstorm the Design (Plan Mode)

Use `/brainstorm` in plan mode (shift+tab twice) to explore requirements:

```
/brainstorm email validation for issue #45
```

Claude will ask questions one at a time:

**Q1:** "Where should validation run?"
- a) Client-side only
- b) Server-side only
- c) Both client and server

**A:** "a) Client-side only for now"

**Q2:** "What email formats should we accept?"
- a) Standard RFC 5322 (strict)
- b) Common formats (username@domain.tld)
- c) Lenient (anything with @ and .)

**A:** "b) Common formats"

After exploration, Claude presents the design and saves to:
`docs/designs/2024-01-15-email-validation-design.md`

**Claude STOPS here** - Review the design document before proceeding.

## Step 4: Create Backlog (Plan Mode)

Use `/backlog-development` in plan mode (shift+tab twice):

```
/backlog-development email-validation
```

Claude creates a detailed backlog:

```markdown
# Email Validation Backlog

**Goal:** Add client-side email validation to registration form.

**Architecture:** Single validation function integrated with existing form.

---

## Task 1: Validation Function

**Files:**
- Create: `src/utils/validation.ts`
- Test: `tests/utils/validation.test.ts`

**Step 1: Write failing test**
\`\`\`typescript
describe('validateEmail', () => {
  it('returns error for empty email', () => {
    expect(validateEmail('')).toBe('Email is required');
  });
});
\`\`\`

**Step 2: Verify failure**
Run: `npm test tests/utils/validation.test.ts`
Expected: FAIL - validateEmail not defined

**Step 3: Implement**
\`\`\`typescript
export function validateEmail(email: string): string | null {
  if (!email) return 'Email is required';
  return null;
}
\`\`\`

**Step 4: Verify pass**
Run: `npm test tests/utils/validation.test.ts`
Expected: PASS

**Step 5: Commit**
`git commit -m "feat(validation): add empty email check (#45)"`

---

## Task 2: Format Validation
[Similar structure...]

---

## Task 3: Form Integration
[Similar structure...]
```

Saved to: `docs/backlogs/2024-01-15-email-validation-backlog.md`

**Claude STOPS here** - Review the backlog document before proceeding.

## Step 5: Implement with Subagents

```
/implement docs/backlogs/2024-01-15-email-validation-backlog.md
```

Claude orchestrates the implementation:

### Task 1 Execution

```
[Dispatch code-implementer]

Implementer: "Implementing Task 1: Validation Function"
- Writing test for empty email check
- Running test: FAIL ✓
- Implementing validateEmail function
- Running test: PASS ✓
- Committed: "feat(validation): add empty email check (#45)"

[Dispatch spec-reviewer]

Spec-reviewer: "✅ Matches requirements. Empty email validation complete."

[Dispatch quality-reviewer]

Quality-reviewer: "✅ Approved. Clean implementation."

[Mark Task 1 complete]
```

### Task 2 Execution

```
[Dispatch code-implementer]

Implementer: "Implementing Task 2: Format Validation"
...
- Committed: "feat(validation): add email format check (#45)"

[Dispatch spec-reviewer]

Spec-reviewer: "❌ Missing: The error message says 'Invalid email'
but spec says 'Please enter a valid email'"

[Implementer fixes]

Implementer: "Updated error message to match spec."

[Re-dispatch spec-reviewer]

Spec-reviewer: "✅ Now matches spec."

[Dispatch quality-reviewer]

Quality-reviewer: "⚠️ Important: Regex could be extracted to constant"

[Implementer fixes]

Implementer: "Extracted EMAIL_REGEX constant."

[Re-dispatch quality-reviewer]

Quality-reviewer: "✅ Approved."

[Mark Task 2 complete]
```

### Task 3 Execution

```
[Similar flow for form integration...]

[All tasks complete]

[Final holistic review]

Quality-reviewer: "All tasks completed. Implementation is consistent
and follows project patterns. Ready for PR."
```

## Step 6: Verify Implementation

```
/verify
```

Claude runs verification:

```
## Verification Report

### Tests
✅ 12/12 tests passed

### Linter
✅ 0 errors, 0 warnings

### Type Checker
✅ No type errors

### Requirements
- [x] Empty email shows 'Email is required' error
- [x] Invalid format shows 'Please enter a valid email' error
- [x] Valid email clears error

### Code Quality
✅ No TODO/FIXME in new code
✅ No debug statements
✅ All changes committed

## Summary
✅ All verifications passed. Ready for PR.
```

## Step 7: Create Pull Request

```
/pr 45
```

Claude generates the PR description:

```markdown
## PR Title
feat: Add email validation to registration

## PR Body
## Summary
Adds client-side email validation to the registration form with
clear error messages for empty and invalid emails.

Closes #45

## Changes
- **Validation Utility**
  - Added `validateEmail` function in `src/utils/validation.ts`
  - Comprehensive test coverage
- **Form Integration**
  - Integrated validation with registration form
  - Real-time validation on blur

## Test Plan
- [x] Empty email shows 'Email is required'
- [x] Invalid format shows 'Please enter a valid email'
- [x] Valid email clears error
- [x] Submit disabled until valid

## Checklist
- [x] Tests pass (12/12)
- [x] Linter passes
- [x] Type checker passes
- [x] No TODO/FIXME in code
```

**Instruction:** Copy this description to your git platform's PR creation form.

## Step 8: After Review

Once PR is approved, merge it via your platform's interface.

Issue #45 auto-closes (if using "Closes #45" keywords). Feature is complete!

## Summary of Commands Used

| Step | Command | Purpose |
|------|---------|---------|
| 1 | Create issue | Track the feature in your tracker |
| 2 | `/branch` | Create feature branch |
| 3 | `/brainstorm` (plan mode) | Explore requirements, write design doc |
| 4 | `/backlog-development` (plan mode) | Create backlog, write backlog doc |
| 5 | `/implement` | Execute with subagents |
| 6 | `/verify` | Pre-PR verification |
| 7 | `/pr` | Generate PR description |
| 8 | Merge PR | Merge via your platform |

## Key Takeaways

1. **Always start with an issue** - Traceability from the beginning
2. **Branch first, then brainstorm** - Feature branch before design work
3. **Use plan mode for design phases** - `/brainstorm` and `/backlog-development` write docs and STOP
4. **Review before proceeding** - Check design and backlog docs before implementation
5. **Let subagents handle reviews** - Two-stage review catches issues
6. **Verify before claiming done** - Evidence, not assumptions
7. **Link everything** - Branch → commits → PR → issue

This workflow ensures high-quality, well-documented, traceable development every time.
