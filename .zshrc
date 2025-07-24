# ~/.zshrc - Fast zinit-powered config migrated from fish

# ============================================================================
# Basic zsh configuration
# ============================================================================

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS
setopt HIST_VERIFY HIST_EXPIRE_DUPS_FIRST

# Basic completion
autoload -Uz compinit
compinit

# Key bindings - choose one:
bindkey -e  # Emacs style (Ctrl+A/E for line start/end) - RECOMMENDED
# bindkey -vi  # Vim style (uncomment if you prefer vim keybindings)

# Atuin will handle history search if installed
if ! command -v atuin >/dev/null; then
    bindkey '^R' history-incremental-search-backward
fi

# ============================================================================
# Zinit Installation and Setup
# ============================================================================

# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# Zinit Plugins (fast loading)
# ============================================================================

# Essential plugins with turbo mode (loads after prompt)
zinit wait lucid for \
    atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
        zdharma-continuum/fast-syntax-highlighting \
    atload"!_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf \
        zsh-users/zsh-completions

# Additional useful plugins
zinit wait lucid for \
    OMZL::git.zsh \
    OMZP::git \
    OMZP::extract \
    agkozak/zsh-z

# Load starship theme
zinit ice as"command" from"gh-r" \
    atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
    atpull"%atclone" src"init.zsh"
zinit light starship/starship

# ============================================================================
# Environment Variables (from your env.fish)
# ============================================================================

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Create XDG directories if they don't exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# Editor and pager
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# OS-specific browser
if [[ "$OSTYPE" == "darwin"* ]]; then
    export BROWSER="open"  # macOS
else
    export BROWSER="xdg-open"  # Linux
fi

# Colorized man pages (from your env.fish)
export LESS_TERMCAP_mb=$'\e[1;34m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\e[47;30m'    # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\e[1;35m'     # begin underline
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

# XDG compliance
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="$XDG_DATA_HOME/lesshst"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"

# ============================================================================
# Tool Initializations (cross-platform)
# ============================================================================

# Homebrew - detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        # Apple Silicon
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - check for Linuxbrew
    if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
fi

# Set Homebrew analytics preference if brew is available
command -v brew >/dev/null && export HOMEBREW_NO_ANALYTICS=1

# Modern tools (loaded with zinit turbo mode - only if installed)
zinit wait lucid for \
    atinit"command -v zoxide >/dev/null && eval \"\$(zoxide init zsh)\"" \
        z-shell/null \
    atinit"command -v fzf >/dev/null && eval \"\$(fzf --zsh)\"" \
        z-shell/null \
    atinit"command -v direnv >/dev/null && eval \"\$(direnv hook zsh)\"" \
        z-shell/null \
    atinit"command -v atuin >/dev/null && eval \"\$(atuin init zsh)\"" \
        z-shell/null \
    atinit"command -v fnm >/dev/null && eval \"\$(fnm env --use-on-cd)\"" \
        z-shell/null

# ============================================================================
# SSH Agent Setup - Generic and Secure
# ============================================================================

# SSH agent initialization (only if no agent running)
if [[ -z "$SSH_AUTH_SOCK" ]]; then
    # Check for existing agent
    if [[ -f ~/.ssh/agent.env ]]; then
        source ~/.ssh/agent.env >/dev/null
    fi
    
    # Start agent if not running
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        ssh-agent > ~/.ssh/agent.env
        source ~/.ssh/agent.env >/dev/null
    fi
fi

# Auto-load SSH keys (only once per session)
# This will try to load common key names - customize in ~/.zshrc.local
if [[ -n "$SSH_AUTH_SOCK" ]] && ! ssh-add -l >/dev/null 2>&1; then
    if [[ -z "$SSH_KEYS_LOADED" ]]; then
        # Try to load common SSH key names
        for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa; do
            if [[ -f "$key" ]]; then
                ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key" 2>/dev/null
            fi
        done
        export SSH_KEYS_LOADED=1
    fi
fi

# ============================================================================
# Aliases (converted from your fish abbreviations)
# ============================================================================

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias h='cd ~'
alias p='pwd'

# File operations  
alias mv='mv -v'
alias rm='rm -v -i'
alias rmf='rm -v -i -rf'
alias cp='cp -v -i'
alias mkdir='mkdir -p'
alias m='mkdir -p'
alias cx='chmod +x'

# Modern replacements
if command -v eza >/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --group-directories-first --icons --color=auto -h'
    alias la='ls -al'  # Keep traditional ls -al as requested
    alias l='eza --group-directories-first --icons --color=auto'
    alias lt='eza --tree --level=2 --long --icons --git'
else
    alias ll='ls -lh'
    alias la='ls -al'  # Traditional ls -al
    alias l='ls --color=auto'
fi

command -v bat >/dev/null && alias cat='bat --style=plain --paging=never'
command -v rg >/dev/null && alias grep='rg'
command -v fd >/dev/null && alias find='fd'

# Git aliases (your extensive git abbreviations)
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gp='git push'
alias gf='git push forgejo'
alias gpf='git push origin && git push forgejo'
alias gff='git fetch forgejo'
alias gc='git clone'
alias gm='git commit -am'
alias gch='git checkout'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git status -sb'
alias gpl='git pull'
alias gps='git pull --recurse-submodules'
alias gfe='git fetch'
alias gre='git remote -v'
alias gsh='git stash'
alias grm='git rm'
alias glg='git log'
alias glog1='git log --oneline -10'
alias gdf='git diff'
alias gd='gitleaks detect'
alias gn='git config user.name'
alias ge='git config user.email'
alias gwho='echo "user.name: $(git config user.name)" && echo "user.email: $(git config user.email)"'
alias gpristine='git reset --hard && git clean -fdx'
alias glog='git log --graph --pretty=format:"%C(auto)%h%d %s %C(green)%cr %C(bold blue)<%an>%Creset"'

# SSH aliases
alias s='ssh'
alias sa='ssh-add'
alias sl='ssh-add -l'
alias sd='ssh-add -D'
alias sk='ssh-keygen -t ed25519 -C'
alias sg='ssh-keygen -t ed25519 -C'
alias ssha='eval $(ssh-agent)'
alias ssht='ssh -T git@github.com'

# System management (cross-platform)
alias df='df -h'
alias du='du -h'
alias ping='ping -c 4'

# Platform-specific aliases
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux-specific
    alias free='free -h'
    alias ports='netstat -tulpn | grep LISTEN'
    alias ips='ip addr show | grep "inet "'
    alias flushdns='sudo systemd-resolve --flush-caches'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific  
    alias ports='netstat -an | grep LISTEN'
    alias ips='ifconfig | grep "inet "'
    alias flushdns='sudo dscacheutil -flushcache'
fi

alias pg='ping google.com'

# Package management
alias b='brew'
alias bp='brew -v update; brew upgrade --force-bottle; brew upgrade; brew cleanup; brew doctor'

# Platform-specific package updates
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - comprehensive system update
    alias ai='sudo apt install'
    alias up='sudo apt update && sudo apt upgrade -y && brew update && brew upgrade && rustup update'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - brew and system updates
    alias up='brew update && brew upgrade && brew cleanup && softwareupdate --install --recommended'
fi
alias ni='npm install'
alias yi='yarn install'
alias yd='yarn dev'
alias bi='bun install'
alias pi='pnpm install'
alias pa='pnpm add'
alias pb='pnpm build'
alias pd='pnpm dev'

# Tmux
alias t='tmux'
alias tt='tmux attach'
alias tad='tmux attach -d'
alias tl='tmux list-sessions'
alias tk='tmux kill-server'
alias tks='tmux kill-session -t'
alias tr='tmux source-file ~/.config/tmux/tmux.conf'
alias tn='tmux new -s $(basename $PWD)'

# Editor and tools
alias v='nvim'
alias n='nvim'
alias va='nvim ~/.zshrc'  # Edit zsh config instead of fish
alias c='cat'
alias tl='tldr'
alias cl='clear'
alias e='exit'
alias ez='exec zsh'  # Restart zsh

# Config management
alias zr='v ~/.zshrc && ez'  # Edit and reload zsh config
alias sr='source ~/.zshrc'   # Just reload without editing

# Project navigation
alias proj='cd ~/Projects'
alias config='cd ~/.config'

# File searching with fzf
alias ff='fd --type f --hidden --exclude .git --exclude node_modules'
alias fp='fd --type f --hidden | fzf --preview "bat --style=numbers --color=always {}"'
alias fv='fd --type f --hidden | fzf | xargs -r nvim'
alias fcd='fd --type d --hidden | fzf | xargs -r cd'
# Note: fh removed since atuin handles history search

# Chezmoi
alias che='chezmoi'
alias ca='chezmoi apply'
alias cs='chezmoi status'
alias cdf='chezmoi diff | bat --paging=always --language=diff'
alias cad='chezmoi add'

# VPN (AdGuard)
alias ad='adguardvpn-cli'
alias ads='adguardvpn-cli status'
alias adc='adguardvpn-cli connect -l'
alias add='adguardvpn-cli disconnect'
alias adloc='adguardvpn-cli list-locations'

# Process management
alias psa='ps aux'
alias psr='ps aux | rg'
alias k9='kill -9'
alias pk='pkill -f'

# Misc utilities
alias dt='date +%Y-%m-%d.%H:%M:%S'
alias where='which'
alias disks='df -P -kHl'
alias yz='yazi'

# Network and system
alias ts='tailscale status'
alias tai='tailscale'
alias zs='sudo zerotier-cli status'
alias zt='sudo zerotier-cli'

# Host file management
alias ch='cat /etc/hosts'
alias vh='sudo nvim /etc/hosts'
alias cc='cat ~/.ssh/config'
alias vc='nvim ~/.ssh/config'

# ============================================================================
# Functions (optional - remove if you don't want them)
# ============================================================================

# No functions needed here since you have aliases for .. etc.

# Magic enter - runs smart commands on empty Enter press
# Remove this entire section if you don't want this feature
magic-enter() {
    if [[ -z $BUFFER ]]; then
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            echo "📁 Git status:"
            git status --short
        else
            echo "📁 Directory contents:"
            ls
        fi
    fi
    zle accept-line
}
zle -N magic-enter
bindkey '^M' magic-enter
# End of magic-enter (comment out lines above if you don't want this)

# ============================================================================
# Zinit Completions and Theme
# ============================================================================

# Load completions
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Advanced completion settings  
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# ============================================================================
# Load local customizations
# ============================================================================

# Load machine-specific config if it exists
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Load work-specific config if it exists  
[[ -f ~/.zshrc.work ]] && source ~/.zshrc.work
