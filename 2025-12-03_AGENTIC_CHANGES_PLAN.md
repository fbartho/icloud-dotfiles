# Shell Setup Changes for Claude Code Compatibility

**Date:** 2025-12-03
**Status:** Complete

## Goal

Reduce verbosity of shell setup when executed by Claude Code agents to save tokens, while preserving full functionality for interactive use.

## Detection Method

Use a unified `AI_AGENT` variable set at the top of `.profile`:

```bash
# Detect AI agents and set unified variable
# Add new agent env vars here as needed
# Known: CLAUDECODE (Claude Code), GEMINI_CLI (Google Gemini), CURSOR_TRACE_ID (Cursor), AIDER
# Note: OpenAI Codex doesn't appear to set a detection variable yet
if [ -n "$CLAUDECODE" ] || [ -n "$GEMINI_CLI" ] || [ -n "$CURSOR_TRACE_ID" ] || [ -n "$AIDER" ]; then
    export AI_AGENT=1
fi
```

- Works in bash, zsh, and fish (with syntax adaptation for fish)
- `[ -n "$AI_AGENT" ]` checks if variable is set and non-empty
- Add new agent detection to the single block at top of `.profile`
- Known agent variables: `CLAUDECODE`, `GEMINI_CLI`, `CURSOR_TRACE_ID`, `AIDER`
- OpenAI Codex: doesn't set a detection variable yet (as of Dec 2025)

## Changes

### 1. `.profile` (line 37-41) - Silence nvm output

**Current:**
```bash
nvm use default
```

**Proposed:**
```bash
if [ -n "$CLAUDECODE" ]; then
    nvm use default --silent
else
    nvm use default
fi
```

### 2. `.profile` (line 108-112) - Suppress gpg-agent echo

**Current:**
```bash
if [ -S ~/.gnupg/S.gpg-agent ]; then
    echo "[gpg-agent]: status is good."
else
    eval $(gpg-agent --daemon)
fi
```

**Proposed:**
```bash
if [ -S ~/.gnupg/S.gpg-agent ]; then
    [ -z "$CLAUDECODE" ] && echo "[gpg-agent]: status is good."
else
    eval $(gpg-agent --daemon)
fi
```

### 3. `.profile` (lines 60-86) - Skip tab-completion for agents

**Rationale:** Agents don't use tab completion. Skipping git-completion, git-prompt, bash-completion, and yarn tab-completion saves significant init time.

**Changes:**
- Wrapped entire tab-completion block in `if [ -z "$CLAUDECODE" ]`
- Echo statements for missing git files now only run for interactive shells
- Cached `brew --prefix` result to avoid slow call: `BREW_PREFIX="${BREW_PREFIX:-$(brew --prefix)}"`

### 4. `bin/ps1` - Minimal prompt for agents

**Current:** Complex PS1 with git status, emoji prompts, colored output, full path.

**Proposed:** Add early exit at top of script:
```bash
# Minimal prompt for Claude Code agents
if [ -n "$CLAUDECODE" ]; then
    export PS1='$ '
    return 0
fi
```

This skips all git status checks, emoji selection, and color processing.

## Shell Compatibility Notes

- `$CLAUDECODE` detection works in bash and zsh unchanged
- For fish migration, you'd use `if set -q CLAUDECODE` and need separate `.fish` config files
- Current files are bash-specific; these changes maintain that

## Future Enhancements (Not in this change)

- [x] Shorten directory path indicator to 2-3 parents / max 40 chars for interactive use

### 5. `bin/ps1` - Shorter path for interactive use

Added `short_pwd()` function that:
- Shows full path if ≤40 chars
- Otherwise shows last 3 path components with `…/` prefix
- Falls back to 2 components if still too long
- Replaces `$HOME` with `~`

Also removed newline from prompt - now single-line: `💚 (branch) path $`

## Log

- **2025-12-03:** Plan created, beginning implementation
- **2025-12-03:** Implementation complete. Both changes applied successfully.
- **2025-12-03:** Fixed: Variable is `CLAUDECODE` (no underscore), not `CLAUDE_CODE`. Updated both files.
- **2025-12-03:** Added `nvm use default --silent` for Claude Code shells.
- **2025-12-03:** Skip all tab-completion setup (git, bash, yarn) for Claude agents. Cached `brew --prefix`.
- **2025-12-03:** Added `short_pwd()` for interactive use - shows 2-3 path components, max 40 chars. Removed newline from prompt.
- **2025-12-03:** Added unified `AI_AGENT` detection at top of `.profile`. Replaced all `CLAUDECODE` checks with `AI_AGENT`.
- **2025-12-03:** Added `GEMINI_CLI` to AI agent detection. OpenAI Codex doesn't set a detection variable yet.
