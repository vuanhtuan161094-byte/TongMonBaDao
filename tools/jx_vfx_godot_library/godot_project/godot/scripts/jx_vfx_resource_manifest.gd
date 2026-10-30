extends RefCounted

# The selected-pack exporter replaces this with static preload() references so
# dynamically addressed textures are included in exported Godot resource packs.
const TEXTURES: Array[Texture2D] = []
