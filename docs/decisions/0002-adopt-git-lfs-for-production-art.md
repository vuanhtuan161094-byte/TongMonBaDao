# ADR-0002 — Adopt Git LFS for production art binaries

Status: proposed
Date: 2026-10-03

## Context

The GitHub text connector is reliable for code/Markdown but not for binary asset transport. The Stage A diagnostic ZIP/Base64 detour already demonstrated the cost of trying to move binary data through a text-only path.

Approved building art also exists outside the live repository, which means later sessions can know *that* it is authoritative but cannot reliably recover the exact source file from Git alone.

Godot production needs a durable distinction between:

- editable/source art;
- exported runtime art;
- import metadata;
- generated cache.

## Options

### A. Keep production binaries outside Git

Pros: simple repository.

Cons: weak traceability; approved sources can be lost between machines/chats; mockups may drift because exact references are unavailable.

### B. Store all binaries as normal Git blobs

Pros: simple checkout.

Cons: repository history grows quickly; PSD/Krita/large PNG revisions are inefficient.

### C. Use Git LFS selectively for production source binaries

Pros:

- source art versions travel with the repository;
- large binary history stays out of normal Git blobs;
- Git LFS supports file patterns and lockable files;
- runtime/text/code history remains lightweight.

Cons:

- every development machine must have Git LFS correctly installed;
- enabling it before the current Windows machine is verified could produce pointer-file confusion;
- ChatGPT's GitHub connector may still not render LFS binary content directly, so Library/conversation references remain useful for visual review.

## Proposed decision

Adopt option C **only after a real Windows setup check**.

Planned layout:

```text
source_art/
  p3/
    buildings/
    characters/
    environment/
    ui/
```

`source_art/` stays outside the Godot project root (`godot/`) so Godot does not waste time importing editable master files.

Runtime exports continue under `godot/assets/p3/...` near the scenes/systems that use them.

Initial LFS candidates should be selective, for example editable masters (`*.psd`, `*.kra`) and large source images/archives, rather than blindly migrating repository history.

Do **not** run history-rewriting `git lfs migrate --everything` as part of this adoption unless explicitly reviewed later.

## Godot import metadata rule

When a runtime image becomes a **repo-managed production asset** under `godot/assets/...`:

- track the source runtime image itself;
- commit its generated `<asset>.import` sidecar because it stores the import configuration;
- do not commit the generated `.godot/` cache/imported directory.

The current Stage A proof is a deliberate exception: its PNGs are locally reconstructed diagnostic assets and therefore both those generated PNGs and their `.png.import` sidecars are ignored. **Do not copy that exception into the final production asset pipeline.**

## Acceptance before status becomes accepted

On the user's Windows machine:

1. verify `git lfs version`;
2. run `git lfs install` if needed;
3. add one disposable/small test source asset pattern;
4. commit/push/pull it;
5. verify working tree contains real bytes, not an unresolved LFS pointer;
6. verify existing Godot FAST gate is unaffected;
7. only then update `.gitattributes` for the final selected source-art patterns.

## Consequences if accepted

- binary source art becomes versionable and recoverable;
- approved-source registry entries can point to actual repo paths;
- base64/ZIP-through-text workarounds are retired for production art;
- production runtime `.import` settings become reproducible rather than machine-local accidents;
- GitHub connector remains responsible for text/code, not binary transport.

## Links

- `source_art/README.md`
- `docs/P3_ASSET_REGISTRY.json`
- `docs/P3_PRESENTATION_MASTER.md`
