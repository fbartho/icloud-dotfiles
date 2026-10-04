# Every zsh reads this file, including the non-interactive shells agents run, and
# .shell-common.sh sources it for bash. Keep it POSIX sh, silent, and fast.

# Rust
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
case ":$PATH:" in
	*":$CARGO_HOME/bin:"*) ;;
	*) export PATH="$CARGO_HOME/bin:$PATH" ;;
esac

# sccache; bin/setup-shell-symlinks copies these into the launchd plist, so rerun it after a change.
export SCCACHE_DIR="$HOME/.cache/sccache"
export SCCACHE_CACHE_SIZE=20G
export SCCACHE_IDLE_TIMEOUT=0
# An absolute path, since a login shell reads this file before Homebrew is on PATH.
# A RUSTC_WRAPPER the caller sets, even to empty, is kept.
if [ -z "${RUSTC_WRAPPER+set}" ]; then
	for _sccache in "$CARGO_HOME/bin/sccache" /opt/homebrew/bin/sccache /usr/local/bin/sccache "$(command -v sccache 2>/dev/null)"; do
		if [ -n "$_sccache" ] && [ -x "$_sccache" ]; then
			export RUSTC_WRAPPER="$_sccache"
			break
		fi
	done
	unset _sccache
fi

# JavaScript package caches
export npm_config_cache="$HOME/.cache/js/npm"
export BUN_INSTALL_CACHE_DIR="$HOME/.cache/js/bun"
# pnpm 11 and later; pnpm 9 and 10 read the same paths from config/pnpm/rc.
export pnpm_config_store_dir="$HOME/.cache/js/pnpm/store"
export pnpm_config_cache_dir="$HOME/.cache/js/pnpm/cache"
# Yarn caches are set in ~/.yarnrc (classic) and ~/.yarnrc.yml (Berry). Both Yarns read
# YARN_CACHE_FOLDER, and Yarn classic reads YARN_GLOBAL_FOLDER as its global-package
# folder, so neither is exported.
