#!/usr/bin/env bash
# PreToolUse hook: Enforce TDD discipline before commit
# BLOCKS commits of source files without corresponding tests

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Check if this is a git commit command
if ! echo "$TOOL_INPUT" | grep -qE "git\s+commit"; then
  echo '{}'
  exit 0
fi

# Check for workflow skip marker
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
if [[ -f "$SKIP_FILE" ]]; then
  echo '{}'
  exit 0
fi

# Check if we're in a git repo with staged files
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo '{}'
  exit 0
fi

# Get staged files
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [[ -z "$STAGED_FILES" ]]; then
  echo '{}'
  exit 0
fi

# Check for source files without corresponding test files being staged
UNTESTED_FILES=""
for file in $STAGED_FILES; do
  # Check if it's a source file (common patterns)
  if [[ "$file" == src/* ]] || [[ "$file" == lib/* ]] || [[ "$file" == app/* ]]; then
    # Check if a test file is also being staged
    STAGED_TESTS=$(echo "$STAGED_FILES" | grep -E "(test|spec|_test|\.test)" || true)
    if [[ -z "$STAGED_TESTS" ]]; then
      UNTESTED_FILES="${UNTESTED_FILES}${file}, "
    fi
  fi
done

if [[ -n "$UNTESTED_FILES" ]]; then
  # Remove trailing comma and space
  UNTESTED_FILES="${UNTESTED_FILES%, }"
  cat <<EOF
{
  "decision": "block",
  "reason": "TDD VIOLATION: Committing source files without tests: ${UNTESTED_FILES}. TDD discipline requires: write test → watch fail → implement → watch pass → commit. Stage test files or use /workflow skip to bypass."
}
EOF
  exit 0
fi

echo '{}'
exit 0
