# Publishing to Claude Code Plugin Marketplace

This document describes the path from local plugin to marketplace distribution.

## Current State

The workflow-ecosystem plugin is currently distributed as a local plugin:
- Clone the repository
- Use `--plugin-dir` flag or install to `~/.claude/plugins/local/`

## Marketplace Requirements

### 1. Separate Marketplace Repository

Create a marketplace repository (e.g., `workflow-ecosystem-marketplace`) with:

```
workflow-ecosystem-marketplace/
├── marketplace.json         # Marketplace manifest
└── README.md               # Marketplace page content
```

### 2. marketplace.json Format

```json
{
  "name": "workflow-ecosystem",
  "version": "0.1.0",
  "description": "Comprehensive workflow ecosystem for human-agent co-development",
  "author": "Your Name",
  "repository": "https://github.com/<user>/workflow-ecosystem",
  "homepage": "https://github.com/<user>/workflow-ecosystem",
  "keywords": [
    "workflow",
    "tdd",
    "git",
    "subagents",
    "verification"
  ]
}
```

### 3. Plugin Repository Requirements

The plugin repository (this repo) must:
- Have a valid `.claude-plugin/plugin.json`
- Have all components at root level (skills/, commands/, agents/, hooks/)
- Be publicly accessible on GitHub
- Have a tagged release matching the marketplace version

## Migration Steps

### Step 1: Prepare Plugin Repository

1. Ensure all tests pass
2. Create a release tag:
   ```bash
   git tag -a v0.1.0 -m "Initial release"
   git push origin v0.1.0
   ```

### Step 2: Create Marketplace Repository

1. Create new repository: `workflow-ecosystem-marketplace`
2. Add `marketplace.json` with plugin details
3. Add README.md describing the plugin

### Step 3: Submit to Marketplace

1. Fork the official Claude Code plugins registry (if exists)
2. Add your marketplace repository URL
3. Submit pull request

## Version Management

When updating the plugin:

1. Update `.claude-plugin/plugin.json` version
2. Update `marketplace.json` version (in marketplace repo)
3. Create matching git tag
4. Push changes to both repositories

### Semantic Versioning

Follow semver for version numbers:
- MAJOR: Breaking changes to skills/commands/agents API
- MINOR: New features, backward compatible
- PATCH: Bug fixes, documentation updates

## Testing Before Release

Before publishing a new version:

1. Test with `--plugin-dir` flag
2. Verify all skills load via Skill tool
3. Verify all commands work via `/command` syntax
4. Verify SessionStart hook fires
5. Run pressure test scenarios

## Rollback Procedure

If a release has issues:

1. Revert `marketplace.json` to previous version
2. Push to marketplace repository
3. Users will get previous version on next install

## Notes

- Marketplace may require approval process
- Keep plugin repository stable (don't force-push main)
- Document breaking changes in CHANGELOG.md
- Consider maintaining LTS versions for major releases
