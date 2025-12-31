---
name: systematic-debugging
description: Use when encountering bugs, test failures, or unexpected behavior. Provides a 4-phase methodology for finding root causes instead of treating symptoms.
---

# Systematic Debugging

## Overview

Find root causes, not symptoms. Never add workarounds without understanding why.

**Core principle:** Investigate first, fix once, verify completely.

## The Iron Law

```
ALWAYS find root cause - NEVER fix symptoms or add workarounds
```

## Four-Phase Debugging

### Phase 1: Investigation

Before touching code:

1. **Read error messages carefully** - The message tells you what failed
2. **Reproduce consistently** - Can you trigger it reliably?
3. **Check recent changes** - What changed since it last worked?

```
STOP if you cannot reproduce the bug.
Intermittent bugs need logging, not guessing.
```

### Phase 2: Pattern Analysis

Find working examples:

1. **Find similar code** - What works in the same codebase?
2. **Compare against references** - How do docs/examples do it?
3. **Identify differences** - What's different between working and broken?
4. **Understand dependencies** - What does this code rely on?

### Phase 3: Hypothesis and Testing

Form and test one hypothesis at a time:

| Step | Action |
|------|--------|
| 1 | Form a single, specific hypothesis |
| 2 | Design minimal test for that hypothesis |
| 3 | Test and observe |
| 4 | If wrong, state "I don't understand X" |
| 5 | Form new hypothesis based on evidence |

**Never test multiple hypotheses simultaneously.**

### Phase 4: Implementation

After you understand the problem:

1. **Have simplest failing test** - Reduce to minimal reproduction
2. **Make one change at a time** - Never multiple fixes at once
3. **Test after each change** - Verify before continuing
4. **Stop and re-analyze** if first fix fails

## When Tests Fail

Your thought process:

```
1. READ THE TEST CAREFULLY - What behavior is it protecting?
2. READ YOUR CHANGES - What did you actually change?
3. UNDERSTAND THE CONNECTION - Why did your change break this test?
4. DECIDE:
   - Old behavior obsolete → Update/delete the test
   - Test caught a real bug → Fix your code
   - Unsure → STOP and ask
```

## Common Mistakes

| Mistake | Why It Fails |
|---------|--------------|
| Shotgun debugging | Multiple changes obscure which one helped |
| Treating symptoms | Problem returns in different form |
| Skipping reproduction | You can't verify a fix without reproduction |
| Ignoring error messages | The answer is often in the error |
| Not checking recent changes | The bug was introduced somehow |

## Red Flags - STOP

If you notice yourself:

- Adding workarounds without understanding why
- Making multiple changes hoping something works
- Ignoring error messages or stack traces
- Saying "I don't know why but this fixes it"
- Feeling frustrated and trying random things

**STOP. Return to Phase 1.**

## Quick Reference

| Phase | Focus | Output |
|-------|-------|--------|
| Investigation | Observe, reproduce | Reliable reproduction steps |
| Pattern Analysis | Compare, contrast | Understanding of expected vs actual |
| Hypothesis | One theory at a time | Tested, verified understanding |
| Implementation | Minimal changes | Root cause fix with evidence |

## The Bottom Line

**Understand before fixing.**

If you can't explain why something broke, you don't understand it.
If you don't understand it, you can't reliably fix it.
