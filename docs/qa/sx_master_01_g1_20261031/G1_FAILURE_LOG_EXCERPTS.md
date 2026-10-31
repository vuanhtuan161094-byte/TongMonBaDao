# G1 raw failure markers (sanitized excerpt)

Source: official Godot 4.7.2 Windows test stdout/stderr in local QA evidence folders.

## PR #57 — 7d5887cb5f5db452177f06649806dbf44c21e461

- SX01 policy test: ERROR: SX01 FAIL: policy and daily quota roundtrip
- P3 O4/O8/O9: SCRIPT ERROR: Parse Error: Cannot infer the type of "name" variable because the value doesn't have a set type.
- B3 satiety: ERROR: B3 PILL FAIL: CARE capability envelope rejects old readers
- B3 CARE: ERROR: B3 CARE FAIL: reload preserves RNG/HP/timers/receipt/policy exactly

## PR #58 — 30aa335f70fafb6382e4448ca77ebe1f6991db7d

- Medicine runtime: SCRIPT ERROR: Parse Error: Cannot infer the type of "cultivation_before" variable because the value doesn't have a set type.
- SX01 policy test: ERROR: SX01 FAIL: policy and daily quota roundtrip
- B3 satiety: ERROR: B3 PILL FAIL: CARE capability envelope rejects old readers
- B3 CARE: ERROR: B3 CARE FAIL: reload preserves RNG/HP/timers/receipt/policy exactly
- SAFE-01 emits malformed-JSON parse errors for its negative fixtures but reports PASS / exit 0; those expected diagnostics are not grouped with candidate failures.

Full raw files remain on the test host (not saves):
- E:/TongMonBaDaoWorkspace/QA_Evidence/SX_MASTER_G1_QA_20261031/pr57_7d5887c/logs/tests/
- E:/TongMonBaDaoWorkspace/QA_Evidence/SX_MASTER_G1_QA_20261031/pr58_30aa335/logs/tests/
