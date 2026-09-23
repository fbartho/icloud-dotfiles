#!/bin/sh
# AI-attribution patterns for commit messages and PR/issue text.
# POSIX sh, sourced by commit-msg and by scripts that need the same list.
# Extend by appending to this list only — every consumer reads from here.

ATTRIBUTION_PATTERNS='
Co-Authored-By:
Co-authored-by:
Generated with \[Claude Code\]
Generated with Claude
🤖 Generated
Assisted-by:
Made-with:
Signed-off-by: Claude
noreply@anthropic\.com
Claude Code <
'

# ATTRIBUTION_GUARD_MODE=reject fails on a match; any other value strips it.
# shellcheck disable=SC2034 # read by the scripts that source this file
case "${ATTRIBUTION_GUARD_MODE:-strip}" in
reject) ATTRIBUTION_MODE='reject' ;;
*) ATTRIBUTION_MODE='strip' ;;
esac

# Prints the first matching pattern and offending line for a given file,
# ignoring comment lines and everything from the commit scissors line down.
# Usage: attribution_scan <file>
# Exit: 0 and prints "pattern|line" on a match, 1 on no match.
attribution_scan() {
	scan_file="$1"
	stripped=$(mktemp)
	# Drop the `git commit -v` diff: everything from the scissors line onward.
	sed '/^# ------------------------ >8 ------------------------$/,$d' "$scan_file" \
		| grep -v '^#' >"$stripped"

	while IFS= read -r pattern; do
		[ -z "$pattern" ] && continue
		match=$(grep -inE "$pattern" "$stripped" | head -1)
		if [ -n "$match" ]; then
			rm -f "$stripped"
			printf '%s|%s\n' "$pattern" "$match"
			return 0
		fi
	done <<EOF
$ATTRIBUTION_PATTERNS
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
