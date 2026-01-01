#!/usr/bin/env bash
# PostToolUse hook: Warn when task marked complete without reviews
# Checks tracker for missing spec-reviewer or quality-reviewer dispatch
#
# This hook fires when TodoWrite marks a task as completed.
# It checks the dispatch tracker to ensure all three subagents were dispatched.
# If reviews are missing, it issues a warning (not a block).
# Only active during the implementing phase.

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Only check TodoWrite tool
[[ "$TOOL_NAME" != "TodoWrite" ]] && { echo '{}'; exit 0; }

# Only check if marking task as completed
# The tool input is JSON with todos array containing status fields
if ! echo "$TOOL_INPUT" | grep -qE '"status"[[:space:]]*:[[:space:]]*"completed"'; then
  echo '{}'
  exit 0
fi

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

# Check if in implementing phase
PHASE_FILE="${SESSION_DIR}/.workflow_phase"
PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "")
[[ "$PHASE" != "implementing" ]] && { echo '{}'; exit 0; }

# Check dispatch tracker
TRACKER_FILE="${SESSION_DIR}/.subagent_dispatch"
[[ ! -f "$TRACKER_FILE" ]] && { echo '{}'; exit 0; }

DISPATCHES=$(cat "$TRACKER_FILE" 2>/dev/null || echo "")

# Check for missing reviewers
MISSING=""
if ! echo "$DISPATCHES" | grep -q "spec-reviewer"; then
  MISSING="${MISSING}spec-reviewer, "
fi
if ! echo "$DISPATCHES" | grep -q "quality-reviewer"; then
  MISSING="${MISSING}quality-reviewer, "
fi

if [[ -n "$MISSING" ]]; then
  # Remove trailing comma and space
  MISSING="${MISSING%, }"
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "SUBAGENT DISPATCH WARNING: Task marked complete but missing: ${MISSING}. Per orchestrating-subagents skill, every task requires: code-implementer -> spec-reviewer -> quality-reviewer. Skipping reviews is negligence, not optimization. Please dispatch the missing reviewers before proceeding."
  }
}
EOF
  exit 0
fi

# All dispatches present - output nothing
echo '{}'
exit 0
