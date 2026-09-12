#!/bin/sh
# Shared delegation logic for every hook shim in this directory: run this
# hook's global check (if any), then exec the repository-local hook of the
# same name so per-repo hooks (e.g. `supe hooks install` pre-commit checks)
# keep running under a global core.hooksPath.
#
# Usage from a shim: HOOK_NAME=<name> . _delegate.sh "$@"
# Shims that need to run logic before delegating (commit-msg) do so above
# the source line and exit non-zero themselves on rejection.

# `git rev-parse --git-path hooks/<name>` resolves under core.hooksPath once
# that is set globally, which would point back at this shim and recurse
# forever. The literal .git/hooks directory ignores core.hooksPath, so
# GIT_DIR is read directly here instead.
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
LOCAL_HOOK="$GIT_DIR/hooks/$HOOK_NAME"

if [ -n "$GIT_DIR" ] && [ -f "$LOCAL_HOOK" ] && [ -x "$LOCAL_HOOK" ]; then
	exec "$LOCAL_HOOK" "$@"
fi

exit 0
