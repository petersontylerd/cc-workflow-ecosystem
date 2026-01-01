#!/usr/bin/env bash
# PostToolUse hook: Check implementer completion for evidence
# Validates that code-implementer responses contain verification evidence.
#
# Fires when: Task tool completes with code-implementer subagent
# Checks for: Test output patterns, git references, file paths
# Warns: If no evidence patterns found (doesn't block)

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
TOOL_OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"

# Only process Task tool completions
[[ "$TOOL_NAME" != "Task" ]] && { echo '{}'; exit 0; }

# Only check code-implementer dispatches
echo "$TOOL_INPUT" | grep -qE 'code-implementer' || { echo '{}'; exit 0; }

# Check for workflow skip
SKIP_FILE="${SESSION_DIR}/.workflow_skip"
[[ -f "$SKIP_FILE" ]] && { echo '{}'; exit 0; }

# Check if in implementing phase
PHASE_FILE="${SESSION_DIR}/.workflow_phase"
PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "")
[[ "$PHASE" != "implementing" ]] && { echo '{}'; exit 0; }

# Check for evidence patterns in the output
# Note: TOOL_OUTPUT may be truncated or unavailable in some cases
if [[ -z "$TOOL_OUTPUT" ]]; then
  # Can't check output - just provide reminder
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "EVIDENCE REMINDER: Ensure implementer provided verification evidence including: test output (passed/failed counts), git diff reference, and list of files modified."
  }
}
EOF
  exit 0
fi

# Initialize evidence tracking
HAS_TEST_EVIDENCE=false
HAS_GIT_EVIDENCE=false
HAS_FILE_EVIDENCE=false

# Check for test output evidence
if echo "$TOOL_OUTPUT" | grep -qiE 'passed|failed|assert|pytest|jest|test.*result|PASS|FAIL|✓|✗|tests? (pass|fail)'; then
  HAS_TEST_EVIDENCE=true
fi

# Check for git evidence
if echo "$TOOL_OUTPUT" | grep -qiE 'git diff|git commit|commit [a-f0-9]{7}|HEAD|staged|modified:'; then
  HAS_GIT_EVIDENCE=true
fi

# Check for file path evidence
if echo "$TOOL_OUTPUT" | grep -qE '\.(py|ts|tsx|js|jsx|go|rs|java|rb|sh|md)\b|src/|tests?/|lib/|app/'; then
  HAS_FILE_EVIDENCE=true
fi

# Generate warning if evidence is missing
MISSING=""
if [[ "$HAS_TEST_EVIDENCE" != "true" ]]; then
  MISSING="${MISSING}test output, "
fi
if [[ "$HAS_GIT_EVIDENCE" != "true" ]]; then
  MISSING="${MISSING}git reference, "
fi
if [[ "$HAS_FILE_EVIDENCE" != "true" ]]; then
  MISSING="${MISSING}file paths, "
fi

if [[ -n "$MISSING" ]]; then
  MISSING="${MISSING%, }"  # Remove trailing comma
  cat <<EOF
{
  "hookSpecificOutput": {
    "additionalContext": "EVIDENCE WARNING: Implementer completion may lack verification evidence. Missing: ${MISSING}. Completion reports should include: (1) test output with pass/fail counts, (2) git diff or commit reference, (3) list of files modified. Reviewers need this evidence to verify work."
  }
}
EOF
else
  echo '{}'
fi

exit 0
