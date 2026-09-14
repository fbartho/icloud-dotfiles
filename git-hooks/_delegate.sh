#!/bin/sh
# Shared delegation logic for every hook shim in this directory: run this
# hook's global check (if any), then exec the repository-local hook of the
# same name so per-repo hooks (e.g. `supe hooks install` pre-commit checks)
# keep running under a global core.hooksPath.
#
# Usage from a shim: HOOK_NAME=<name> . _delegate.sh "$@"
# Shims that need to run logic before delegating (commit-msg) do so above
# the source line and exit non-zero themselves on rejection.

# `git rev-parse --git-path hooks/<name>` resolves under core.hooksPath,
# which points back at this shim. The common dir's hooks/ ignores
# core.hooksPath, and in a worktree only the common dir has a hooks/.
LOCAL_GIT_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
LOCAL_HOOK="$LOCAL_GIT_DIR/hooks/$HOOK_NAME"

if [ -n "$LOCAL_GIT_DIR" ] && [ -f "$LOCAL_HOOK" ] && [ -x "$LOCAL_HOOK" ]; then
	exec "$LOCAL_HOOK" "$@"
fi

exit 0
