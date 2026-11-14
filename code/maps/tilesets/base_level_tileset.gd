@abstract class_name LevelTileset extends Node

@abstract func write_to_vram(vram, offset: Vector2i) -> void
@abstract func get_vram_data() -> Texture2D
@abstract func get_complex_wall(key: String) -> Array
