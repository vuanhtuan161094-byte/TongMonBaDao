#!/usr/bin/env bash
# Godot 4.7.2 may exit 0 while emitting GDScript parse/compilation errors.
# Fail closed on either a nonzero process exit or real engine error markers.
set -euo pipefail
log_dir="${RUNNER_TEMP:-/tmp}/tmb_godot_strict"
mkdir -p "$log_dir"
log="$(mktemp "$log_dir/godot.XXXXXXXX.log")"
set +e
godot "$@" 2>&1 | tee "$log"
exit_code=${PIPESTATUS[0]}
set -e
if [ "$exit_code" -ne 0 ]; then
  echo "GODOT_STRICT_FAIL exit=$exit_code log=$log" >&2
  exit "$exit_code"
fi
if grep -Eq 'SCRIPT ERROR:|(^|[[:space:]])ERROR:|FATAL:|Compilation failed' "$log"; then
  echo "GODOT_STRICT_FAIL engine_errors_detected log=$log" >&2
  exit 1
fi
echo "GODOT_STRICT_PASS exit=0 log=$log"
