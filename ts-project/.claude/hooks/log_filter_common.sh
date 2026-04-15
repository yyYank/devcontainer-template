#!/bin/sh
set -eu

MAX_LINES="${LOG_FILTER_MAX_LINES:-100}"
MODE="${1:-post}"
INPUT="$(cat)"

tool_name="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')"
[ "$tool_name" = "Bash" ] || exit 0

COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')"
[ -n "$COMMAND" ] || exit 0

TOOL_ERROR="$(printf '%s' "$INPUT" | jq -r '.error // .tool_response.stderr? // ""')"
TOOL_SUCCESS="$(printf '%s' "$INPUT" | jq -r '
  if (.tool_response | type) == "object" then
    (.tool_response.success // (if (.tool_response.exitCode // .tool_response.exit_code // 0) == 0 then true else false end))
  else
    true
  end
')"
RAW_RESPONSE="$(printf '%s' "$INPUT" | jq -r '
  if .tool_response? then
    [
      .tool_response.stdout?,
      .tool_response.stderr?,
      .tool_response.output?,
      .tool_response.result?,
      (.tool_response.content? | if type == "array" then map(.text? // .content? // empty) | join("\n") else empty end),
      (if (.tool_response | type) == "string" then .tool_response else empty end)
    ] | map(select(type == "string" and length > 0)) | join("\n")
  else
    ""
  end
')"

trim_lines() {
  awk -v max="$MAX_LINES" '
    NR <= max { print; next }
    END {
      if (NR > max) {
        printf("[truncated %d lines]\n", NR - max)
      }
    }
  '
}

emit_context() {
  jq -n --arg event_name "$1" --arg text "$2" '{
    hookSpecificOutput: {
      hookEventName: $event_name,
      additionalContext: $text
    }
  }'
}

deny_command() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
}

command_matches() {
  printf '%s\n' "$COMMAND" | grep -Eiq "$1"
}

is_plain_git_diff() {
  printf '%s\n' "$COMMAND" | grep -Eq '^[[:space:]]*git diff[[:space:]]*$'
}

is_plain_git_status() {
  printf '%s\n' "$COMMAND" | grep -Eq '^[[:space:]]*git status[[:space:]]*$'
}

is_git_diff_command() {
  command_matches '(^|[[:space:]])git diff([[:space:]]|$)'
}

is_git_status_command() {
  command_matches '(^|[[:space:]])git status([[:space:]]|$)'
}

is_terraform_command() {
  command_matches '(^|[[:space:]])terraform (plan|apply|destroy|show|validate|fmt|test)([[:space:]]|$)'
}

is_json_command() {
  command_matches '(^|[[:space:]])(jq|gh api|curl)([[:space:]]|$)' || command_matches '(^|[[:space:]])terraform show -json([[:space:]]|$)' || printf '%s' "$RAW_RESPONSE" | jq -e . >/dev/null 2>&1
}

is_test_command() {
  case "$PROJECT_PROFILE" in
    go-node)
      command_matches '(^|[[:space:]])(go test|npm test|pnpm test|yarn test|vitest|jest|pytest)([[:space:]]|$)'
      ;;
    terraform)
      command_matches '(^|[[:space:]])(terraform test|pytest)([[:space:]]|$)'
      ;;
    typescript-node)
      command_matches '(^|[[:space:]])(npm test|pnpm test|yarn test|vitest|jest|pytest)([[:space:]]|$)'
      ;;
    *)
      return 1
      ;;
  esac
}

pre_profile_checks() {
  case "$PROJECT_PROFILE" in
    go-node)
      if command_matches '(^|[[:space:]])pytest([[:space:]]|$)' && ! command_matches '(^|[[:space:]])pytest .* -q([[:space:]]|$)|(^|[[:space:]])pytest -q([[:space:]]|$)'; then
        deny_command "Use \`pytest -q --maxfail=5 --tb=short\` to reduce test log noise."
        return 0
      fi

      if command_matches '(^|[[:space:]])go test([[:space:]].*)?-v([[:space:]]|$)' && command_matches '(^|[[:space:]])go test .*\.{3}([[:space:]]|$)|(^|[[:space:]])go test ./\.\.\.([[:space:]]|$)'; then
        deny_command "Avoid verbose full-suite Go tests. Use \`go test ./...\` first, or scope \`-v\` to a package under investigation."
        return 0
      fi
      ;;
    terraform)
      if command_matches '(^|[[:space:]])terraform (plan|apply|destroy)([[:space:]]|$)' && ! command_matches '(^|[[:space:]])terraform .* -no-color([[:space:]]|$)'; then
        deny_command "Use \`terraform plan -no-color\`, \`terraform apply -no-color\`, or \`terraform destroy -no-color\` to avoid ANSI-heavy output."
        return 0
      fi

      if command_matches '(^|[[:space:]])terraform show([[:space:]]|$)' && ! command_matches '(^|[[:space:]])terraform show -json([[:space:]]|$)'; then
        deny_command "Prefer \`terraform show -json | jq ...\` so the hook can keep only the relevant keys."
        return 0
      fi

      if command_matches '(^|[[:space:]])pytest([[:space:]]|$)' && ! command_matches '(^|[[:space:]])pytest .* -q([[:space:]]|$)|(^|[[:space:]])pytest -q([[:space:]]|$)'; then
        deny_command "Use \`pytest -q --maxfail=5 --tb=short\` to reduce test log noise."
        return 0
      fi
      ;;
    typescript-node)
      if command_matches '(^|[[:space:]])pytest([[:space:]]|$)' && ! command_matches '(^|[[:space:]])pytest .* -q([[:space:]]|$)|(^|[[:space:]])pytest -q([[:space:]]|$)'; then
        deny_command "Use \`pytest -q --maxfail=5 --tb=short\` to reduce test log noise."
        return 0
      fi

      if command_matches '(^|[[:space:]])(vitest|jest)([[:space:]]|$)' && command_matches '(^|[[:space:]])(--watch|--watchAll)([[:space:]]|$)'; then
        deny_command "Avoid watch-mode test runs in Claude Code. Use a one-shot command such as \`vitest run\` or \`jest --runInBand\`."
        return 0
      fi
      ;;
  esac
}

pre_check() {
  if is_plain_git_diff; then
    deny_command "Avoid plain \`git diff\` because it produces large outputs. Use \`git diff --stat\`, \`git diff --name-only\`, or scope it with \`git diff -- <path>\` first."
    return 0
  fi

  if is_plain_git_status; then
    deny_command "Prefer \`git status --short\` to keep output compact."
    return 0
  fi

  pre_profile_checks
}

summarize_git_diff() {
  filtered="$(printf '%s\n' "$RAW_RESPONSE" | grep -E '^(diff --git|--- |\+\+\+ |@@|rename from |rename to |new file mode |deleted file mode |index )' || true)"
  [ -n "$filtered" ] || return 1

  files="$(printf '%s\n' "$filtered" | grep -c '^diff --git' || true)"
  hunks="$(printf '%s\n' "$filtered" | grep -c '^@@' || true)"
  body="$(printf '%s\n' "$filtered" | trim_lines)"
  printf '[%s] Compressed git diff summary for `%s`\nfiles=%s hunks=%s\n%s\n' "$PROJECT_PROFILE" "$COMMAND" "$files" "$hunks" "$body"
}

summarize_git_status() {
  filtered="$(printf '%s\n' "$RAW_RESPONSE" | grep -E '^(M|A|D|R|C|UU|\?\?)[[:space:]]' || true)"
  [ -n "$filtered" ] || return 1

  count="$(printf '%s\n' "$filtered" | sed '/^$/d' | wc -l | tr -d ' ')"
  body="$(printf '%s\n' "$filtered" | trim_lines)"
  printf '[%s] Compressed git status for `%s`\nentries=%s\n%s\n' "$PROJECT_PROFILE" "$COMMAND" "$count" "$body"
}

summarize_test_output() {
  important="$(printf '%s\n%s\n' "$TOOL_ERROR" "$RAW_RESPONSE" | grep -E '(FAIL|ERROR|Exception|Traceback|panic:|--- FAIL:|not ok|AssertionError|^E[[:space:]]|^F[[:space:]]|^PASS$|^FAIL$|^ok[[:space:]]|^Ran [0-9]+ tests|^[0-9]+ passed|^[0-9]+ failed|^Test Suites:|^Tests:|^Snapshots:|^collected [0-9]+ items)' || true)"
  [ -n "$important" ] || important="$(printf '%s\n%s\n' "$TOOL_ERROR" "$RAW_RESPONSE" | tail -n 20)"
  [ -n "$important" ] || return 1

  count="$(printf '%s\n' "$important" | sed '/^$/d' | wc -l | tr -d ' ')"
  body="$(printf '%s\n' "$important" | trim_lines)"
  printf '[%s] Compressed test output for `%s`\nmatched_lines=%s\n%s\n' "$PROJECT_PROFILE" "$COMMAND" "$count" "$body"
}

summarize_terraform() {
  filtered="$(printf '%s\n%s\n' "$TOOL_ERROR" "$RAW_RESPONSE" | grep -E '^(Error:|Warning:|Plan:|No changes\.|Apply complete!|Changes to Outputs:|│ Error:|│ Warning:)' || true)"
  [ -n "$filtered" ] || return 1

  body="$(printf '%s\n' "$filtered" | trim_lines)"
  printf '[%s] Compressed terraform output for `%s`\n%s\n' "$PROJECT_PROFILE" "$COMMAND" "$body"
}

summarize_json() {
  if printf '%s' "$RAW_RESPONSE" | jq -e . >/dev/null 2>&1; then
    summary="$(printf '%s' "$RAW_RESPONSE" | jq -c '
      def shrink:
        if type == "object" then
          with_entries(select(.key | IN("status"; "message"; "error"; "errors"; "warning"; "warnings"; "summary"; "result"; "count"; "total"; "exitCode"; "exit_code")))
          + (if has("items") and (.items | type) == "array" then {items_count: (.items | length)} else {} end)
          + (if has("data") and (.data | type) == "object" then {data_keys: (.data | keys)} else {} end)
          + {top_level_keys: (keys[0:12])}
        elif type == "array" then
          {items_count: length, sample: .[0:3]}
        else
          .
        end;
      shrink
    ' 2>/dev/null || true)"
  else
    summary=""
  fi

  [ -n "$summary" ] || return 1
  printf '[%s] Compressed JSON output for `%s`\n%s\n' "$PROJECT_PROFILE" "$COMMAND" "$summary"
}

post_check() {
  if [ "$TOOL_SUCCESS" = "false" ] || [ -n "$TOOL_ERROR" ]; then
    failure_check
    return
  fi

  summary=""

  if is_git_diff_command; then
    summary="$(summarize_git_diff || true)"
  elif is_git_status_command; then
    summary="$(summarize_git_status || true)"
  elif is_test_command; then
    summary="$(summarize_test_output || true)"
  elif is_terraform_command; then
    summary="$(summarize_terraform || true)"
  elif is_json_command; then
    summary="$(summarize_json || true)"
  fi

  [ -n "$summary" ] || exit 0
  emit_context "PostToolUse" "$summary"
}

failure_check() {
  summary=""

  if is_test_command; then
    summary="$(summarize_test_output || true)"
  elif is_terraform_command; then
    summary="$(summarize_terraform || true)"
  elif is_git_diff_command; then
    summary="$(summarize_git_diff || true)"
  elif is_git_status_command; then
    summary="$(summarize_git_status || true)"
  elif is_json_command; then
    summary="$(summarize_json || true)"
  fi

  [ -n "$summary" ] || summary="$(printf '[%s] Bash command failed: `%s`\n%s\n' "$PROJECT_PROFILE" "$COMMAND" "$TOOL_ERROR")"
  emit_context "PostToolUse" "$summary"
}

case "$MODE" in
  pre)
    pre_check
    ;;
  post)
    post_check
    ;;
  failure)
    failure_check
    ;;
  *)
    echo "Unknown mode: $MODE" >&2
    exit 1
    ;;
esac
