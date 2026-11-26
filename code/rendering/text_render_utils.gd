class_name TextRenderUtils extends RefCounted

const CHAR_DEF := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const NUM_DEF := "0123456789@"
const SYM_DEF := "[]()/?!+-%=_:;   \" \'.,"

const CMD_BEGIN := "<"
const CMD_END := ">"


# This expects the prototype font layout when building the return data
static func build_line(text: String, char_size: Vector2i) -> Array:
	var overrides := {}
	var to_return := []
	var in_cmd := false
	var cmd_buf := ""
	
	var offset := 0
	for s_char in text:
		if is_whitepace(s_char):
			pass
		elif is_cmd_start(s_char):
			in_cmd = true
			cmd_buf = ""
			continue
		elif is_cmd_end(s_char):
			in_cmd = false
			# submit cmd_buf to verify command
			_submit_cmd(cmd_buf, overrides)
			continue
		elif in_cmd:
			cmd_buf += s_char
			continue
			
		elif is_alphabetic(s_char):
			to_return.push_back([sample_alphabetic(s_char), Vector2i(offset, 0), overrides.get("color", Color.WHITE)])
		elif is_numeric(s_char):
			to_return.push_back([sample_numeric(s_char), Vector2i(offset, 0), overrides.get("color", Color.WHITE)])
		elif is_symbolic(s_char):
			to_return.push_back([sample_symbolic(s_char), Vector2i(offset, 0), overrides.get("color", Color.WHITE)])
		
		offset += char_size.x
	
	return to_return

static func register_line(font_vram_origo: Vector2i, text: String, char_size: Vector2i, dst_pos_px: Vector2i, layer: int) -> Array[int]:
	var char_tuples := build_line(text, char_size)
	var cmd_ids: Array[int] = []
	for tuple in char_tuples:
		cmd_ids.push_back(Splatmap.register_cmd(layer, SplatDrawTintedDecalCmd.create(
			tuple[0] + font_vram_origo, dst_pos_px + tuple[1], false, tuple[2], false, false
		)))
	return cmd_ids


static func _submit_cmd(cmd_buf: String, overrides: Dictionary) -> void:
	if cmd_buf.length() < 2: # Invalid CMD
		return
	
	match cmd_buf[0]:
		"/":
			_cancel_cmd(cmd_buf[1], overrides)
		"c":
			var html_col := _cmd_value(cmd_buf)
			var color := Color.from_string(html_col, Color.TRANSPARENT)
			if color != Color.TRANSPARENT:
				overrides["color"] = color


static func _cmd_value(cmd_buf: String) -> String:
	var split := cmd_buf.split(":")
	if split.size() < 2:
		return ""
	return split[1]


static func _cancel_cmd(cmd: String, overrides: Dictionary) -> void:
	match cmd:
		"c":
			overrides.erase("color")


#region Char Sampling

static func sample_alphabetic(s_char: String) -> Vector2i:
	if s_char.to_upper() == s_char:
		return Vector2i(CHAR_DEF.findn(s_char), 0)
	else:
		return Vector2i(CHAR_DEF.findn(s_char), 1)

static func sample_numeric(s_char: String) -> Vector2i:
	return Vector2i(NUM_DEF.findn(s_char), 2)

static func sample_symbolic(s_char: String) -> Vector2i:
	return Vector2i(SYM_DEF.findn(s_char), 3)

#endregion
#region Char Type Checks

static func is_alphabetic(s_char: String) -> bool:
	return s_char.to_upper() in CHAR_DEF

static func is_numeric(s_char: String) -> bool:
	return s_char in NUM_DEF

static func is_symbolic(s_char: String) -> bool:
	return s_char in SYM_DEF

static func is_whitepace(s_char: String) -> bool:
	return s_char == " "

static func is_cmd_start(s_char: String) -> bool:
	return s_char == CMD_BEGIN

static func is_cmd_end(s_char: String) -> bool:
	return s_char == CMD_END

#endregion
