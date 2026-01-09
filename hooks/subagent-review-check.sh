#!/usr/bin/env bash
# PreToolUse hook: Block TodoWrite when task marked complete without reviews
# Checks tracker for missing spec-reviewer or quality-reviewer dispatch
#
# This hook fires when TodoWrite marks a task as completed.
# It checks the dispatch tracker to ensure all three subagents were dispatched.
# If reviews are missing, it blocks the TodoWrite operation.
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
  "decision": "block",
  "reason": "BLOCKED: Task completion requires reviewer dispatch.\\n\\n**Current state:**\\n- Missing reviewers: ${MISSING}${FIX_WARNING}\\n\\n**Required action:**\\n1. Dispatch missing reviewers via Task tool\\n2. Wait for approvals (or fix issues if found)\\n3. Then mark task complete\\n\\n**Why:** Per orchestrating-subagents skill, every task requires:\\n  code-implementer -> spec-reviewer -> quality-reviewer\\n\\n**Escape hatch:** /workflow skip (not recommended)"
}
EOF
  elif [[ -n "$FIX_WARNING" ]]; then
    # All dispatches present but needs_refix is set
    cat <<EOF
{
  "decision": "block",
  "reason": "BLOCKED: Fresh reviews required after fix.\\n\\n**Current state:**\\n- Previous review found issues\\n- Implementer was re-dispatched to fix\\n- Reviewers NOT re-dispatched after fix\\n\\n**Required action:**\\n1. Re-dispatch spec-reviewer to verify fix\\n2. Re-dispatch quality-reviewer to verify fix\\n3. Only mark complete when BOTH approve AFTER fix\\n\\n**Why:** Reviews before fixes are stale and don't validate the fix.\\n\\n**Escape hatch:** /workflow skip (not recommended)"
}
EOF
  fi
  exit 0
fi

# All dispatches present, no fix needed - output nothing
echo '{}'
exit 0
