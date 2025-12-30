#!/usr/bin/env bash
# PostToolCall hook: Mark brainstorming as active when skill is invoked

set -euo pipefail

# Create session directory if needed
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
mkdir -p "$SESSION_DIR"

# Create marker file
MARKER_FILE="${SESSION_DIR}/.brainstorming_active"
touch "$MARKER_FILE"

cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "BRAINSTORMING MODE ACTIVE: Write/Edit tools are now blocked until you save the design to docs/designs/ or invoke /backlog-development. This ensures thorough design exploration before implementation."
  }
}
EOF
exit 0
