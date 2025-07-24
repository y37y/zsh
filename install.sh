#!/bin/bash

# Universal Zsh Configuration Installer
# Supports macOS (Intel/Apple Silicon) and Linux

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if [[ $(uname -m) == "arm64" ]]; then
            ARCH="apple_silicon"
            BREW_PREFIX="/opt/homebrew"
        else
            ARCH="intel"
            BREW_PREFIX="/usr/local"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        ARCH=$(uname -m)
        BREW_PREFIX="/home/linuxbrew/.linuxbrew"
    else
        error "Unsupported OS: $OSTYPE"
    fi
    
    info "Detected: $OS ($ARCH)"
}

# Check if command exists
check_command() {
    if ! command -v "$1" &>/dev/null; then
        return 1
    fi
    return 0
}

# Install Homebrew if needed
install_homebrew() {
    if ! check_command brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH
        if [[ "$OS" == "macos" ]]; then
            echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" >> ~/.zprofile
            eval "$($BREW_PREFIX/bin/brew shellenv)"
        elif [[ "$OS" == "linux" ]]; then
            echo "eval \"\$($BREW_PREFIX/bin/brew shellenv)\"" >> ~/.bashrc
            eval "$($BREW_PREFIX/bin/brew shellenv)"
        fi
        
        success "Homebrew installed!"
    else
        info "Homebrew already installed"
    fi
}

# Install essential tools
install_tools() {
    info "Installing essential tools..."
    
    local tools=(
        "starship"      # Modern prompt
        "bat"           # Better cat
        "eza"           # Better ls  
        "fd"            # Better find
        "ripgrep"       # Better grep
        "fzf"           # Fuzzy finder
        "zoxide"        # Smart cd
    )
    
    for tool in "${tools[@]}"; do
        if ! check_command "$tool"; then
            info "Installing $tool..."
            if check_command brew; then
                brew install "$tool"
            elif [[ "$OS" == "linux" ]] && check_command apt; then
                # Linux package names might differ
                case "$tool" in
                    "bat") sudo apt install -y bat ;;
                    "eza") 
                        # eza might need manual install on older systems
                        if ! sudo apt install -y eza 2>/dev/null; then
                            warning "eza not available via apt, skipping..."
                        fi ;;
                    "fd") sudo apt install -y fd-find ;;
                    "ripgrep") sudo apt install -y ripgrep ;;
                    "fzf") sudo apt install -y fzf ;;
                    "zoxide") 
                        # zoxide might need manual install
                        if ! sudo apt install -y zoxide 2>/dev/null; then
                            warning "zoxide not available via apt, install manually from: https://github.com/ajeetdsouza/zoxide"
                        fi ;;
                    "starship")
                        warning "starship not available via apt, install manually from: https://starship.rs"
                        ;;
                esac
            fi
        else
            info "$tool already installed"
        fi
    done
}

# Install optional tools
install_optional_tools() {
    info "Installing optional tools..."
    
    local optional_tools=(
        "atuin"         # Better history
        "direnv"        # Environment management
        "fnm"           # Fast Node Manager
        "lazygit"       # Git UI
        "gitleaks"      # Git secrets scanner
    )
    
    for tool in "${optional_tools[@]}"; do
        if ! check_command "$tool"; then
            if check_command brew; then
                info "Installing optional tool: $tool"
                brew install "$tool" 2>/dev/null || warning "Could not install $tool"
            fi
        fi
    done
}

# Install Zinit
install_zinit() {
    local zinit_dir="${HOME}/.local/share/zinit/zinit.git"
    
    if [[ ! -d "$zinit_dir" ]]; then
        info "Installing Zinit plugin manager..."
        bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
        success "Zinit installed!"
    else
        info "Zinit already installed"
    fi
}

# Setup zsh config
setup_config() {
    info "Setting up zsh configuration..."
    
    # Backup existing config
    if [[ -f ~/.zshrc ]]; then
        local backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp ~/.zshrc "$backup_file"
        info "Backed up existing .zshrc to $backup_file"
    fi
    
    # Copy new config
    if [[ -f ".zshrc" ]]; then
        cp .zshrc ~/.zshrc
        success "Zsh configuration installed!"
    else
        error ".zshrc file not found in current directory"
    fi
}

# Set zsh as default shell
setup_shell() {
    local zsh_path
    zsh_path=$(which zsh)
    
    if [[ "$SHELL" != "$zsh_path" ]]; then
        info "Setting zsh as default shell..."
        
        # Add zsh to /etc/shells if not present
        if ! grep -q "$zsh_path" /etc/shells; then
            echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
        fi
        
        # Change shell
        chsh -s "$zsh_path"
        success "Default shell changed to zsh"
        warning "You may need to log out and back in for the change to take effect"
    else
        info "Zsh is already your default shell"
    fi
}

# Main installation flow
main() {
    echo "🚀 Zsh Configuration Installer"
    echo "==============================="
    echo
    
    detect_os
    install_homebrew
    install_tools
    install_optional_tools
    install_zinit
    setup_config
    setup_shell
    
    echo
    success "Installation complete! 🎉"
    echo
    info "Next steps:"
    echo "1. Run 'exec zsh' to start using the new configuration"
    echo "2. Check the README.md for available aliases and shortcuts"
    echo "3. Customize ~/.zshrc or create ~/.zshrc.local for personal additions"
    echo
    warning "Note: Some tools may require a terminal restart to work properly"
}

# Run the installer
main "$@"
