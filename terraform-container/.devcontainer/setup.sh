#!/bin/sh
set -eu

# mise のインストール
curl -fsSL https://mise.run | sh

# ツールのインストール
MISE_CONFIG_FILE=.devcontainer/mise.toml ~/.local/bin/mise install

# npm グローバルパッケージのインストール
MISE_CONFIG_FILE=.devcontainer/mise.toml ~/.local/bin/mise exec -- sh -lc \
  'npm config set prefix "$HOME/.npm-global" && npm install -g @anthropic-ai/claude-code @openai/codex'

# apt パッケージのインストール
sudo apt-get update
sudo apt-get install -y git-delta zsh-autosuggestions zsh-syntax-highlighting gh
