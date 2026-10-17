# Tools and source provenance — Game/APK reverse (17 Oct 2026)

This list references external **upstream projects**; no third-party code, binaries, skills or scripts are imported by this project skill. Always review license, security advisories, exact release version and checksums before a local installation. **No upstream commit/version is pinned or installed by this document.** Never follow upstream `main` blindly, consistent with `skills/SOURCE_LOCK.md`.

| Route | Upstream repository | Why/limits |
| --- | --- | --- |
| General agent skill reference | https://github.com/EncidXVII/claude-reverse-engineering-skill | Cross-format triage and playbooks; a reference, **not** installed/endorsed bundled scripts |
| APK Java/Kotlin | https://github.com/skylot/jadx | DEX→readable Java-like code; incomplete recovery is normal |
| APK resources/Smali | https://github.com/iBotPeaches/Apktool | Decode Android resource table/manifest, Smali; not original Kotlin/Java source |
| Android Python inspection | https://github.com/androguard/androguard | APK/DEX inspection for scripted audits |
| Godot builds | https://github.com/GDRETools/gdsdecomp | PCK and resource recovery/GDScript; validate target Godot version, not native extension source |
| Unity serialized assets | https://github.com/AssetRipper/AssetRipper | Asset analysis/recovery; engine/build/version dependent; GPL-3.0 tool license does **not** confer rights in extracted artwork |
| Unity IL2CPP | https://github.com/SamboyCoding/Cpp2IL | IL2CPP semantic analysis, not complete original source |
| Other native code | https://github.com/NationalSecurityAgency/ghidra | ELF/PE/.so inspection; more costly and deeper than routine asset/UI tasks |
| Optional runtime investigation | https://github.com/frida/frida | Authorized dynamic instrumentation in isolated environment only |

## Decision table

- **APK shell / app metadata**: 7-Zip list + JADX + Apktool; engine check immediately.
- **Godot reference**: GDRETools after version gate; source reconstruction may be partial.
- **Unity reference**: AssetRipper; Cpp2IL only for identified IL2CPP and authorized semantic study.
- **UI/UX demonstration only**: video/screenshots and systematic manual experience; reverse tool often adds no value.
- **Third-party game**: observable interaction can inspire an independently implemented UI. Extracted proprietary assets/code must **not** enter `godot/` or `source_art/` without proof of permission.
- **Source A / ENV-02A**: existing manifest/hash provenance requirements remain fully effective.

## External-agent skill caution

Do **not** run e.g. `npx skills add` or `curl ... | bash` automatically; external SKILL.md may contain executable hooks or instructions. Review dependencies/scripts, pin a specific upstream commit, and obtain explicit installation authorization. This project playbook is original text rather than a verbatim third-party skill distribution.

## Acceptance for this documentation-only packet

1. `SKILL.md` has correct name/description front matter, trigger, routing, rights and sandbox gates.
2. Every tool link points to an identifiable upstream; no false claims that tools were installed or run.
3. Only these two new Markdown files are introduced. No production, QA, balance, CI or game assets changed.
4. Follow-up work remains separately authorized; this doc is **not** evidence any target game has been decompiled or tested.
