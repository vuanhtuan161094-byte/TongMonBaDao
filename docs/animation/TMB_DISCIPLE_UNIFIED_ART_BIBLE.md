# TMB DISCIPLE UNIFIED ART BIBLE

Date: 2026-11-11  
Authority: Issue #77, PR #72 HEAD 7587e2be5bb0800d6c84d4fb28e35c8951bebcc0
Status: WORKING CONTRACT — NOT OWNER VISUAL ACCEPTANCE

## 1. Purpose and authority

This bible defines one visual family for disciple sprites. The accepted Nữ Độc Tu is the style anchor, not permission to recreate her identity from an incomplete atlas. Keep source art, turnarounds, map actors, and combat actors separate. Do not change gameplay, SaveService, Combat V2/V5, the P3.2 runtime actor, or approved files in this packet.

Issue #77 overrides the older P3.2 art direction only for the isolated disciple-family visual pilot. The canonical P3.2 rig, canvas and gameplay authority remain unchanged.

## 2. Locked female identity and source status

The owner-locked source is image(20261109-102800).png, 1448×1086, SHA-256 435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118. Its design is long violet-black hair, jade/gold ornament and tassels, emerald eyes and forehead poison rune, black/jade robe with antique-gold trim, adult Shadow Chibi proportions. Preserve the known neck/shoulder alignment debt and the approved face, outfit, and palette.

The exact master was found in the owner-provided TMB_Poison_V4_Ket_Qua_Godot7_Sprite_20261110.zip. Its SHA-256 435f8969c3d89468ddbdec837a44365b212b58e01082728c3f21f2b08249c118 matches the immutable locked identity exactly. It is committed at godot/labs/character_family/assets/nu_doc_tu_v4_candidate/owner_approved_master.png. The earlier BLOCKED_SOURCE_ART lookup is superseded. No male/female healer master is approved yet.

The six older Grok-derived sheets remain unchanged and visual-only. Their manifest is three-quarter-right and the original video package is absent; they are not replaced by this four-direction candidate.

## 3. Shared visual rules

- Mature compact chibi: 3.0–3.5 heads tall. At the map target, the silhouette must read at 60–75 px.
- One pixel density and edge language across the family. Use deliberate pixel clusters, not a mixture of smooth portrait painting and pixel edges.
- Stable upper-left key light, dark violet/ink shadow family, restrained jade, antique gold, and natural skin. Role palettes may shift within this family.
- Material separation must remain readable at target size: hair mass, cloth, leather, metal, and skin use different cluster shapes and value steps.
- Every direction depicts the same identity, age, face, hairline, outfit construction, accessories, and proportions. A back view hides the face; a profile is a true profile.
- Four authored views are front, right, back, and left. Do not mirror an asymmetric design unless its manifest explicitly says mirror_safe=true and a visual check confirms it.
- Feet are complete, share the ground line, and retain visible negative space between legs. No image may touch or cross its canvas or direction-cell boundary.
- Use a neutral consistent background for review. Do not bake VFX, aura, attack glow, text, labels, or a floor into character sprites.
- Candidate assets are never runtime-ready until their source, editable layers, canvas, pivot, and directional continuity are reviewed.

## 4. Identity design boundaries

### Nữ Độc Tu — locked identity

Retain the locked face, emerald eyes, forehead mark, crown/ornament, long violet-black hair, jade/gold robe and tassels. Do not use the current three-quarter atlas to infer unseen front/back/left design details. Do not replace it with the independent healer candidate.

### Male sword cultivator — distinct identity

Use a broader angular shoulder line, segmented armor, restrained serpent motif, stern adult facial structure, short/medium tied hair, and a sheathed sword. It must read as a different person and costume, not a face-swapped Nữ Độc Tu.

### Additional female healer — distinct identity

Use a practical hairstyle and healer silhouette, separate from the Poison Tu crown/long-hair identity. Keep the shared family palette and material language. Do not add poison marks, effects, or borrowed face details.

## 5. Separate canvas contracts

### Map actor

Follow docs/P3_2_MODULAR_ACTOR_SPEC.md: 128×128 RGBA, foot anchor (64,104), no auto-crop, common registration, public directions down/right/up/left. Keep the actor around 60–75 px at map zoom 1.0. The family contact sheets in this packet are not map exports.

### Combat actor

Follow Issue #77: 160×192 RGBA, pivot (80,179). Keep it a separate export from the map canvas. Do not enlarge a map actor to create a combat portrait.

## 6. Motion contracts — no fake motion

- idle: one still frame is permitted. No invented blink or body sway.
- walk: needs front/back and side contact/pass keys, independent leg articulation, arm counter-swing, a clean loop, and rooted feet.
- cast: separate preparation, seal, release event marker, and recovery.
- attack: distinct wind-up, strike/contact, and recovery.
- hit: clear recoil and response.
- death: controlled collapse and settled pose.
- No per-frame AI rerenders, whole-image warps, camera-only attacks, or substituting one clip for another. A missing clip stays MISSING.
- Every event marker must match a real authored motion frame. VFX must not manufacture gameplay events.
- The existing Grok atlas sequence may be previewed as its real stored frames; it does not prove the four-direction family or locked-source identity.

## 7. Editable source and rig handoff

Every accepted master must retain an editable layered source (ORA or equivalent) and record source hashes, authoring tool, canvas, cell layout, pivot/foot anchor, view mapping, layer names, and export settings. Keep underlap at joints and provide complete hidden regions before rigging. Weapon and accessories are separate layers when they move independently.

Use one shared coarse rig per compatible body family only after the master and joint underlap are reviewed. Avoid fragmenting the character into tiny pieces. Do not deform the face, eyes, hands, feet, or entire image to simulate motion.

## 8. Required asset statuses

- APPROVED_SOURCE: exact owner-approved source and provenance present.
- CANDIDATE_NOT_APPROVED: usable only in an isolated review.
- BLOCKED_SOURCE_ART: the locked source is absent or hash does not match.
- REJECTED: a reproducible quality failure exists.
- NOT_AUTHORED: no real clip/layer has been made.
- VERIFIED_FILE: checksum, dimensions and file availability passed; this is not visual acceptance.
- PENDING_OWNER_VISUAL: user review is still required.
- RUNTIME_NOT_INTEGRATED: not referenced by production scenes.

Never infer APPROVED from a manifest, a passing parser, or a Godot import.

## 9. Stage gates

1. AS-CHAR-01: inventory existing, approved, candidate, rejected, missing, and runtime-used files; keep provenance and hashes.
2. AS-CHAR-02: review the three-character family at the same scale, camera, light, ground line, and neutral background. Locked female source absence blocks her rebuild; independent candidates do not unlock her.
3. AS-CHAR-03: author and review real motion before creating looping GIF/MP4 evidence. Show one action sheet at a time. Current generated turnarounds are static only.
4. AS-CHAR-04: do not create cosmetic combinations or a 30-character lineup until AS-02 and AS-03 receive visual approval.
5. AS-CHAR-05: integrate only after isolated Godot visual and runtime evidence, with explicit owner approval. Windows/Android physical evidence remains separate from headless checks.

## 10. Current guardrail

The character-family lab added with Issue #77 is an isolated reviewer only. It uses the existing Nữ atlas as a real frame sequence and displays two new independent static candidates. It does not replace source art, create a production resource path, modify a shared scene, or claim an animation pass.

## 11. Current source archive and candidate boundary

The supplied V4 ZIP is preserved with its seven PNG source/atlas files and four animated GIF previews in the isolated character-family review area. The approved master hash matches the immutable identity; action atlases remain CANDIDATE_NOT_FOR_PRODUCTION. Their static alpha-grid report has unresolved visual review and they have not been imported or played by Godot 4.7.2. Green projectile/light pixels are baked into Cast/Attack. The builder references raw action images absent from the ZIP, so export regeneration is not reproducible from this package alone.

The separate ECO-07 virtual-GUI ZIP contains gameplay/UI screenshots and metrics, not character art. It is useful as a 1280×720 UI reference, not as sprite or animation source.
