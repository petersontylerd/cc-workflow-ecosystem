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
  "reason": "BLOCKED: TDD violation - source files without tests.\n\n**Current state:**\n- Source files staged: ${UNTESTED_FILES}\n- Test files staged: none\n\n**Required action:**\n1. Write failing test first (red phase)\n2. Verify test fails\n3. Implement code to pass test\n4. Verify test passes (green phase)\n5. Stage BOTH test and source files\n6. Commit\n\n**Why:** TDD catches bugs early and ensures all code is tested.\n\n**Escape hatch:** /workflow skip (not recommended)"
}
EOF
  exit 0
fi

# Check for empty/trivial test patterns in staged test files
TRIVIAL_TESTS=""
for file in $STAGED_FILES; do
  # Only check test files
  if [[ "$file" =~ (test|spec|_test|\.test) ]]; then
    if [[ -f "$file" ]]; then
      # Check for trivial patterns
      if grep -qE '^\s*pass\s*$|assert\s+True|expect\(true\)\.toBe\(true\)|def\s+test_\w+\([^)]*\):\s*pass' "$file" 2>/dev/null; then
        TRIVIAL_TESTS="${TRIVIAL_TESTS}${file}, "
      fi
    fi
  fi
done

if [[ -n "$TRIVIAL_TESTS" ]]; then
  TRIVIAL_TESTS="${TRIVIAL_TESTS%, }"
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "TEST QUALITY WARNING: Potentially trivial test patterns detected in: ${TRIVIAL_TESTS}.\n\nPatterns found may include: 'pass', 'assert True', 'expect(true).toBe(true)'.\n\nPlease ensure tests actually exercise the production code and verify expected behavior."
  }
}
EOF
  exit 0
fi

echo '{}'
exit 0
