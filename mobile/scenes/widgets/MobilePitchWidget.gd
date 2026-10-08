class_name MobilePitchWidget
extends Control

const Player = preload("res://scripts/Player.gd")
const Tactics = preload("res://scripts/Tactics.gd")

signal player_clicked(player: Player)

var starting_five: Array[Player] = []
var selected_player: Player = null
var tactical_formation: int = Tactics.TacticalFormation.FORMATION_1_2_1

func _init() -> void:
	custom_minimum_size = Vector2(340, 360)

func set_lineup(players: Array[Player], selected: Player = null, formation: int = -1) -> void:
	starting_five = players
	selected_player = selected
	if formation >= 0:
		tactical_formation = formation
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var idx = _get_slot_at_pos(event.position)
		if idx != -1 and idx < starting_five.size():
			player_clicked.emit(starting_five[idx])

func _get_formation_positions() -> Array[Vector2]:
	return Tactics.get_formation_positions(tactical_formation)

func _get_slot_roles() -> Array:
	return Tactics.get_slot_roles(tactical_formation)

func _get_slot_at_pos(pos: Vector2) -> int:
	var s = size
	var positions = _get_formation_positions()
	for i in positions.size():
		var slot_center = positions[i] * s
		if pos.distance_to(slot_center) <= 30.0:
			return i
	return -1

func _draw() -> void:
	var s = size
	if s.x <= 20.0 or s.y <= 20.0:
		return

	# Fond pelouse verte
	draw_rect(Rect2(Vector2.ZERO, s), Color("14532d"))

	# Rayures de tonte
	var num_stripes = 6
	var stripe_h = s.y / float(num_stripes)
	for i in num_stripes:
		if i % 2 == 1:
			draw_rect(Rect2(0, i * stripe_h, s.x, stripe_h), Color(1.0, 1.0, 1.0, 0.05))

	# Ligne de touche
	var pad = 12.0
	var inner_rect = Rect2(pad, pad, s.x - pad * 2.0, s.y - pad * 2.0)
	draw_rect(inner_rect, Color(1.0, 1.0, 1.0, 0.5), false, 1.5)

	# Ligne médiane & cercle central
	var mid_y = s.y * 0.5
	draw_line(Vector2(pad, mid_y), Vector2(s.x - pad, mid_y), Color(1.0, 1.0, 1.0, 0.4), 1.5)
	draw_arc(Vector2(s.x * 0.5, mid_y), 36.0, 0, TAU, 32, Color(1.0, 1.0, 1.0, 0.4), 1.5)

	# But adverse (haut) et notre but (bas)
	var cage_w = inner_rect.size.x * 0.32
	draw_rect(Rect2((s.x - cage_w) * 0.5, pad - 6.0, cage_w, 6.0), Color(1.0, 1.0, 1.0, 0.5), false, 1.5)
	draw_rect(Rect2((s.x - cage_w) * 0.5, s.y - pad, cage_w, 6.0), Color(1.0, 1.0, 1.0, 0.5), false, 1.5)

	var default_font = ThemeDB.fallback_font
	var font_size = 11

	# Bannière Note Moyenne d'Équipe en direct
	if starting_five.size() > 0:
		var slot_roles = _get_slot_roles()
		var sum_eff: float = 0.0
		for idx in range(starting_five.size()):
			var p_item = starting_five[idx]
			var target_role = slot_roles[idx] if idx < slot_roles.size() else p_item.position
			sum_eff += float(p_item.get_effective_overall(target_role))
		var avg_team = sum_eff / float(starting_five.size())

		var banner_w = minf(260.0, s.x - pad * 2.0 - 10.0)
		var banner_h = 24.0
		var banner_rect = Rect2((s.x - banner_w) * 0.5, pad + 4.0, banner_w, banner_h)
		draw_rect(banner_rect, Color(0.06, 0.10, 0.18, 0.94), true)
		draw_rect(banner_rect, Color("facc15"), false, 1.2)

		var form_name = Tactics.get_formation_name(tactical_formation)
		var banner_txt = "⭐ %s : %.1f OVR" % [form_name, avg_team]
		var b_size = default_font.get_string_size(banner_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 10)
		draw_string(default_font, Vector2((s.x - b_size.x) * 0.5, pad + 18.0), banner_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color("facc15"))

	# Jetons de joueurs
	var positions = _get_formation_positions()
	for i in positions.size():
		var slot_pos = positions[i] * s
		if i < starting_five.size():
			var p = starting_five[i]
			_draw_player_token(slot_pos, p, default_font, font_size, i)
		else:
			_draw_empty_slot(slot_pos, default_font, font_size)

func _draw_player_token(pos: Vector2, p: Player, font: Font, font_size: int, slot_idx: int) -> void:
	var r = 20.0
	var is_selected = (p == selected_player)
	var pos_color = Color("f59e0b")
	match p.position:
		Player.Position.DEF: pos_color = Color("38bdf8")
		Player.Position.MID: pos_color = Color("10b981")
		Player.Position.FWD: pos_color = Color("f43f5e")

	var slot_roles = _get_slot_roles()
	var slot_role = slot_roles[slot_idx] if slot_idx < slot_roles.size() else p.position
	var penalty = p.get_position_penalty(slot_role)
	var eff_ovr = p.get_effective_overall(slot_role)

	# Sélection
	if is_selected:
		draw_circle(pos, r + 5.0, Color(0.98, 0.8, 0.08, 0.35))
		draw_arc(pos, r + 4.0, 0, TAU, 32, Color("facc15"), 2.5)

	# Fond pion
	draw_circle(pos, r, Color(0.08, 0.12, 0.22, 0.95))
	draw_arc(pos, r, 0, TAU, 32, Color("f87171") if penalty > 0 else pos_color, 2.0)

	# Poste
	var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
	var p_sz = font.get_string_size(pos_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 8)
	draw_string(font, pos + Vector2(-p_sz.x * 0.5, -2), pos_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 8, pos_color)

	# Note
	var ovr_txt = str(eff_ovr) if penalty == 0 else ("%d↓" % eff_ovr)
	var o_sz = font.get_string_size(ovr_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 10)
	draw_string(font, pos + Vector2(-o_sz.x * 0.5, 12), ovr_txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color("facc15") if penalty == 0 else Color("f87171"))

	# Nom sous le pion
	var disp_name = p.full_name.split(" ")[0]
	if disp_name.length() > 9:
		disp_name = disp_name.substr(0, 8) + "."
	var name_box_w = 70.0
	var name_rect = Rect2(pos.x - name_box_w * 0.5, pos.y + r + 2.0, name_box_w, 14.0)
	draw_rect(name_rect, Color(0.06, 0.09, 0.16, 0.90), true)
	draw_rect(name_rect, Color("facc15") if is_selected else Color(0.2, 0.3, 0.45, 0.5), false, 1.0)
	var n_sz = font.get_string_size(disp_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 9)
	draw_string(font, Vector2(pos.x - n_sz.x * 0.5, pos.y + r + 12.0), disp_name, HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color("f1f5f9"))

func _draw_empty_slot(pos: Vector2, font: Font, font_size: int) -> void:
	var r = 18.0
	draw_circle(pos, r, Color(0, 0, 0, 0.35))
	draw_arc(pos, r, 0, TAU, 24, Color(1, 1, 1, 0.3), 1.0)
	var txt = "+"
	var t_sz = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
	draw_string(font, pos + Vector2(-t_sz.x * 0.5, 5), txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color(1, 1, 1, 0.5))
