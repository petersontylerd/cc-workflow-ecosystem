#!/usr/bin/env bash
# PostToolUse hook: Warn after TodoWrite marks task complete without reviews
# Checks tracker for missing spec-reviewer or quality-reviewer dispatch
#
# This hook fires after TodoWrite marks a task as completed.
# It checks the dispatch tracker to ensure all three subagents were dispatched.
# If reviews are missing, it warns about the violation.
# Only active during the implementing phase.
#
# NOTE: This was previously a PreToolUse blocking hook, but Claude Code runtime
# ignores blocking for TodoWrite tools (Issue #4669, closed as "not planned").
# Converted to PostToolUse warning in v1.20.0.

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
  "systemMessage": "⚠️ WARNING: Task marked complete without required reviews!\\n\\n**What happened:**\\n- You just marked a task as completed\\n- Missing reviewers: ${MISSING}${FIX_WARNING}\\n\\n**Recommended action:**\\n1. Dispatch missing reviewers via Task tool\\n2. Wait for approvals (or fix issues if found)\\n3. Consider reverting the completion status until reviewed\\n\\n**Why this matters:** Per orchestrating-subagents skill, every task requires:\\n  code-implementer -> spec-reviewer -> quality-reviewer\\n\\n**Note:** Blocking was attempted but Claude Code runtime ignores PreToolUse blocks for TodoWrite (Issue #4669)."
}
EOF
  elif [[ -n "$FIX_WARNING" ]]; then
    # All dispatches present but needs_refix is set
    cat <<EOF
{
  "systemMessage": "⚠️ WARNING: Task marked complete without fresh reviews after fix!\\n\\n**What happened:**\\n- Previous review found issues\\n- Implementer was re-dispatched to fix\\n- Reviewers NOT re-dispatched after fix\\n- You marked the task complete anyway\\n\\n**Recommended action:**\\n1. Re-dispatch spec-reviewer to verify fix\\n2. Re-dispatch quality-reviewer to verify fix\\n3. Consider reverting the completion status until re-reviewed\\n\\n**Why this matters:** Reviews before fixes are stale and don't validate the fix.\\n\\n**Note:** Blocking was attempted but Claude Code runtime ignores PreToolUse blocks for TodoWrite (Issue #4669)."
}
EOF
  fi
  exit 0
fi

# All dispatches present, no fix needed - no warning
echo '{}'
exit 0
