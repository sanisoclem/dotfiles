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

    # ── prompt, jumps, completions ───────────────────────────────────────────
    # starship replaces the `pure` prompt CachyOS sets up above.
    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source

    # carapace bridges completions from other shells; set before the init.
    set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
    command -q carapace; and carapace _carapace | source

    # atuin takes over ctrl-r with searchable, per-directory shell history.
    # Add --disable-up-arrow if you want Up to stay fish's own history.
    command -q atuin; and atuin init fish | source

    command -q fastfetch; and fastfetch
end
