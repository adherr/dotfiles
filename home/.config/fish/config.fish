if status is-interactive
    fish_add_path -g $HOME/bin $HOME/.local/bin

    starship init fish | source
end
