if status is-interactive
    # ── path ─────────────────────────────────────────────────────────────────
    fish_add_path ~/.local/bin
    fish_add_path ~/.cargo/bin
    fish_add_path ~/.local/share/pnpm
    fish_add_path /usr/local/bin

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
    command -q starship; and starship init fish | source
    command -q zoxide; and zoxide init fish | source

    # carapace bridges completions from other shells; set before the init.
    set -gx CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
    command -q carapace; and carapace _carapace | source

    command -q fastfetch; and fastfetch
end

