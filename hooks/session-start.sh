#!/usr/bin/env bash
# SessionStart hook for workflow ecosystem

set -euo pipefail

# Determine plugin root directory (one level up from hooks/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Session state directory
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
mkdir -p "$SESSION_DIR"

# Branch detection (A2): Auto-set phase to 'branched' if on feature branch with idle phase
BRANCH_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  if [[ -n "$CURRENT_BRANCH" && "$CURRENT_BRANCH" != "main" && "$CURRENT_BRANCH" != "master" ]]; then
    PHASE_FILE="${SESSION_DIR}/.workflow_phase"
    CURRENT_PHASE=$(cat "$PHASE_FILE" 2>/dev/null || echo "idle")
    if [[ "$CURRENT_PHASE" == "idle" || -z "$CURRENT_PHASE" ]]; then
      echo "branched" > "$PHASE_FILE"
      BRANCH_INFO="\\n\\n**Branch detected:** On '$CURRENT_BRANCH'. Phase auto-set to 'branched'. Ready for /brainstorm (plan mode)."
    fi
  fi
fi

# Read using-ecosystem content
using_ecosystem_content=$(cat "${PLUGIN_ROOT}/skills/using-ecosystem/SKILL.md" 2>&1 || echo "Error reading using-ecosystem skill")

# Escape outputs for JSON using pure bash
escape_for_json() {
    local input="$1"
    local output=""
    local i char
    for (( i=0; i<${#input}; i++ )); do
        char="${input:$i:1}"
        case "$char" in
            $'\\') output+='\\' ;;
            '"') output+='\"' ;;
            $'\n') output+='\n' ;;
            $'\r') output+='\r' ;;
            $'\t') output+='\t' ;;
            *) output+="$char" ;;
        esac
    done
    printf '%s' "$output"
}

using_ecosystem_escaped=$(escape_for_json "$using_ecosystem_content")

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have access to the workflow ecosystem.${BRANCH_INFO}\n\n**Below is the full content of your 'using-ecosystem' skill - your introduction to the workflow ecosystem. For all other skills, use the 'Skill' tool:**\n\n${using_ecosystem_escaped}\n\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
