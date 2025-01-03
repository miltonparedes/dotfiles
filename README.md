# dotfiles

# Installation

## Requirements

- Python 3.10+
- just
- uv

## Installation

```bash
just install
```

## Configuration

### Remote host

Set the remote host in `sample.env` and rename it to `.env`.

### Remote user

Set the remote user in `sample.env` and rename it to `.env`.

### Remote workspace

Set the remote workspace in `sample.env` and rename it to `.env`.

## Set raycast scripts folder

# Devcontainers Setup

If you only want to install the development container configuration with CLI tools and aliases:

```bash
# Optional: Set OpenAI API key for aichat configuration
export OPENAI_API_KEY=your-api-key-here

# Run the installation script
curl -sSL https://raw.githubusercontent.com/miltonparedes/dotfiles/main/devcontainers/install.sh | bash
```

This will install and configure:
- Basic development tools
- Rust and Cargo
- CLI tools (just, aichat, zoxide)
- Lazygit
- Shell aliases and configurations
