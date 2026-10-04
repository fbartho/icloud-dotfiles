# env.nu - Nushell environment configuration
# Nushell-native translation of .shell-common.sh

# Detect AI agents and set unified variable
if ($env.CLAUDECODE? | is-not-empty) or ($env.GEMINI_CLI? | is-not-empty) or ($env.CURSOR_TRACE_ID? | is-not-empty) or ($env.AIDER? | is-not-empty) {
    $env.AI_AGENT = "1"
}

# Random shell prompt emoji (used by starship)
let shell_prompts = [
    '$' '☀' '⭐'
    '🍀' '🌎' '⛄' '🌊' '💩' '🔥'
    '🍺' '🥟' '🥘' '🍛' '🍣' '🍹'
    '🚀' '🌙' '✨' '🪐' '☄️' '💫'
    '🌸' '🌵' '🍄' '🌴' '🦋' '🌈'
    '🦊' '🐙' '🦉' '🐢' '🐳' '🦎'
    '⚡' '💎' '🎯' '🔮' '🎲' '⚓'
    '👾' '🤖' '👻' '🎃' '🍕' '🌮'
]
$env.SHELL_EMOJI = ($shell_prompts | get (random int 0..($shell_prompts | length | $in - 1)))

# Homebrew (Apple Silicon)
$env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")
$env.PATH = ($env.PATH | prepend "/opt/homebrew/sbin")
$env.HOMEBREW_PREFIX = "/opt/homebrew"
$env.HOMEBREW_CELLAR = "/opt/homebrew/Cellar"
$env.HOMEBREW_REPOSITORY = "/opt/homebrew"

# Core environment variables
$env.EDITOR = "emacs"
$env.CODE_DIR = $"($env.HOME)/Code"
$env.ICLOUD_DRIVE = $"($env.HOME)/.icloud-drive"
$env.GPG_TTY = (do { ^tty } | complete | get stdout | str trim)

# NVM directory (nvm doesn't support nushell natively)
$env.NVM_DIR = $"($env.HOME)/.nvm"

# PATH additions
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.ebrain-vault/.scripts/bin")
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.bin")
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")
$env.PATH = ($env.PATH | prepend "/usr/local/sbin")

# Rust/Cargo
$env.CARGO_HOME = $"($env.HOME)/.cargo"
$env.RUSTUP_HOME = $"($env.HOME)/.rustup"
if ($"($env.CARGO_HOME)/bin" | path exists) {
    $env.PATH = ($env.PATH | prepend $"($env.CARGO_HOME)/bin")
}

# sccache
$env.SCCACHE_DIR = $"($env.HOME)/.cache/sccache"
$env.SCCACHE_CACHE_SIZE = "20G"
$env.SCCACHE_IDLE_TIMEOUT = "0"
# A RUSTC_WRAPPER the caller sets, even to empty, is kept.
if ($env.RUSTC_WRAPPER? == null) {
    let sccache = ([$"($env.CARGO_HOME)/bin/sccache" "/opt/homebrew/bin/sccache" "/usr/local/bin/sccache"] | where { path exists } | first 1)
    if ($sccache | is-not-empty) {
        $env.RUSTC_WRAPPER = ($sccache | first)
    }
}

# JavaScript package caches
$env.npm_config_cache = $"($env.HOME)/.cache/js/npm"
$env.BUN_INSTALL_CACHE_DIR = $"($env.HOME)/.cache/js/bun"
$env.pnpm_config_store_dir = $"($env.HOME)/.cache/js/pnpm/store"
$env.pnpm_config_cache_dir = $"($env.HOME)/.cache/js/pnpm/cache"


# Starship prompt
source ~/.cache/starship/init.nu
