#!/usr/bin/env bash
# PostToolUse hook: Guide output after exiting plan mode during design phases
# Fires when ExitPlanMode is used; transitions phase and reminds to write output

set -euo pipefail

# Read current workflow phase
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
PHASE_FILE="${SESSION_DIR}/.workflow_phase"
PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "idle")

case "$PHASE" in
  "brainstorming")
    # Transition to backlog-ready to allow design write
    echo "backlog-ready" > "$PHASE_FILE"
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "BRAINSTORMING OUTPUT PHASE: You have exited plan mode. Phase transitioned to 'backlog-ready' to allow writing.\n\nNow:\n1. Write the design document to docs/designs/YYYY-MM-DD-<topic>-design.md\n2. STOP after writing - do NOT proceed to implementation\n3. User will run /backlog-development when ready\n\nDO NOT offer to implement, create backlogs, or proceed automatically."
  }
}
EOF
    ;;
  "backlog-ready")
    # Phase already allows writing, just provide guidance
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG OUTPUT PHASE: You have exited plan mode.\n\nNow:\n1. Write the backlog document to docs/backlogs/YYYY-MM-DD-<feature>-backlog.md\n2. STOP after writing - do NOT proceed to implementation\n3. User will run /implement when ready\n\nDO NOT offer to implement, dispatch subagents, or proceed automatically."
  }
}
EOF
    ;;
  *)
    # Other phases - no special handling
    echo '{}'
    ;;
esac
exit 0
