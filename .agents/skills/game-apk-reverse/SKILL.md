---
name: game-apk-reverse
description: "Phân tích có kiểm soát game APK/AAB/XAPK, PC builds, Unity và Godot (PCK, GDScript, resources, native libs) để học kiến trúc, UI/UX, cấu trúc asset và kiểm toán bản build; dùng khi người dùng yêu cầu reverse engineering game, APK, source hoặc nhận diện engine. Chỉ phân tích được phép; không mặc định sao chép game hay asset bên thứ ba."
---

# GAME / APK REVERSE — TÔNG MÔN BÁ ĐẠO

## 0. Purpose & authority

This is an **agent playbook**, NOT a bundled APK decompiler, source-code extractor, permission grant, background service or executable installer. Read `AGENTS.md`, `skills/SOURCE_LOCK.md` and `references/TOOLS.md` before use. Live `main` gameplay remains canonical; reversing a reference game does NOT establish gameplay truth.

Default scope: inspect authorized builds/assets and produce actionable observations about **map UI, worker assignment, progress bars, mining animations, resource feedback, camera movement, 1280x720 landscape**, and asset/animation formats for *Tông Môn Bá Đạo*. Actual functionality must be confirmed in project source and tests, not guessed from reference screenshots.

## 1. Mandatory gates

1. **RIGHTS** — Record owner, source URL/filename, explicit permission/terms, and intended operation: inspect only vs reuse. If rights are unknown, allow lawful high-level observation but do **NOT** redistribute, import or present extracted proprietary code/art as reusable game assets. If access is unauthorized, STOP. Extracting a file is NOT a license to use it. VLTK1 third-party art remains unverified; Source A has project-specific proof requirements.
2. **INTEGRITY** — Copy input read-only into an isolated analysis area *outside* `godot/`, `source_art/` and `user://`; record exact filename, file size, SHA-256 and provenance. Keep originals immutable. Never overwrite local game, saves or assets.
3. **SAFETY** — Treat unknown APKs/binaries as untrusted. Static-first; do not execute unknown programs, installers or scripts from repos. No pipe-to-shell installation. Use isolated VM/emulator for dynamic tests only with permission. Never upload proprietary APKs to public scanners or third-party services without approval.
4. **CHANGE CONTROL** — Tool analysis is read-only by default; NEVER silently modify GitHub `main`, game source, balance, tests, CI, workflow or install tools. Proposed game-code or asset imports require separate authorized packet per `AGENTS.md`. Never start CI or merge automatically.
5. **TRUTH** — Mark findings VERIFIED_STATIC, VERIFIED_RUNTIME, INFERRED, or UNVERIFIED. Decompiled code is approximate, renamed/optimized content may be missing; exact original source is NOT guaranteed. No fabricated screenshots, routes, assets, model/animation files or PASS statuses.

## 2. Route by artifact, not by extension alone

- `*.apk`, `*.xapk`, `*.aab` → inspect ZIP structure / `AndroidManifest.xml`, `classes*.dex`, `lib/*`, `assets/*`; use JADX for Java/Kotlin wrappers and Apktool for resources/Smali. Fingerprint engine **before** attempting recovery.
- Godot (PCK / embedded PCK / Godot APK) → GDRETools/gdsdecomp for PCK resources/GDScript recovery, with explicit **version compatibility gate** (Godot 4.7.2 support must be tested on the actual target). GDExtension/native code may not be reconstructable.
- Unity (Unity data layout, `globalgamemanagers`, `*.assets`, `libil2cpp.so`, `global-metadata.dat`) → AssetRipper for serialized assets; Cpp2IL for IL2CPP semantics; Ghidra for authorized native investigation. Tools have version/build limitations. **Unity .NET/Mono vs IL2CPP** must be distinguished first.
- Unknown engine / ELF / PE / `*.so` → fingerprint with basic file metadata and Ghidra only when necessary.
- Raw `*.png`, `*.atlas`, `*.json`, Spine files → inspect manifest, dimensions, atlases, rig linkage, license and hashes. Do not label an exported image as a rig or substitute generated art for Source A.
- No binary available, only gameplay video/screenshots → analyze UX as observation; do not claim source, engine, exact rates, hitboxes or timers.

## 3. Minimal Windows workflow (offline/static)

Run from a **separate read-only input** and empty output directory; choose actual paths:

```powershell
Get-Item "D:\Analysis\input\sample.apk" | Select-Object FullName,Length
Get-FileHash "D:\Analysis\input\sample.apk" -Algorithm SHA256
# If 7-Zip is already installed: list only. Do not execute the APK.
7z l "D:\Analysis\input\sample.apk"
# Optional tools ONLY if already installed and approved:
jadx -d "D:\Analysis\out\jadx" "D:\Analysis\input\sample.apk"
apktool d "D:\Analysis\input\sample.apk" -o "D:\Analysis\out\resources"
```

For Godot/Unity, consult verified upstream usage instructions, install from reviewed releases **only after separate approval**, and keep extracted output outside the game repo. Do not run full recovery merely because a file has `.apk` extension. Do not automatically rebuild/re-sign APKs or deploy to phones.

## 4. Evidence → game improvement (not source copying)

For a comparison with `Ta Là Tông Sư` / `最强祖师` or other games, record:
- Visible player action → feedback (e.g. assign one disciple → walk to mine → mining state → progress/timer → exact awarded amount → warehouse).
- What is visible vs what is merely assumed; zoom, animation, naming, touch targets and legibility.
- Relevant *Tông Môn Bá Đạo* authority paths, gaps, proposed minimal packet and exact acceptance proof.
- UI presentation never fabricates output: the **canonical scheduler/warehouse/job authority** determines reward amounts, not animations.
- Separate rights column: OBSERVE ONLY / REUSE AUTHORIZED / UNKNOWN. No direct copying of proprietary decompiled code or third-party sprites.

## 5. Deliverables and stop conditions

Produce `reverse_report.md` **outside the repo unless explicitly instructed otherwise**, containing: target and hash, permission/provenance, engine fingerprint and uncertainty, tools with versions, commands attempted, paths inspected, extracted inventory counts/hashes, concrete findings with evidence pointers, limitations, reusable-art rights decision, and next actions.

Stop at RIGHTS/INTEGRITY/SAFETY blockers. Label blocked steps `PENDING`, not PASS. If Godot 4.7.2 runtime or a Windows tool is unavailable, label **RUNTIME PENDING**. Never present recovered/decompiled output as the original authoring project without independent validation.
