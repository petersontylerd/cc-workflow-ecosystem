#!/usr/bin/env bash
# PreToolCall hook: Check for TDD discipline before commit
# Reminds about test-first development when committing source files

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Check if this is a git commit command
if ! echo "$TOOL_INPUT" | grep -qE "git\s+commit"; then
  echo '{}'
  exit 0
fi

# Determine plugin root to check project structure
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
  "hookSpecificOutput": {
    "additionalContext": "TDD REMINDER: Committing source files without corresponding tests: ${UNTESTED_FILES}. Per TDD discipline: write test first, watch it fail, implement, watch it pass, then commit. Consider adding tests before committing."
  }
}
EOF
  exit 0
fi

echo '{}'
exit 0
