class_name PitchWidget
extends Control

signal player_clicked(player: Player)
signal player_right_clicked(player: Player)

var starting_five: Array[Player] = []
var selected_player: Player = null

# Positions normalisées pour la formation 1-2-1 de foot à 5
const FORMATION_POSITIONS = [
	Vector2(0.5, 0.86),  # 0: Gardien
	Vector2(0.5, 0.66),  # 1: Défenseur
	Vector2(0.24, 0.44), # 2: Milieu Gauche
	Vector2(0.76, 0.44), # 3: Milieu Droit
	Vector2(0.5, 0.20)   # 4: Pivot / Attaquant
]

func set_starting_five(players: Array[Player], selected: Player = null) -> void:
	starting_five = players
	selected_player = selected
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var clicked_idx = _get_slot_at_pos(event.position)
		if clicked_idx != -1 and clicked_idx < starting_five.size():
			if event.double_click or event.button_index == MOUSE_BUTTON_RIGHT:
				player_right_clicked.emit(starting_five[clicked_idx])
			elif event.button_index == MOUSE_BUTTON_LEFT:
				player_clicked.emit(starting_five[clicked_idx])

func _get_slot_at_pos(pos: Vector2) -> int:
	var s = size
	for i in FORMATION_POSITIONS.size():
		var slot_center = FORMATION_POSITIONS[i] * s
		if pos.distance_to(slot_center) <= 32.0:
			return i
	return -1

func _draw() -> void:
	var s = size
	if s.x <= 20.0 or s.y <= 20.0:
		return

	# Fond pelouse synthétique
	var field_rect = Rect2(Vector2.ZERO, s)
	draw_rect(field_rect, Color("14532d"))

	# Bandes de tonte
	var num_stripes = 8
	var stripe_h = s.y / float(num_stripes)
	for i in num_stripes:
		if i % 2 == 1:
			draw_rect(Rect2(0, i * stripe_h, s.x, stripe_h), Color(1.0, 1.0, 1.0, 0.05))

	# Ligne de touche / contour
	var pad = 16.0
	var inner_rect = Rect2(pad, pad, s.x - pad * 2.0, s.y - pad * 2.0)
	var line_color = Color(1.0, 1.0, 1.0, 0.65)
	var line_w = 2.5
	draw_rect(inner_rect, line_color, false, line_w)

	# Ligne médiane
	var mid_y = s.y * 0.5
	draw_line(Vector2(pad, mid_y), Vector2(s.x - pad, mid_y), line_color, line_w)

	# Rond central
	var center = Vector2(s.x * 0.5, mid_y)
	draw_circle(center, 3.0, line_color)
	draw_arc(center, minf(s.x, s.y) * 0.16, 0, TAU, 48, line_color, line_w)

	# Surfaces de réparation
	var goal_w = inner_rect.size.x * 0.5
	draw_arc(Vector2(s.x * 0.5, pad), goal_w * 0.5, 0, PI, 32, line_color, line_w)
	draw_arc(Vector2(s.x * 0.5, s.y - pad), goal_w * 0.5, PI, TAU, 32, line_color, line_w)

	# Cages
	var cage_w = inner_rect.size.x * 0.28
	draw_rect(Rect2((s.x - cage_w) * 0.5, pad - 8.0, cage_w, 8.0), Color(1.0, 1.0, 1.0, 0.4), false, 2.0)
	draw_rect(Rect2((s.x - cage_w) * 0.5, s.y - pad, cage_w, 8.0), Color(1.0, 1.0, 1.0, 0.4), false, 2.0)

	# Bannière Note Moyenne d'Équipe en direct
	if starting_five.size() > 0:
		var slot_roles = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.MID, Player.Position.FWD]
		var sum_eff: float = 0.0
		for idx in range(starting_five.size()):
			var p_item = starting_five[idx]
			var target_role = slot_roles[idx] if idx < slot_roles.size() else p_item.position
			sum_eff += float(p_item.get_effective_overall(target_role))
		var avg_team = sum_eff / float(starting_five.size())

		var banner_w = minf(230.0, s.x - pad * 2.0 - 10.0)
		var banner_h = 24.0
		var banner_rect = Rect2((s.x - banner_w) * 0.5, pad + 4.0, banner_w, banner_h)
		draw_rect(banner_rect, Color(0.06, 0.10, 0.18, 0.94), true)
		draw_rect(banner_rect, Color("facc15"), false, 1.2)

		var banner_txt = "⭐ 5 DE DÉPART : %.1f OVR" % avg_team
		var b_size = default_font.get_string_size(banner_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 11)
		draw_string(default_font, Vector2((s.x - b_size.x) * 0.5, pad + 20.0), banner_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color("facc15"))

	# Jetons de joueurs
	var default_font = ThemeDB.fallback_font
	var font_size = 11

	for i in FORMATION_POSITIONS.size():
		var slot_pos = FORMATION_POSITIONS[i] * s
		if i < starting_five.size():
			var p = starting_five[i]
			_draw_player_token(slot_pos, p, default_font, font_size, i)
		else:
			_draw_empty_slot(slot_pos, default_font, font_size)

const PlayerFaceWidget = preload("res://scenes/PlayerFaceWidget.gd")

func _draw_player_token(pos: Vector2, p: Player, font: Font, font_size: int, slot_idx: int) -> void:
	var r = 24.0
	var is_selected = (p == selected_player)
	var pos_color = Color("f59e0b")
	match p.position:
		Player.Position.DEF: pos_color = Color("38bdf8")
		Player.Position.MID: pos_color = Color("10b981")
		Player.Position.FWD: pos_color = Color("f43f5e")

	var slot_roles = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.MID, Player.Position.FWD]
	var slot_role = slot_roles[slot_idx] if slot_idx < slot_roles.size() else p.position
	var penalty = p.get_position_penalty(slot_role)
	var eff_ovr = p.get_effective_overall(slot_role)

	# Anneau de sélection dorée
	if is_selected:
		draw_circle(pos, r + 7.0, Color(0.98, 0.8, 0.08, 0.35))
		draw_arc(pos, r + 5.0, 0, TAU, 36, Color("facc15"), 3.0)

	# Ombre portée
	draw_circle(pos + Vector2(0, 3), r + 2.0, Color(0, 0, 0, 0.40))

	# Cercle de fond
	draw_circle(pos, r, Color("0f172a"))

	# Visage du joueur
	var face_id = p.face_data.get("face_id", -1)
	if face_id == -1:
		face_id = abs(hash(p.full_name)) % PlayerFaceWidget.TOTAL_FACES
	var tex = PlayerFaceWidget.get_face_texture(face_id)
	if tex != null:
		var d = (r - 1.0) * 2.0
		var dest_rect = Rect2(pos.x - r + 1.0, pos.y - r + 1.0, d, d)
		draw_texture_rect(tex, dest_rect, false)

	# Anneau extérieur du jeton
	draw_arc(pos, r - 0.5, 0, TAU, 36, Color("facc15") if is_selected else (Color("f87171") if penalty > 0 else pos_color), 2.5)

	# Pastille Poste (Haut Gauche)
	var pos_badge_c = pos + Vector2(-r * 0.72, -r * 0.72)
	draw_circle(pos_badge_c, 8.5, pos_color)
	draw_arc(pos_badge_c, 8.5, 0, TAU, 16, Color.WHITE, 1.0)
	var pos_str = ["G", "D", "M", "A"][p.position]
	var p_size = font.get_string_size(pos_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 9)
	draw_string(font, pos_badge_c + Vector2(-p_size.x * 0.5, 3.5), pos_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color.WHITE)

	# Pastille Note OVR (Haut Droite) - Affiche la note effective avec indicateur de malus
	var ovr_badge_c = pos + Vector2(r * 0.72, -r * 0.72)
	var ovr_badge_color = Color("0f172a")
	var ovr_text_color = Color("facc15") if penalty == 0 else Color("f87171")
	draw_circle(ovr_badge_c, 10.0, ovr_badge_color)
	draw_arc(ovr_badge_c, 10.0, 0, TAU, 16, ovr_text_color, 1.4)
	var text_ovr = str(eff_ovr) if penalty == 0 else ("%d↓" % eff_ovr)
	var ovr_size = font.get_string_size(text_ovr, HORIZONTAL_ALIGNMENT_CENTER, -1, 9)
	draw_string(font, ovr_badge_c + Vector2(-ovr_size.x * 0.5, 3.5), text_ovr, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, ovr_text_color)

	# Nom du joueur sous le pion
	var name_box_w = 90.0
	var name_box_h = 16.0
	var name_rect = Rect2(pos.x - name_box_w * 0.5, pos.y + r + 3.0, name_box_w, name_box_h)
	draw_rect(name_rect, Color(0.12, 0.16, 0.26, 0.95) if is_selected else Color(0.06, 0.09, 0.16, 0.9), true)
	draw_rect(name_rect, Color("facc15") if is_selected else (Color("f87171") if penalty > 0 else pos_color), false, 1.5 if is_selected else 1.0)

	var display_name = p.full_name
	var parts = p.full_name.split(" ")
	if parts.size() > 0 and not parts[0].is_empty():
		display_name = parts[0]
	if p.is_transfer_listed:
		display_name += " 🏷️"
	if display_name.length() > 13:
		display_name = display_name.substr(0, 11) + "."
	var name_size = font.get_string_size(display_name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size - 1)
	draw_string(font, Vector2(pos.x - name_size.x * 0.5, pos.y + r + 15.0), display_name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size - 1, Color("facc15") if is_selected else Color("f1f5f9"))



func _draw_empty_slot(pos: Vector2, font: Font, _font_size: int) -> void:
	var r = 20.0
	draw_circle(pos, r, Color(0.1, 0.15, 0.25, 0.5))
	draw_arc(pos, r, 0, TAU, 32, Color(1.0, 1.0, 1.0, 0.3), 1.5)
	var txt = "+"
	var t_size = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
	draw_string(font, pos + Vector2(-t_size.x * 0.5, 5), txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(1.0, 1.0, 1.0, 0.5))
