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
# Workflow order: /branch → /brainstorm (plan mode) → /backlog-development (plan mode) → /implement → /verify
case "$TOOL_INPUT" in
  *git-workflow*|*branch*)
    NEW_PHASE="branched"
    MESSAGE="Branch created. Ready for /brainstorm (use plan mode)."
    ;;
  *brainstorm*)
    NEW_PHASE="brainstorming"
    MESSAGE="Brainstorming complete. Ready for /backlog-development (use plan mode)."
    ;;
  *developing-backlogs*|*backlog-development*)
    NEW_PHASE="backlog-ready"
    MESSAGE="Backlog ready. Proceed with /implement or manual implementation."
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
