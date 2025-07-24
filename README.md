# 🐚 Zsh Configuration

A fast, cross-platform zsh configuration with modern tools integration. Supports macOS (Intel & Apple Silicon) and Linux.

## ✨ Features

- **🚀 Fast startup** (~50ms) with Zinit plugin manager
- **🎨 Modern prompt** with Starship
- **🔍 Smart search** with fzf and optional Atuin
- **📁 Enhanced navigation** with zoxide and eza
- **🎯 200+ aliases** for common tasks
- **🔧 Cross-platform** - auto-detects macOS/Linux
- **⚡ Syntax highlighting** and autosuggestions

## 🛠️ Quick Install

```bash
# Clone the repo
git clone https://github.com/y37y/zsh.git
cd zsh

# Run the installer
./install.sh

# Start using it
exec zsh
```

## 📋 Prerequisites

### Core Tools (Required)
```bash
# Install zsh (if not already installed)
# macOS: Already installed
# Linux: sudo apt install zsh

# Install essential tools
brew install starship bat eza fd ripgrep fzf zoxide
# or on Linux without homebrew:
# sudo apt install fd-find ripgrep fzf
```

### Optional Tools (Enhanced Experience)
```bash
# Better history (highly recommended)
brew install atuin

# Environment management
brew install direnv

# Node.js version manager
brew install fnm

# Git tools
brew install lazygit gitleaks
```

## 🎯 Key Aliases & Shortcuts

### Navigation
```bash
..          # cd ..
...         # cd ../..
l           # ls with icons
ll          # long listing
la          # ls -al
```

### Git (Extensive)
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
```

### Editor & Tools
```bash
v           # nvim
n           # nvim  
c           # cat (with bat)
ez          # exec zsh (restart shell)
zr          # edit ~/.zshrc and reload
sr          # source ~/.zshrc (reload config)
```

### Navigation & Projects
```bash
proj        # cd ~/Projects
config      # cd ~/.config
```

### File Search
```bash
ff          # find files (fd)
fp          # file picker with preview (fzf + bat)
fv          # find and edit in nvim
```

### SSH & Config
```bash
vc          # edit ~/.ssh/config
va          # edit ~/.zshrc
sl          # ssh-add -l (list keys)
```

## 🔧 Cross-Platform Support

### macOS
- **Apple Silicon**: Uses `/opt/homebrew/`
- **Intel**: Uses `/usr/local/`
- **Auto-detection**: No manual configuration needed

### Linux
- **Package managers**: Includes `apt` aliases
- **Homebrew**: Supports Linuxbrew if installed
- **System tools**: Uses appropriate Linux commands

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

### Platform-Specific Config
Create platform-specific files:
```bash
# ~/.zshrc.darwin - macOS only
# ~/.zshrc.linux - Linux only
```

## 🚀 Performance

- **Startup time**: ~30-50ms
- **Plugin loading**: Turbo mode with Zinit
- **Tool detection**: Only loads what's installed

## 📁 What's Included

```
zsh/
├── .zshrc          # Main configuration
├── install.sh      # Cross-platform installer
├── tools.md        # Tool installation guide
└── README.md       # This file
```

## 🔄 Updating

```bash
# Update the config
cd ~/Projects/zsh
git pull

# Copy to home directory
cp .zshrc ~/.zshrc

# Reload
exec zsh
```
