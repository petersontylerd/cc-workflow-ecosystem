#!/usr/bin/env bash
# PreToolUse hook: Enforce workflow phase sequence before code edits
# Workflow order: /branch → /brainstorm (plan mode) → /backlog-development (plan mode) → /implement → /verify
# Blocks Write/Edit until user has completed backlog-ready phase

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
  "branched")
    cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Branch created but design not complete. Run /brainstorm (in plan mode) then /backlog-development before coding. Use /workflow skip to bypass (not recommended)."
}
EOF
    ;;
  "brainstorming")
    cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Brainstorming complete but no backlog. Run /backlog-development (in plan mode) to create a bite-sized backlog before coding. Use /workflow skip to bypass (not recommended)."
}
EOF
    ;;
  "idle")
    # Idle state - warning only, not blocking
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "WORKFLOW ADVISORY: No active workflow detected. Consider: /branch → /brainstorm → /backlog-development → /implement for disciplined development."
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
