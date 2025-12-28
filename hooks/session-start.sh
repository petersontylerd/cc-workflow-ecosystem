#!/usr/bin/env bash
# SessionStart hook for workflow ecosystem

set -euo pipefail

# Determine plugin root directory (one level up from hooks/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PLUGIN_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

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
    "additionalContext": "<EXTREMELY_IMPORTANT>\nYou have access to the workflow ecosystem.\n\n**Below is the full content of your 'using-ecosystem' skill - your introduction to the workflow ecosystem. For all other skills, use the 'Skill' tool:**\n\n${using_ecosystem_escaped}\n\n</EXTREMELY_IMPORTANT>"
  }
}
EOF

exit 0
