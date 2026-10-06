# Nix installer only patches /etc/zshrc /etc/bashrc, not fish; source its
# fish-native equivalent ourselves.
if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
end

set -g fish_greeting

# settings.json env values don't expand ~/$HOME, so this can't live there
set -gx CLAUDE_CODE_TMPDIR $HOME/src/claude-tmp

# Default autosuggestion color is too close to normal text brightness to read
# as "ghost text" (looks like it's already typed). Dim it to base16 Tomorrow's
# base03 (comment color, matches Ghostty's `theme = Tomorrow`) and italicize.
set -g fish_color_autosuggestion 969896 --italics

if status is-interactive
    fish_add_path -g $HOME/bin $HOME/.local/bin $HOME/.docker/bin

    set -l op_sock ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
    if test -S $op_sock
        set -gx SSH_AUTH_SOCK $op_sock
    else
        ssh-add -l >/dev/null 2>&1; or ssh-add --apple-load-keychain -q 2>/dev/null
    end

    starship init fish | source
    type -q direnv; and direnv hook fish | source
    type -q devenv; and devenv hook fish | source
    mise activate fish | source
    zoxide init fish --cmd cd | source
    fzf --fish | source

    function e
        set -q argv[1]; or set argv .
        if string match -qr '^ghostel(,|$)' -- "$INSIDE_EMACS"
            for f in $argv
                ghostel_cmd find-file-other-window (path resolve -- $f)
            end
        else
            emacsclient -n $argv
        end
    end
end
