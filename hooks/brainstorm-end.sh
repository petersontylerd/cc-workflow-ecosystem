#!/usr/bin/env bash
# PostToolUse hook: Clear brainstorming marker when design is saved or /backlog-development invoked

set -euo pipefail

# Remove marker file if it exists
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
MARKER_FILE="${SESSION_DIR}/.brainstorming_active"

if [[ -f "$MARKER_FILE" ]]; then
  rm -f "$MARKER_FILE"
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "BRAINSTORMING MODE ENDED: Design phase complete. Write/Edit tools are now available for implementation."
  }
}
EOF
  exit 0
fi

# No marker was set
echo '{}'
exit 0
