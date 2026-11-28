#!/usr/bin/env bash
set -euo pipefail
# Ubuntu packaged Noto (SIL OFL), same faces for Godot capture and Web export.
# No changes to the map or underlying game state.
cd "$(dirname "$0")/../.."
if [[ ! -s /usr/share/fonts/truetype/noto/NotoSans-Regular.ttf || ! -s /usr/share/fonts/truetype/noto/NotoSerif-Regular.ttf ]]; then
  sudo apt-get update -qq
  sudo apt-get install -y -qq fonts-noto-core
fi
target=godot/art/uiux/fonts
mkdir -p "$target"
for name in NotoSans-Regular.ttf NotoSans-Bold.ttf NotoSerif-Regular.ttf; do
  install -m 0644 "/usr/share/fonts/truetype/noto/$name" "$target/$name"
  test -s "$target/$name"
done
if [[ -f /usr/share/doc/fonts-noto-core/copyright ]]; then
  cp /usr/share/doc/fonts-noto-core/copyright "$target/NOTICES.txt"
fi
sha256sum "$target"/*.ttf
