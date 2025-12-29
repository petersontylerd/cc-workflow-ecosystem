#!/usr/bin/env bash
# PreToolCall hook: Remind about verification before git commit
# This hook adds a warning when attempting to commit without explicit /verify mention

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Check if this is a git commit command
if echo "$TOOL_INPUT" | grep -qE "git\s+commit"; then
  # Output a reminder - this adds context, doesn't block
  cat <<'EOF'
{
  "hookSpecificOutput": {
    "additionalContext": "VERIFICATION REMINDER: Before committing, ensure you have run /verify and confirmed all tests, linter, and build pass. The verification skill requires evidence before claims - 'should pass' is not sufficient."
  }
}
EOF
  exit 0
fi

# Not a git commit - no action needed
echo '{}'
exit 0
