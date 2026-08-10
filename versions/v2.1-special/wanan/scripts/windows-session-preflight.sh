#!/usr/bin/env bash

set -u

task_id="${1:-${WANAN_ROOT_TASK_ID:-}}"
if [[ -z "$task_id" || ! "$task_id" =~ ^[A-Za-z0-9._-]+$ ]]; then
  echo "usage: source windows-session-preflight.sh <root-task-id>" >&2
  return 2 2>/dev/null || exit 2
fi

state_root="${WANAN_STATE_ROOT:-$HOME/.wanan/state}"
temp_root="${WANAN_TEMP_ROOT:-$HOME/.wanan/temp}"
if command -v cygpath >/dev/null 2>&1; then
  if [[ "$state_root" =~ ^[A-Za-z]:[\\/].* ]]; then
    state_root="$(cygpath -u "$state_root")"
  fi
  if [[ "$temp_root" =~ ^[A-Za-z]:[\\/].* ]]; then
    temp_root="$(cygpath -u "$temp_root")"
  fi
fi
state_dir="$state_root/$task_id"
env_file="$state_dir/env.sh"
report_file="$state_dir/report.txt"

mkdir -p "$state_dir" "$temp_root" || { return 3 2>/dev/null || exit 3; }

if [[ -f "$env_file" ]]; then
  # shellcheck disable=SC1090
  source "$env_file"
  echo "Wanan preflight cache reused: $report_file"
  return 0 2>/dev/null || exit 0
fi

task_temp="$(mktemp -d "$temp_root/$task_id.XXXXXX")" || { return 3 2>/dev/null || exit 3; }

original_temp="${TEMP:-${TMP:-/tmp}}"
windows_temp=""
if command -v cmd.exe >/dev/null 2>&1 && command -v cygpath >/dev/null 2>&1; then
  windows_temp="$(cmd.exe //D //C 'echo %TEMP%' 2>/dev/null | tr -d '\r' | tail -n 1)"
  if [[ -n "$windows_temp" && -d "$(cygpath -u "$windows_temp")" ]]; then
    original_temp="$(cygpath -u "$windows_temp")"
  fi
fi
temp_entries=0
temp_warning="no"
if [[ -d "$original_temp" ]]; then
  temp_entries="$(find "$original_temp" -mindepth 1 -maxdepth 1 -print 2>/dev/null | head -n 2001 | wc -l | tr -d ' ')"
  if [[ "$temp_entries" -ge 2001 ]]; then
    temp_warning="yes-at-least-2001"
  fi
fi

pwsh_path=""
if command -v pwsh >/dev/null 2>&1; then
  pwsh_path="$(command -v pwsh)"
elif [[ -x "/c/Program Files/PowerShell/7/pwsh.exe" ]]; then
  pwsh_path="C:/Program Files/PowerShell/7/pwsh.exe"
fi

bash_path="$BASH"
if command -v cygpath >/dev/null 2>&1; then
  bash_path="$(cygpath -w "$BASH")"
fi

cat >"$env_file" <<EOF
export WANAN_PREFLIGHT_DONE=1
export WANAN_ROOT_TASK_ID='$task_id'
export WANAN_TASK_TEMP='$task_temp'
export TEMP='$task_temp'
export TMP='$task_temp'
export TMPDIR='$task_temp'
export LANG='C.UTF-8'
export LC_ALL='C.UTF-8'
export PYTHONUTF8='1'
export PYTHONIOENCODING='utf-8'
EOF

cat >"$report_file" <<EOF
root_task_id=$task_id
original_temp=${windows_temp:-$original_temp}
original_temp_scan_path=$original_temp
original_temp_top_level_entries_capped=$temp_entries
original_temp_warning=$temp_warning
dedicated_temp=$task_temp
system_temp_modified=no
git_bash=$bash_path
pwsh7=${pwsh_path:-unavailable}
encoding=UTF-8-process-local
EOF

# shellcheck disable=SC1090
source "$env_file"
echo "Wanan preflight completed once: $report_file"
return 0 2>/dev/null || exit 0
