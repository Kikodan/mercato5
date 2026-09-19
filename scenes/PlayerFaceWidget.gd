class_name PlayerFaceWidget
extends Control

var player: Player = null
var face_data: Dictionary = {}
var kit_primary: Color = Color("1e3a8a")
var kit_secondary: Color = Color("38bdf8")

const TOTAL_FACES = 196
static var texture_cache: Dictionary = {}

static func get_face_texture(face_id: int) -> Texture2D:
	var safe_id = clampi(face_id, 0, TOTAL_FACES - 1)
	if texture_cache.has(safe_id):
		return texture_cache[safe_id]
	var path = "res://assets/faces/face_%d.png" % safe_id
	if ResourceLoader.exists(path):
		var res = load(path)
		if res != null:
			texture_cache[safe_id] = res
			return res
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img != null:
			var tex = ImageTexture.create_from_image(img)
			texture_cache[safe_id] = tex
			return tex
	return null

func setup_player(p: Player, primary_col: Color = Color("1e3a8a"), sec_col: Color = Color("38bdf8")) -> void:
	player = p
	if p != null and not p.face_data.is_empty():
		face_data = p.face_data
	kit_primary = primary_col
	kit_secondary = sec_col
	queue_redraw()

func _draw() -> void:
	var s = minf(size.x, size.y)
	if s < 10.0:
		return

	var center = Vector2(size.x * 0.5, size.y * 0.5)
	var radius = s * 0.48

	# 1. Fond du macaron (cercle moderne avec anneau aux couleurs du club)
	draw_circle(center, radius, Color(0.06, 0.09, 0.15, 0.95))
	draw_arc(center, radius - 1.0, 0, TAU, 48, kit_primary, 2.5)

	# 2. Déterminer l'index du visage PNG
	var face_id = face_data.get("face_id", -1)
	if face_id == -1:
		if player != null:
			face_id = abs(hash(player.full_name)) % TOTAL_FACES
		else:
			face_id = 0

	# 3. Dessiner le portrait transparent découpé
	var tex = get_face_texture(face_id)
	if tex != null:
		var tex_w = float(tex.get_width())
		var tex_h = float(tex.get_height())
		var scale_factor = (radius * 1.88) / tex_h
		var draw_w = tex_w * scale_factor
		var draw_h = tex_h * scale_factor
		var dest_rect = Rect2(center.x - draw_w * 0.5, center.y - draw_h * 0.50, draw_w, draw_h)
		draw_texture_rect(tex, dest_rect, false)
