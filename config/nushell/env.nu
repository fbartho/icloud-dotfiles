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
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.bin")
$env.PATH = ($env.PATH | prepend $"($env.HOME)/.local/bin")
$env.PATH = ($env.PATH | prepend "/usr/local/sbin")

# Rust/Cargo
if ($"($env.HOME)/.cargo/bin" | path exists) {
    $env.PATH = ($env.PATH | prepend $"($env.HOME)/.cargo/bin")
}


# Starship prompt
source ~/.cache/starship/init.nu
