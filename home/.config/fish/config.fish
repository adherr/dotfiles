# Nix installer only patches /etc/zshrc /etc/bashrc, not fish; source its
# fish-native equivalent ourselves.
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

if status is-interactive
    fish_add_path -g $HOME/bin $HOME/.local/bin

    starship init fish | source
    direnv hook fish | source
    devenv hook fish | source
    mise activate fish | source
end
