if status is-interactive
    # Commands to run in interactive sessions can go here 
    source "$HOME/.cargo/env.fish"

    fish_add_path ~/.cargo/bin
    fish_add_path /opt/homebrew/bin
    fish_add_path /usr/local/bin
    fish_add_path ~/.local/bin

    alias ls='eza --icons'
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias cat='bat'
    alias find='fd'
    alias grep='rg'

    set -Ux CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense' # optional
    carapace _carapace | source
    starship init fish | source
    zoxide init fish | source

    screenfetch
end

function nvimf
    set selected_file (fd --type f --hidden --exclude .git | fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    if test -n "$selected_file"
        nvim $selected_file
    end
end

function yy
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# pnpm
set -gx PNPM_HOME "/Users/mel/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
