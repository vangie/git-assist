#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Base directory for test repositories
TEST_REPOS_DIR="test/repos"

# Parse command line arguments
SPECIFIC_SCENARIO=""
COMMAND_TYPE=""
while getopts "s:c:" opt; do
  case $opt in
    s)
      SPECIFIC_SCENARIO="$OPTARG"
      ;;
    c)
      COMMAND_TYPE="$OPTARG"
      ;;
    \?)
      echo -e "${RED}Invalid option: -$OPTARG${NC}" >&2
      exit 1
      ;;
  esac
done

# Function to create a test repository
create_test_repo() {
    local repo_name=$1
    local command=$2
    
    # Skip if we're initializing a specific scenario and this isn't it
    if [ -n "$SPECIFIC_SCENARIO" ] && [ "$repo_name" != "$SPECIFIC_SCENARIO" ]; then
        return
    fi
    
    # Skip if we're initializing a specific command type and this isn't it
    if [ -n "$COMMAND_TYPE" ] && [ "$command" != "$COMMAND_TYPE" ]; then
        return
    fi
    
    local repo_path="$TEST_REPOS_DIR/${command}_${repo_name}"
    
    echo -e "${BLUE}Creating test repository:${NC} ${YELLOW}$repo_path${NC}"
    
    # Create and initialize repository
    mkdir -p "$repo_path"
    cd "$repo_path"
    
    # Create a minimal project structure (much faster than using npx)
    mkdir -p src
    
    # Create a simple HTML file
    cat > index.html << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Project</title>
    <link rel="stylesheet" href="src/style.css">
</head>
<body>
    <h1>Test Project</h1>
    <script src="src/main.js"></script>
</body>
</html>
EOF

    # Create a simple CSS file
    cat > src/style.css << EOF
body {
    font-family: sans-serif;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}
EOF

    # Create a simple JS file
    cat > src/main.js << EOF
// Main application logic
console.log('App initialized');
EOF

    # Create a README
    cat > README.md << EOF
# Test Project

A simple project for testing git-$command.
EOF
    
    # Initialize git and set user config
    git init > /dev/null 2>&1
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Initial commit
    git add .
    git commit -m "Initial commit" > /dev/null 2>&1
    
    # Return to original directory
    cd - > /dev/null
}

# Clean up repository directories
if [ -n "$SPECIFIC_SCENARIO" ]; then
    if [ -n "$COMMAND_TYPE" ]; then
        # Clean specific scenario for specific command
        rm -rf "$TEST_REPOS_DIR/${COMMAND_TYPE}_${SPECIFIC_SCENARIO}"
    else
        # Clean specific scenario for both commands
        rm -rf "$TEST_REPOS_DIR/gen_${SPECIFIC_SCENARIO}"
        rm -rf "$TEST_REPOS_DIR/up_${SPECIFIC_SCENARIO}"
    fi
else
    if [ -n "$COMMAND_TYPE" ]; then
        # Clean all scenarios for specific command
        rm -rf "$TEST_REPOS_DIR/${COMMAND_TYPE}_"*
    else
        # Clean all repositories
        rm -rf "$TEST_REPOS_DIR"
    fi
fi

mkdir -p "$TEST_REPOS_DIR"

# Initialize git-gen scenarios
# Scenario 1: Clean repository (just initialized)
create_test_repo "clean" "gen"

# Scenario 2: Unstaged changes only
create_test_repo "unstaged" "gen"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "unstaged" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "gen" ]; }; then
    cd "$TEST_REPOS_DIR/gen_unstaged"
    echo "// New feature - track user activity" >> src/main.js
    cd - > /dev/null
fi

# Scenario 3: Staged changes only
create_test_repo "staged" "gen"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "staged" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "gen" ]; }; then
    cd "$TEST_REPOS_DIR/gen_staged"
    echo "// TODO: Add dark mode support" >> src/main.js
    git add src/main.js
    cd - > /dev/null
fi

# Scenario 4: Both staged and unstaged changes
create_test_repo "mixed" "gen"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "mixed" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "gen" ]; }; then
    cd "$TEST_REPOS_DIR/gen_mixed"
    echo "// Add responsive layout" >> src/main.js
    git add src/main.js
    echo "/* Add mobile styles */" >> src/style.css
    cd - > /dev/null
fi

# Scenario 5: For testing amend
create_test_repo "amend" "gen"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "amend" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "gen" ]; }; then
    cd "$TEST_REPOS_DIR/gen_amend"
    echo "// Add user authentication" >> src/main.js
    git add src/main.js
    git commit -m "feat: add authentication" > /dev/null 2>&1
    echo "// Fix security vulnerability in auth" >> src/main.js
    git add src/main.js
    cd - > /dev/null
fi

# Initialize git-up scenarios
# Scenario 1: Clean repository (just initialized)
create_test_repo "clean" "up"

# Scenario 2: Unstaged changes only
create_test_repo "unstaged" "up"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "unstaged" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "up" ]; }; then
    cd "$TEST_REPOS_DIR/up_unstaged"
    echo "// New feature - user profile management" >> src/main.js
    cd - > /dev/null
fi

# Scenario 3: Staged changes only
create_test_repo "staged" "up"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "staged" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "up" ]; }; then
    cd "$TEST_REPOS_DIR/up_staged"
    echo "// Add user settings panel" >> src/main.js
    git add src/main.js
    cd - > /dev/null
fi

# Scenario 4: For testing dry-run
create_test_repo "dry-run" "up"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "dry-run" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "up" ]; }; then
    cd "$TEST_REPOS_DIR/up_dry-run"
    echo "// Add notification system" >> src/main.js
    git add src/main.js
    cd - > /dev/null
fi

# Scenario 5: For testing branch name editing
create_test_repo "edit" "up"
if { [ -z "$SPECIFIC_SCENARIO" ] || [ "$SPECIFIC_SCENARIO" = "edit" ]; } && { [ -z "$COMMAND_TYPE" ] || [ "$COMMAND_TYPE" = "up" ]; }; then
    cd "$TEST_REPOS_DIR/up_edit"
    echo "// Add custom theme support" >> src/main.js
    git add src/main.js
    cd - > /dev/null
fi

# Create help test repository for both commands
create_test_repo "help" "gen"
create_test_repo "help" "up"

if [ -n "$SPECIFIC_SCENARIO" ]; then
    if [ -n "$COMMAND_TYPE" ]; then
        echo -e "${GREEN}Test repository '${COMMAND_TYPE}_${SPECIFIC_SCENARIO}' created successfully in ${YELLOW}$TEST_REPOS_DIR${NC}!"
    else
        echo -e "${GREEN}Test repositories for scenario '${SPECIFIC_SCENARIO}' created successfully in ${YELLOW}$TEST_REPOS_DIR${NC}!"
    fi
else
    if [ -n "$COMMAND_TYPE" ]; then
        echo -e "${GREEN}Test repositories for command 'git-${COMMAND_TYPE}' created successfully in ${YELLOW}$TEST_REPOS_DIR${NC}!"
    else
        echo -e "${GREEN}All test repositories created successfully in ${YELLOW}$TEST_REPOS_DIR${NC}!"
    fi
fi 