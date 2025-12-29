#!/bin/bash
# Release script for workflow-ecosystem plugin
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 1.1.0

set -e

VERSION=$1

# Validate version argument
if [[ -z "$VERSION" ]]; then
  echo "Usage: ./scripts/release.sh <version>"
  echo "Example: ./scripts/release.sh 1.1.0"
  exit 1
fi

# Validate semver format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be semver format (e.g., 1.1.0)"
  exit 1
fi

# Get current version
CURRENT_VERSION=$(grep -o '"version": "[^"]*"' .claude-plugin/plugin.json | head -1 | cut -d'"' -f4)

echo "Current version: $CURRENT_VERSION"
echo "New version: $VERSION"

# Check if new version is different
if [[ "$VERSION" == "$CURRENT_VERSION" ]]; then
  echo "Error: New version must be different from current version"
  exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^v$VERSION$"; then
  echo "Error: Tag v$VERSION already exists"
  exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
  echo "Error: You have uncommitted changes. Commit or stash them first."
  exit 1
fi

# Update version in plugin.json
sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$VERSION\"/" .claude-plugin/plugin.json

# Update version in marketplace.json
sed -i "s/\"version\": \"$CURRENT_VERSION\"/\"version\": \"$VERSION\"/" .claude-plugin/marketplace.json

# Verify both files were updated
PLUGIN_VERSION=$(grep -o '"version": "[^"]*"' .claude-plugin/plugin.json | head -1 | cut -d'"' -f4)
MARKETPLACE_VERSION=$(grep -o '"version": "[^"]*"' .claude-plugin/marketplace.json | cut -d'"' -f4)

if [[ "$PLUGIN_VERSION" != "$VERSION" ]] || [[ "$MARKETPLACE_VERSION" != "$VERSION" ]]; then
  echo "Error: Failed to update version files"
  git checkout .claude-plugin/plugin.json .claude-plugin/marketplace.json
  exit 1
fi

echo "Updated versions in plugin.json and marketplace.json"

# Commit the version bump
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore(release): bump version to $VERSION"

# Create tag
git tag "v$VERSION"

echo ""
echo "Version $VERSION prepared. To publish:"
echo "  git push origin master --tags"
echo ""
read -p "Push now? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  git push origin master --tags
  echo ""
  echo "✓ Released v$VERSION"
  echo ""
  echo "Users can update with:"
  echo "  /plugin update workflow-ecosystem"
else
  echo ""
  echo "Release prepared but not pushed."
  echo "Run 'git push origin master --tags' when ready."
fi
