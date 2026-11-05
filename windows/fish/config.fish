# CachyOS ships its own fish config (pacman aliases, `done` notifications, a
# bat-backed MANPAGER, a `pure` prompt). Keep it as the base and layer on top —
# the bits below deliberately override its ls/la/ll aliases and its greeting.
source /usr/share/cachyos-fish-config/cachyos-config.fish

# That file defines fish_greeting eagerly, which shadows functions/fish_greeting.fish
# (autoloading only fires for functions that aren't already defined). Erase it so ours
# is picked up — otherwise fastfetch runs twice, once here and once as the greeting.
functions --erase fish_greeting

if status is-interactive
    # ── path ─────────────────────────────────────────────────────────────────
    fish_add_path ~/.local/bin
    fish_add_path ~/.cargo/bin
    fish_add_path ~/go/bin
    fish_add_path ~/.local/share/pnpm
    fish_add_path /usr/local/bin
    fish_add_path /home/mel/.dotnet/tools

    # ── modern replacements ──────────────────────────────────────────────────
    if command -q eza
        alias ls 'eza --icons'
        alias ll 'eza -l --icons --git'
        alias la 'eza -la --icons --git'
    end
    command -q bat; and alias cat bat
    command -q fd; and alias find fd
    command -q rg; and alias grep rg

    # ── ccr tools ────────────────────────────────────────────────────────────
    # These reach internal hosts, so they always go through the SOCKS proxy.
    # `command cdt` (or sst, ccrutils) still runs one directly.
    if command -q proxychains4
        alias cdt 'proxychains4 -q cdt'
        alias sst 'proxychains4 -q sst'
        alias ccr 'source ~/.config/fish/ccr.fish'
        alias ccrutils 'proxychains4 -q ccrutils'
        alias ccr-kubectl 'env HTTPS_PROXY=socks5://127.0.0.1:1080 kubectl'
        alias ccr-k9s 'env HTTPS_PROXY=socks5://127.0.0.1:1080 k9s'
    end

    alias task go-task

    # ── prompt, jumps, completions ───────────────────────────────────────────
    # starship replaces the `pure` prompt CachyOS sets up above.
    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source

    # carapace bridges completions from other shells; set before the init.
    set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
    command -q carapace; and carapace _carapace | source
    set -gx EDITOR nvim

    set -gx GPG_TTY (tty)

    # atuin takes over ctrl-r with searchable, per-directory shell history.
    # Add --disable-up-arrow if you want Up to stay fish's own history.
    command -q atuin; and atuin init fish | source

    command -q fastfetch; and fastfetch
end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# opencode
fish_add_path /home/mel/.opencode/bin
