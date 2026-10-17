---
name: game-apk-reverse
description: "Dùng khi được yêu cầu phân tích hợp lệ game, APK/AAB/XAPK, Godot PCK hoặc Unity build: nhận diện engine, phân tích tĩnh, UX và asset provenance. Không dùng để tự động cài công cụ, phá bảo vệ, lấy asset không có quyền hoặc thay đổi game."
---

# GAME / APK REVERSE — TÔNG MÔN BÁ ĐẠO

## 0. Purpose & authority

This is an **instruction-only agent skill**, NOT a bundled decompiler, source-code extractor, permission grant, background service or executable installer. It does not install or run upstream tools by itself.

**Codex discovery:** Use this skill only when the working checkout contains `.agents/skills/game-apk-reverse/SKILL.md`. From the repository root (or a descendant), run `/skills` and select `game-apk-reverse`, or mention `$game-apk-reverse` explicitly. Automatic selection depends on Codex skill discovery and the metadata; **a draft PR that has not been checked out or merged does not make the skill available on `main`**. If Codex does not detect a newly checked-out skill, restart Codex. This is a static format/placement assessment, **not** a live Codex activation test.

**Authority:** Read repository-root `AGENTS.md`, `docs/GAME_SYSTEM_ARCHITECTURE.md`, `skills/SOURCE_LOCK.md` and this skill's `references/TOOLS.md` (relative to the SKILL.md directory). `AGENTS.md` currently disallows Codex/Work for **repository coding** without a new explicit user instruction. This skill does not override that rule. Live `main` gameplay remains canonical; reversing a reference game does NOT establish gameplay truth.

Default scope: inspect authorized builds/assets and produce actionable observations about **map UI, worker assignment, progress bars, mining animations, resource feedback, camera movement, 1280x720 landscape**, and asset/animation formats for *Tông Môn Bá Đạo*. Actual functionality must be confirmed in project source and tests, not guessed from reference screenshots.

## 1. Mandatory gates

1. **RIGHTS** — Record source URL/filename, lawful possession/access, rights holder or publisher when known, relevant terms, and the intended operation: observation, reverse analysis, or reuse. Verify applicable law and restrictions for the proposed act; this skill does not grant permission to bypass DRM, accounts, encryption, licensing or technical controls. If authority for the proposed operation is missing, STOP that operation; public screenshots/observable UX may still be studied independently when lawful. Never redistribute or import extracted proprietary code/art without verified reuse rights. Extraction does not grant a license. VLTK1 third-party art remains unverified; Source A requires existing provenance proof.
2. **INTEGRITY** — Keep original input immutable; use a separate copy and empty output folder *outside* `godot/`, `source_art/`, existing game workspace and `user://`. Record exact filename, byte size, SHA-256, build/source context, and provenance. Never overwrite local game, save, approved asset or the input. Inspect extraction paths and archive sizes first (path traversal/zip bombs), and use a sandbox when handling untrusted archives.
3. **SAFETY** — Treat unknown APKs/binaries as untrusted. Static-first; do not execute unknown programs, installers or scripts from repos. No pipe-to-shell installation. Use isolated VM/emulator for dynamic tests only with permission. Never upload proprietary APKs to public scanners or third-party services without approval.
4. **CHANGE CONTROL** — Tool analysis is read-only by default; NEVER silently modify GitHub `main`, game source, balance, tests, CI, workflow or install tools. Proposed game-code or asset imports require separate authorized packet per `AGENTS.md`. Never start CI or merge automatically.
5. **TRUTH** — Mark findings VERIFIED_STATIC, VERIFIED_RUNTIME, INFERRED, or UNVERIFIED. Decompiled code is approximate, renamed/optimized content may be missing; exact original source is NOT guaranteed. No fabricated screenshots, routes, assets, model/animation files or PASS statuses.

## 2. Route by artifact, not by extension alone

- `*.apk`, `*.xapk`, `*.aab` → list archive entries and identify packaging first. A normal APK may contain `AndroidManifest.xml`, `classes*.dex`, `lib/*`, `assets/*`; **AABs use modules** (for example `base/manifest/AndroidManifest.xml`), while XAPK may contain multiple split APKs and optional OBB/data. Do not assume one root APK layout. JADX analyzes DEX bytecode (Java-like output, not original Kotlin); Apktool handles APK resources/Smali (AAB/XAPK require format-aware unpacking first). Inspect game content/engine only after the container layout and provenance are known.
- Godot (PCK / embedded PCK / Godot APK) → GDRETools/gdsdecomp for supported archive, resource and GDScript operations. Identify **the source game build version** before choosing a compatible GDRETools release; the *Tông Môn Bá Đạo* Godot **4.7.2** baseline is a separate runtime target and does not imply the source APK uses 4.7.2. Upstream states Godot 2.x–4.x families are supported, **not guaranteed for each future minor release or encrypted/custom builds**. Native GDExtension/GDNative and C# scripts cannot be reconstructed by GDRETools.
- Unity (Unity data layout, `globalgamemanagers`, `*.assets`, `libil2cpp.so`, `global-metadata.dat`) → AssetRipper for serialized assets. Distinguish **Mono/.NET** (`*_Data/Managed/*.dll`, e.g. `Assembly-CSharp.dll`) → ILSpy for authorized .NET inspection, from **IL2CPP** (`libil2cpp.so`/GameAssembly plus metadata) → Cpp2IL for partial reconstructed managed structure; Ghidra only for necessary authorized native investigation. Unity/C++/IL2CPP source decompilation is not a guarantee of original gameplay code, names or scenes. Tool support varies by game/engine version.
- Unknown engine / ELF / PE / `*.so` → fingerprint with basic file metadata and Ghidra only when necessary.
- Raw `*.png`, `*.atlas`, `*.json`, Spine files → inspect manifest, dimensions, atlases, rig linkage, license and hashes. Do not label an exported image as a rig or substitute generated art for Source A.
- No binary available, only gameplay video/screenshots → analyze UX as observation; do not claim source, engine, exact rates, hitboxes or timers.

## 3. Minimal Windows workflow (offline/static)

Run from a **separate read-only input** and empty output directory; choose actual paths:

```powershell
$inputFile = "D:\Analysis\input\sample.apk" # replace with an authorized sample
Get-Item -LiteralPath $inputFile | Select-Object FullName,Length
Get-FileHash -LiteralPath $inputFile -Algorithm SHA256
# List only: run if 7-Zip is already installed and approved.
if (Get-Command 7z -ErrorAction SilentlyContinue) { 7z l $inputFile }
# Optional decompilation, separately approved; examples assume supported APK, not AAB/XAPK:
# jadx.bat -d "D:\Analysis\out\jadx" $inputFile
# apktool.bat d $inputFile -o "D:\Analysis\out\resources"
# On Windows, exact wrapper names and options depend on reviewed installed releases.
```

For any engine, consult the **pinned, reviewed release** instructions before executing; tool availability and command compatibility are **PENDING** until actually verified. Installing/downloading tools requires separate approval. Do not run full recovery merely because a file has `.apk` extension. Never auto-rebuild/re-sign, modify installed applications, bypass protections, or deploy to phones. Check the output location is new, empty and outside the game workspace before running any extractor.

## 4. Evidence → game improvement (not source copying)

For a comparison with `Ta Là Tông Sư` / `最强祖师` or other games, record:
- Visible player action → feedback (e.g. assign one disciple → walk to mine → mining state → progress/timer → awarded amount when **actually observable** → warehouse when **actually observable**).
- What is visible vs what is merely assumed; zoom, animation, naming, touch targets and legibility.
- Relevant *Tông Môn Bá Đạo* authority paths, gaps, proposed minimal packet and exact acceptance proof.
- UI presentation never fabricates output: the **canonical scheduler/warehouse/job authority** determines reward amounts, not animations.
- Separate rights column: OBSERVE ONLY / REUSE AUTHORIZED / UNKNOWN. No direct copying of proprietary decompiled code or third-party sprites.

## 5. Deliverables and stop conditions

Produce `reverse_report.md` **outside the repo unless explicitly instructed otherwise**, containing: target and hash, permission/provenance, engine fingerprint and uncertainty, tools with versions, commands attempted, paths inspected, extracted inventory counts/hashes, concrete findings with evidence pointers, limitations, reusable-art rights decision, and next actions.

Stop at RIGHTS/INTEGRITY/SAFETY blockers. Label blocked steps `PENDING`, not PASS. Distinguish **FORMAT/STATIC REVIEW**, **CODEX DISCOVERY PENDING LOCAL**, **EXTRACTION PENDING AUTHORIZED SAMPLE**, and **WINDOWS/GODOT RUNTIME PENDING USER**. No screenshot review or reverse report proves a playable game feature without backend and runtime evidence. Never present recovered/decompiled output as the original authoring project without independent validation.

### Document-only acceptance checklist

- [ ] SKILL.md has valid YAML `name`/`description`, directory name matches, and relative reference exists.
- [ ] Codex discovery path is valid; **local enumeration/invocation remains unverified** without a checkout/session.
- [ ] Engine paths, APK vs AAB/XAPK, Unity Mono vs IL2CPP, Godot and native limits are accurately separated.
- [ ] No upstream scripts installed; no input binaries decompiled or redistributed; no permission/QA claims invented.
- [ ] GitHub diff is docs-only; no gameplay, asset, CI or main changes.

