#!/usr/bin/env bash
# PostToolUse hook: Warn after Write/Edit in early workflow phases
# Workflow order: /branch → /brainstorm (plan mode) → /backlog-development (plan mode) → /implement → /verify
# Warns if Write/Edit occurs before backlog-ready phase
#
# NOTE: This was previously a PreToolUse blocking hook, but Claude Code runtime
# ignores blocking for Write/Edit tools (Issue #4669, closed as "not planned").
# Converted to PostToolUse warning in v1.20.0.

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
  "systemMessage": "⚠️ WARNING: Edit made before design phase complete!\n\n**What happened:**\n- You just edited code while in 'branched' phase\n- Design exploration was skipped\n\n**Recommended action:**\n1. Consider undoing this change\n2. Press shift+tab twice to enter plan mode\n3. Run: /brainstorm to explore requirements\n4. Run: /backlog-development to create task list\n5. Then redo changes systematically\n\n**Why this matters:** Design before code prevents rework and ensures complete understanding.\n\n**Note:** Blocking was attempted but Claude Code runtime ignores PreToolUse blocks for Write/Edit (Issue #4669)."
}
EOF
    ;;
  "brainstorming")
    cat <<'EOF'
{
  "systemMessage": "⚠️ WARNING: Edit made before backlog created!\n\n**What happened:**\n- You just edited code while in 'brainstorming' phase\n- Backlog creation was skipped\n\n**Recommended action:**\n1. Consider undoing this change\n2. Press shift+tab twice to enter plan mode\n3. Run: /backlog-development to create task list\n4. Then redo changes following the backlog\n\n**Why this matters:** A detailed backlog with 2-5 minute tasks ensures consistent, high-quality implementation.\n\n**Note:** Blocking was attempted but Claude Code runtime ignores PreToolUse blocks for Write/Edit (Issue #4669)."
}
EOF
    ;;
  "idle")
    # Idle state - info only
    cat <<'EOF'
{
  "systemMessage": "ℹ️ INFO: No active workflow detected.\n\n**Recommended workflow:**\n/branch → /brainstorm (plan mode) → /backlog-development (plan mode) → /implement → /verify\n\n**Quick start:**\nRun: /branch feat/<issue>-<slug>\n\nUse /workflow help for details."
}
EOF
    ;;
  "backlog-ready"|"implementing"|"verifying")
    # These phases allow editing - no warning needed
    echo '{}'
    ;;
  *)
    # Unknown phase - warning
    cat <<EOF
{
  "systemMessage": "⚠️ WORKFLOW WARNING: Unknown phase '$PHASE'. Consider running /workflow reset to clear state."
}
EOF
    ;;
esac
exit 0
