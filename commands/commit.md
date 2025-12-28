---
description: Create an atomic commit with proper conventional commit message format
argument-hint: "[type]: [description] or just [description]"
---

# /commit Command

Create an atomic, well-formatted commit.

## Usage

```
/commit feat: add email validation
/commit fix: resolve login timeout
/commit                           # Interactive - analyze changes and suggest
```

## Workflow

### Step 1: Check Status

```bash
git status
```

Identify:
- Staged changes
- Unstaged changes
- Untracked files

### Step 2: Verify Atomicity

Ensure changes represent ONE logical unit:
- Related files only
- Single purpose
- Complete (tests included)

If changes are not atomic:
- Suggest staging specific files
- Recommend splitting into multiple commits

### Step 3: Run Verification

Before committing:
```bash
# Run tests for changed files
[test command]

# Run linter
[lint command]
```

If verification fails, fix before committing.

### Step 4: Format Message

Use Conventional Commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting (no code change) |
| `refactor` | Code change that doesn't fix/add |
| `test` | Adding/fixing tests |
| `chore` | Maintenance, deps, tooling |

### Scope

Optional component/area:
- `feat(auth): add OAuth2 login`
- `fix(api): handle null response`
- `test(validation): add email format tests`

### Description Guidelines

- Imperative mood: "add" not "added" or "adds"
- Lowercase
- No period at end
- Max 50 characters

### Step 5: Create Commit

```bash
git add [files]
git commit -m "[formatted message]"
```

### Step 6: Confirm

Report:
- Files committed
- Commit message
- Commit hash

## Examples

### Good Commits

```bash
git commit -m "feat(auth): add Google OAuth2 login"
git commit -m "fix(api): handle null user response gracefully"
git commit -m "test(validation): add email format edge cases"
git commit -m "refactor(utils): extract date formatting helpers"
git commit -m "docs(readme): add setup instructions"
```

### Bad Commits (Avoid)

```bash
git commit -m "fix stuff"           # Vague
git commit -m "WIP"                 # Not complete
git commit -m "Fixed the bug."     # Past tense, period
git commit -m "Add feature and fix bug and update docs"  # Multiple things
```

## Interactive Mode

When called without arguments (`/commit`):

1. Analyze staged changes
2. Suggest appropriate type based on files
3. Propose commit message
4. Ask for confirmation or edits

## Issue References

Include issue references in commits:

```bash
# Reference issue
git commit -m "feat(auth): add OAuth2 config (#42)"

# Close issue (for final commit)
git commit -m "feat(auth): complete OAuth2 integration (closes #42)"
```

## Pre-Commit Checks

If pre-commit hooks exist, they run automatically.

If hooks fail:
1. Read error output
2. Fix the issue
3. Re-stage if needed
4. Try commit again

**Never use `--no-verify`** to skip hooks.

## Related Commands

- `/branch` - Create feature branch
- `/verify` - Run verification checks
- `/pr` - Create pull request
