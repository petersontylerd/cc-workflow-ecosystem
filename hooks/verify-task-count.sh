#!/usr/bin/env bash
# PreToolUse hook: Verify task count at /verify
# Compares completed tasks against expected count from backlog.
#
# Fires when: Skill tool is called with verification|verify pattern
# Reads: .expected_task_count from session state
# Warns: If completed tasks don't match expected (doesn't block)

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

# Check if we have an expected task count
EXPECTED_FILE="${SESSION_DIR}/.expected_task_count"
[[ ! -f "$EXPECTED_FILE" ]] && { echo '{}'; exit 0; }

EXPECTED_COUNT=$(cat "$EXPECTED_FILE" 2>/dev/null || echo "0")
[[ "$EXPECTED_COUNT" -eq 0 ]] && { echo '{}'; exit 0; }

# Try to count completed tasks from backlog (if marked with [COMPLETED])
BACKLOG_PATH=""
if [[ -f "${SESSION_DIR}/.backlog_path" ]]; then
  BACKLOG_PATH=$(cat "${SESSION_DIR}/.backlog_path" 2>/dev/null || echo "")
fi

COMPLETED_COUNT=0
if [[ -n "$BACKLOG_PATH" ]] && [[ -f "$BACKLOG_PATH" ]]; then
  # Count tasks marked as completed
  COMPLETED_COUNT=$(grep -cE '^\[COMPLETED\]|## Task.*\[COMPLETED\]|### Task.*\[COMPLETED\]' "$BACKLOG_PATH" 2>/dev/null || echo "0")
fi

# Generate output
if [[ "$COMPLETED_COUNT" -eq 0 ]]; then
  # Can't determine completed count from backlog - just provide info
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "TASK COUNT REMINDER: Expected $EXPECTED_COUNT tasks from backlog. Ensure all tasks were completed before proceeding with verification. Unable to auto-detect completion status from backlog."
  }
}
EOF
elif [[ "$COMPLETED_COUNT" -lt "$EXPECTED_COUNT" ]]; then
  MISSING=$((EXPECTED_COUNT - COMPLETED_COUNT))
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "TASK COUNT WARNING: Only $COMPLETED_COUNT of $EXPECTED_COUNT tasks marked complete. $MISSING tasks may be missing. Please verify all backlog tasks were implemented before proceeding."
  }
}
EOF
else
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "TASK COUNT VERIFIED: All $EXPECTED_COUNT tasks appear to be complete."
  }
}
EOF
fi

exit 0
