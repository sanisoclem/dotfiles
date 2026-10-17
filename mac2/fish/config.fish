/opt/homebrew/bin/brew shellenv fish | source

if status is-interactive
    # ── path ─────────────────────────────────────────────────────────────────
    fish_add_path ~/.local/bin
    fish_add_path ~/.cargo/bin
    fish_add_path /opt/homebrew/opt/rustup/bin
    fish_add_path ~/go/bin
    fish_add_path ~/.local/share/pnpm
    fish_add_path /usr/local/bin
    fish_add_path ~/.dotnet/tools

    # ── modern replacements ──────────────────────────────────────────────────
    if command -q eza
        alias ls 'eza --icons'
        alias ll 'eza -l --icons --git'
        alias la 'eza -la --icons --git'
    end
    command -q bat; and alias cat bat
    command -q fd; and alias find fd
    command -q rg; and alias grep rg

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
fish_add_path ~/.opencode/bin
