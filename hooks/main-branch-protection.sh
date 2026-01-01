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
  "reason": "BLOCKED: Edit prevented on main/master branch.\n\n**Current state:**\n- Branch: main/master (protected)\n- Phase: N/A (branch protection applies regardless of phase)\n\n**Required action:**\nRun: /branch feat/<issue>-<slug>  (for new features)\n  or: /branch fix/<issue>-<slug>   (for bug fixes)\n\n**Why:** Feature branch workflow protects main from incomplete work. Changes should be reviewed via PR before merging.\n\n**Escape hatch:** /workflow skip (not recommended - bypasses all enforcement)"
}
EOF
  exit 0
fi

# On feature branch - allow
echo '{}'
exit 0
