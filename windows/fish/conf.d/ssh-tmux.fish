if status is-interactive; and set -q SSH_TTY; and not set -q TMUX; and command -q tmux
    tmux-attach-or-create
end
