#!/bin/sh
# Standalone tests for commit-msg and claude-attribution-guard.sh in both
# ATTRIBUTION_GUARD_MODE values. Exits non-zero on any failure. Needs jq.

HOOKS=$(CDPATH='' cd -- "$(dirname "$0")" && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT INT TERM

ATTRIBUTION_GUARD_LOG="$WORK/guard.log"
export ATTRIBUTION_GUARD_LOG

FAILS=0
PASSES=0

pass() {
	PASSES=$((PASSES + 1))
	printf 'ok   %s\n' "$1"
}

fail() {
	FAILS=$((FAILS + 1))
	printf 'FAIL %s\n' "$1"
	[ -n "$2" ] && printf '     %s\n' "$2"
}

check() {
	desc="$1"
	shift
	if "$@"; then pass "$desc"; else fail "$desc"; fi
}

jq_true() {
	jq -e "$1" "$2" >/dev/null
}

has_attribution() {
	grep -qiE 'Co-Authored-By:|Generated with|noreply@anthropic|🤖' "$1"
}

command -v jq >/dev/null 2>&1 || {
	echo "jq is required" >&2
	exit 1
}

# ---- commit-msg -------------------------------------------------------------

REPO="$WORK/repo"
git init -q "$REPO"
git -C "$REPO" config core.hooksPath "$HOOKS"
git -C "$REPO" config user.name "Test"
git -C "$REPO" config user.email "test@example.com"
git -C "$REPO" config commit.gpgsign false

TRAILER='Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>'

run_hook() {
	(cd "$REPO" && ATTRIBUTION_GUARD_MODE="$1" sh "$HOOKS/commit-msg" "$2")
}

# Strip mode: a real commit with a trailer succeeds without the trailer.
echo one >"$REPO/f"
git -C "$REPO" add f
if ATTRIBUTION_GUARD_MODE='strip' git -C "$REPO" commit -q -m "fix: thing" -m "$TRAILER" 2>"$WORK/err"; then
	body=$(git -C "$REPO" log -1 --format=%B)
	if printf '%s' "$body" | grep -q 'Co-Authored-By'; then
		fail "commit-msg strip: trailer removed from commit" "$body"
	else
		pass "commit-msg strip: trailer removed from commit"
	fi
	check "commit-msg strip: body keeps subject" test "$(printf '%s' "$body" | head -1)" = "fix: thing"
	check "commit-msg strip: stderr notice" grep -q "^commit-msg: stripped AI attribution line: $TRAILER\$" "$WORK/err"
	check "commit-msg strip: log line written" grep -q "	commit-msg	" "$ATTRIBUTION_GUARD_LOG"
else
	fail "commit-msg strip: commit with trailer succeeds" "$(cat "$WORK/err")"
fi

# Unset mode defaults to strip.
echo two >"$REPO/f"
git -C "$REPO" add f
if env -u ATTRIBUTION_GUARD_MODE git -C "$REPO" commit -q -m "fix: default" -m "$TRAILER" 2>/dev/null; then
	pass "commit-msg unset mode: strips"
else
	fail "commit-msg unset mode: strips"
fi

# Reject mode: the same commit fails.
echo three >"$REPO/f"
git -C "$REPO" add f
if ATTRIBUTION_GUARD_MODE=reject git -C "$REPO" commit -q -m "fix: other" -m "$TRAILER" 2>/dev/null; then
	fail "commit-msg reject: commit with trailer rejected"
else
	pass "commit-msg reject: commit with trailer rejected"
fi

# Stripped trailer leaves no trailing blank lines.
printf 'Subject\n\nBody text.\n\n%s\n\n' "$TRAILER" >"$WORK/msg-trailing"
printf 'Subject\n\nBody text.\n' >"$WORK/msg-trailing.expected"
run_hook strip "$WORK/msg-trailing" 2>/dev/null
check "commit-msg strip: trailing blank lines collapsed" cmp -s "$WORK/msg-trailing" "$WORK/msg-trailing.expected"

# A clean message is untouched byte-for-byte in both modes.
for mode in strip reject; do
	printf 'feat: clean\n\nNothing to see.\n# Please enter the commit message\n' >"$WORK/msg-clean"
	cp "$WORK/msg-clean" "$WORK/msg-clean.orig"
	if run_hook "$mode" "$WORK/msg-clean" 2>/dev/null; then
		check "commit-msg $mode: clean message untouched" cmp -s "$WORK/msg-clean" "$WORK/msg-clean.orig"
	else
		fail "commit-msg $mode: clean message accepted"
	fi
done

# A `git commit -v` diff below the scissors line is never modified.
for mode in strip reject; do
	cat >"$WORK/msg-scissors" <<'EOF'
feat: verbose

Body.
# Please enter the commit message for your changes.
# ------------------------ >8 ------------------------
# Do not modify or remove the line above.
diff --git a/f b/f
+Co-Authored-By: Someone <noreply@anthropic.com>
EOF
	cp "$WORK/msg-scissors" "$WORK/msg-scissors.orig"
	if run_hook "$mode" "$WORK/msg-scissors" 2>/dev/null; then
		check "commit-msg $mode: scissors region untouched" cmp -s "$WORK/msg-scissors" "$WORK/msg-scissors.orig"
	else
		fail "commit-msg $mode: scissors message accepted"
	fi
done

# The repo-local commit-msg hook still runs, with the message path as $1.
cat >"$REPO/.git/hooks/commit-msg" <<EOF
#!/bin/sh
cp "\$1" "$WORK/delegated"
EOF
chmod +x "$REPO/.git/hooks/commit-msg"
echo four >"$REPO/f"
git -C "$REPO" add f
git -C "$REPO" commit -q -m "fix: delegated" -m "$TRAILER" 2>/dev/null
check "commit-msg: delegates stripped message to repo-local hook" \
	test "$(cat "$WORK/delegated" 2>/dev/null)" = "fix: delegated"
rm -f "$REPO/.git/hooks/commit-msg"

# ---- claude-attribution-guard.sh --------------------------------------------

GUARD="$HOOKS/claude-attribution-guard.sh"

# run_guard <mode> <tool_name> <command>; sets GUARD_STATUS, writes $WORK/out.
run_guard() {
	jq -n --arg t "$2" --arg c "$3" \
		'{tool_name: $t, tool_input: {command: $c, description: "d"}}' \
		| ATTRIBUTION_GUARD_MODE="$1" sh "$GUARD" >"$WORK/out" 2>"$WORK/guard-err"
	GUARD_STATUS=$?
}

CMD_HEREDOC=$(cat <<'OUTER'
git commit -m "$(cat <<'EOF'
feat: add thing

Body line.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
EOF
)"
OUTER
)

CMD_GH='gh pr create --title "Add thing" --body "Summary of the change.

🤖 Generated with [Claude Code](https://claude.com/claude-code)"'

CMD_INLINE='git commit -m "fix: inline" -m "Co-Authored-By: Claude <noreply@anthropic.com>" && git status'

CMD_NOVERIFY='git commit --no-verify -m "fix: skip hooks"'
CMD_CLEAN='git commit -m "fix: clean"'

# assert_stripped <label> <must-contain>
assert_stripped() {
	label="$1"
	: >"$WORK/rewritten"
	if [ "$GUARD_STATUS" -ne 0 ]; then
		fail "guard strip $label: exit 0" "status $GUARD_STATUS: $(cat "$WORK/guard-err")"
		return
	fi
	if ! jq -e '.hookSpecificOutput.updatedInput.command' "$WORK/out" >/dev/null 2>&1; then
		fail "guard strip $label: updatedInput.command present" "$(cat "$WORK/out")"
		return
	fi
	jq -j '.hookSpecificOutput.updatedInput.command' "$WORK/out" >"$WORK/rewritten"
	if has_attribution "$WORK/rewritten"; then
		fail "guard strip $label: attribution removed" "$(cat "$WORK/rewritten")"
	else
		pass "guard strip $label: attribution removed"
	fi
	check "guard strip $label: rewritten command parses" sh -n "$WORK/rewritten"
	check "guard strip $label: keeps '$2'" grep -qF -- "$2" "$WORK/rewritten"
	check "guard strip $label: no permissionDecision" \
		jq_true '.hookSpecificOutput | has("permissionDecision") | not' "$WORK/out"
	check "guard strip $label: hookEventName" \
		jq_true '.hookSpecificOutput.hookEventName == "PreToolUse"' "$WORK/out"
	check "guard strip $label: other tool_input fields kept" \
		jq_true '.hookSpecificOutput.updatedInput.description == "d"' "$WORK/out"
	check "guard strip $label: notice" \
		jq_true '.hookSpecificOutput.additionalContext == "attribution guard: stripped AI attribution from command"' "$WORK/out"
}

: >"$ATTRIBUTION_GUARD_LOG"
run_guard strip Bash "$CMD_HEREDOC"
assert_stripped "(a) heredoc" "feat: add thing"
check "guard strip (a) heredoc: terminator kept" grep -qx 'EOF' "$WORK/rewritten"
check "guard strip (a): log line written" grep -q "	pretooluse	" "$ATTRIBUTION_GUARD_LOG"

run_guard strip Bash "$CMD_GH"
assert_stripped "(b) gh body" "Summary of the change."

run_guard strip Bash "$CMD_INLINE"
assert_stripped "inline -m" "&& git status"

for mode in strip reject; do
	run_guard "$mode" Bash "$CMD_NOVERIFY"
	check "guard $mode (c) --no-verify: exit 2" test "$GUARD_STATUS" -eq 2
done

for mode in strip reject; do
	run_guard "$mode" Bash "$CMD_CLEAN"
	check "guard $mode (d) clean: exit 0" test "$GUARD_STATUS" -eq 0
	check "guard $mode (d) clean: no output" test ! -s "$WORK/out"

	run_guard "$mode" Read "$CMD_HEREDOC"
	check "guard $mode (e) non-Bash: exit 0" test "$GUARD_STATUS" -eq 0
	check "guard $mode (e) non-Bash: no output" test ! -s "$WORK/out"
done

run_guard reject Bash "$CMD_HEREDOC"
check "guard reject (a) heredoc: exit 2" test "$GUARD_STATUS" -eq 2
run_guard reject Bash "$CMD_GH"
check "guard reject (b) gh body: exit 2" test "$GUARD_STATUS" -eq 2

printf '\n%s passed, %s failed\n' "$PASSES" "$FAILS"
[ "$FAILS" -eq 0 ]
