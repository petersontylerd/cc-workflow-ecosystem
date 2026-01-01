#!/usr/bin/env bash
# PostToolUse hook: Lint backlog for placeholders and missing test commands
# Scans backlog files when written to docs/backlogs/ for quality issues.
#
# Fires when: Write tool targets docs/backlogs/*.md
# Checks for:
#   - TODO, FIXME, XXX placeholders
#   - Ellipsis (...) as placeholder
#   - "# implement", "// implement", "# add", "// add" comments
#   - Python 'pass' or 'raise NotImplementedError'
#   - Missing test commands (no "Run:" pattern per task)
# Warns: Lists specific issues found (doesn't block)

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Only process Write tool
[[ "$TOOL_NAME" != "Write" ]] && { echo '{}'; exit 0; }

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

# Extract file path from tool input
FILE_PATH=""
if echo "$TOOL_INPUT" | grep -qE '"file_path"'; then
  FILE_PATH=$(echo "$TOOL_INPUT" | grep -oE '"file_path"\s*:\s*"[^"]+"' | sed 's/.*: *"//' | sed 's/"$//' || echo "")
fi

# Only check backlog files
[[ ! "$FILE_PATH" =~ docs/backlogs/.*\.md$ ]] && { echo '{}'; exit 0; }
[[ ! -f "$FILE_PATH" ]] && { echo '{}'; exit 0; }

# Initialize issue tracking
ISSUES=""

# Check for placeholder patterns
check_pattern() {
  local pattern="$1"
  local description="$2"
  local matches
  matches=$(grep -nE "$pattern" "$FILE_PATH" 2>/dev/null | head -5 || echo "")
  if [[ -n "$matches" ]]; then
    ISSUES="${ISSUES}\\n- $description:\\n$(echo "$matches" | sed 's/^/    /')\\n"
  fi
}

# Check for TODO/FIXME/XXX
check_pattern 'TODO|FIXME|XXX' 'TODO/FIXME/XXX placeholders'

# Check for ellipsis placeholder (standalone ... not in prose)
check_pattern '^\s*\.\.\.\s*$|`\.\.\.\`' 'Ellipsis placeholders'

# Check for implement/add comments
check_pattern '#\s*(implement|add)|//\s*(implement|add)' 'Placeholder implementation comments'

# Check for Python pass/NotImplementedError
check_pattern '^\s*pass\s*$|raise NotImplementedError' 'Python placeholder patterns'

# Check for empty function bodies (basic heuristic)
check_pattern '^\s*def\s+\w+\([^)]*\):\s*$' 'Potentially empty function definitions'

# Count tasks and test commands
TASK_COUNT=$(grep -cE '^#{2,3}\s+Task\s+[0-9]+' "$FILE_PATH" 2>/dev/null || echo "0")
RUN_COUNT=$(grep -cE '^\s*Run:|^Run:' "$FILE_PATH" 2>/dev/null || echo "0")

if [[ "$TASK_COUNT" -gt 0 ]] && [[ "$RUN_COUNT" -lt "$TASK_COUNT" ]]; then
  MISSING=$((TASK_COUNT - RUN_COUNT))
  ISSUES="${ISSUES}\\n- Missing test commands: Found $RUN_COUNT 'Run:' commands for $TASK_COUNT tasks ($MISSING potentially missing)\\n"
fi

# Generate output
if [[ -n "$ISSUES" ]]; then
  # Escape for JSON
  ISSUES_ESCAPED=$(echo -e "$ISSUES" | sed 's/"/\\"/g' | tr '\n' ' ' | sed 's/  */ /g')
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG QUALITY WARNING: Issues found in $FILE_PATH:\\n$ISSUES_ESCAPED\\nPlease review and ensure all code snippets are complete. Placeholders indicate incomplete specifications that will confuse implementers."
  }
}
EOF
else
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG LINT: No placeholder issues found in $FILE_PATH. All tasks have test commands."
  }
}
EOF
fi

exit 0
