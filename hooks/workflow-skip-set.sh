#!/usr/bin/env bash
# PostToolUse hook: Set workflow skip marker when /workflow skip is invoked
# Allows experienced users to bypass enforcement

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Check if this is a workflow skip command
if ! echo "$TOOL_INPUT" | grep -qiE "workflow.*skip"; then
  echo '{}'
  exit 0
fi

# Create session directory if needed
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
mkdir -p "$SESSION_DIR"

# Create skip marker
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
touch "$SKIP_FILE"

cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "WORKFLOW ENFORCEMENT SKIPPED: All workflow checks bypassed for this session. Remember: TDD, feature branches, and verification exist to prevent bugs and maintain code quality. Use /workflow reset to re-enable enforcement."
  }
}
EOF
exit 0
