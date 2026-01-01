#!/usr/bin/env bash
# PostToolUse hook: Guide output after exiting plan mode during brainstorming
# Fires when ExitPlanMode is used; transitions phase and reminds to write design

set -euo pipefail

# Read current workflow phase
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
PHASE_FILE="${SESSION_DIR}/.workflow_phase"
PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "idle")

# Only provide guidance during brainstorming phase
if [[ "$PHASE" != "brainstorming" ]]; then
  echo '{}'
  exit 0
fi

# Transition to backlog-ready to allow design write
# This unblocks Write/Edit but user must still run /backlog-development before implementing
echo "backlog-ready" > "$PHASE_FILE"

cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "BRAINSTORMING OUTPUT PHASE: You have exited plan mode. Phase transitioned to 'backlog-ready' to allow writing.\n\nNow:\n1. Write the design document to docs/designs/YYYY-MM-DD-<topic>-design.md\n2. STOP after writing - do NOT proceed to implementation\n3. User will run /backlog-development when ready\n\nDO NOT offer to implement, create backlogs, or proceed automatically."
  }
}
EOF
exit 0
