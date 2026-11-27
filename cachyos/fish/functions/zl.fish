function zl --description 'Start or attach to the zellij session of a layout, or list the layouts with zl ls'
    argparse --min-args 1 --max-args 1 -- $argv; or return
    switch $argv[1]
        case ls
            __zl_list
        case '*'
            __zl_open $argv[1]
    end
end

function __zl_open --argument-names name
    ~/.config/scripts/zellij-layout-sessions $name; or return
    if set -q ZELLIJ
        zellij action switch-session $name
    else
        zellij attach $name
    end
end

function __zl_list
    set -l running (zellij list-sessions --no-formatting 2>/dev/null | string match -v '*EXITED*' | string replace -r ' \[Created .*' '')
    for name in (path basename -E ~/.config/zellij/layouts/*.kdl)
        if contains -- $name $running
            echo "$name (running)"
        else
            echo $name
        end
    end
end
