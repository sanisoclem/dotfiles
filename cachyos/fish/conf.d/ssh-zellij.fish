if status is-interactive; and set -q SSH_TTY; and not set -q ZELLIJ; and command -q zellij
    ~/.config/scripts/zellij-reattach
end
