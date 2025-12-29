---
description: Run pre-completion verification checks before claiming work is done
argument-hint: "[optional: specific verification to run]"
---

# /verify Command

Run comprehensive verification before claiming completion.

## Usage

```
/verify                    # Full verification
/verify tests             # Just test verification
/verify requirements      # Check requirements coverage
```

## Workflow

This command invokes the `verification` skill.

### What Happens

1. **Run Tests**
   ```bash
   # Run full test suite
   [project test command]
   ```
   - Verify: 0 failures, all pass
   - Report: X/Y tests passed

2. **Run Linter**
   ```bash
   # Run linter
   [project lint command]
   ```
   - Verify: 0 errors
   - Report: Clean or list issues

3. **Run Type Checker** (if applicable)
   ```bash
   # Run type checker
   [project typecheck command]
   ```
   - Verify: 0 errors
   - Report: Clean or list issues

4. **Run Build** (if applicable)
   ```bash
   # Run build
   [project build command]
   ```
   - Verify: Exit code 0
   - Report: Success or failure

5. **Check Requirements**
   - Re-read original requirements
   - Verify each requirement individually
   - Report: Checklist with status

6. **Check Code Quality**
   - No TODO/FIXME in new code
   - No debug statements left
   - No uncommitted changes

### Output

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

## The Iron Rule

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

- Run the command
- See the output
- THEN make the claim

"Should work" or "probably fixed" is NOT verification.

## Verification Checklist

- [ ] All tests pass (run fresh, see output)
- [ ] Linter passes (run fresh, see output)
- [ ] Build passes (if applicable)
- [ ] Type checker passes (if applicable)
- [ ] Each requirement verified
- [ ] No TODO/FIXME in new code
- [ ] No debug statements
- [ ] Git status clean

## Next Steps

After verification passes:
- `/pr` - Create a pull request with the verified changes
- `/commit` - Make additional commits if needed before PR

## Related Commands

- `/implement` - Execute implementation plan
- `/pr` - Create pull request (after verify passes)
