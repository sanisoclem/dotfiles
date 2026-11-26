function tmux-reattach --description 'Attach to the most recently used detached tmux session, or create one'
    set -l session (__tmux_reattach_detached_sessions_by_recent_use)[1]
    if set -q session[1]
        tmux attach-session -t $session
    else
        tmux new-session
    end
end

function __tmux_reattach_detached_sessions_by_recent_use
    tmux list-sessions -f '#{==:#{session_attached},0}' -F '#{session_activity} #{session_id}' 2>/dev/null | sort -rn | string split -f2 ' '
end
