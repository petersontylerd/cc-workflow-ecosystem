---
description: Create a pull request with proper template, linking to related issues
argument-hint: "[optional: issue number to close]"
---

# /pr Command

Create a pull request with a structured description and issue linking.

## Usage

```
/pr                    # Create PR, auto-detect issue from branch
/pr 42                 # Create PR closing issue #42
/pr --draft            # Create as draft PR
```

## Workflow

This command invokes the `git-workflow` skill.

### Step 1: Pre-PR Verification

Before creating PR, verify:
```bash
# All tests pass
[run test command]

# Linter passes
[run lint command]

# Branch is up to date
git fetch origin && git status
```

If verification fails, fix issues before proceeding.

### Step 2: Gather Information

1. Get issue number from branch name or argument
2. Read commits on branch for summary
3. Identify files changed

```bash
# Commits since branching from main
git log main..HEAD --oneline

# Files changed
git diff main --name-only
```

### Step 3: Generate PR Description

Use this template:

```markdown
## Summary
[2-3 sentences describing what this PR does]

Closes #[issue-number]

## Changes
- [Bullet list of key changes]
- [Grouped by component/area]

## Test Plan
- [ ] [Specific test case 1]
- [ ] [Specific test case 2]
- [ ] [Manual verification step]

## Screenshots
[If UI changes, include before/after]

## Notes
[Any additional context, breaking changes, or migration steps]
```

### Step 4: Output PR Description

Display the generated PR description for the user to copy:

```
## PR Title
[type]: [description]

## PR Body
[generated description from Step 3]
```

Instruct user: "Copy this to your git hosting platform's PR/MR creation form."

### Step 5: Confirm Preparation

Report:
- Generated PR title and description
- Issue(s) that will be closed when merged
- Suggested reviewers (if any)

## Branch to Title Mapping

| Branch | PR Title |
|--------|----------|
| `feat/42-user-auth` | `feat: Add user authentication` |
| `fix/123-login-bug` | `fix: Resolve login timeout issue` |
| `chore/456-deps` | `chore: Update dependencies` |

## Options

| Option | Effect |
|--------|--------|
| `--draft` | Mark description as draft |
| `--reviewer @user` | Suggest reviewer in output |

## Error Handling

| Error | Response |
|-------|----------|
| Tests failing | "Tests must pass before PR. Run /verify first." |
| No commits | "No commits on branch. Nothing to PR." |
| Already has PR | "PR #X already exists for this branch." |
| Not on feature branch | "Switch to a feature branch first." |

## Next Steps

After PR is created:
- Await review feedback from team members
- Address any review comments with additional commits
- Merge after approval (using your team's merge policy)

## Related Commands

- `/verify` - Run verification before PR
- `/branch` - Create feature branch
- `/commit` - Make atomic commits
