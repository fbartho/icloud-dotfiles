#!/bin/sh
# PreToolUse guard for Bash calls to git commit / gh pr / gh issue.
# - --no-verify is always blocked (exit 2): it skips the commit-msg hook.
# - git commit text matching the reject list in attribution-patterns.sh (AI-
#   company email domains) is always blocked (exit 2). gh commands skip it.
# - Text matching the strip list is removed from the command and returned as
#   hookSpecificOutput.updatedInput, leaving the permission flow untouched.
#   With ATTRIBUTION_GUARD_MODE=reject, a match blocks the command (exit 2).
# git commit is rewritten here too: a repo with its own core.hooksPath never
# runs the global commit-msg hook. PR/issue bodies only pass through here.

HOOK_DIR=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
NOTICE='attribution guard: stripped AI attribution from command'

INPUT=$(cat)

# The trailing x keeps command substitution from eating trailing newlines.
if command -v jq >/dev/null 2>&1; then
	TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')
	COMMAND=$(printf '%s' "$INPUT" | jq -j '.tool_input.command // empty'; printf x)
else
	TOOL_NAME=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); print(d.get("tool_name") or "")' 2>/dev/null)
	COMMAND=$(printf '%s' "$INPUT" | python3 -c 'import json,sys; d=json.load(sys.stdin); sys.stdout.write((d.get("tool_input") or {}).get("command") or "")' 2>/dev/null; printf x)
fi
COMMAND=${COMMAND%x}

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
trap 'rm -f "$TMP_CMD" "$TMP_CMD.new"' EXIT
printf '%s' "$COMMAND" >"$TMP_CMD"

case "$COMMAND" in
*"git commit"*)
	while IFS= read -r pattern; do
		[ -z "$pattern" ] && continue
		grep -qiE -e "$pattern" "$TMP_CMD" || continue
		echo "blocked: git commit text carries an AI-company email address matching '$pattern'; remove the address" >&2
		exit 2
	done <<EOF
$ATTRIBUTION_REJECT_PATTERNS
EOF
	;;
esac

while IFS= read -r pattern; do
	[ -z "$pattern" ] && continue
	# Removes the match through end of line, stopping at a quote so the
	# closing quote of a -m/--body argument on the footer line survives.
	# Leading punctuation, whitespace, and emoji before the match go with it.
	# A ^ pattern also matches just after a quote, and a $ pattern just before
	# one; the quote is kept.
	sed_pattern=$(printf '%s' "$pattern" | sed 's|/|\\/|g')
	case "$pattern" in
	'^'*)
		match_pattern="(^|[\"'])${pattern#^}"
		sed_expr="s/(^|[\"'])(${sed_pattern#^})[^\"']*/\\1/Ig"
		;;
	*'$')
		body=${sed_pattern%\$}
		match_pattern="${pattern%\$}([\"']|\$)"
		sed_expr="s/[^[:alnum:]\"']*(${body})\"/\"/Ig;s/[^[:alnum:]\"']*(${body})'/'/Ig;s/[^[:alnum:]\"']*(${body})\$//Ig"
		;;
	*)
		match_pattern=$pattern
		sed_expr="s/[^[:alnum:]\"']*(${sed_pattern})[^\"']*//Ig"
		;;
	esac
	grep -qiE -e "$match_pattern" "$TMP_CMD" || continue
	if [ "$ATTRIBUTION_MODE" = reject ]; then
		echo "blocked: command text matches AI-attribution pattern '$pattern'" >&2
		exit 2
	fi
	sed -E "$sed_expr" "$TMP_CMD" >"$TMP_CMD.new" \
		&& cat "$TMP_CMD.new" >"$TMP_CMD"
	attribution_log pretooluse "$pattern"
done <<EOF
$ATTRIBUTION_PATTERNS
EOF

NEW_COMMAND=$(cat "$TMP_CMD"; printf x)
NEW_COMMAND=${NEW_COMMAND%x}
[ "$NEW_COMMAND" = "$COMMAND" ] && exit 0

if command -v jq >/dev/null 2>&1; then
	printf '%s' "$INPUT" | jq -c --arg cmd "$NEW_COMMAND" --arg msg "$NOTICE" \
		'{hookSpecificOutput: {hookEventName: "PreToolUse", updatedInput: (.tool_input + {command: $cmd}), additionalContext: $msg}}'
else
	printf '%s' "$INPUT" | python3 -c '
import json, sys
d = json.load(sys.stdin)
tool_input = dict(d.get("tool_input") or {})
tool_input["command"] = sys.argv[1]
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "updatedInput": tool_input, "additionalContext": sys.argv[2]}}))
' "$NEW_COMMAND" "$NOTICE"
fi
exit 0
