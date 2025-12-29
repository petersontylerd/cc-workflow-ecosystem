# Releasing workflow-ecosystem

This document describes how to release new versions of the plugin.

## Quick Release

```bash
./scripts/release.sh 1.1.0
```

This script will:
1. Validate the version format (semver)
2. Update `plugin.json` and `marketplace.json`
3. Commit the version bump
4. Create a git tag
5. Optionally push to origin

## Pre-push Validation

A pre-push hook automatically validates:

| Check | What it catches |
|-------|-----------------|
| Version mismatch | `plugin.json` and `marketplace.json` have different versions |
| Unreleased changes | Code changed since last tag but version not bumped |
| Missing tag | Version was bumped but no `v{version}` tag exists |

### Installing the hook (first-time setup)

```bash
cp scripts/pre-push-version-check.sh .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

## Manual Release Process

If you prefer not to use the script:

```bash
# 1. Update versions in both files
#    .claude-plugin/plugin.json
#    .claude-plugin/marketplace.json

# 2. Commit the version bump
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore(release): bump version to X.Y.Z"

# 3. Create tag
git tag vX.Y.Z

# 4. Push
git push origin master --tags
```

## Versioning Guidelines

Follow [semantic versioning](https://semver.org/):

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking changes | MAJOR | 1.0.0 → 2.0.0 |
| New features (backward compatible) | MINOR | 1.0.0 → 1.1.0 |
| Bug fixes | PATCH | 1.0.0 → 1.0.1 |

## What Users See

After a release, users can update with:

```bash
/plugin update workflow-ecosystem
```

Or if auto-update is enabled, they get updates automatically on Claude Code startup.
