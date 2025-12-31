#!/bin/bash
# Pre-push hook: Validates version consistency before pushing
# Install: cp scripts/pre-push-version-check.sh .git/hooks/pre-push && chmod +x .git/hooks/pre-push

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Skip version validation for feature branches (only enforce on main/master)
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
  echo -e "${GREEN}✓${NC} Feature branch '$CURRENT_BRANCH' - skipping version validation"
  exit 0
fi

echo "Running version validation..."

# 1. Check that plugin.json and marketplace.json versions match
PLUGIN_VERSION=$(grep -o '"version": "[^"]*"' .claude-plugin/plugin.json | head -1 | cut -d'"' -f4)
MARKETPLACE_VERSION=$(grep -o '"version": "[^"]*"' .claude-plugin/marketplace.json | cut -d'"' -f4)

if [[ "$PLUGIN_VERSION" != "$MARKETPLACE_VERSION" ]]; then
  echo -e "${RED}ERROR: Version mismatch!${NC}"
  echo "  plugin.json:      $PLUGIN_VERSION"
  echo "  marketplace.json: $MARKETPLACE_VERSION"
  echo ""
  echo "Run: ./scripts/release.sh <version> to fix"
  exit 1
fi

echo -e "${GREEN}✓${NC} Versions match: $PLUGIN_VERSION"

# 2. Get the last version tag
LAST_TAG=$(git tag -l 'v*' --sort=-v:refname | head -1)

if [[ -z "$LAST_TAG" ]]; then
  echo -e "${YELLOW}!${NC} No previous version tags found (first release?)"
  exit 0
fi

LAST_TAG_VERSION=${LAST_TAG#v}
echo "  Last tag: $LAST_TAG"

# 3. Check if there are commits since the last tag
COMMITS_SINCE_TAG=$(git rev-list "$LAST_TAG"..HEAD --count)

if [[ "$COMMITS_SINCE_TAG" -eq 0 ]]; then
  echo -e "${GREEN}✓${NC} No new commits since $LAST_TAG"
  exit 0
fi

echo "  Commits since $LAST_TAG: $COMMITS_SINCE_TAG"

# 4. Check if any non-version files changed since last tag
CHANGED_FILES=$(git diff --name-only "$LAST_TAG"..HEAD | grep -v "^.claude-plugin/plugin.json$" | grep -v "^.claude-plugin/marketplace.json$" || true)

if [[ -n "$CHANGED_FILES" ]]; then
  # There are real changes (not just version bumps)

  # 5. Check if version was incremented
  if [[ "$PLUGIN_VERSION" == "$LAST_TAG_VERSION" ]]; then
    echo -e "${RED}ERROR: Code changes detected but version not incremented!${NC}"
    echo ""
    echo "Changed files since $LAST_TAG:"
    echo "$CHANGED_FILES" | head -10
    if [[ $(echo "$CHANGED_FILES" | wc -l) -gt 10 ]]; then
      echo "  ... and more"
    fi
    echo ""
    echo "Current version: $PLUGIN_VERSION (same as $LAST_TAG)"
    echo ""
    echo "Run: ./scripts/release.sh <new-version> to create a release"
    exit 1
  fi

  # 6. Check if tag exists for new version
  if ! git tag -l | grep -q "^v$PLUGIN_VERSION$"; then
    echo -e "${RED}ERROR: Version $PLUGIN_VERSION has no matching tag!${NC}"
    echo ""
    echo "The version was bumped but 'v$PLUGIN_VERSION' tag is missing."
    echo ""
    echo "Either:"
    echo "  1. Create the tag: git tag v$PLUGIN_VERSION"
    echo "  2. Or use: ./scripts/release.sh $PLUGIN_VERSION"
    exit 1
  fi
fi

echo -e "${GREEN}✓${NC} Version validation passed"
exit 0
