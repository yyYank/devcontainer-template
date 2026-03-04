# Show prompt as "dev-<project>" (git root name, or current dir outside git).
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

PROMPT='dev-$(prompt_project_name) %# '
