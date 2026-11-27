function zellij-attach-or-create --description 'Attach to the newest zellij session nothing is attached to, or create one'
    set -l session (__zellij_attach_or_create_detached_sessions)[-1]
    if set -q session[1]
        zellij attach $session
    else
        zellij
    end
end

function __zellij_attach_or_create_detached_sessions
    for session in (__zellij_attach_or_create_running_sessions)
        __zellij_attach_or_create_has_clients $session; or echo $session
    end
end

function __zellij_attach_or_create_running_sessions
    zellij list-sessions --no-formatting 2>/dev/null | string match -v '*(EXITED*' | string split -f1 ' '
end

function __zellij_attach_or_create_has_clients --argument-names session
    test (count (zellij --session $session action list-clients 2>/dev/null)) -gt 1
end
