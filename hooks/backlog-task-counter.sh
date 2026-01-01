#!/usr/bin/env bash
# PreToolUse hook: Count backlog tasks at /implement start
# Counts tasks and stores expected count for later verification.
# Also warns about large backlogs (E1).
#
# Fires when: Skill tool is called with implement|orchestrating pattern
# Reads: Backlog file from session state or recent docs/backlogs/
# Stores: Expected task count in .expected_task_count

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

mkdir -p "$SESSION_DIR"

# Try to find the backlog path from session state or tool input
BACKLOG_PATH=""

# First check if there's a backlog path in session state
if [[ -f "${SESSION_DIR}/.backlog_path" ]]; then
  BACKLOG_PATH=$(cat "${SESSION_DIR}/.backlog_path" 2>/dev/null || echo "")
fi

# If not found, try to extract from tool input (args parameter)
if [[ -z "$BACKLOG_PATH" ]] && echo "$TOOL_INPUT" | grep -qE 'docs/backlogs/'; then
  BACKLOG_PATH=$(echo "$TOOL_INPUT" | grep -oE 'docs/backlogs/[^"]+\.md' | head -1 || echo "")
fi

# If still not found, look for most recent backlog file
if [[ -z "$BACKLOG_PATH" ]] && [[ -d "docs/backlogs" ]]; then
  BACKLOG_PATH=$(ls -t docs/backlogs/*.md 2>/dev/null | head -1 || echo "")
fi

# If no backlog found, warn but don't block
if [[ -z "$BACKLOG_PATH" ]] || [[ ! -f "$BACKLOG_PATH" ]]; then
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG INFO: No backlog file found. If you're implementing from a backlog, ensure it exists in docs/backlogs/ or pass the path explicitly. Task count tracking will be skipped."
  }
}
EOF
  exit 0
fi

# Count tasks in backlog (pattern: ### Task N: or ## Task N:)
TASK_COUNT=$(grep -cE '^#{2,3}\s+Task\s+[0-9]+' "$BACKLOG_PATH" 2>/dev/null || echo "0")

# Store expected count
echo "$TASK_COUNT" > "${SESSION_DIR}/.expected_task_count"
echo "$BACKLOG_PATH" > "${SESSION_DIR}/.backlog_path"

# Generate output with size warning if applicable
if [[ "$TASK_COUNT" -eq 0 ]]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG WARNING: No tasks found in $BACKLOG_PATH. Expected pattern: '### Task N: [description]'. Please verify backlog format."
  }
}
EOF
elif [[ "$TASK_COUNT" -ge 16 ]]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG SIZE WARNING: Very large backlog detected ($TASK_COUNT tasks in $BACKLOG_PATH). Strongly recommend splitting into phases of 5-10 tasks each. Large backlogs risk context overflow and quality degradation in later tasks."
  }
}
EOF
elif [[ "$TASK_COUNT" -ge 11 ]]; then
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG SIZE INFO: Large backlog detected ($TASK_COUNT tasks). Consider splitting if tasks are complex. Found backlog at: $BACKLOG_PATH"
  }
}
EOF
else
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "BACKLOG TRACKING: Found $TASK_COUNT tasks in $BACKLOG_PATH. Task completion will be verified at /verify."
  }
}
EOF
fi

exit 0
