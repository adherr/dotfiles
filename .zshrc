# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# uniquify PATH
typeset -U -g PATH path
# add non-linked homebrew packages to override system packages
path=( $HOME/bin /usr/local/opt/mysql-client/bin /usr/local/opt/curl/bin /usr/local/opt/make/libexec/gnubin /usr/local/opt/python/libexec/bin /Library/TeX/texbin /usr/local/bin $path )
# put in by packaging tools
path=( $path $HOME/.local/bin $HOME/.cargo/bin )
fpath=(/Users/aherr/.oh-my-zsh/custom/completions $fpath)

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(docker docker-compose git mix ruby rails)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Use 1password ssh-agent
export SSH_AUTH_SOCK=~/.1password/agent.sock
# this breaks things that try to load things into the agent automatically, like teleport
# luckily, at Roadie we don't really need those certs in the agent because they get added to the kube config
export TELEPORT_USE_LOCAL_SSH_AGENT=false

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='emacs'
else
  export EDITOR='emacs -n'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# I expect emacs's concept of forward and backward word, make that happen here
bindkey -N aherr emacs
bindkey -M aherr "^[F" emacs-forward-word "^[f" emacs-forward-word
bindkey -M aherr "^[B" emacs-backward-word "^[b" emacs-backward-word
bindkey -A aherr main

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Emacs aliases
alias en='emacsclient -n'
alias ec='emacsclient -c'
alias ecn='emacsclient -n -c'

# tmux
alias tmux='TERM=xterm-256color tmux'

# Ruby aliases
#unalias rg # because ripgrep is more useful than rails generate
alias bundle='nocorrect bundle'
alias be='bundle exec'
alias git=hub

# chef
alias knife='nocorrect knife'

# docker aliases
alias drmi='docker rmi $(docker images -f dangling=true -q)'
alias drmc='docker rm $(docker ps -a -f status=exited -q)'

# colorize commands as they are typed
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# shell options
unsetopt share_history
unsetopt correct_all
setopt no_hup
setopt extended_glob

# for scripts that use the bash `complete` function
autoload -U +X bashcompinit && bashcompinit

# iex
export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 2097152"

# Direnv
eval "$(direnv hook zsh)"

# iTerm2 on mac OS
# enable shell integration
source ~/.config/iterm2/iterm2_shell_integration.`basename $SHELL`

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
ZLE_RPROMPT_INDENT=0
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# heroku autocomplete setup
HEROKU_AC_ZSH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;

# 1Password CLI uses Touch ID
OP_BIOMETRIC_UNLOCK_ENABLED=true
