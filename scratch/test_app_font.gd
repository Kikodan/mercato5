extends SceneTree

func _init():
	var font = load("res://assets/fonts/app_font.tres")
	assert(font != null, "Impossible de charger app_font.tres")
	print("✓ app_font.tres chargé avec succès")
	
	var chars = ["A", "é", "ç", "⚽", "⚙", "💾", "🏠", "🔄", "🏆", "💼", "📊", "🎯", "🛡", "👤", "⚠️", "★", "⚡", "⇄", "▶", "⏸"]
	for ch in chars:
		var cp = ch.unicode_at(0)
		var has = font.has_char(cp)
		print("  ", ch, ": ", has)
		assert(has, "Le caractère " + ch + " doit être présent !")
	print("✓ Tous les caractères et émojis sont supportés !")
	quit(0)
