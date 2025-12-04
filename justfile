# Detect OS
os := os()

# Ensure we're running on Linux
_check-os:
    #!/usr/bin/env bash
    if [[ "{{os}}" != "linux" ]]; then
        echo "❌ Error: This justfile only supports Linux. Detected OS: {{os}}"
        exit 1
    fi


# Source install_utils function
source_install_utils := "source " + justfile_directory() + "/bin/install_utils.sh"

# ============================================================================
# Installation Profiles
# ============================================================================

# Bloomberg Linux profile - Install everything needed for Bloomberg Linux machines
profile-bloomberg-linux: _check-os \
    setup-bashrc \
    install-neovim \
    install-tmux \
    install-fzf \
    install-shell-scripts
    @echo "✅ Bloomberg Linux profile installation complete!"

# ============================================================================
# Shell Configuration
# ============================================================================

# Setup .bashrc to source dotfiles configs
setup-bashrc: _check-os
    #!/usr/bin/env bash
    set -euo pipefail

    DOTFILES_RC="$HOME/.bashrc_dotfiles"
    BASHRC="$HOME/.bashrc"

    # Create the dotfiles rc file if it doesn't exist
    touch "$DOTFILES_RC"

    # Add source line to .bashrc if not already present
    if ! grep -q "source.*\.bashrc_dotfiles" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "# Source dotfiles configurations" >> "$BASHRC"
        echo "[ -f \"\$HOME/.bashrc_dotfiles\" ] && source \"\$HOME/.bashrc_dotfiles\"" >> "$BASHRC"
        echo "✅ Added dotfiles sourcing to .bashrc"
    else
        echo "✅ .bashrc already configured to source dotfiles"
    fi

# Install common shell scripts
install-shell-scripts: _check-os
    #!/usr/bin/env bash
    set -euo pipefail
    {{source_install_utils}}

    echo "Installing shell scripts..."

    SCRIPTS_DIR="{{justfile_directory()}}/shell_scripts"

    install_shell_script "git.sh" "$SCRIPTS_DIR/git.sh"
    install_shell_script "github.sh" "$SCRIPTS_DIR/github.sh"
    install_shell_script "fzf.sh" "$SCRIPTS_DIR/fzf.sh"
    install_shell_script "docker.sh" "$SCRIPTS_DIR/docker.sh"
    install_shell_script "misc.sh" "$SCRIPTS_DIR/misc.sh"

    echo "✅ Shell scripts installation complete!"

# ============================================================================
# Individual Installation Recipes
# ============================================================================

# Install Neovim (Linux only)
install-neovim: _check-os
    #!/usr/bin/env bash
    set -euo pipefail
    {{source_install_utils}}

    echo "Installing Neovim and xclip on Linux..."
    yum install -y xclip
    apt-get install -y neovim # yum had an older version of neovim.
    echo "✅ Neovim and xclip installed successfully!"

    # Symlink nvim_chad config
    nvim_chad_path="{{justfile_directory()}}/nvim_chad"
    if [[ -d "$nvim_chad_path" ]]; then
        echo "Setting up Neovim configuration..."
        safe_symlink "$nvim_chad_path" ~/.config/nvim
    else
        echo "⚠️  Warning: nvim_chad/ folder not found in {{justfile_directory()}}"
    fi

    # Install vim shell script
    vim_script="{{justfile_directory()}}/shell_scripts/vim.sh"
    install_shell_script "vim.sh" "$vim_script"

# Install Tmux (Linux only)
install-tmux: _check-os
    #!/usr/bin/env bash
    set -euo pipefail
    {{source_install_utils}}

    echo "Installing Tmux on Linux..."
        apt-get update
        apt-get install -y tmux
        echo "✅ Tmux installed successfully!"

        # Symlink tmux config
        tmux_conf="{{justfile_directory()}}/dotfiles/tmux.conf"
        if [[ -f "$tmux_conf" ]]; then
            echo "Setting up Tmux configuration..."
            safe_symlink "$tmux_conf" ~/.tmux.conf
        else
            echo "⚠️  Warning: tmux.conf not found in {{justfile_directory()}}/dotfiles"
        fi

    # Install tmux shell script
    tmux_script="{{justfile_directory()}}/shell_scripts/tmux.sh"
    install_shell_script "tmux.sh" "$tmux_script"

# Install FZF (Linux only)
install-fzf: _check-os
    #!/usr/bin/env bash
    set -euo pipefail
    {{source_install_utils}}

    echo "Installing FZF and ripgrep on Linux..."
        yum install -y fzf ripgrep
        echo "✅ FZF and ripgrep installed successfully!"

        # Add fzf bash integration to bashrc_dotfiles
        DOTFILES_RC="$HOME/.bashrc_dotfiles"
        FZF_LINE='eval "$(fzf --bash)"'
        if ! grep -q "fzf --bash" "$DOTFILES_RC" 2>/dev/null; then
            echo "$FZF_LINE" >> "$DOTFILES_RC"
            echo "✅ Added fzf bash integration to shell configuration"
        else
            echo "✅ fzf bash integration already in shell configuration"
        fi

    # Install fzf shell script
    fzf_script="{{justfile_directory()}}/shell_scripts/fzf.sh"
    install_shell_script "fzf.sh" "$fzf_script"
