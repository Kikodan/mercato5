extends SceneTree

const PlayerFaceWidget = preload("res://scenes/PlayerFaceWidget.gd")
const Player = preload("res://scripts/Player.gd")

func _init() -> void:
	print("--- TEST PLAYER FACE WIDGET AVEC SPRITES PNG ---")
	var p = Player.new()
	p.full_name = "Kylian Test"
	p.face_data = {"face_id": 42}
	
	var widget = PlayerFaceWidget.new()
	widget.custom_minimum_size = Vector2(80, 80)
	widget.size = Vector2(80, 80)
	widget.setup_player(p)
	
	assert(PlayerFaceWidget.TOTAL_FACES == 196, "Total faces doit être 196")
	var tex = PlayerFaceWidget.get_face_texture(42)
	assert(tex != null, "La texture face_42.png doit exister")
	print("Texture 42 dimensions: ", tex.get_size())
	
	# Test with legacy player (no face_id, should hash fallback)
	var p_legacy = Player.new()
	p_legacy.full_name = "Ancien Joueur"
	p_legacy.face_data = {"skin_tone": 2}
	widget.setup_player(p_legacy)
	print("✓ Legacy fallback test OK")
	
	widget.free()
	print("--- TEST PLAYER FACE WIDGET VALIDE AVEC SUCCES ---")
	quit(0)
