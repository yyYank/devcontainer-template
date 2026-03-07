#!/bin/sh
set -eu

# npm グローバルパッケージのインストール
npm install -g @anthropic-ai/claude-code @openai/codex

# apt パッケージのインストール
sudo apt-get update
sudo apt-get install -y git-delta zsh-autosuggestions zsh-syntax-highlighting
