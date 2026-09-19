extends SceneTree

func _init():
	var font = ThemeDB.fallback_font
	var test_chars = [
		"⚽", "⚙", "💾", "🏠", "🔄", "🏆", "💼", "📬", "📊", "🎯", "🛡", "👤", "⚠️", "★", "⚡", "⇄", "▶", "⏸", "⏭", "⏮",
		"•", "■", "▶", "◆", "▲", "✓", "✗", "€", "$", "£"
	]
	print("--- TEST HAS_CHAR IN FALLBACK FONT ---")
	for ch in test_chars:
		var cp = ch.unicode_at(0)
		var has = font.has_char(cp)
		print(ch, " (U+", String.num_int64(cp, 16).to_upper(), "): ", has)
	quit(0)
