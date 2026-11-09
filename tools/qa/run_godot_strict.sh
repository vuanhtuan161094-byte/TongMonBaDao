#!/usr/bin/env bash
# Official Godot 4.7.2 can return exit 0 while emitting script errors.
# Strict by default; one explicit O9 harness teardown RID debt exception.
set -euo pipefail
allow_test_teardown_rids=0
if [ "${1:-}" = "--allow-o9-test-teardown-rid-leaks" ]; then
  allow_test_teardown_rids=1
  shift
fi
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
engine_errors="$(grep -E 'SCRIPT ERROR:|(^|[[:space:]])ERROR:|FATAL:|Compilation failed' "$log" || true)"
if [ "$allow_test_teardown_rids" -eq 1 ] && [ -n "$engine_errors" ]; then
  debt_regex='^ERROR: [0-9]+ RID allocations of type .* were leaked at exit\.$'
  debt_lines="$(printf '%s\n' "$engine_errors" | grep -E "$debt_regex" || true)"
  if [ -n "$debt_lines" ]; then
    echo "GODOT_QA_DEBT=o9_renderer_shutdown_rid_leaks"
    printf '%s\n' "$debt_lines"
  fi
  engine_errors="$(printf '%s\n' "$engine_errors" | grep -Ev "$debt_regex" || true)"
fi
if [ -n "$engine_errors" ]; then
  printf '%s\n' "$engine_errors" >&2
  echo "GODOT_STRICT_FAIL engine_errors_detected log=$log" >&2
  exit 1
fi
echo "GODOT_STRICT_PASS exit=0 log=$log"
