class_name SplatWavyEffect extends SplatEffect

@export_range(0.0, 16.0, 0.5) var amplitude: float = 6.5
@export_range(0.001, 0.2, 0.001) var frequency: float = 0.075
@export_range(0.0, 10.0, 0.1) var speed: float = 1.5

# Vertical region affected by the effect, in image pixel coordinates.
@export_range(0, 4096, 1) var effect_y_start: int = 16
@export_range(0, 4096, 1) var effect_y_end: int = 112

# Distance over which the effect fades at each boundary.
@export_range(0, 128, 1) var fade_distance: int = 16

var _time: float = 0.0

func apply_to_image(image: Image) -> void:
	if image.is_empty():
		return
	
	var source: Image = image.duplicate()
	var width := source.get_width()
	var height := source.get_height()
	
	var y_start := clampi(effect_y_start, 0, height)
	var y_end := clampi(effect_y_end, y_start, height)
	
	if y_start >= y_end:
		return
	
	for y in range(y_start, y_end):
		# Calculate fade strength near the start and end boundaries.
		var fade := 1.0
		
		if fade_distance > 0:
			var fade_in := float(y - y_start) / fade_distance
			var fade_out := float(y_end - 1 - y) / fade_distance
			fade = clampf(minf(fade_in, fade_out), 0.0, 1.0)
		
		# Calculate the vertical displacement for this row.
		var vertical_wave := sin(
			float(y) * frequency - _time
		) * amplitude * fade
		
		var offset_y := roundi(vertical_wave)
		var source_y := clampi(y + offset_y, 0, height - 1)
		
		# Copy the entire row in one native operation.
		image.blit_rect(
			source,
			Rect2i(0, source_y, width, 1),
			Vector2i(0, y)
		)


func tick(delta: float) -> void:
	_time += delta * speed
