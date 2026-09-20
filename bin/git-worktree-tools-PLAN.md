# Git Worktree Tools - Implementation Plan

## Overview

Two related tools for managing git worktrees beyond the standard `git worktree` commands:

1. **`git-worktree-disconnect`** - Convert a linked worktree into a standalone repository
2. **`git-worktree-move-root`** - Move the "root" (main .git directory) to a different worktree

---

## Tool 1: `git-worktree-disconnect`

### Purpose
Disconnect a worktree from its parent repository, converting it into a fully independent clone.

### Usage
```bash
cd /path/to/worktree
git worktree-disconnect [--force]
```

### Behavior
1. **Safety check**: Refuse to run if there are uncommitted modifications or deletions (new/untracked files are OK)
   - Use `--force` to override this check
2. **Find the root repo**: Parse the `.git` file to locate the main repository
3. **Copy git state**:
   - Copy the shared `.git` directory contents to create a standalone repo
   - Preserve the current branch/HEAD state
4. **Clean up references**:
   - Remove this worktree from the parent's `.git/worktrees/` directory
   - Convert the `.git` file to a `.git` directory

### Post-conditions
- Both repositories are fully independent clones
- Each repo remains checked out at its correct branch
- Parent repo no longer knows about the disconnected worktree

### Git Internals Involved
- `.git` file in worktree contains: `gitdir: /path/to/main/.git/worktrees/<id>`
- Parent repo has: `.git/worktrees/<id>/` with HEAD, gitdir, etc.
- Shared objects in: `.git/objects/`
- Shared refs in: `.git/refs/` (except per-worktree refs)

---

## Tool 2: `git-worktree-move-root`

### Purpose
Move the "root" repository (where `.git/` directory lives) to a different worktree location.

### Usage
```bash
# From the current root, specify new root:
cd /path/to/current-root
git worktree-move-root /path/to/target-worktree

# OR from a worktree, make it the new root:
cd /path/to/worktree
git worktree-move-root --to-here
```

### Behavior
1. **Validate**:
   - In "from here to there" mode: CWD must be the root (has `.git/` directory)
   - In "to here" mode: CWD must be a linked worktree (has `.git` file)
   - Target must be an existing worktree of this repo
2. **Move the .git directory**:
   - Move `.git/` from old root to new root
3. **Update all worktree references**:
   - Convert old root to a linked worktree (`.git` file pointing to new location)
   - Convert new root from linked worktree to having the actual `.git/` directory
   - Update all other worktrees' `.git` files to point to new location
   - Update `.git/worktrees/*/gitdir` files to reflect any path changes

### Post-conditions
- New root has the `.git/` directory
- Old root and all other worktrees have `.git` files pointing to new root
- All worktrees remain functional at their correct branches

---

## Implementation Details

### Language & Style
- **Bash** (`#!/usr/bin/env bash`)
- Follow existing patterns in `bin/` (see `git-recentco`, `git-chown` for reference)
- Use `set -e` for error handling
- Include usage documentation in comments

### Common Functions Needed
```bash
# Check if CWD is a worktree (has .git file) vs root (has .git directory)
is_worktree() { [[ -f .git ]]; }
is_root() { [[ -d .git ]]; }

# Get the main .git directory path
get_git_common_dir() { git rev-parse --git-common-dir; }

# Get this worktree's private git dir
get_git_dir() { git rev-parse --git-dir; }

# Check for uncommitted changes (excluding untracked)
has_uncommitted_changes() { ! git diff --quiet || ! git diff --cached --quiet; }
```

### Key Git Commands
- `git rev-parse --git-dir` - Get $GIT_DIR (per-worktree)
- `git rev-parse --git-common-dir` - Get shared repo location
- `git worktree list` - List all worktrees
- `git worktree remove` - Standard removal (not what we want, but reference)

### File Operations Required

#### For `git-worktree-disconnect`:
1. Read `.git` file to get gitdir path
2. Copy `.git/objects/`, `.git/refs/`, `.git/config`, etc.
3. Copy worktree-specific HEAD from `.git/worktrees/<id>/HEAD`
4. Remove `.git/worktrees/<id>/` from parent
5. Replace `.git` file with `.git/` directory

#### For `git-worktree-move-root`:
1. Move entire `.git/` directory to new location
2. Update each worktree's `.git` file content
3. Update each `.git/worktrees/*/gitdir` file
4. Create `.git` file at old root pointing to new location
5. Delete the worktree entry for the new root (it's now the main repo)

---

## Edge Cases & Safety

### Both Tools
- [ ] Handle spaces in paths
- [ ] Handle symlinks in paths
- [ ] Verify git repository before operating
- [ ] Check for locked worktrees

### `git-worktree-disconnect`
- [ ] Refuse if uncommitted changes (without --force)
- [ ] Handle case where worktree has local branches not pushed
- [ ] Preserve remote configuration
- [ ] Handle submodules (if any)

### `git-worktree-move-root`
- [ ] Atomic operation (or rollback on failure)
- [ ] Handle case where some worktrees are on different filesystems
- [ ] Preserve all worktree-specific state (bisect, rebase in progress, etc.)

---

## Testing Plan

### Test Setup
```bash
# Create test environment
mkdir /tmp/worktree-test && cd /tmp/worktree-test
mkdir main && cd main
git init && echo "init" > README && git add . && git commit -m "init"
git worktree add ../wt-a -b branch-a
git worktree add ../wt-b -b branch-b
git worktree add ../wt-next -b branch-next
```

### Test Cases for `git-worktree-disconnect`
1. Basic disconnect from clean worktree
2. Refuse disconnect with uncommitted changes
3. Force disconnect with uncommitted changes
4. Verify both repos work independently after disconnect
5. Verify parent no longer lists disconnected worktree

### Test Cases for `git-worktree-move-root`
1. Move root from main to wt-next (from-here-to-there mode)
2. Move root to current worktree (--to-here mode)
3. Verify all worktrees still function after move
4. Verify git operations work from each location

---

## Open Questions

1. **Naming**: Is `git-worktree-disconnect` the best name? Alternatives:
   - `git-worktree-detach`
   - `git-worktree-clone`
   - `git-worktree-standalone`

2. **Remote handling for disconnect**: Should the disconnected repo keep the same remotes, or should there be an option to set a different remote?

3. **Move-root atomicity**: How to handle partial failures during root move? Create backup first?

4. **Single tool vs two tools**: Should these be one tool with subcommands (`git-worktree-manage disconnect|move-root`) or separate tools?

---

## Unrelated TODOs (captured during this session)

- [ ] Fish shell barfs on `corepack enable` command (needed for yarn) when re-sourcing config

---

## Progress Tracker

- [x] Research git worktree internals
- [x] Analyze existing bin/ conventions
- [x] Create implementation plan
- [x] Implement `git-worktree-disconnect`
- [x] Test `git-worktree-disconnect`
- [x] Implement `git-worktree-move-root`
- [x] Test `git-worktree-move-root`
- [x] Add usage documentation (in script headers)

## Implementation Notes

### Key learnings during implementation:

1. **Worktree internal structure**: Each worktree needs these files in `.git/worktrees/<id>/`:
   - `HEAD` - the branch/ref this worktree is on
   - `gitdir` - path to the worktree's `.git` file
   - `commondir` - relative path from worktree entry to shared `.git/` (must be `../..`)
   - `index` - staging area for this worktree
   - `logs/` - reflog directory
   - `refs/` - per-worktree refs (bisect, etc.)

2. **macOS symlink gotcha**: `/tmp` is a symlink to `/private/tmp`. Use `pwd -P` to resolve symlinks and get consistent paths.

3. **git-worktree-disconnect** converts a linked worktree to standalone by:
   - Copying shared `.git/` contents (objects, refs, hooks, config)
   - Copying worktree-specific HEAD and index
   - Removing worktree entry from parent
   - Replacing `.git` file with `.git/` directory

4. **git-worktree-move-root** moves the root by:
   - Creating a worktree entry for the old root (with all required files including commondir)
   - Copying the new root's worktree HEAD to become the main HEAD
   - Removing the new root's worktree entry
   - Moving the `.git/` directory
   - Updating all `.git` files to point to new location
