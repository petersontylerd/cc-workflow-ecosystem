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
  "reason": "BLOCKED: Edit prevented - design phase not complete.\n\n**Current state:**\n- Phase: branched\n- Next step: Design exploration needed\n\n**Required action:**\n1. Press shift+tab twice to enter plan mode\n2. Run: /brainstorm\n3. Then: /backlog-development\n\n**Why:** Design before code prevents rework. Explore requirements and create a backlog of bite-sized tasks before implementing.\n\n**Escape hatch:** /workflow skip (not recommended)"
}
EOF
    ;;
  "brainstorming")
    cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Edit prevented - backlog not created.\n\n**Current state:**\n- Phase: brainstorming\n- Next step: Create implementation backlog\n\n**Required action:**\n1. Press shift+tab twice to enter plan mode\n2. Run: /backlog-development\n\n**Why:** A detailed backlog with 2-5 minute tasks ensures consistent, high-quality implementation.\n\n**Escape hatch:** /workflow skip (not recommended)"
}
EOF
    ;;
  "idle")
    # Idle state - warning only, not blocking
    cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "WORKFLOW INFO: No active workflow detected.\n\n**Recommended workflow:**\n/branch → /brainstorm (plan mode) → /backlog-development (plan mode) → /implement → /verify\n\n**Quick start:**\nRun: /branch feat/<issue>-<slug>\n\nUse /workflow help for details."
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
    "additionalContext": "WORKFLOW WARNING: Unknown phase '$PHASE'. Consider running /workflow reset to clear state."
  }
}
EOF
    ;;
esac
exit 0
