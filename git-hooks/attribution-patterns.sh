#!/bin/sh
# Rejected AI-attribution patterns for commit messages and PR/issue text.
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
