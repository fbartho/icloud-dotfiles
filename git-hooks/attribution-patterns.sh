#!/bin/sh
# AI-attribution patterns for commit messages and PR/issue text.
# POSIX sh, sourced by commit-msg and by scripts that need the same lists.
# Extend by appending to these lists only — every consumer reads from here.
# Each line is an extended regex, matched case-insensitively. [[:<:]] and
# [[:>:]] are word boundaries that BSD grep and BSD sed both accept; BSD sed
# has no \b. A leading ^ or trailing $ anchors to the start or end of a line;
# the PreToolUse guard also anchors them just inside a quote, where a -m or
# --body argument begins or ends.

# Strip list: matching lines are stripped, or rejected when
# ATTRIBUTION_GUARD_MODE=reject.
# shellcheck disable=SC2034 # read by the scripts that source this file
ATTRIBUTION_PATTERNS='
Co-Authored-By:
Co-authored-by:
^[^[:alnum:]"'\'']*(this [a-z -]{1,30} (was|is) )?Generated[[:space:]]+(with|by|using)[[:>:]]
Generated-by:
🤖 Generated
Assisted-by:
Made-with:
Signed-off-by:[[:space:]]*claude([[:space:]]+(code|opus|sonnet|haiku|fable|[0-9])[^<"'\'']*)?[[:space:]]*<
Signed-off-by:[[:space:]]*claude([[:space:]]+(code|opus|sonnet|haiku|fable|[0-9])[^<"'\'']*)?[[:space:]]*$
Signed-off-by:[^"'\'']*[[:<:]](anthropic|openai|chatgpt|gpt|codex|copilot|cursor|gemini|devin-ai|devin ai|aider|windsurf|codeium|amazon-q|google-labs-jules|muse|antigravity)[[:>:]]
noreply@anthropic\.com
Claude Code <
'

# Reject list: AI-company email domains. A match anywhere in a commit message
# rejects the commit in either ATTRIBUTION_GUARD_MODE. @cursor.com is the
# domain of Cursor's `cursoragent@cursor.com` co-author trailer.
# shellcheck disable=SC2034 # read by the scripts that source this file
ATTRIBUTION_REJECT_PATTERNS='
@anthropic\.com[[:>:]]
@chatgpt\.com[[:>:]]
@openai\.com[[:>:]]
@facebook\.com[[:>:]]
@google\.com[[:>:]]
@microsoft\.com[[:>:]]
@meta\.com[[:>:]]
@cursor\.com[[:>:]]
'

# ATTRIBUTION_GUARD_MODE=reject fails on a strip-list match; any other value
# strips it.
# shellcheck disable=SC2034 # read by the scripts that source this file
case "${ATTRIBUTION_GUARD_MODE:-strip}" in
reject) ATTRIBUTION_MODE='reject' ;;
*) ATTRIBUTION_MODE='strip' ;;
esac

# Prints the first matching pattern and offending line for a given file,
# ignoring comment lines and everything from the commit scissors line down.
# Usage: attribution_scan <file> <patterns>
# Exit: 0 and prints "pattern<TAB>line" on a match, 1 on no match. The
# separator is a tab because patterns contain `|`.
attribution_scan() {
	scan_file="$1"
	scan_patterns="$2"
	stripped=$(mktemp)
	# Drop the `git commit -v` diff: everything from the scissors line onward.
	sed '/^# ------------------------ >8 ------------------------$/,$d' "$scan_file" \
		| grep -v '^#' >"$stripped"

	while IFS= read -r pattern; do
		[ -z "$pattern" ] && continue
		match=$(grep -inE "$pattern" "$stripped" | head -1)
		if [ -n "$match" ]; then
			rm -f "$stripped"
			printf '%s\t%s\n' "$pattern" "$match"
			return 0
		fi
	done <<EOF
$scan_patterns
EOF

	rm -f "$stripped"
	return 1
}

# Appends one tab-separated line to the strip log; never fails.
# Usage: attribution_log <layer> <pattern>
attribution_log() {
	log_file="${ATTRIBUTION_GUARD_LOG:-$HOME/Library/Caches/ebrain/attribution-guard.log}"
	{
		mkdir -p "$(dirname "$log_file")" \
			&& printf '%s\t%s\t%s\t%s\n' \
				"$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$1" "$2" "$PWD" >>"$log_file"
	} 2>/dev/null || true
}
