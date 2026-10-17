# Tools, compatibility and provenance — Game/APK reverse (17 Oct 2026)

**Status:** upstream reference audit only. These URLs identify external projects; no code, binary, third-party skills or executables are installed, embedded or pinned by this PR. Before any installation/recovery, review each tool's **exact release/commit, license, provenance, checksums, security advisories and target-format compatibility**, then request permission. Do not silently track upstream `main`. This follows `skills/SOURCE_LOCK.md`.

## Codex skill loading — VERIFIED DOCUMENTATION, NOT LIVE-RUN

- Official skill docs: https://learn.chatgpt.com/docs/build-skills
- Repo skill path: `.agents/skills/game-apk-reverse/SKILL.md`; references live in `references/TOOLS.md` relative to `SKILL.md`. Required front matter keys: `name` and `description`; `agents/openai.yaml` and executable helpers are **optional**.
- Codex searches `.agents/skills` from current directory up to repository root. Invoke using `/skills` then select `game-apk-reverse`, or type `$game-apk-reverse`; matching descriptions can also select implicitly. If a skill is not reflected after checkout, restart the session.
- A **draft PR only** does not install a skill on the **main** checkout. Confirm branch/tree and active Codex workspace before attempting discovery. No Codex runtime activation test is claimed for this documentation audit.
- Existing project `AGENTS.md` bans Codex/Work for **repository coding** without a separate explicit instruction; skill discovery or analysis is NOT implementation authorization.

## Audited tool routing

| Target or route | Verified upstream | Capabilities and constraints |
| --- | --- | --- |
| General agent skill *reference only* | https://github.com/EncidXVII/claude-reverse-engineering-skill | Upstream describes Codex CLI support. Do **not** install the external skill, trust its scripts, or claim its content is copied here. This project's `SKILL.md` is independently authored. |
| Android DEX in APK / AAB | https://github.com/skylot/jadx | DEX→Java-like decompilation with CLI and GUI; often incomplete and never original Kotlin project; review release-specific AAB/XAPK handling. |
| Standard Android APK resources / Smali | https://github.com/iBotPeaches/Apktool | APK resource/manifest decoding and Smali; **not** original Java/Kotlin. For AAB/XAPK, identify/extract contained APK modules first; do not treat package types as identical. |
| Optional scripted APK / DEX inspection | https://github.com/androguard/androguard | Python API and tools for structured static inspection; optional, not a default requirement. |
| Godot PCK, APK or embedded game | https://github.com/GDRETools/gdsdecomp | Reads supported Godot 2.x–4.x family builds; GDScript/resource recovery depends on exact build and support. Does not recover GDExtension, native, or Mono/C# source. No confirmed **Godot 4.7.2** target compatibility without testing that version. |
| Unity serialized assets | https://github.com/AssetRipper/AssetRipper | Unity asset / dependency and export analysis. Upstream states 3.5.0–6000.4.X support with varying quality. Tool GPL-3.0 ≠ rights to original game assets. |
| Unity Mono managed assemblies | https://github.com/icsharpcode/ILSpy | .NET/Mono assembly browser and decompiler for available C# DLLs, e.g. `Assembly-CSharp.dll`. Not useful for raw IL2CPP native game binary alone. |
| Unity IL2CPP | https://github.com/SamboyCoding/Cpp2IL | Work-in-progress IL2CPP metadata/native processing to partially recover managed structures; upstream notes incomplete CIL output and changing CLI. Not original code. |
| Native ELF/PE/.so examination | https://github.com/NationalSecurityAgency/ghidra | Lower-level disassembly/decompilation when separately authorized; not a routine Unity/Android asset extractor. |
| Optional dynamic instrumentation | https://github.com/frida/frida | Advanced investigation in isolated environment and only with explicit rights/approval; not required for ordinary UI/UX work. |

Upstream source/compatibility pointers:
- Codex format and discovery: https://learn.chatgpt.com/docs/build-skills
- Godot support and limitations: https://github.com/GDRETools/gdsdecomp#readme
- Unity AssetRipper limitations and asset range: https://github.com/AssetRipper/AssetRipper#readme
- Unity Mono assembly issue guide: https://github.com/AssetRipper/AssetRipper/blob/master/docs/articles/CommonIssues.md
- JADX README and command formats: https://github.com/skylot/jadx#readme
- Apktool project: https://github.com/iBotPeaches/Apktool
- Cpp2IL WIP and ILSpy recommendation: https://github.com/SamboyCoding/Cpp2IL#readme

## Correct decision tree

1. **Only reference video/screenshots:** Analyze player UX/flows. No executable decompiler or engine classification is justified.
2. **APK:** Inspect ZIP inventory and package structure, package name/metadata when permitted. `classes*.dex`/Android UI → JADX; resources/Smali → Apktool. Engine artifacts guide the next branch.
3. **AAB:** Modules (`base/`, feature modules) and manifests differ from APK. **XAPK:** multiple APK splits/OBB may exist. First identify constituent files; do not blindly use Apktool as if the container were a single APK.
4. **Godot:** Detect engine/version and whether a recoverable PCK exists; use supported GDRETools release and record failure modes. Godot **4.7.2** for *Tông Môn Bá Đạo* does not prove the reference game's engine version.
5. **Unity:** Inspect Unity data formats with AssetRipper; if `Managed/*.dll` indicates Mono, use ILSpy. If `libil2cpp.so` or `GameAssembly.dll` plus matching metadata indicates IL2CPP, evaluate Cpp2IL; use Ghidra only if needed.
6. **Unidentified native:** Passive file identification first; Ghidra only within explicitly authorized low-level scope.
7. **Use in *Tông Môn Bá Đạo*:** Keep reference-game observations separate from canonical Godot simulation state. Recreate behavior independently; never import proprietary recovered bytes without rights.

## Windows command review (examples, not executed)

- Built-in PowerShell: `Get-FileHash -LiteralPath $inputFile -Algorithm SHA256`.
- 7-Zip list: `7z l $inputFile` only if `Get-Command 7z` succeeds. Listing is not content validation.
- JADX decompile: on supported Windows installation, `jadx.bat -d <new_output_folder> <input.apk>`; *do not assume every XAPK/AAB can be handled as APK*.
- Apktool: depending on installed wrapper, `apktool.bat d <input.apk> -o <new_output_folder>` or a verified `java -jar apktool_*.jar d ...`. Only on a standard APK after safety and rights gates.
- Commands are **examples**; tool versions and local executables were not verified or run. Decompilation writes generated files, so enforce isolated output and immutable input; do not run from within the Godot repo.

## Governance and rights

- Software tool licenses apply to the **tool**; extracted third-party graphics/code remain subject to their own rights and applicable law.
- No automatic acquisition of reference-game APKs, bypass of DRM/online service authentication, proprietary-source redistribution, publishing decompiled data, or runtime instrumentation.
- **Source A / ENV-02A** require existing manifests, file identity and SHA-256 evidence; **VLTK1** original art rights remain unverified.
- Do not install external skills via `npx skills add`, `curl | bash`, script hooks or a clone-and-run shortcut. If approved later, inspect and pin the reviewed upstream commit.
- Without an actual authorized binary, the document audit is **STATIC VERIFIED**, but recovery, Codex loading, Windows and Godot runtime all remain **PENDING**.

## Acceptance criteria — documentation-only packet

1. Repo skill path and YAML front matter agree with official Codex docs, and referenced file exists.
2. Source repositories exist and are mapped accurately; Mono vs IL2CPP and APK vs AAB vs XAPK are distinct.
3. No claim of release pinning, installation, extraction or runtime test. No proprietary asset/source rights inferred.
4. Only `SKILL.md` and `references/TOOLS.md` are edited/added in this PR. No engine gameplay, CI, QA assertions, save, assets or `main` changes.
