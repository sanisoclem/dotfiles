function tmux-attach-or-create --description 'Attach to the most recently used tmux session this machine is not attached to, or create one'
    set -l session (__tmux_attach_or_create_sessions_free_here)[1]
    if set -q session[1]
        tmux attach-session -t $session
    else
        tmux new-session
    end
end

function __tmux_attach_or_create_sessions_free_here
    set -l attached_here (__tmux_attach_or_create_sessions_attached_here)
    for session in (__tmux_attach_or_create_sessions_by_recent_use)
        contains -- $session $attached_here; or echo $session
    end
end

function __tmux_attach_or_create_sessions_attached_here
    set -l here (__tmux_attach_or_create_ssh_client_address $fish_pid)
    tmux list-clients -F '#{client_pid} #{session_id}' 2>/dev/null | while read -l pid session
        test "$(__tmux_attach_or_create_ssh_client_address $pid)" = "$here"; and echo $session
    end
end

function __tmux_attach_or_create_sessions_by_recent_use
    tmux list-sessions -F '#{session_activity} #{session_id}' 2>/dev/null | sort -rn | string split -f2 ' '
end

function __tmux_attach_or_create_ssh_client_address --argument-names pid
    string split0 <? /proc/$pid/environ | string replace -rf '^SSH_CONNECTION=(\S+) .*' '$1'
end
