---
description: Create or switch to a feature branch with enforcement of naming conventions and clean working tree
argument-hint: "[type/]<issue-number>-<description> (e.g., feat/42-user-auth or just 42-user-auth)"
---

# /branch Command

Create or switch to a properly named feature branch.

## Usage

```
/branch feat/42-user-authentication
/branch 42-user-auth              # Defaults to feat/ prefix
/branch fix/123-login-bug
```

## Workflow

This command invokes the `git-workflow` skill.

### Step 1: Verify Clean Working Tree

Run `git status -sb` to check for uncommitted changes.

**If changes exist**, offer options:
- Commit changes first
- Stash changes
- Discard changes (with confirmation)

### Step 2: Validate Branch Name

Check branch name follows convention:
- `<type>/<issue>-<slug>`
- Types: feat, fix, chore, refactor, docs, test
- Issue number is numeric
- Slug is lowercase with hyphens

If no type prefix provided, default to `feat/`.

### Step 3: Create Branch from Latest Main

```bash
git checkout main
git pull --ff-only
git checkout -b <validated-branch-name>
```

### Step 4: Confirm Success

```bash
git status -sb
```

Report: "Created and switched to branch `<name>`. Ready for development."

## Argument Parsing

| Input | Interpreted As |
|-------|----------------|
| `feat/42-user-auth` | `feat/42-user-auth` |
| `42-user-auth` | `feat/42-user-auth` |
| `fix/123-bug` | `fix/123-bug` |
| `chore/456-deps` | `chore/456-deps` |

## Error Handling

| Error | Response |
|-------|----------|
| Already on target branch | "Already on branch `<name>`" |
| Uncommitted changes | Offer resolution options |
| Invalid branch name | Explain convention, ask for correction |
| Branch already exists | Offer to switch or create new name |
| Pull fails | Report error, suggest manual resolution |

## Next Steps

After creating the branch:
- `/brainstorm` - Explore requirements if unclear
- `/backlog-development` - Create backlog if design is ready
- Start development with clear feature scope

## Related

- `git-workflow` skill for full git discipline
- `/commit` command for atomic commits
- `/pr` command for pull request creation
