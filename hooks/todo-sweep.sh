#!/usr/bin/env bash
# PreToolUse hook: Sweep for remaining TODO:BACKLOG markers at /verify
# Fires when: Skill tool invoked with 'verification' or 'verify' pattern
# Purpose: Final gate to catch incomplete tasks before claiming verification complete
#
# Warns (non-blocking) if any TODO:BACKLOG[task-N] markers remain in codebase

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

# Search for remaining TODO:BACKLOG markers in codebase
# Exclude common non-source directories
REMAINING=$(grep -rn "TODO:BACKLOG\[task-" . \
    --include="*.py" --include="*.js" --include="*.ts" \
    --include="*.tsx" --include="*.jsx" --include="*.go" \
    --include="*.rs" --include="*.java" --include="*.rb" \
    --include="*.c" --include="*.cpp" --include="*.h" \
    --include="*.sh" --include="*.swift" --include="*.kt" \
    --exclude-dir=".venv" --exclude-dir="venv" \
    --exclude-dir="node_modules" --exclude-dir=".git" \
    --exclude-dir="build" --exclude-dir="dist" \
    --exclude-dir=".pytest_cache" --exclude-dir="__pycache__" \
    --exclude-dir=".mypy_cache" --exclude-dir=".ruff_cache" \
    2>/dev/null || true)

if [[ -n "$REMAINING" ]]; then
  COUNT=$(echo "$REMAINING" | wc -l)
  # Extract unique files with line numbers
  FILES_INFO=$(echo "$REMAINING" | head -5 | sed 's/:.*TODO:BACKLOG/: TODO:BACKLOG/' | tr '\n' '; ' | sed 's/; $//')

  # Check if there are more than 5
  if [[ "$COUNT" -gt 5 ]]; then
    FILES_INFO="${FILES_INFO}; ... and $((COUNT - 5)) more"
  fi

  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "TODO:BACKLOG WARNING: ${COUNT} task marker(s) remain in codebase. These indicate incomplete tasks: ${FILES_INFO}. Review implementations and ensure markers are removed before claiming verification complete."
  }
}
EOF
else
  # All clear - no remaining markers
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "TODO:BACKLOG SWEEP: No task markers remain. All injected TODOs have been removed."
  }
}
EOF
fi

exit 0
