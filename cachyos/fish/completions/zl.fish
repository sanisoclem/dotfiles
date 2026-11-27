complete -c zl -f
complete -c zl -n __fish_is_first_arg -a ls -d 'List the layouts'
complete -c zl -n __fish_is_first_arg -a '(path basename -E ~/.config/zellij/layouts/*.kdl)'
