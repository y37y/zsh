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

# --- Ensure user bins are on PATH early (needed for atuin, etc.) ---
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-$HOME/.rustup}"
export GOPATH="${GOPATH:-$HOME/go}"
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"

# Common local bins first so `command -v` works during init
for P in "$HOME/.atuin/bin" "$HOME/.local/bin" "$CARGO_HOME/bin" "$PNPM_HOME" "$GOPATH/bin" "/usr/local/go/bin"; do
  case ":$PATH:" in *":$P:"*) ;; *) PATH="$P:$PATH" ;; esac
done
export PATH

# Basic completion
autoload -Uz compinit
compinit

# Key bindings - choose one:
bindkey -e  # Emacs style (Ctrl+A/E for line start/end) - RECOMMENDED
# bindkey -vi  # Vim style (uncomment if you prefer vim keybindings)

# Atuin will handle history search if installed (direct init; no zinit race)
if command -v atuin >/dev/null; then
  eval "$(atuin init zsh)"
else
  bindkey '^R' history-incremental-search-backward
fi

# ============================================================================
# Zinit Installation and Setup
# ============================================================================

# Install zinit if not present
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
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

# XDG compliance extras
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export LESSHISTFILE="$XDG_DATA_HOME/lesshst"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"

# Create XDG directories if they don't exist
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# ============================================================================
# Tool Initializations (cross-platform)
# ============================================================================

# Homebrew - detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
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

# Modern tools (init via zinit where applicable; Atuin initialized earlier)
zinit wait lucid for \
    atinit"command -v zoxide >/dev/null && eval \"\$(zoxide init zsh --cmd cd)\"" \
        z-shell/null \
    atinit"command -v fzf >/dev/null && eval \"\$(fzf --zsh 2>/dev/null || echo '')\"" \
        z-shell/null \
    atinit"command -v direnv >/dev/null && eval \"\$(direnv hook zsh)\"" \
        z-shell/null

# fnm: ensure Node/npm are available on any shell (macOS + Linux)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

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
if [[ -n "$SSH_AUTH_SOCK" ]] && ! ssh-add -l >/dev/null 2>&1; then
    if [[ -z "$SSH_KEYS_LOADED" ]]; then
        for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa; do
            if [[ -f "$key" ]]; then
                ssh-add --apple-use-keychain "$key" 2>/dev/null || ssh-add "$key" 2>/dev/null
            fi
        done
        export SSH_KEYS_LOADED=1
    fi
fi

# ============================================================================
# Cross-platform tool aliases
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
    alias la='eza -la --group-directories-first --icons --color=auto -h'
    alias l='eza --group-directories-first --icons --color=auto'
    alias lt='eza --tree --level=2 --long --icons --git'
else
    alias ll='ls -lh'
    alias la='ls -alh'
    alias l='ls --color=auto'
fi

# bat/batcat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat >/dev/null; then
    alias cat='batcat --style=plain --paging=never'
    alias bat='batcat'
fi

# fd/fdfind
if command -v fd >/dev/null; then
    alias find='fd'
elif command -v fdfind >/dev/null; then
    alias find='fdfind'
    alias fd='fdfind'
fi

# ripgrep
command -v rg >/dev/null && alias grep='rg'

# Go aliases
alias gob='go build'
alias goc='go clean'
alias got='go test'
alias gor='go run'
alias goi='go install'
alias gom='go mod tidy'

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gp='git push'
alias gc='git clone'
alias gm='git commit -am'
alias gch='git checkout'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gst='git status -sb'
alias gstsh='git stash'
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

# System management
alias df='df -h'
alias du='du -h'
alias ping='ping -c 4'
alias pg='ping google.com'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias free='free -h'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    :  # placeholder
fi

# Package management
alias b='brew'
alias bp='brew -v update; brew upgrade --force-bottle; brew upgrade; brew cleanup; brew doctor'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias ai='sudo apt install'
    alias up='brew update && brew upgrade && sudo apt update && sudo apt upgrade -y && rustup update'
elif [[ "$OSTYPE" == "darwin"* ]]; then
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
alias va='nvim ~/.zshrc'
alias c='cat'
alias tl='tldr'
alias cl='clear'
alias e='exit'
alias ez='exec zsh'

# Config management
alias zr='v ~/.zshrc && ez'
alias sz='source ~/.zshrc'
alias zp='cp ~/.zshrc ~/Projects/zsh/.zshrc'

# Project navigation
alias proj='cd ~/Projects'
alias config='cd ~/.config'

# File searching with fzf
alias ff='fd --type f --hidden --exclude .git --exclude node_modules'
alias fp='fd --type f --hidden | fzf --preview "bat --style=numbers --color=always {}"'
alias fv='fd --type f --hidden | fzf | xargs -r nvim'
alias fcd='fd --type d --hidden | fzf | xargs -r cd'

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

# Network and system - Enhanced networking aliases
alias ts='tailscale status'
alias tai='tailscale'
alias zs='sudo zerotier-cli status'
alias zt='sudo zerotier-cli'

# ============================================================================
# Enhanced Networking Aliases
# ============================================================================

# Basic network info
alias myip='curl -s ipinfo.io/ip'
alias myipv='curl -s ipinfo.io'

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias localip='hostname -I | awk "{print \$1}"'
    alias ips='ip addr show | grep "inet " | grep -v 127.0.0.1'
    alias ipa='ip addr show'
    alias iproute='ip route show'
    alias ports='ss -tuln | grep LISTEN'
    alias portsx='sudo ss -tulpn'
    alias flushdns='sudo systemd-resolve --flush-caches && echo "DNS cache flushed"'
    alias dnsinfo='systemd-resolve --status'
    alias netrestart='sudo systemctl restart NetworkManager'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    alias localip='ipconfig getifaddr en0'
    alias ips='ifconfig | grep "inet " | grep -v 127.0.0.1'
    alias ipa='ifconfig'
    alias iproute='netstat -rn'
    alias ports='netstat -an | grep LISTEN'
    alias portsx='sudo lsof -i -P | grep LISTEN'
    alias flushdns='sudo dscacheutil -flushcache && echo "DNS cache flushed"'
    alias dnsinfo='scutil --dns'
    alias netrestart='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
fi

# DNS queries and testing
alias dig8='dig @8.8.8.8'
alias dig1='dig @1.1.1.1'
alias dnstest='dig google.com @8.8.8.8 && dig google.com @1.1.1.1'

# Enhanced connectivity testing
alias p1='ping 1.1.1.1'
alias p8='ping 8.8.8.8'
alias pc='ping cloudflare.com'
alias pingt='ping -c 4'

# Port and service testing
alias portcheck='nc -zv'
alias listening='sudo lsof -i -P | grep LISTEN'

# HTTP testing
alias header='curl -I'
alias httpcode='curl -s -o /dev/null -w "%{http_code}"'

# Speed and performance testing
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3'
alias checknet='ping -c 1 8.8.8.8 >/dev/null 2>&1 && echo "Internet: ✓" || echo "Internet: ✗"'

# Simple web server
alias serve='python3 -m http.server 8000'

# SSL/Certificate testing
alias sslcheck='openssl s_client -connect'

# Host file management
alias ch='cat /etc/hosts'
alias vh='sudo nvim /etc/hosts'
alias cc='cat ~/.ssh/config'
alias vc='nvim ~/.ssh/config'

# ============================================================================
# Functions
# ============================================================================

# Magic enter - runs smart commands on empty Enter press
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
# Performance optimizations
# ============================================================================

# Disable some slow features for better performance
skip_global_compinit=1

# ============================================================================
# Load local customizations
# ============================================================================

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
[[ -f ~/.zshrc.work  ]] && source ~/.zshrc.work

# ============================================================================
# Platform-specific final adjustments
# ============================================================================

# (Already ensured early) Keep ~/.local/bin in PATH even if modified later
for P in "$HOME/.local/bin" ; do
  case ":$PATH:" in *":$P:"*) ;; *) PATH="$P:$PATH" ;; esac
done
export PATH

