@tool extends EditorContextMenuPlugin

func _popup_menu(paths: PackedStringArray) -> void:
	if paths.size() != 1:
		return
	
	var path := paths[0]
	
	# Only offer the command for BakeRegionResources.
	var definition := ResourceLoader.load(path) as BakeRegionResource
	
	if definition == null:
		return
	
	add_context_menu_item(
		"Bake Atlas",
		_on_bake_pressed
	)


func _on_bake_pressed(paths: PackedStringArray) -> void:
	if paths.size() != 1:
		return
	
	var definition := ResourceLoader.load(paths[0]) as BakeRegionResource
	
	if definition == null:
		push_error("Selected resource is not a BakeRegionResource.")
		return
	
	_bake(definition)


func _bake(definition: BakeRegionResource) -> void:
	print("Starting atlas bake...")
	var result := BakeryProcess.bake(definition)
	
	if not result.success:
		return
	
	result = BakeryProcess.pack(
		result,
		definition.max_columns
	)
	
	if not result.success:
		return
	
	var source_path := definition.source_image.resource_path
	if source_path.is_empty():
		push_error("Source image must have a saved resource path.")
		return
	
	var directory := source_path.get_base_dir()
	var filename := source_path.get_file().get_basename()
	var atlas_path := directory.path_join(
		"vcpr_" + filename + ".png"
	)
	
	var metadata_path := directory.path_join(
		"vcpr_" + filename + ".tres"
	)
	
	# Save atlas.
	var error: Error = result.packed_image.save_png(atlas_path)
	
	if error != OK:
		push_error("Failed to save atlas: %s" % error_string(error))
		return
	
	result.atlas_path = atlas_path
	error = ResourceSaver.save(result, metadata_path)
	
	if error != OK:
		push_error("Failed to save metadata: %s" % error_string(error))
		return
	
	print("Atlas bake completed!")
	print("Input tiles: ", result.input_tile_count)
	print("Unique tiles: ", result.unique_tile_count)
	print("Duplicates: ", result.duplicate_tile_count)
	print("Transparent: ", result.empty_tile_count)
	print("Atlas size: ", result.atlas_size)
	print("Output: ", atlas_path)
	print("Metadata: ", metadata_path)
