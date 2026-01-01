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

# Check for needs_refix flag (B3)
NEEDS_REFIX_FILE="${SESSION_DIR}/.needs_refix"
FIX_WARNING=""
if [[ -f "$NEEDS_REFIX_FILE" ]]; then
  FIX_WARNING="\\n\\n**FIX CYCLE WARNING:** Issues were found in previous review and implementer was re-dispatched to fix them. Fresh reviews are required after fixes."
fi

# Check for missing reviewers
MISSING=""
if ! echo "$DISPATCHES" | grep -q "spec-reviewer"; then
  MISSING="${MISSING}spec-reviewer, "
fi
if ! echo "$DISPATCHES" | grep -q "quality-reviewer"; then
  MISSING="${MISSING}quality-reviewer, "
fi

if [[ -n "$MISSING" ]] || [[ -n "$FIX_WARNING" ]]; then
  # Remove trailing comma and space
  MISSING="${MISSING%, }"

  if [[ -n "$MISSING" ]]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "SUBAGENT DISPATCH WARNING: Task marked complete but missing: ${MISSING}.${FIX_WARNING}\\n\\nPer orchestrating-subagents skill, every task requires: code-implementer -> spec-reviewer -> quality-reviewer. After ANY fix, dispatch reviewers again. Skipping reviews is negligence, not optimization."
  }
}
EOF
  elif [[ -n "$FIX_WARNING" ]]; then
    # All dispatches present but needs_refix is set
    cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "RE-REVIEW WARNING: Task marked complete but issues were found in previous review and implementer was re-dispatched.\\n\\nReviewers dispatched before the fix don't count as fresh reviews. Please dispatch spec-reviewer and quality-reviewer again to verify the fix. Never mark complete without fresh review after fixes."
  }
}
EOF
  fi
  exit 0
fi

# All dispatches present, no fix needed - output nothing
echo '{}'
exit 0
