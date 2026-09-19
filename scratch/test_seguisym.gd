extends SceneTree

func _init():
	var font = FontFile.new()
	var err = font.load_dynamic_font("C:/Windows/Fonts/seguisym.ttf")
	print("Load seguisym err: ", err)
	var test_chars = [
		"⚽", "⚙", "💾", "🏠", "🔄", "🏆", "💼", "📬", "📊", "🎯", "🛡", "👤", "⚠️", "★", "⚡", "⇄", "▶", "⏸", "⏭", "⏮",
		"•", "■", "▶", "◆", "▲", "✓", "✗", "€", "$", "£"
	]
	print("--- TEST HAS_CHAR IN SEGUISYM ---")
	for ch in test_chars:
		var cp = ch.unicode_at(0)
		var has = font.has_char(cp)
		print(ch, " (U+", String.num_int64(cp, 16).to_upper(), "): ", has)
	quit(0)
