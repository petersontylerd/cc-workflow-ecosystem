---
description: Create a bite-sized backlog with exact file paths, complete code, and test commands
argument-hint: "[feature name or design document path]"
---

# /backlog-development Command

Create a detailed backlog from a design or requirements.

## Usage

```
/backlog-development user-authentication
/backlog-development docs/designs/2024-01-15-auth-design.md
/backlog-development "add email validation to registration"
```

## Workflow

This command invokes the `developing-backlogs` skill.

### What Happens

1. **Read Design**: Load the design document or understand the feature
2. **Break Down Tasks**: Decompose into 2-5 minute steps
3. **Detail Each Task**: For each task, specify:
   - Exact file paths to create/modify
   - Complete code (no placeholders)
   - Test commands with expected output
   - TDD cycle (test -> fail -> implement -> pass -> commit)
4. **Save Backlog**: Write to `docs/backlogs/YYYY-MM-DD-<feature>-backlog.md`

### Output Format

```markdown
# [Feature] Backlog

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Technologies]

---

## Task 1: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Test: `tests/path/to/test.py`

**Step 1: Write failing test**
[Complete test code]

**Step 2: Run test to verify it fails**
Run: `pytest tests/...`
Expected: FAIL

**Step 3: Write minimal implementation**
[Complete implementation code]

**Step 4: Run test to verify it passes**
Run: `pytest tests/...`
Expected: PASS

**Step 5: Commit**
`git commit -m "feat(scope): description"`

---

## Task 2: ...
```

### Next Steps

After backlog is complete:
- `/implement` - Execute with subagent orchestration
- Manual execution following the backlog steps

## Key Principles

- **2-5 minutes per step** - Bite-sized and focused
- **Complete code** - No "add validation here"
- **Exact commands** - Include expected output
- **TDD always** - Test -> Fail -> Implement -> Pass -> Commit

## Related Commands

- `/brainstorm` - Explore design before creating backlog
- `/branch` - Create feature branch
- `/implement` - Execute the backlog
- `/verify` - Validate implementation
