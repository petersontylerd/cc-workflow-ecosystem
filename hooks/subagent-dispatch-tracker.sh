#!/usr/bin/env bash
# PostToolUse hook: Track subagent dispatch during /implement
# Tracks Task tool dispatches and records in session state
#
# This hook tracks which subagents have been dispatched for the current task.
# It resets the tracker when a new code-implementer is dispatched (new task).
# Only active during the implementing phase.

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Only process Task tool completions
[[ "$TOOL_NAME" != "Task" ]] && { echo '{}'; exit 0; }

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

# Check if in implementing phase
PHASE_FILE="${SESSION_DIR}/.workflow_phase"
PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "")
[[ "$PHASE" != "implementing" ]] && { echo '{}'; exit 0; }

mkdir -p "$SESSION_DIR"
TRACKER_FILE="${SESSION_DIR}/.subagent_dispatch"

# Detect subagent type from tool input and update tracker
# The tool input contains the subagent_type parameter
if echo "$TOOL_INPUT" | grep -qE 'code-implementer'; then
  # New task started - reset tracker
  echo "code-implementer" > "$TRACKER_FILE"
elif echo "$TOOL_INPUT" | grep -qE 'spec-reviewer'; then
  # Append spec-reviewer to tracker
  echo "spec-reviewer" >> "$TRACKER_FILE"
elif echo "$TOOL_INPUT" | grep -qE 'quality-reviewer'; then
  # Append quality-reviewer to tracker
  echo "quality-reviewer" >> "$TRACKER_FILE"
fi

echo '{}'
exit 0
