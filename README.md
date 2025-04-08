# Git Assist

A command-line tool for enhancing Git workflow with AI-powered assistance, designed to make version control more efficient and user-friendly.

## Features

- 🤖 AI-powered Git command suggestions and explanations
- 📝 Interactive commit message generation
- 🔍 Smart branch management and conflict resolution
- ⚡️ Quick access to common Git operations
- 🎯 Customizable prompts and configurations
- 🚀 Pipeline support for automated workflows

## Installation

### Using Homebrew (Recommended)

```bash
# Add the tap
brew tap vangie/formula

# Install git-assist
brew install git-assist
```

## Usage

### Main Commands

#### Generate Commit Messages (`git gen`)

```bash
# Generate and commit with the staged changes
git gen

# Only show the generated message for staged changes
git gen --msg-only

# Amend the last commit message
git gen --amend

# Show what the amended message would be without changing it
git gen --amend --msg-only
```

#### Create Feature Branches (`git up`)

```bash
# Create a new branch and commit staged changes
git up

# Show what would be done without making changes
git up --dry-run
```

### Configuration

#### LLM Model Configuration (`git assist-model`)

```bash
# Configure OpenAI or Azure OpenAI models
git assist-model --config
```

#### Prompt Management (`git assist-prompt`)

```bash
# Manage prompts interactively
git assist-prompt --config
```

## Requirements

- Git 2.0 or later
- OpenAI API key or Azure OpenAI API key
- Basic understanding of Git commands

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
