#!/usr/bin/env bash
# PreToolCall hook: Validate context packet for subagent dispatch
# Checks that Task tool calls include required context sections
# Provides warnings (not blocks) per user preference

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
MISSING_CORE=""
MISSING_ENHANCED=""

# Core sections (highly recommended)
if ! echo "$TOOL_INPUT" | grep -qiE '(##\s*Task:|Task:|### Task)'; then
  MISSING_CORE="${MISSING_CORE}Task header, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(##\s*Context|### Context|context:)'; then
  MISSING_CORE="${MISSING_CORE}Context section, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(##\s*Requirements|### Requirements|requirements:)'; then
  MISSING_CORE="${MISSING_CORE}Requirements section, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(success criteria|##\s*Success|### Success)'; then
  MISSING_CORE="${MISSING_CORE}Success Criteria, "
fi

# Enhanced sections (recommended for better subagent performance)
if ! echo "$TOOL_INPUT" | grep -qiE '(##\s*Purpose|### Purpose|purpose:)'; then
  MISSING_ENHANCED="${MISSING_ENHANCED}Purpose (WHY task matters), "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(environment|verification|##\s*Environment|### Environment)'; then
  MISSING_ENHANCED="${MISSING_ENHANCED}Environment Verification, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(failure mode|potential failure|##\s*Failure|### Failure|what could go wrong)'; then
  MISSING_ENHANCED="${MISSING_ENHANCED}Potential Failure Modes, "
fi

if ! echo "$TOOL_INPUT" | grep -qiE '(required skill|##\s*Skills|### Skills|skill.*consult)'; then
  MISSING_ENHANCED="${MISSING_ENHANCED}Required Skills, "
fi

# Build warning message
WARNING_MSG=""

if [[ -n "$MISSING_CORE" ]]; then
  MISSING_CORE="${MISSING_CORE%, }"
  WARNING_MSG="CONTEXT PACKET WARNING: Missing core sections: ${MISSING_CORE}. "
fi

if [[ -n "$MISSING_ENHANCED" ]]; then
  MISSING_ENHANCED="${MISSING_ENHANCED%, }"
  if [[ -n "$WARNING_MSG" ]]; then
    WARNING_MSG="${WARNING_MSG}Also missing enhanced sections: ${MISSING_ENHANCED}. "
  else
    WARNING_MSG="CONTEXT PACKET SUGGESTION: Consider adding enhanced sections: ${MISSING_ENHANCED}. "
  fi
fi

if [[ -n "$WARNING_MSG" ]]; then
  WARNING_MSG="${WARNING_MSG}Per orchestrating-subagents skill, complete context packets improve subagent performance. See skills/orchestrating-subagents/SKILL.md for the full format."
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "${WARNING_MSG}"
  }
}
EOF
  exit 0
fi

# All sections present
echo '{}'
exit 0
