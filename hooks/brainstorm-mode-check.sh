#!/usr/bin/env bash
# PreToolCall hook: Block Write/Edit during brainstorming
# Uses a session marker file to track brainstorming state

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"

# Only check Write and Edit tools
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
  echo '{}'
  exit 0
fi

# Check for brainstorming marker in session directory
# Claude Code sets CLAUDE_SESSION_DIR for persistent session state
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
MARKER_FILE="${SESSION_DIR}/.brainstorming_active"

if [[ -f "$MARKER_FILE" ]]; then
  cat <<'EOF'
{
  "decision": "block",
  "reason": "Write/Edit tools are blocked during brainstorming phase. Complete the design exploration and save to docs/plans/ before writing code. Use /plan when ready to proceed to implementation planning."
}
EOF
  exit 0
fi

# Not in brainstorming mode - allow
echo '{}'
exit 0
