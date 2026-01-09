#!/usr/bin/env bash
# PostToolUse hook: Warn after Write/Edit on main/master branch
# Detects direct edits to main branches and warns (blocking is broken in Claude Code)
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
  "systemMessage": "⚠️ WARNING: Edit made on main/master branch!\n\n**What happened:**\n- You just edited a file on the protected main/master branch\n- This bypasses the feature branch workflow\n\n**Recommended action:**\n1. Undo this change: `git checkout -- <file>`\n2. Create a feature branch: `git checkout -b feat/<slug>`\n3. Redo the change on the feature branch\n\n**Why this matters:** Feature branch workflow protects main from incomplete work. Changes should be reviewed via PR before merging.\n\n**Note:** Blocking was attempted but Claude Code runtime ignores PreToolUse blocks for Write/Edit (Issue #4669)."
}
EOF
  exit 0
fi

# On feature branch - no warning needed
echo '{}'
exit 0
