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
        # Ensure brew is in PATH
        if [[ "$OS" == "linux" ]] && [[ ":$PATH:" != *":$BREW_PREFIX/bin:"* ]]; then
            eval "$($BREW_PREFIX/bin/brew shellenv)"
        fi
    fi
}

# Install via package manager
install_via_package_manager() {
    local tool="$1"
    local linux_package="$2"
    
    if [[ "$OS" == "linux" ]] && check_command apt; then
        info "Installing $tool via apt..."
        if sudo apt install -y "$linux_package" 2>/dev/null; then
            return 0
        else
            warning "$tool not available via apt"
            return 1
        fi
    fi
    return 1
}

# Install via Homebrew
install_via_brew() {
    local tool="$1"
    
    if check_command brew; then
        info "Installing $tool via Homebrew..."
        if brew install "$tool" 2>/dev/null; then
            return 0
        else
            warning "Failed to install $tool via Homebrew"
            return 1
        fi
    fi
    return 1
}

# Install manual tools
install_manual_tool() {
    local tool="$1"
    
    case "$tool" in
        "starship")
            info "Installing Starship..."
            curl -sS https://starship.rs/install.sh | sh -s -- --yes
            ;;
        "zoxide")
            info "Installing zoxide..."
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
            ;;
        "atuin")
            info "Installing Atuin..."
            curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
            ;;
        *)
            warning "Don't know how to manually install $tool"
            return 1
            ;;
    esac
}

# Install essential tools with Homebrew preference
install_tools() {
    info "Installing essential tools (preferring Homebrew for latest versions)..."
    
    local essential_tools=(
        "starship"       # Modern prompt
        "bat"           # Better cat
        "eza"           # Better ls (only available via Homebrew on most systems)
        "fd"            # Better find
        "ripgrep"       # Better grep
        "fzf"           # Fuzzy finder
        "zoxide"        # Smart cd
    )
    
    for tool in "${essential_tools[@]}"; do
        if check_command "$tool"; then
            info "$tool already installed"
            continue
        fi
        
        local installed=false
        
        # Try Homebrew first (preferred for latest versions)
        if install_via_brew "$tool"; then
            installed=true
        # Fallback to apt only for basic tools if Homebrew fails
        elif [[ "$OS" == "linux" ]]; then
            case "$tool" in
                "bat") 
                    if install_via_package_manager "$tool" "bat"; then
                        installed=true
                    fi ;;
                "fd") 
                    if install_via_package_manager "$tool" "fd-find"; then
                        installed=true
                        # Create symlink since apt installs as 'fdfind'
                        mkdir -p ~/.local/bin
                        ln -sf "$(which fdfind)" ~/.local/bin/fd 2>/dev/null || true
                    fi ;;
                "ripgrep") 
                    if install_via_package_manager "$tool" "ripgrep"; then
                        installed=true
                    fi ;;
                "fzf") 
                    if install_via_package_manager "$tool" "fzf"; then
                        installed=true
                    fi ;;
                "starship")
                    if install_manual_tool "$tool"; then
                        installed=true
                    fi ;;
                "zoxide")
                    if install_manual_tool "$tool"; then
                        installed=true
                    fi ;;
                *)
                    warning "$tool not available via apt, try installing Homebrew"
                    ;;
            esac
        fi
        
        if $installed; then
            success "$tool installed successfully"
        else
            warning "Could not install $tool"
            if [[ "$OS" == "linux" ]] && ! check_command brew; then
                info "Consider installing Homebrew for better tool support: https://brew.sh"
            fi
        fi
    done
}

# Install optional tools (Homebrew only for simplicity)
install_optional_tools() {
    info "Installing optional tools..."
    
    local optional_tools=(
        "atuin"         # Better history (if not manually installed)
        "direnv"        # Environment management
        "fnm"           # Fast Node Manager
        "lazygit"       # Git UI
        "gitleaks"      # Git secrets scanner
    )
    
    for tool in "${optional_tools[@]}"; do
        if ! check_command "$tool"; then
            if install_via_brew "$tool"; then
                success "Optional tool $tool installed"
            else
                info "Skipping optional tool $tool"
            fi
        else
            info "Optional tool $tool already installed"
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

# Install zsh if needed
install_zsh() {
    if ! check_command zsh; then
        info "Installing zsh..."
        if [[ "$OS" == "linux" ]] && check_command apt; then
            sudo apt install -y zsh
        elif [[ "$OS" == "macos" ]]; then
            # Zsh comes with macOS by default
            error "Zsh should be available on macOS by default"
        else
            error "Cannot install zsh automatically on this system"
        fi
        success "Zsh installed!"
    else
        info "Zsh already installed"
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
    
    # Copy starship config if it exists
    if [[ -f "starship.toml" ]]; then
        mkdir -p ~/.config
        cp starship.toml ~/.config/starship.toml
        success "Starship configuration installed!"
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

# Post-installation setup
post_install() {
    info "Running post-installation setup..."
    
    # Ensure directories exist
    mkdir -p ~/.local/bin ~/.config
    
    # Add ~/.local/bin to PATH if not present (for manual installs and symlinks)
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
    fi
    
    # Create symlinks for apt-installed tools with different names (if needed)
    if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
        ln -sf "$(which fdfind)" ~/.local/bin/fd
        info "Created fd symlink for fdfind (apt version)"
    fi
    
    if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
        ln -sf "$(which batcat)" ~/.local/bin/bat
        info "Created bat symlink for batcat (apt version)"
    fi
    
    # Remind about Homebrew benefits
    if [[ "$OS" == "linux" ]] && ! check_command brew; then
        echo
        warning "For the latest versions of development tools, consider installing Homebrew:"
        echo "  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash"
        echo "  Then run this installer again for newer tool versions"
    fi
}

# Main installation flow
main() {
    echo "🚀 Zsh Configuration Installer"
    echo "==============================="
    echo
    
    detect_os
    install_zsh
    install_homebrew
    install_tools
    install_optional_tools
    install_zinit
    setup_config
    post_install
    setup_shell
    
    echo
    success "Installation complete! 🎉"
    echo
    info "Next steps:"
    echo "1. Run 'exec zsh' to start using the new configuration"
    echo "2. Check the README.md for available aliases and shortcuts"
    echo "3. Customize ~/.zshrc or create ~/.zshrc.local for personal additions"
    echo
    if [[ "$OS" == "linux" ]]; then
        echo "4. If some tools aren't working, try: 'source ~/.zshrc' or restart your terminal"
    fi
    echo
    warning "Note: Some tools may require a terminal restart to work properly"
}

# Run the installer
main "$@"
