class_name TextRenderUtils extends RefCounted

const CHAR_DEF := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const NUM_DEF := "0123456789@"
const SYM_DEF := "[]()/?!+-%=_:;   \" \'.,"


# This expects the prototype font layout when building the return data
static func build_line(text: String, char_size: Vector2i) -> Array:
	var to_return := []
	
	var offset := 0
	for s_char in text:
		if is_whitepace(s_char):
			pass
		elif is_alphabetic(s_char):
			to_return.push_back([sample_alphabetic(s_char), Vector2i(offset, 0)])
		elif is_numeric(s_char):
			to_return.push_back([sample_numeric(s_char), Vector2i(offset, 0)])
		elif is_symbolic(s_char):
			to_return.push_back([sample_symbolic(s_char), Vector2i(offset, 0)])
		
		offset += char_size.x
	
	return to_return

static func register_line(font_vram_origo: Vector2i, text: String, char_size: Vector2i, dst_pos_px: Vector2i, layer: int) -> int:
	var char_tuples := build_line(text, char_size)
	var cmd_arr := []
	for tuple in char_tuples:
		cmd_arr.push_back([tuple[0] + font_vram_origo, tuple[1], false, false, true])
	
	return Splatmap.register_draw(SplatDrawComplexCmd.new(
		cmd_arr, dst_pos_px, layer, false, false
	))


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

#endregion
