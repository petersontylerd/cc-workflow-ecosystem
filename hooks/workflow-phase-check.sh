#!/usr/bin/env bash
# PreToolUse hook: Enforce workflow phase sequence before code edits
# Blocks Write/Edit until user has completed /branch and /backlog-development phases

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"

# Only check Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
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

# Read current workflow phase
PHASE_FILE="${SESSION_DIR}/.workflow_phase"
PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "idle")

case "$PHASE" in
  "brainstorming")
    cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Still in brainstorming phase. Complete workflow: /branch → /backlog-development before editing code. Use /workflow skip to bypass (not recommended)."
}
EOF
    ;;
  "branched")
    cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Branch created but no backlog. Run /backlog-development to create a bite-sized backlog before coding. Use /workflow skip to bypass (not recommended)."
}
EOF
    ;;
  "idle")
    # Idle state - warning only, not blocking
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "WORKFLOW ADVISORY: No active workflow detected. Consider: /brainstorm → /branch → /backlog-development → /implement for disciplined development."
  }
}
EOF
    ;;
  "backlog-ready"|"implementing"|"verifying")
    # These phases allow editing
    echo '{}'
    ;;
  *)
    # Unknown phase - allow with warning
    cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "WORKFLOW WARNING: Unknown phase '$PHASE'. Proceeding but consider /workflow reset."
  }
}
EOF
    ;;
esac
exit 0
