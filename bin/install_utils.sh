#!/usr/bin/env bash

# Function to safely symlink with backup
safe_symlink() {
    local source="$1"
    local target="$2"
    
    # Expand ~ to full path
    target="${target/#\~/$HOME}"
    
    if [[ -e "$target" || -L "$target" ]]; then
        echo "⚠️  Warning: $target already exists!"
        local backup="${target}.replaced"
        echo "Moving existing $target to $backup"
        mv "$target" "$backup"
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -s "$source" "$target"
    echo "✅ Symlinked $source -> $target"
}

# Function to add a shell script to bashrc_dotfiles (source from current location)
install_shell_script() {
    local script_name="$1"
    local source_path="$2"
    local dotfiles_rc="$HOME/.bashrc_dotfiles"
    
    if [[ -f "$source_path" ]]; then
        # Add to bashrc_dotfiles if not already present
        local source_line="source $source_path"
        if ! grep -q "$source_path" "$dotfiles_rc" 2>/dev/null; then
            echo "$source_line" >> "$dotfiles_rc"
            echo "✅ Added $script_name to shell configuration"
        else
            echo "✅ $script_name already in shell configuration"
        fi
    else
        echo "⚠️  Warning: $script_name not found at $source_path"
    fi
}
