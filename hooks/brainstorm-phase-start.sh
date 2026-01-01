#!/usr/bin/env bash
# PreToolUse hook: Set workflow phase to brainstorming when skill starts
# Ensures Write/Edit blocking is active before the design output phase

set -euo pipefail

# Create session directory if needed
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
mkdir -p "$SESSION_DIR"

PHASE_FILE="${SESSION_DIR}/.workflow_phase"
echo "brainstorming" > "$PHASE_FILE"

cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "BRAINSTORMING PHASE STARTED: Use plan mode for exploration (Explore/Plan subagents). Remember: EXIT plan mode before writing the design document to docs/designs/."
  }
}
EOF
exit 0
