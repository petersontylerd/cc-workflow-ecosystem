#!/usr/bin/env bash
# PreToolCall hook: Validate context packet for subagent dispatch
# Checks that Task tool calls include required context sections

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Only check Task tool calls
if [[ "$TOOL_NAME" != "Task" ]]; then
  echo '{}'
  exit 0
fi

# Check for subagent_type parameter indicating this is a subagent dispatch
if ! echo "$TOOL_INPUT" | grep -qE '"subagent_type"'; then
  echo '{}'
  exit 0
fi

# Check for code-implementer, spec-reviewer, or quality-reviewer dispatch
if ! echo "$TOOL_INPUT" | grep -qE '(code-implementer|spec-reviewer|quality-reviewer)'; then
  echo '{}'
  exit 0
fi

# Check for required context packet sections in the prompt
MISSING_SECTIONS=""

if ! echo "$TOOL_INPUT" | grep -qiE '(##\s*Task:|Task:|### Task)'; then
  MISSING_SECTIONS="${MISSING_SECTIONS}Task header, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(##\s*Context|### Context|context:)'; then
  MISSING_SECTIONS="${MISSING_SECTIONS}Context section, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(##\s*Requirements|### Requirements|requirements:)'; then
  MISSING_SECTIONS="${MISSING_SECTIONS}Requirements section, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(success criteria|##\s*Success|### Success)'; then
  MISSING_SECTIONS="${MISSING_SECTIONS}Success Criteria, "
fi

if [[ -n "$MISSING_SECTIONS" ]]; then
  # Remove trailing comma and space
  MISSING_SECTIONS="${MISSING_SECTIONS%, }"
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "CONTEXT PACKET WARNING: Subagent dispatch may be missing required sections: ${MISSING_SECTIONS}. Per orchestrating-subagents skill, each subagent needs complete context to perform well. Consider adding missing sections before dispatching."
  }
}
EOF
  exit 0
fi

# All sections present
echo '{}'
exit 0
