# HF01 — Xích Diệm Khai Văn | Hỏa Phù active 01 (Human)

Canonical source: `tmb.skill.talisman.hoa_phu.active_01.human` — `damage / fire / single_target / cap1`, cast 0.50, cooldown 9.4, range 8.5, projectile_speed 8.5, ratio 1.12. The catalogue is a CANDIDATE, V6.3 disabled. No Burn, DoT, spread or stun.

Independent first-party sprite production: `tools/vfx/paint_tal06_xich_diem.py` generates 12 × 256² baked burnt-gold seal frames (1024×768 WebP alpha); 12 × 384×224 organic comet frames (1536×672); 8 × 288×224 scorched-impact frames (1152×448); separated master WebPs and 256×128 restrained ember foot sign. Source is original code-paint, not extracted Source A/JX or promotional screenshot, and the game engine only orchestrates actual RGBA atlas cells, transform, alpha, and soft glows. No rig. Old painterly lightning effects are not recolored or modified.

The LAB draws a **real existing monster walk SpriteFrames atlas** for moving-target QA rather than a standing female substitute. The single previously locked monster moves (not a targeting change). Talisman appears at the caster hand, head travels .64→1.46 toward current monster position, one local demo contact .46→1.80 and scorched ground fades by 2.66. Demo timing is not a Combat V2 hit/receipt; future PvE integration requires separately authorized event and ID routing. True screen-space flying trajectory is not a projectile-speed formula or gameplay mechanic change.

Exact-SHA Godot 4.7.2 GL Compatibility, 1280×720 movie, fourteen stills, GIF, palette/alpha/face-occlusion audit needed. `OWNER_VISUAL_PENDING / PVE_INTEGRATION_HOLD / PHYSICAL_WINDOWS_ANDROID_PENDING`. Do not call a CI test art approval.
