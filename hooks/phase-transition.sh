#!/usr/bin/env bash
# PostToolUse hook: Update workflow phase when skills complete
# Tracks state machine transitions through the workflow

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Create session directory if needed
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
mkdir -p "$SESSION_DIR"

PHASE_FILE="${SESSION_DIR}/.workflow_phase"
OLD_PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "idle")
NEW_PHASE="$OLD_PHASE"
MESSAGE=""

# Determine new phase based on skill invoked
# Match skill names from the Skill tool input
case "$TOOL_INPUT" in
  *brainstorm*)
    NEW_PHASE="brainstorming"
    MESSAGE="Entered brainstorming phase. Write/Edit blocked until /branch → /plan complete."
    ;;
  *git-workflow*|*branch*)
    NEW_PHASE="branched"
    MESSAGE="Branch created. Now run /plan to create implementation plan."
    ;;
  *writing-plans*|*plan*)
    NEW_PHASE="planned"
    MESSAGE="Plan created. Ready for implementation via /implement or direct coding."
    ;;
  *orchestrating*|*implement*)
    NEW_PHASE="implementing"
    MESSAGE="Implementation in progress."
    ;;
  *verification*|*verify*)
    NEW_PHASE="verifying"
    MESSAGE="Verification phase. Ready for PR when complete."
    ;;
esac

# Only output if phase changed
if [[ "$NEW_PHASE" != "$OLD_PHASE" ]]; then
  echo "$NEW_PHASE" > "$PHASE_FILE"
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "WORKFLOW PHASE: $OLD_PHASE → $NEW_PHASE. $MESSAGE"
  }
}
EOF
else
  echo '{}'
fi

exit 0
