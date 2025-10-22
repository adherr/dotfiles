# uniquify PATH
typeset -U -g PATH path
# add non-linked homebrew packages to override system packages
path=( $(brew --prefix)/opt/scala@2.13/bin $(brew --prefix)/opt/mysql-client/bin $(brew --prefix)/opt/curl/bin $(brew --prefix)/opt/make/libexec/gnubin $(brew --prefix)/opt/python/libexec/bin /Library/TeX/texbin $(brew --prefix)/bin $path )
# put in by packaging tools
path=( $path $HOME/.cargo/bin )
# windsurf
path=( $HOME/.codeium/windsurf/bin $path )
# my stuff
path=( $HOME/bin $HOME/.local/bin $path )
# asdf
export ASDF_DATA_DIR="$HOME/.asdf"
path=( ${ASDF_DATA_DIR:-$HOME/.asdf}/shims $path )

# Enable persistent history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Configure the push directory stack (most people don't need this)
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Emacs keybindings
bindkey -e
# Use the up and down keys to navigate the history
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward
# Use Ctrl+Left and Ctrl+Right to move by words

# Use 1password ssh-agent
export SSH_AUTH_SOCK=~/.1password/agent.sock
# this breaks things that try to load things into the agent automatically, like teleport
# luckily, at Roadie we don't really need those certs in the agent because they get added to the kube config
export TELEPORT_USE_LOCAL_SSH_AGENT=false

# 1Password CLI uses Touch ID
OP_BIOMETRIC_UNLOCK_ENABLED=true

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='emacs'
elif [[ $(uname) == "Darwin" ]]; then
  export EDITOR='emacs --no-desktop'
else
  export EDITOR='emacs -n'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# I expect emacs's concept of forward and backward word, make that happen here
bindkey -N aherr emacs
bindkey -M aherr "^[F" emacs-forward-word "^[f" emacs-forward-word
bindkey -M aherr "^[B" emacs-backward-word "^[b" emacs-backward-word
bindkey -A aherr main

export LESS='-R'
alias ls='ls --color=auto'

# Emacs aliases
alias en='emacsclient -n'
alias ec='emacsclient -c'
alias ecn='emacsclient -n -c'

# tmux
alias tmux='TERM=xterm-256color tmux'

# Ruby aliases
alias be='bundle exec'
alias git=hub

# docker aliases
alias drmi='docker rmi $(docker images -f dangling=true -q)'
alias drmc='docker rm $(docker ps -a -f status=exited -q)'
alias dc='docker compose'

# colorize commands as they are typed
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# shell options
setopt no_hup
setopt extended_glob

# Initialize completion
autoload -U compinit; compinit
# for scripts that use the bash `complete` function
autoload -U +X bashcompinit && bashcompinit

# iex
export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 2097152"

# Direnv
eval "$(direnv hook zsh)"

# iTerm2 on mac OS
# enable shell integration
source ~/.config/iterm2/iterm2_shell_integration.`basename $SHELL`

# starship prompt
eval "$(starship init zsh)"

# heroku autocomplete setup
HEROKU_AC_ZSH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Set up zoxide to move between folders efficiently
eval "$(zoxide init zsh)"
# suggested by bbatsov https://batsov.com/articles/2025/06/12/zoxide-tips-and-tricks/
alias cd='z'
alias j='z'
alias jj='zi'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
