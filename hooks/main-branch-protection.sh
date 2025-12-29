#!/usr/bin/env bash
# PreToolUse hook: Block Write/Edit on main/master branch
# Enforces feature branch workflow by preventing direct edits to main branches

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

# Check if we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  # Not a git repo - skip enforcement
  echo '{}'
  exit 0
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" ]]; then
  cat <<'EOF'
{
  "decision": "block",
  "reason": "BLOCKED: Cannot edit code on main/master branch. Feature branch workflow requires: /branch feat/<issue>-<slug> or /branch fix/<issue>-<slug> first. Use /workflow skip to bypass (not recommended)."
}
EOF
  exit 0
fi

# On feature branch - allow
echo '{}'
exit 0
