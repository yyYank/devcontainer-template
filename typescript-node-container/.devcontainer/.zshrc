# Devcontainer-specific zsh config.
# Set DEVCONTAINER_SOURCE_HOST_ZSHRC=1 if you want to source ~/.zshrc.host.
export LANG=ja_JP.UTF-8

if [[ "${DEVCONTAINER_SOURCE_HOST_ZSHRC:-0}" == "1" && -f "$HOME/.zshrc.host" ]]; then
  source "$HOME/.zshrc.host"
fi

if [[ -x "$HOME/.local/bin/mise" ]]; then
  eval "$("$HOME/.local/bin/mise" activate zsh)"
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

# Prompt: simple powerline-like style with project segment.
setopt PROMPT_SUBST

prompt_project_name() {
  local root remote repo
  root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$root" ]]; then
    remote=$(git remote get-url origin 2>/dev/null)
    if [[ -n "$remote" ]]; then
      repo="${remote:t}"
      repo="${repo%.git}"
      if [[ -n "$repo" ]]; then
        echo "$repo"
        return
      fi
    fi
    echo "${root:t}"
  else
    echo "${PWD:t}"
  fi
}

prompt_git_branch() {
  local branch
  branch=$(git branch --show-current 2>/dev/null)
  if [[ -n "$branch" ]]; then
    echo "$branch"
  fi
}

# Use a Powerline separator glyph if available in the terminal font.
typeset -g POWERLINE_SEP=''
if [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then
  POWERLINE_SEP='>'
fi

prompt_branch_segment() {
  local branch
  branch=$(prompt_git_branch)
  if [[ -n "$branch" ]]; then
    echo "%K{magenta}%F{white} ${branch} %k%f%F{magenta}${POWERLINE_SEP}%f "
  fi
}

PROMPT='%K{blue}%F{white} dev %k%f%F{blue}${POWERLINE_SEP}%f%K{cyan}%F{black} $(prompt_project_name) %k%f%F{cyan}${POWERLINE_SEP}%f $(prompt_branch_segment)%# '
