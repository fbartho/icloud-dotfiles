#!/bin/sh
# PreToolUse guard: blocks Bash calls to git commit / gh pr / gh issue whose
# command text carries AI-attribution boilerplate or --no-verify, before the
# text ever reaches git or GitHub. Layer 1 (commit-msg hook) catches the
# commit case after the fact; this catches it before, and covers PR/issue
# bodies that commit-msg never sees.

HOOK_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)

INPUT=$(cat)

if command -v jq >/dev/null 2>&1; then
	TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')
	COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')
else
	TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_name") or "")' 2>/dev/null)
	COMMAND=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print((d.get("tool_input") or {}).get("command") or "")' 2>/dev/null)
fi

[ "$TOOL_NAME" = "Bash" ] || exit 0
[ -n "$COMMAND" ] || exit 0

case "$COMMAND" in
*"git commit"* | *"gh pr create"* | *"gh pr edit"* | *"gh pr comment"* | *"gh issue create"* | *"gh issue comment"*) ;;
*) exit 0 ;;
esac

if printf '%s' "$COMMAND" | grep -qE -- '--no-verify'; then
	echo "blocked: command uses --no-verify, which bypasses the commit-msg attribution guard" >&2
	exit 2
fi

# shellcheck source=./attribution-patterns.sh
. "$HOOK_DIR/attribution-patterns.sh"

TMP_CMD=$(mktemp)
printf '%s\n' "$COMMAND" >"$TMP_CMD"

while IFS= read -r pattern; do
	[ -z "$pattern" ] && continue
	if grep -qinE "$pattern" "$TMP_CMD"; then
		echo "blocked: command text matches AI-attribution pattern '$pattern'" >&2
		rm -f "$TMP_CMD"
		exit 2
	fi
done <<EOF
$ATTRIBUTION_PATTERNS
EOF

rm -f "$TMP_CMD"
exit 0
