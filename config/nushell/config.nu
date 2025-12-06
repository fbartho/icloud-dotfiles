# config.nu - Nushell configuration

# Minimal prompt for AI agents
if ($env.AI_AGENT? | is-not-empty) {
    $env.PROMPT_COMMAND = {|| "$ " }
    $env.PROMPT_COMMAND_RIGHT = {|| "" }
}

# Shell configuration
$env.config.show_banner = false
$env.config.edit_mode = "emacs"
$env.config.history.max_size = 10000
$env.config.history.sync_on_enter = true
$env.config.history.file_format = "sqlite"
$env.config.completions.case_sensitive = false
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.algorithm = "fuzzy"
$env.config.cursor_shape.emacs = "line"
$env.config.cursor_shape.vi_insert = "line"
$env.config.cursor_shape.vi_normal = "block"

# Load aliases
source ~/.aliases.nu
