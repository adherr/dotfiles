# Nix installer only patches /etc/zshrc /etc/bashrc, not fish; source its
# fish-native equivalent ourselves.
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

set -g fish_greeting

# Default autosuggestion color is too close to normal text brightness to read
# as "ghost text" (looks like it's already typed). Dim it to base16 Tomorrow's
# base03 (comment color, matches Ghostty's `theme = Tomorrow`) and italicize.
set -g fish_color_autosuggestion 969896 --italics

if status is-interactive
    fish_add_path -g $HOME/bin $HOME/.local/bin $HOME/.docker/bin

    starship init fish | source
    type -q direnv; and direnv hook fish | source
    type -q devenv; and devenv hook fish | source
    mise activate fish | source
    zoxide init fish --cmd cd | source
    fzf --fish | source
end
