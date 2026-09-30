from pathlib import Path
import sys

root = Path(__file__).resolve().parents[1]
gd = root / "godot"
required = [
    "project.godot",
    "scenes/p0/p0_sandbox.tscn",
    "src/simulation/core/game_rng.gd",
    "src/simulation/core/p0_factory.gd",
    "src/simulation/core/simulation_scheduler.gd",
    "src/simulation/state/simulation_state.gd",
    "src/simulation/ai/decision_system.gd",
    "src/simulation/combat/combat_system.gd",
    "src/simulation/economy/economy_system.gd",
    "src/simulation/save/save_service.gd",
    "tests/simulation/p0_invariant_test.gd",
    "tests/simulation/p0_save_roundtrip_test.gd",
]
missing = [p for p in required if not (gd / p).exists()]
if missing:
    print("STATIC SANITY FAIL: missing", missing)
    sys.exit(1)

tokens = {
    "seeded rng": "RandomNumberGenerator",
    "money invariant": "Money conservation failed",
    "behavior gate": "danger_visits",
    "save version": "SAVE_VERSION",
    "11 action coverage": '&"REST"',
}
corpus = "\n".join(p.read_text(encoding="utf-8") for p in gd.rglob("*.gd"))
for label, token in tokens.items():
    if token not in corpus:
        print(f"STATIC SANITY FAIL: {label} token missing: {token}")
        sys.exit(1)

print("STATIC SANITY PASS")
print("GDScript files:", len(list(gd.rglob("*.gd"))))
