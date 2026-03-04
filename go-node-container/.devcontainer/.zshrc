# Devcontainer-specific zsh config.
# Set DEVCONTAINER_SOURCE_HOST_ZSHRC=1 if you want to source ~/.zshrc.host.
export LANG=ja_JP.UTF-8

if [[ "${DEVCONTAINER_SOURCE_HOST_ZSHRC:-0}" == "1" && -f "$HOME/.zshrc.host" ]]; then
  source "$HOME/.zshrc.host"
fi

if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Improve ls readability with stronger color contrast.
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

export LS_COLORS="${LS_COLORS}:di=1;38;5;33:ln=1;38;5;45:ex=1;38;5;46:*.tar=1;38;5;214:*.zip=1;38;5;214:*.jpg=1;38;5;141:*.jpeg=1;38;5;141:*.png=1;38;5;141:*.gif=1;38;5;141"
alias ls='ls --color=auto -F'
alias ll='ls -lah'
alias la='ls -A'
