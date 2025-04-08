#!/usr/bin/env bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[90m'
NC='\033[0m' # No Color

# Menu colors
MENU_NUMBER=$YELLOW
MENU_OPTION=$NC
MENU_BACK=$GRAY
MENU_EXIT=$GRAY

# Function to print colored messages
print_message() {
    local color=$1
    local message=$2
    local no_newline=$3
    if [ "$no_newline" = "-n" ]; then
        echo -en "${color}${message}${NC}"
    else
        echo -e "${color}${message}${NC}"
    fi
}

# Function to print debug messages
debug_message() {
    [ "$DEBUG" = "true" ] && print_message "$1" "$2"
}

# Function to get config directory
get_config_dir() {
    if [ -n "$GIT_ASSIST_HOME" ]; then
        echo "$GIT_ASSIST_HOME"
    else
        echo "$HOME/.config/git-assist"
    fi
}

# Function to ensure config directory exists
ensure_config_dir() {
    local config_dir="$1"
    mkdir -p "$config_dir"
    if [ ! -d "$config_dir" ]; then
        print_message "$RED" "Failed to create config directory: $config_dir"
        exit 1
    fi
}

# Function to check git repository
check_git_repo() {
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        print_message "$RED" "Error: Not a git repository"
        exit 1
    fi
}

# Function to get staged changes
get_staged_changes() {
    git diff --cached --name-status
}

# Function to get all changes
get_all_changes() {
    git diff --name-status
}

# Function to show staged files
show_staged_files() {
    echo -e "${CYAN}Changes to be committed:${NC}"
    echo "  (use \"git restore --staged <file>...\" to unstage)"
    echo
    git diff --cached --name-status | while read -r status file; do
        case "$status" in
            M) echo -e "        ${CYAN}modified:   $file${NC}" ;;
            A) echo -e "        ${CYAN}new file:   $file${NC}" ;;
            D) echo -e "        ${CYAN}deleted:    $file${NC}" ;;
            R) echo -e "        ${CYAN}renamed:    $file${NC}" ;;
            C) echo -e "        ${CYAN}copied:     $file${NC}" ;;
            *) echo -e "        ${CYAN}changed:    $file${NC}" ;;
        esac
    done
    echo
}

# Function to ensure EDITOR is set
ensure_editor() {
    # If EDITOR is not set or is empty, try to find vim
    if [ -z "${EDITOR:-}" ]; then
        if command -v vim &> /dev/null; then
            export EDITOR=vim
        elif command -v vi &> /dev/null; then
            export EDITOR=vi
        else
            print_message "$RED" "Error: No suitable editor found. Please set EDITOR environment variable."
            exit 1
        fi
    fi
}

# Function to edit text in editor
edit_text() {
    local text=$1
    local git_dir=$(git rev-parse --git-dir)
    local temp_file="$git_dir/EDIT_TEXT"
    echo "$text" > "$temp_file"
    
    # Use /dev/tty to ensure proper terminal interaction
    ${EDITOR:-vim} "$temp_file" </dev/tty >/dev/tty
    local status=$?
    
    # Check for different exit statuses:
    # 0 = normal exit
    # 1 = error exit without writing (:cq)
    # >1 = other error exits
    if [ $status -eq 1 ]; then
        echo "Editing cancelled"
        return 1
    elif [ $status -gt 1 ]; then
        echo "Error occurred while editing"
        return 1
    fi
    
    # Read the edited text
    local edited_text=$(cat "$temp_file")
    if [ -z "$(echo "$edited_text" | tr -d '[:space:]')" ]; then
        echo "Empty text not allowed"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_message "$YELLOW" "[DRY-RUN] Text after editing:"
        echo -e "$edited_text"
    fi
    
    echo "$edited_text"
    return 0
}

# Function to check if origin remote exists
check_origin_exists() {
    if ! git remote get-url origin &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            print_message "$YELLOW" "[DRY-RUN] Warning: No 'origin' remote found"
        else
            print_message "$YELLOW" "Warning: No 'origin' remote found. Branch created but not pushed."
        fi
        return 1
    fi
    return 0
}

# Function to mask key
mask_key() {
    local key="$1"
    if [ -z "$key" ]; then
        echo "not set"
    else
        echo "${key:0:4}...${key: -4}"
    fi
} 