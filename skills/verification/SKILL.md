---
name: verification
description: Enforces evidence-before-claims discipline with fresh verification output. Use when about to claim work is complete, before expressing satisfaction or success, before committing or creating PRs, or when tempted to say "should work" or "probably fixed".
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

## Common Verification Requirements

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, "looks good" |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

If you notice yourself:
- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!")
- About to commit/push/PR without verification
- Trusting agent success reports without checking
- Relying on partial verification
- Thinking "just this once"
- Feeling tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality |
|--------|---------|
| "Should work now" | RUN the verification |
| "I'm confident" | Confidence ≠ evidence |
| "Just this once" | No exceptions |
| "Linter passed" | Linter ≠ tests ≠ build |
| "Agent said success" | Verify independently |
| "I'm tired" | Exhaustion ≠ excuse |
| "Partial check is enough" | Partial proves nothing |
| "Different words so rule doesn't apply" | Spirit over letter |
| "Ship now, fix later" | Broken in prod is worse |
| "It's urgent" | Urgency ≠ skip verification |

## Handling Time Pressure

### "We need to ship in 5 minutes"
```
"I understand the urgency. Let me run the fastest meaningful verification:

1. Run critical path tests only (30 seconds)
2. Quick smoke test of the change (30 seconds)
3. Commit with evidence

This gives us confidence without full suite delay."
```

### "Tests take too long, skip them"
```
"Full suite may be slow, but we can run targeted tests:

[test command for only changed files]

This catches regressions in what we changed without the full wait."
```

### "We can test after deploy"
```
"Testing in production is risky - users see bugs first.
Let me run the minimum verification:

1. [Specific test for the changed functionality]
2. [Quick build check]

If these pass, we have evidence the core change works."
```

### Absolute Minimum

If truly forced to choose ONE verification:
```
Run the test that exercises the exact change being made.
If that passes, we have evidence for that specific claim.
Never ship with zero verification.
```

## /verify as the Final Gate

**Full verification runs at /verify, not per-task during /implement.**

### During /implement
- Subagents run **targeted tests only** (TDD cycle for their specific feature)
- Reviewers **trust implementer evidence** (don't re-run tests)
- No full suite runs per-task

### At /verify
- Full test suite runs
- Full lint check
- Full type check
- Full build (if applicable)
- This is THE verification gate before PR

### Why This Separation?

| Approach | Time for 10-task backlog |
|----------|-------------------------|
| Full suite per task (old) | ~600 minutes |
| Targeted + final verify (new) | ~30 minutes |

- **Targeted TDD tests** prove each feature works individually
- **Full suite at /verify** catches any integration issues
- **Reviewers verifying evidence** is faster than re-running tests

This is not skipping verification - it's doing the right verification at the right time.

## Verification Patterns

### Tests

```bash
# Run the full test suite
pytest tests/ -v

# Or specific test file
npm test src/components/Login.test.tsx

# Check output for: X passed, 0 failed
```

**Correct:**
```
[Run test command] [See: 34/34 pass] "All tests pass"
```

**Wrong:**
```
"Should pass now" / "Looks correct"
```

### Build

```bash
# Run full build
npm run build

# Check exit code = 0
```

**Correct:**
```
[Run build] [See: exit 0] "Build passes"
```

**Wrong:**
```
"Linter passed" (linter ≠ build)
```

### Regression Tests (TDD Red-Green)

```
1. Write test → Run (should FAIL)
2. Implement fix → Run (should PASS)
3. Verify the test was actually testing the bug:
   - Revert fix → Run (MUST FAIL)
   - Restore fix → Run (MUST PASS)
```

**Correct:**
```
[Write test] → [Run: FAIL] → [Implement] → [Run: PASS] → [Revert: FAIL] → [Restore: PASS]
"Regression test verified with red-green cycle"
```

**Wrong:**
```
"I've written a regression test" (without red-green verification)
```

### Requirements Verification

```
1. Re-read the original requirements/backlog
2. Create checklist of each requirement
3. Verify each one individually
4. Report completion only when ALL checked
```

**Correct:**
```
Requirements checklist:
- [x] User can log in with email - verified in test_login_email
- [x] User can log in with Google - verified in test_login_google
- [x] Session persists across restarts - verified in test_session_persistence
All requirements verified.
```

**Wrong:**
```
"Tests pass, phase complete" (tests ≠ requirements)
```

### Agent Delegation

```
1. Agent reports success
2. Check VCS diff for actual changes
3. Verify changes match expectations
4. Only then trust completion
```

**Correct:**
```
Agent reported success.
[Run: git diff HEAD~1] [See: expected changes]
Changes verified.
```

**Wrong:**
```
"Agent completed successfully" (trust without verify)
```

## Pre-Completion Checklist

Before claiming ANY work is complete:

- [ ] All tests pass (run fresh, see output)
- [ ] Linter passes (run fresh, see output)
- [ ] Build passes (run fresh, see exit code)
- [ ] Type checker passes (if applicable)
- [ ] No TODO:BACKLOG markers remain (check hook output)
- [ ] No TODO/FIXME in new code
- [ ] Documentation updated (if applicable)
- [ ] Each requirement verified individually
- [ ] Git status clean (no uncommitted changes)

## Example Verification Report

Output should follow this structured format:

```markdown
## Verification Report

### Tests
✅ 47/47 tests passed

### Linter
✅ 0 errors, 0 warnings

### Type Checker
✅ No type errors

### Build
✅ Build successful (exit 0)

### Requirements
- [x] User can log in with email
- [x] User can log in with Google
- [x] Session persists across restarts

### Code Quality
✅ No TODO/FIXME in new code
✅ No debug statements
✅ All changes committed

## Summary
✅ All verifications passed. Ready for PR.
```

If any check fails, report it clearly:

```markdown
### Tests
❌ 45/47 tests passed, 2 failed
  - test_login_timeout: AssertionError
  - test_session_expiry: Timeout
```

## When to Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Reporting to stakeholders

**The rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
