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

# Fix tracking file (B3)
NEEDS_REFIX_FILE="${SESSION_DIR}/.needs_refix"

# Detect subagent type from tool input and update tracker
# The tool input contains the subagent_type parameter
if echo "$TOOL_INPUT" | grep -qE 'code-implementer'; then
  # Check if this is a re-dispatch after reviewers found issues
  if [[ -f "$TRACKER_FILE" ]] && grep -q "spec-reviewer\|quality-reviewer" "$TRACKER_FILE" 2>/dev/null; then
    # Reviewers were dispatched, now implementer re-dispatched = fix cycle
    # Set needs_refix flag to ensure fresh reviews after fix
    touch "$NEEDS_REFIX_FILE"
  fi
  # New task or fix started - reset tracker but preserve needs_refix
  echo "code-implementer" > "$TRACKER_FILE"
elif echo "$TOOL_INPUT" | grep -qE 'spec-reviewer'; then
  # Append spec-reviewer to tracker
  echo "spec-reviewer" >> "$TRACKER_FILE"
  # Clear needs_refix if this is a fresh review after fix
  if [[ -f "$NEEDS_REFIX_FILE" ]]; then
    rm -f "$NEEDS_REFIX_FILE"
  fi
elif echo "$TOOL_INPUT" | grep -qE 'quality-reviewer'; then
  # Append quality-reviewer to tracker
  echo "quality-reviewer" >> "$TRACKER_FILE"
  # Clear needs_refix if this is a fresh review after fix
  if [[ -f "$NEEDS_REFIX_FILE" ]]; then
    rm -f "$NEEDS_REFIX_FILE"
  fi
fi

echo '{}'
exit 0
