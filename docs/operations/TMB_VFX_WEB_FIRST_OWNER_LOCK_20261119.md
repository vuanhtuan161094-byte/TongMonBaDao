# TMB — WEB-FIRST VFX REVIEW / ONE CANONICAL PAGES SITE · 19/11/2026

**Owner decision:** Test VFX interactively on web instead of generating MP4 at every revision. This changes presentation/review, NOT the Art-First V4 G3/G3.5/G7 quality gates or Combat V2 authority. No parallel game, rig, Codex Cloud, merge, or PvE attach.

## One address, two roles

- Existing canonical game: same GitHub Pages site, path `/play/`, still the ONLY playable game.
- New isolated VFX art reviewer: same domain/site, path `/vfx/`. Clearly LAB_ONLY, not another game and cannot write saves, damage, XP or releases.
- Wiki stays `/wiki/`. Pages workflow `wiki-player-pages.yml` builds all paths together and deploys ONE Pages artifact. No extra branch or second Pages environment.

Godot 4.7.2 Web export uses Compatibility/WebGL2 and no threads (`variant/thread_support=false`), matching the official site's existing export templates. The browser view is interactive, not a video. Web will be faster for owner's repeated inspection after deployment, but native/physical-device rendering may still differ. Export requires HTML/JS/WASM/PCK, not a standalone single HTML.

## First published VFX scenario

AS48 Kiếm Tu male, Phi Kiếm Truy Ảnh, Human. Reviewer reuses REAL existing AS48 candidate four Front attack cels; separate jian texture, four V9.3 frame grips, real moving monster, and technical shader cue routed by read-only event bridge. Cast and hit events are synthetic LAB_ONLY, never actual battle hits.

- Click Thử lại chiêu to replay; buttons toggle pause, moving monster, VFX on/off, dark/bright backdrop, actor 1×/2× and speed 0.25× to 2×.
- Asset and FX source are copied byte-for-byte by `tools/vfx/stage_vfx_web_review.py` into ephemeral CI export stage. Copies are not committed as a second game; Codex-owned asset sources remain untouched.
- Only FRONT is confirmed; missing directions need authentic actor/anchor source. Future skill candidates can enter the SAME Web hub after passing source checks. No placeholder school options suggesting unavailable art.
- Existing Sword shader is TECHNICAL_CUE_ONLY, not approved Art-First illustrated G3 source and not final Sword VFX art.

## CI build and review

1. On applicable PR #72 commits, existing Pages workflow checks Wiki/game and exports the canonical game `/play/`.
2. Same job stages a tiny VFX-only Godot export from exact same SHA, verifies actual source hashes, imports, parses, runs one focused logic smoke and exports to `/vfx/`. No routine MP4 encoding.
3. One Pages deployment publishes game, wiki, reviewer together. Fail any step => do not claim new revision is live. `build-info.txt` records exact SHA and status if export succeeds.
4. Native MovieWriter workflow `.github/workflows/vfx-sword-as48-anchor-native.yml` is manual `workflow_dispatch`, not a video on every change. Art-First V4 native G3.5 is still required after real RGBA source and moving-target preflight; owner art approval separate.

**Status boundary:** This begins with one AS48 isolated technical sample. Neither 4 directions nor original Human Sword VFX G3 art approval is granted by an HTML export.

## Review link

`https://vuanhtuan161094-byte.github.io/TongMonBaDao/vfx/` — verify Pages deploy before claiming working.

Official Godot docs: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_web.html
