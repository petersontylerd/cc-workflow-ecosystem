#!/usr/bin/env bash
# PostToolUse hook: Inject TODO:BACKLOG markers into test files
# Fires when: Task tool completes with code-implementer dispatch
# Purpose: Create persistent anchors in code that remind implementers of their task
#
# Injects format: # TODO:BACKLOG[task-N]: See backlog for requirements
# Location: Line 2 of the test file (after shebang/encoding line)

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Only process Task tool completions
[[ "$TOOL_NAME" != "Task" ]] && { echo '{}'; exit 0; }

# Only process code-implementer dispatches
echo "$TOOL_INPUT" | grep -qE 'code-implementer' || { echo '{}'; exit 0; }

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

# Check if in implementing phase
PHASE_FILE="${SESSION_DIR}/.workflow_phase"
PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "")
[[ "$PHASE" != "implementing" ]] && { echo '{}'; exit 0; }

mkdir -p "$SESSION_DIR"
TODO_TRACKER="${SESSION_DIR}/.backlog_todos"

# Extract task number from task description (e.g., "## Task 3:" or "### Task 3:")
TASK_NUM=$(echo "$TOOL_INPUT" | grep -oE '##+ Task [0-9]+' | head -1 | grep -oE '[0-9]+' || echo "")
[[ -z "$TASK_NUM" ]] && { echo '{}'; exit 0; }

# Extract test file path from Files section
# Look for "Test:" line and extract the path (handles backticks and various formats)
TEST_FILE=$(echo "$TOOL_INPUT" | grep -E '^\s*[-*]?\s*Test:' | head -1 | sed 's/.*Test:[[:space:]]*`\{0,1\}//' | sed 's/`.*$//' | sed 's/[[:space:]]*$//' || echo "")
[[ -z "$TEST_FILE" ]] && { echo '{}'; exit 0; }

# Determine comment syntax based on file extension
get_comment_prefix() {
  local file="$1"
  local ext="${file##*.}"
  case "$ext" in
    py|rb|sh|bash|yml|yaml|toml|r|pl|pm)
      echo "#"
      ;;
    js|ts|tsx|jsx|java|c|cpp|cc|h|hpp|go|rs|swift|kt|scala|cs)
      echo "//"
      ;;
    *)
      echo "#"  # Default fallback
      ;;
  esac
}

COMMENT_PREFIX=$(get_comment_prefix "$TEST_FILE")
TODO_MARKER="${COMMENT_PREFIX} TODO:BACKLOG[task-${TASK_NUM}]: See backlog for requirements"

# Check if file exists
if [[ ! -f "$TEST_FILE" ]]; then
  # File doesn't exist yet - track as pending, implementer will create it
  echo "task-${TASK_NUM}:${TEST_FILE}:pending" >> "$TODO_TRACKER"
  echo '{}'
  exit 0
fi

# Check if TODO already exists (idempotency)
if grep -q "TODO:BACKLOG\[task-${TASK_NUM}\]" "$TEST_FILE" 2>/dev/null; then
  echo '{}'
  exit 0
fi

# Check if file is binary (skip binary files)
if file "$TEST_FILE" 2>/dev/null | grep -qv "text"; then
  echo '{}'
  exit 0
fi

# Inject TODO at line 2 (after shebang/encoding/first import line)
sed -i "1a\\${TODO_MARKER}" "$TEST_FILE"

# Track injection
echo "task-${TASK_NUM}:${TEST_FILE}" >> "$TODO_TRACKER"

# Output confirmation
cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "TODO:BACKLOG[task-${TASK_NUM}] injected into ${TEST_FILE}. Remove this marker as you implement the task."
  }
}
EOF

exit 0
