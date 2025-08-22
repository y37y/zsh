# 🐚 Zsh Configuration

A fast, cross-platform zsh configuration with modern tools integration. Supports macOS (Intel & Apple Silicon) and Linux with **Homebrew-first approach** for latest tool versions.

## ✨ Features

- **🚀 Fast startup** (~50ms) with Zinit plugin manager
- **🎨 Modern prompt** with Starship
- **🔍 Smart search** with fzf and optional Atuin
- **📁 Enhanced navigation** with zoxide and eza
- **🎯 300+ aliases** for common tasks including comprehensive networking
- **🔧 Cross-platform** - auto-detects macOS/Linux with Homebrew preference
- **⚡ Syntax highlighting** and autosuggestions
- **🌐 Enhanced networking** aliases for development and system administration
- **🛠️ Smart tool detection** - only loads what's installed

## 🛠️ Quick Install

```bash
# Clone the repo
git clone https://github.com/y37y/zsh.git
cd zsh

# Run the installer (prioritizes Homebrew for latest versions)
./install.sh

# Start using it
exec zsh
```

## 📋 Prerequisites

### Recommended Installation Method
The installer **prioritizes Homebrew** for latest tool versions and cross-platform consistency:

```bash
# Homebrew is automatically installed by the installer
# Then essential tools are installed via Homebrew for latest versions:
# starship, bat, eza, fd, ripgrep, fzf, zoxide
```

### Manual Installation (Alternative)
```bash
# Install essential tools via Homebrew (recommended)
brew install starship bat eza fd ripgrep fzf zoxide

# Or on Linux via apt (older versions)
sudo apt install zsh bat fd-find ripgrep fzf
# Note: eza and zoxide may not be available via apt
```

### Optional Tools (Enhanced Experience)
```bash
# Better history (highly recommended)
brew install atuin

# Development tools
brew install direnv fnm lazygit gitleaks

# Networking tools (for enhanced aliases)
brew install nmap mtr
```

## 🍎 macOS Specific Setup

### Terminal Shell Configuration
macOS Terminal opens login shells by default, which only read `.zprofile` (not `.zshrc`). After installation, create a `.zprofile` file to source your `.zshrc`:

```bash
echo 'source ~/.zshrc' >> ~/.zprofile
```

## 🎯 Key Aliases & Shortcuts

### Navigation
```bash
..          # cd ..
...         # cd ../..
l           # ls with icons (eza)
ll          # long listing with icons
la          # ls -al with icons
```

### Git (Extensive - 25+ aliases)
```bash
g           # git
ga          # git add
gc          # git clone
gco         # git checkout
gcb         # git checkout -b (create new branch)
gst         # git status -sb
gp          # git push
gpl         # git pull
gm          # git commit -am
glog        # pretty git log with graph
glog1       # git log --oneline -10
gwho        # show current git user name and email
```

### Networking (NEW - 20+ aliases)
```bash
myip        # external IP address
localip     # local IP address
ips         # all network interfaces
ports       # show listening ports
portsx      # show ports with process info
dig8        # query Google DNS (8.8.8.8)
dig1        # query Cloudflare DNS (1.1.1.1)
dnstest     # test multiple DNS servers
checknet    # quick connectivity test
speedtest   # internet speed test
```

### Editor & Tools
```bash
v           # nvim
n           # nvim  
c           # cat (with bat syntax highlighting)
ez          # exec zsh (restart shell)
zr          # edit ~/.zshrc and reload
sz          # source ~/.zshrc (reload config)
```

### Navigation & Projects
```bash
proj        # cd ~/Projects
config      # cd ~/.config
```

### File Search (fzf integration)
```bash
ff          # find files (fd)
fp          # file picker with preview (fzf + bat)
fv          # find and edit in nvim
fcd         # find directory and cd into it
```

### Package Management (Cross-platform)
```bash
b           # brew
bp          # brew update and upgrade
up          # comprehensive system update (Homebrew + system)
# Linux: brew update && brew upgrade && apt update && apt upgrade
# macOS: brew update && brew upgrade && softwareupdate
```

### SSH & Config
```bash
vc          # edit ~/.ssh/config
va          # edit ~/.zshrc
sl          # ssh-add -l (list keys)
```

## 🔧 Cross-Platform Support

### Tool Installation Priority
1. **Homebrew** (latest versions, consistent across platforms)
2. **Manual install** (for tools like Starship, Atuin)
3. **System package manager** (apt/dnf - fallback only)

### Platform Detection
- **macOS Apple Silicon**: Uses `/opt/homebrew/`
- **macOS Intel**: Uses `/usr/local/`
- **Linux**: Uses `/home/linuxbrew/.linuxbrew/` if available
- **Auto-detection**: No manual configuration needed

### Tool Name Handling
Automatically handles different tool names across systems:
- `bat` vs `batcat`
- `fd` vs `fdfind`
- Creates symlinks when needed

## ⚙️ Customization

### Add Personal Aliases
Edit `.zshrc` or create `.zshrc.local`:

```bash
# ~/.zshrc.local - Personal additions (not tracked in git)
alias myalias='my command'
export MY_VAR='value'

# Add your specific SSH keys
ssh-add --apple-use-keychain ~/.ssh/id_ed25519_mykey 2>/dev/null
```

### Work-Specific Config
```bash
# ~/.zshrc.work - Work-specific additions
alias vpn='connect-to-work-vpn'
export WORK_ENV='production'
```

## 🚀 Performance

- **Startup time**: ~50ms
- **Plugin loading**: Turbo mode with Zinit
- **Tool detection**: Only loads what's installed
- **Smart initialization**: Conditional loading prevents errors

## 📁 What's Included

```
zsh/
├── .zshrc          # Main configuration (~400 lines)
├── install.sh      # Cross-platform installer with Homebrew preference
├── starship.toml   # Starship prompt configuration (optional)
└── README.md       # This file
```

## 🔄 Updating

### Update Configuration
```bash
# Update the config repository
cd ~/Projects/zsh
git pull

# Apply changes
cp .zshrc ~/.zshrc

# Reload shell
exec zsh
```

### Update Tools
```bash
# Update all tools (uses your 'up' alias)
up

# Or manually update Homebrew tools
brew update && brew upgrade
```

## 🌐 Networking Features

Enhanced networking aliases for developers and system administrators:

- **IP Management**: External/local IP detection, interface listing
- **DNS Testing**: Multiple DNS server testing, cache flushing
- **Port Monitoring**: Listen port detection, port testing
- **Performance Testing**: Speed tests, connectivity checks
- **Development**: Local HTTP server, SSL certificate checking

## 🎯 Why Homebrew First?

- **Latest versions**: Homebrew packages are more recent than system packages
- **Consistency**: Same tool versions across macOS and Linux
- **Better maintenance**: Homebrew packages are better maintained for development tools
- **Easy updates**: Single `brew upgrade` command
