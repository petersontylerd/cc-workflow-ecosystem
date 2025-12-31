---
description: Create or switch to a feature branch with enforcement of naming conventions and clean working tree
argument-hint: "[type/]<issue-number>-<description> (e.g., feat/42-user-auth)"
---

# /branch Command

Create or switch to a properly named feature branch.

## Usage

```
/branch feat/42-user-authentication
/branch 42-user-auth              # Defaults to feat/ prefix
/branch fix/123-login-bug
```

Use the **git-workflow** skill for branching conventions and workflow.
