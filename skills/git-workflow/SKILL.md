---
name: git-workflow
description: Use when creating branches, making commits, or managing version control - enforces feature branch workflow and atomic commits
---

# Git Workflow

## Overview

Feature branch development is MANDATORY. Never commit directly to main/master.

**Core principle:** Isolated feature development with atomic, traceable commits.

## The Iron Laws

```
1. NEVER commit to main/master directly
2. ALWAYS use feature branches
3. ALWAYS use atomic commits (one logical change)
4. ALWAYS reference issues in commits when applicable
```

## Branch Naming Convention

```
<type>/<issue-number>-<short-description>
```

### Types

| Type | When to Use |
|------|-------------|
| `feat/` | New feature or functionality |
| `fix/` | Bug fix |
| `chore/` | Maintenance, dependencies, tooling |
| `refactor/` | Code restructuring without behavior change |
| `docs/` | Documentation only |
| `test/` | Test additions or modifications |

### Examples

```bash
feat/42-user-authentication
fix/123-login-timeout
chore/456-update-dependencies
refactor/789-extract-validation
```

## Pre-Work Repository Preparation

**MANDATORY before any changes:**

### Step 1: Check for uncommitted changes

```bash
git status -sb
```

- If clean: Proceed to Step 2
- If changes exist: Commit, stash, or discard before branching

### Resolution Options (for uncommitted changes)

**Option A - Commit relevant changes:**
```bash
git add <paths-to-commit>
git commit -m "WIP: describe changes before branching"
```

**Option B - Stash changes:**
```bash
git stash push --include-untracked --message "<context>-pre-branch"
```

**Option C - Discard changes:**
```bash
git restore --staged <paths>
git restore <paths>
```

### Step 2: Create feature branch from main

```bash
git checkout main
git pull --ff-only
git checkout -b <type>/<issue>-<description>
git status -sb
```

## Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Commit Types

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting (no code change) |
| `refactor` | Code restructuring |
| `test` | Adding tests |
| `chore` | Maintenance |

### Good Commit Messages

```bash
# Feature
git commit -m "feat(auth): add OAuth2 login with Google"

# Bug fix with issue reference
git commit -m "fix(api): handle null response in user fetch (#123)"

# Refactoring
git commit -m "refactor(validation): extract email validator to shared utils"
```

### Bad Commit Messages

```bash
git commit -m "fix stuff"           # Vague
git commit -m "WIP"                 # Not atomic
git commit -m "Changes"             # Meaningless
git commit -m "asdfasdf"            # Garbage
```

## Atomic Commits

Each commit should:

1. **Be complete**: Pass all tests, compile, work
2. **Be focused**: One logical change
3. **Be reversible**: Can be reverted without breaking other things
4. **Be traceable**: Clear message explaining WHY

### Signs of Non-Atomic Commits

- "and" in the commit message
- Multiple unrelated files changed
- Tests failing after commit
- Commit message is vague or generic

### Breaking Down Large Changes

Instead of one massive commit:

```bash
# Bad: One huge commit
git commit -m "feat: add user authentication system"

# Good: Series of atomic commits
git commit -m "feat(auth): add User model with password hashing"
git commit -m "feat(auth): add login endpoint"
git commit -m "feat(auth): add session middleware"
git commit -m "feat(auth): add logout endpoint"
git commit -m "test(auth): add authentication integration tests"
```

## Issue Integration

### Link Branch to Issue

```bash
# Branch name includes issue number
git checkout -b feat/42-user-authentication
```

### Reference Issues in Commits

```bash
# Progress on issue
git commit -m "feat(auth): add login form (#42)"

# Close issue when complete
git commit -m "feat(auth): complete OAuth flow (closes #42)"
```

### Structure Large Features

For large features, create a parent issue with sub-tasks in your issue tracker:

1. **Parent issue**: The main feature (e.g., "Add user authentication")
2. **Sub-tasks**: Individual work items linked to the parent
3. **Reference pattern**: Include "Part of #42" in sub-task descriptions

## FORBIDDEN Operations

| Operation | Why Forbidden |
|-----------|---------------|
| `--no-verify` | Bypasses quality checks |
| `--force` on shared branches | Destroys history |
| Direct commits to main | No review process |
| `git add -A` without `git status` | May include unintended files |

## Handling Pushback

### "It's a tiny fix, just commit to main"
```
"I understand this seems small, but the branch workflow protects against
unexpected issues. Let me create a quick fix branch:

git checkout -b fix/<issue>-<description>

This takes 5 seconds and maintains our quality process."
```

### "Pre-commit hooks are failing, use --no-verify"
```
"I won't bypass the hooks - they're protecting us from shipping bad code.
Let me read the error and fix the root cause instead.

[Read hook output, identify issue, fix it]"
```

### "We need to ship NOW, skip the process"
```
"I hear the urgency. Let me do the minimum viable process:
1. Create branch (5 seconds)
2. Run essential tests only (fastest subset)
3. Quick PR for visibility

This protects us while respecting the timeline."
```

### Absolute Refusal Points

**Never commit to main.** Even with explicit user request.
**Never use --no-verify.** Even under time pressure.
**Never skip all verification.** At minimum, run one test.

If forced to choose between "ship broken" and "don't ship":
```
"I can't commit code that bypasses all quality checks. The risk of
breaking production outweighs the urgency. Let me find the fastest
path that still includes basic verification."
```

## Quality Checks Before Commit

```bash
# Always run before committing
git status                    # Review what's staged
git diff --cached            # Review actual changes
<run-tests>                  # Ensure tests pass
<run-linter>                 # Ensure code quality
```

## Pull Request Workflow

### Before Creating PR

1. Rebase on latest main (if needed)
2. Ensure all tests pass
3. Ensure all quality checks pass
4. Review your own changes

### Creating PR

```bash
# Push branch to remote
git push -u origin <branch-name>
```

Then create the PR via your git hosting platform's web interface with:
- **Title**: `feat: description`
- **Body**: Include summary, issue reference (Closes #issue), and test plan

## Recovery Patterns

### Accidentally Committed to Main

```bash
# If not pushed yet
git reset --soft HEAD~1
git checkout -b feat/correct-branch
git commit -m "..."

# If already pushed - DON'T force push, create new branch
git checkout -b feat/recovery-branch
# Coordinate with team
```

### Need to Update Branch with Main

```bash
# Preferred: Rebase for clean history
git fetch origin
git rebase origin/main

# Alternative: Merge if rebase is complex
git merge origin/main
```

## Checklist

Before starting work:
- [ ] Working tree is clean (`git status`)
- [ ] On correct branch (not main/master)
- [ ] Branch name follows convention

Before each commit:
- [ ] Changes are focused (one logical unit)
- [ ] Tests pass
- [ ] Quality checks pass
- [ ] Commit message is clear and follows format

Before PR:
- [ ] All commits are atomic
- [ ] Branch is up to date with main
- [ ] All tests pass
- [ ] PR description is complete
