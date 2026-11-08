@tool class_name BakeryProcess extends RefCounted

static func bake(definition: BakeRegionResource) -> BakeResultResource:
	if definition == null:
		return _failure("Bake definition is null.")
		
	if definition.source_image == null:
		return _failure("No source image assigned.")
	
	var tile_size := definition.tile_size
	
	if tile_size.x <= 0 or tile_size.y <= 0:
		return _failure("Tile size must be greater than zero.")
	
	if definition.regions.is_empty():
		return _failure("No regions have been defined.")
	
	# Obtain the source image and normalize it to RGBA8.
	var source := definition.source_image.get_image()
	
	if source == null or source.is_empty():
		return _failure("Could not retrieve source image.")
	
	source = source.duplicate()
	source.convert(Image.FORMAT_RGBA8)
	
	var image_size := source.get_size()
	
	var result := BakeResultResource.new()
	result.source_image_path = definition.source_image.resource_path
	result.regions = definition.regions.duplicate()
	result.tile_size = tile_size
	
	var hash_buckets: Dictionary = {}
	
	var input_tile_count := 0
	for region_index in range(definition.regions.size()):
		var region: Rect2i = definition.regions[region_index]
		
		if region.size.x <= 0 or region.size.y <= 0:
			return _failure("Region %d has an invalid size." % region_index)
		
		if region.position.x < 0 or region.position.y < 0:
			return _failure("Region %d extends outside the image." % region_index)
		
		if region.end.x > image_size.x or region.end.y > image_size.y:
			return _failure("Region %d extends outside the image." % region_index)
		
		if region.size.x % tile_size.x != 0 or region.size.y % tile_size.y != 0:
			return _failure("Region %d dimensions must be divisible by the tile size." % region_index)
		
		# Traverse the region in tile-sized increments.
		var tiles_x := region.size.x / tile_size.x
		var tiles_y := region.size.y / tile_size.y
		
		for ty in range(tiles_y):
			for tx in range(tiles_x):
				var tile_position := region.position + Vector2i(tx * tile_size.x, ty * tile_size.y)
				
				var tile_rect := Rect2i(tile_position, tile_size)
				var tile_image := source.get_region(tile_rect)
				var tile_data := tile_image.get_data()
				
				var mapping := BakeTileMapping.new()
				mapping.region_index = region_index
				mapping.tile_position = Vector2i(tx, ty)
				mapping.source_rect = tile_rect
								# Discard fully transparent tiles.
				if _is_fully_transparent(tile_data):
					result.empty_tile_count += 1
					result.mappings.append(mapping)
					continue
				
				mapping.has_transparency = _has_transparency(tile_data)
				
				# Find or register the unique tile.
				mapping.tile_index = _find_or_add_tile(
					tile_data,
					result.unique_tiles,
					hash_buckets
				)
				result.mappings.append(mapping)
	result.unique_tile_count = result.unique_tiles.size()
	result.duplicate_tile_count = (
		result.input_tile_count
		- result.unique_tile_count
		- result.empty_tile_count
	)
	
	return result


static func pack(result: BakeResultResource, max_columns: int = 16) -> BakeResultResource:
	if result == null:
		return _failure("Bake result is null.")
	
	if max_columns <= 0:
		return _failure("Maximum columns must be greater than zero.")
	
	if result.unique_tiles.is_empty():
		# An entirely transparent source still produces a valid image.
		result.atlas_size = result.tile_size
		result.atlas_columns = 0
		result.atlas_rows = 0
		result.packed_image = Image.create(
			result.tile_size.x,
			result.tile_size.y,
			false,
			Image.FORMAT_RGBA8
		)
		result.packed_image.fill(Color.TRANSPARENT)
		return result
	
	var tile_size := result.tile_size
	var columns := mini(max_columns, result.unique_tiles.size())
	var rows := ceili(float(result.unique_tiles.size()) / columns)
	
	result.atlas_columns = columns
	result.atlas_rows = rows
	result.atlas_size = Vector2i(
		columns * tile_size.x,
		rows * tile_size.y
	)
	
	var atlas := Image.create(
		result.atlas_size.x,
		result.atlas_size.y,
		false,
		Image.FORMAT_RGBA8
	)
	
	atlas.fill(Color.TRANSPARENT)
	
	# Write each unique tile into the atlas.
	for i in range(result.unique_tiles.size()):
		var position := Vector2i((i % columns) * tile_size.x, (i / columns) * tile_size.y)
		var tile_image := Image.create_from_data(tile_size.x, tile_size.y, false, Image.FORMAT_RGBA8, result.unique_tiles[i])
		atlas.blit_rect(tile_image, Rect2i(Vector2i.ZERO, tile_size), position)

	# Resolve atlas positions for all original tiles.
	for mapping in result.mappings:
		if mapping.is_empty:
			continue
		
		var index := mapping.tile_index
		
		mapping.atlas_position = Vector2i(
			(index % columns) * tile_size.x,
			(index / columns) * tile_size.y
		)
	
	# Keep the image available at runtime for saving.
	result.packed_image = atlas
	
	return result


## Returns true if every pixel has an alpha value of zero.
static func _is_fully_transparent(data: PackedByteArray) -> bool:
	for i in range(3, data.size(), 4):
		if data[i] != 0:
			return false
	
	return true


static func _has_transparency(data: PackedByteArray) -> bool:
	for i in range(3, data.size(), 4):
		if data[i] != 255:
			return true
	return false


static func _find_or_add_tile(tile_data: PackedByteArray, unique_tiles: Array[PackedByteArray], hash_buckets: Dictionary) -> int:
	var tile_hash := hash(tile_data)
	
	if hash_buckets.has(tile_hash):
		for candidate_index in hash_buckets[tile_hash]:
			if unique_tiles[candidate_index] == tile_data:
				return candidate_index
	else:
		hash_buckets[tile_hash] = []
	
	var new_index := unique_tiles.size()
	
	unique_tiles.append(tile_data)
	hash_buckets[tile_hash].append(new_index)
	
	return new_index


static func _failure(message: String) -> BakeResultResource:
	push_error("BakeryProcess: " + message)

	var result := BakeResultResource.new()
	result.error_message = message

	return result
