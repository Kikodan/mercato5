class_name MatchPitch2D
extends Control

var home_club: Club
var away_club: Club

# Positions normalisées sur le terrain (0..1, 0..1)
var home_players: Array[Dictionary] = []
var away_players: Array[Dictionary] = []
var ball_pos: Vector2 = Vector2(0.5, 0.5)
var ball_target: Vector2 = Vector2(0.5, 0.5)
var ball_trail: Array[Vector2] = []
var current_anim_tween: Tween = null
var simulation_speed: float = 1.0

# Effets visuels
var fx_type: String = "" # "goal", "save", "tackle", "foul"
var fx_pos: Vector2 = Vector2.ZERO
var fx_timer: float = 0.0
var fx_text: String = ""

# Formations 1-2-1 normalisées
const BASE_HOME_FORMATION = [
	Vector2(0.08, 0.50), # 0: GK
	Vector2(0.24, 0.50), # 1: DEF
	Vector2(0.36, 0.28), # 2: MID Left
	Vector2(0.36, 0.72), # 3: MID Right
	Vector2(0.46, 0.50)  # 4: FWD
]

const BASE_AWAY_FORMATION = [
	Vector2(0.92, 0.50), # 0: GK
	Vector2(0.76, 0.50), # 1: DEF
	Vector2(0.64, 0.28), # 2: MID Left
	Vector2(0.64, 0.72), # 3: MID Right
	Vector2(0.54, 0.50)  # 4: FWD
]

var match_time: float = 0.0

func setup(home: Club, away: Club) -> void:
	home_club = home
	away_club = away
	home_players.clear()
	away_players.clear()
	match_time = 0.0

	for i in 5:
		var p = home.starting_five[i] if i < home.starting_five.size() else null
		home_players.append({
			"player": p,
			"pos": BASE_HOME_FORMATION[i],
			"target": BASE_HOME_FORMATION[i],
			"render_pos": BASE_HOME_FORMATION[i],
			"num": str(i + 1)
		})

	for i in 5:
		var p = away.starting_five[i] if i < away.starting_five.size() else null
		away_players.append({
			"player": p,
			"pos": BASE_AWAY_FORMATION[i],
			"target": BASE_AWAY_FORMATION[i],
			"render_pos": BASE_AWAY_FORMATION[i],
			"num": str(i + 1)
		})

	ball_pos = Vector2(0.5, 0.5)
	ball_target = Vector2(0.5, 0.5)
	ball_trail.clear()
	fx_type = ""
	fx_timer = 0.0
	queue_redraw()

func set_speed(s: float) -> void:
	simulation_speed = s

func _process(delta: float) -> void:
	if size.x <= 10 or size.y <= 10:
		return

	match_time += delta * simulation_speed

	var lerp_weight = clampf(delta * 4.0 * simulation_speed, 0.0, 1.0)
	for i in home_players.size():
		var hp = home_players[i]
		hp["pos"] = hp["pos"].lerp(hp["target"], lerp_weight)
		if i > 0: # Joueurs de champ Domicile
			var phase = match_time * 2.8 + float(i) * 1.6
			var organic = Vector2(
				sin(phase) * 0.012 + cos(phase * 0.6) * 0.007,
				cos(phase * 0.8) * 0.016 + sin(phase * 0.4) * 0.006
			)
			var ball_pull = (ball_pos - hp["pos"]) * 0.07
			hp["render_pos"] = hp["pos"] + organic + ball_pull
		else: # Gardien Domicile qui coulisse devant son but
			var gk_y_track = (ball_pos.y - hp["pos"].y) * 0.30
			hp["render_pos"] = Vector2(hp["pos"].x, clampf(hp["pos"].y + gk_y_track, 0.35, 0.65))

	for i in away_players.size():
		var ap = away_players[i]
		ap["pos"] = ap["pos"].lerp(ap["target"], lerp_weight)
		if i > 0: # Joueurs de champ Extérieur
			var phase = match_time * 2.8 + float(i) * 1.9 + 1.0
			var organic = Vector2(
				sin(phase) * 0.012 + cos(phase * 0.6) * 0.007,
				cos(phase * 0.8) * 0.016 + sin(phase * 0.4) * 0.006
			)
			var ball_pull = (ball_pos - ap["pos"]) * 0.07
			ap["render_pos"] = ap["pos"] + organic + ball_pull
		else: # Gardien Extérieur
			var gk_y_track = (ball_pos.y - ap["pos"].y) * 0.30
			ap["render_pos"] = Vector2(ap["pos"].x, clampf(ap["pos"].y + gk_y_track, 0.35, 0.65))

	var ball_weight = clampf(delta * 8.0 * simulation_speed, 0.0, 1.0)
	ball_pos = ball_pos.lerp(ball_target, ball_weight)

	ball_trail.push_front(ball_pos * size)
	if ball_trail.size() > 7:
		ball_trail.pop_back()

	if fx_timer > 0.0:
		fx_timer -= delta * simulation_speed
		if fx_timer <= 0.0:
			fx_type = ""

	queue_redraw()

func trigger_idle_possession(home_attacking: bool) -> void:
	if current_anim_tween and current_anim_tween.is_valid():
		return

	var atk_team = home_players if home_attacking else away_players
	var def_team = away_players if home_attacking else home_players

	var passer_idx = randi_range(1, 4)
	var receiver_idx = randi_range(1, 4)
	while receiver_idx == passer_idx:
		receiver_idx = randi_range(1, 4)

	var p2_pos = atk_team[receiver_idx]["pos"]
	var shift = Vector2(randf_range(-0.04, 0.04), randf_range(-0.06, 0.06))
	atk_team[receiver_idx]["target"] = clamp_field(atk_team[receiver_idx]["target"] + shift)
	ball_target = p2_pos

	# Les autres coéquipiers se démarquent
	for i in range(1, 5):
		if i != receiver_idx:
			var roam = Vector2(randf_range(-0.03, 0.03), randf_range(-0.04, 0.04))
			atk_team[i]["target"] = clamp_field(BASE_HOME_FORMATION[i] + roam if home_attacking else BASE_AWAY_FORMATION[i] + roam)

	# Les défenseurs coulissent en bloc
	var bloc_shift = (ball_target.x - 0.5) * 0.15
	for i in range(1, 5):
		var base_p = BASE_AWAY_FORMATION[i] if home_attacking else BASE_HOME_FORMATION[i]
		def_team[i]["target"] = clamp_field(Vector2(base_p.x + bloc_shift, base_p.y + randf_range(-0.03, 0.03)))

func play_event_animation(evt: Dictionary) -> void:
	if current_anim_tween and current_anim_tween.is_valid():
		current_anim_tween.kill()

	current_anim_tween = create_tween()
	var evt_type = evt.get("event_type", "")
	var is_home = (evt.get("atk_club") == home_club)
	var dir = 1.0 if is_home else -1.0

	var goal_target = Vector2(0.96, 0.5 + randf_range(-0.12, 0.12)) if is_home else Vector2(0.04, 0.5 + randf_range(-0.12, 0.12))
	var atk_dict = _find_player_dict(evt.get("attacker"), is_home)
	var def_dict = _find_player_dict(evt.get("defender"), not is_home)
	var gk_dict = _find_gk_dict(not is_home)

	var step_time = 0.32 / max(0.5, simulation_speed)

	match evt_type:
		"tackle":
			var tackle_spot = Vector2(0.65 if is_home else 0.35, randf_range(0.3, 0.7))
			current_anim_tween.tween_callback(func():
				if atk_dict: atk_dict["target"] = tackle_spot
				if def_dict: def_dict["target"] = tackle_spot + Vector2(-0.02 * dir, 0.0)
				ball_target = tackle_spot
			)
			current_anim_tween.tween_interval(step_time)
			current_anim_tween.tween_callback(func():
				_trigger_fx("tackle", tackle_spot * size, "⚔️ TACLE !")
				ball_target = tackle_spot + Vector2(-0.14 * dir, (0.2 if randf() < 0.5 else -0.2))
			)
			current_anim_tween.tween_interval(step_time)
			current_anim_tween.tween_callback(func(): _reset_team_targets())

		"foul":
			var foul_spot = Vector2(0.60 if is_home else 0.40, randf_range(0.3, 0.7))
			current_anim_tween.tween_callback(func():
				if atk_dict: atk_dict["target"] = foul_spot
				if def_dict: def_dict["target"] = foul_spot
				ball_target = foul_spot
			)
			current_anim_tween.tween_interval(step_time)
			current_anim_tween.tween_callback(func():
				_trigger_fx("foul", foul_spot * size, "🟨 FAUTE !")
			)
			current_anim_tween.tween_interval(step_time * 1.2)
			current_anim_tween.tween_callback(func(): _reset_team_targets())

		"save":
			var shot_spot = Vector2(0.80 if is_home else 0.20, randf_range(0.35, 0.65))
			current_anim_tween.tween_callback(func():
				if atk_dict: atk_dict["target"] = shot_spot
				ball_target = shot_spot
			)
			current_anim_tween.tween_interval(step_time)
			current_anim_tween.tween_callback(func():
				ball_target = goal_target
				if gk_dict: gk_dict["target"] = goal_target + Vector2(-0.02 * dir, 0.0)
			)
			current_anim_tween.tween_interval(step_time * 0.8)
			current_anim_tween.tween_callback(func():
				_trigger_fx("save", goal_target * size, "🧤 PARADE !")
				ball_target = goal_target + Vector2(-0.15 * dir, (0.2 if randf() < 0.5 else -0.2))
			)
			current_anim_tween.tween_interval(step_time)
			current_anim_tween.tween_callback(func(): _reset_team_targets())

		"goal":
			var shot_spot = Vector2(0.82 if is_home else 0.18, randf_range(0.35, 0.65))
			current_anim_tween.tween_callback(func():
				if atk_dict: atk_dict["target"] = shot_spot
				ball_target = shot_spot
			)
			current_anim_tween.tween_interval(step_time)
			current_anim_tween.tween_callback(func():
				ball_target = goal_target
			)
			current_anim_tween.tween_interval(step_time * 0.7)
			current_anim_tween.tween_callback(func():
				_trigger_fx("goal", goal_target * size, "⚽ BUUUT !!!")
				if atk_dict: atk_dict["target"] = shot_spot + Vector2(-0.08 * dir, 0.0)
			)
			current_anim_tween.tween_interval(step_time * 1.5)
			current_anim_tween.tween_callback(func():
				ball_target = Vector2(0.5, 0.5)
				_reset_team_targets()
			)

func _trigger_fx(type: String, pos: Vector2, text: String) -> void:
	fx_type = type
	fx_pos = pos
	fx_text = text
	fx_timer = 0.9

func _reset_team_targets() -> void:
	for i in home_players.size():
		home_players[i]["target"] = BASE_HOME_FORMATION[i]
	for i in away_players.size():
		away_players[i]["target"] = BASE_AWAY_FORMATION[i]

func _find_player_dict(p: Player, in_home: bool) -> Dictionary:
	var team = home_players if in_home else away_players
	if p != null:
		for item in team:
			if item["player"] == p:
				return item
	return team[4] if team.size() > 4 else team[0]

func _find_gk_dict(in_home: bool) -> Dictionary:
	var team = home_players if in_home else away_players
	return team[0]

func clamp_field(v: Vector2) -> Vector2:
	return Vector2(clampf(v.x, 0.05, 0.95), clampf(v.y, 0.1, 0.9))

# ==================== RENDU GRAPHIQUE DU TERRAIN ====================

func _draw() -> void:
	var s = size
	if s.x <= 20.0 or s.y <= 20.0:
		return

	# 1. Pelouse synthétique dégradée avec bandes de tonte
	draw_rect(Rect2(Vector2.ZERO, s), Color("15803d"))
	var num_stripes = 10
	var stripe_w = s.x / float(num_stripes)
	for i in num_stripes:
		if i % 2 == 1:
			draw_rect(Rect2(i * stripe_w, 0, stripe_w, s.y), Color(1.0, 1.0, 1.0, 0.04))

	# 2. Lignes blanches officielles
	var pad = 12.0
	var pitch_rect = Rect2(pad, pad, s.x - pad * 2.0, s.y - pad * 2.0)
	var line_col = Color(1.0, 1.0, 1.0, 0.75)
	var line_w = 2.0
	draw_rect(pitch_rect, line_col, false, line_w)

	# Ligne médiane et rond central
	var mid_x = s.x * 0.5
	draw_line(Vector2(mid_x, pad), Vector2(mid_x, s.y - pad), line_col, line_w)
	draw_circle(Vector2(mid_x, s.y * 0.5), 3.0, line_col)
	draw_arc(Vector2(mid_x, s.y * 0.5), minf(s.x, s.y) * 0.18, 0, TAU, 36, line_col, line_w)

	# Surfaces de réparation (arcs gauche et droite)
	var pen_r = s.y * 0.28
	draw_arc(Vector2(pad, s.y * 0.5), pen_r, -PI * 0.5, PI * 0.5, 24, line_col, line_w)
	draw_arc(Vector2(s.x - pad, s.y * 0.5), pen_r, PI * 0.5, PI * 1.5, 24, line_col, line_w)

	# Cages de but (blanches avec filet)
	var goal_h = s.y * 0.28
	var goal_rect_home = Rect2(pad - 12.0, (s.y - goal_h) * 0.5, 12.0, goal_h)
	var goal_rect_away = Rect2(s.x - pad, (s.y - goal_h) * 0.5, 12.0, goal_h)
	draw_rect(goal_rect_home, Color(1, 1, 1, 0.3), true)
	draw_rect(goal_rect_home, line_col, false, 2.0)
	draw_rect(goal_rect_away, Color(1, 1, 1, 0.3), true)
	draw_rect(goal_rect_away, line_col, false, 2.0)

	# 3. Traînée du ballon
	for i in ball_trail.size():
		var alpha = (1.0 - float(i) / float(ball_trail.size())) * 0.35
		var r_t = 6.0 - (float(i) * 0.6)
		draw_circle(ball_trail[i], maxf(2.0, r_t), Color(1.0, 1.0, 1.0, alpha))

	# 4. Joueurs Domicile (Home)
	var h_col = home_club.primary_color if home_club else Color("1e3a8a")
	var h_sec = home_club.secondary_color if home_club else Color("38bdf8")
	for hp in home_players:
		var p_render = hp.get("render_pos", hp["pos"]) * s
		_draw_match_player(p_render, h_col, h_sec, hp["num"], true)

	# 5. Joueurs Extérieur (Away)
	var a_col = away_club.primary_color if away_club else Color("b91c1c")
	var a_sec = away_club.secondary_color if away_club else Color("facc15")
	for ap in away_players:
		var p_render = ap.get("render_pos", ap["pos"]) * s
		_draw_match_player(p_render, a_col, a_sec, ap["num"], false)

	# 6. Le Ballon
	var bp = ball_pos * s
	draw_circle(bp + Vector2(2, 3), 5.5, Color(0, 0, 0, 0.35))
	draw_circle(bp, 6.0, Color.WHITE)
	draw_circle(bp, 2.5, Color("0f172a"))
	draw_arc(bp, 6.0, 0, TAU, 16, Color("1e293b"), 1.2)

	# 7. Effets visuels (FX)
	if fx_timer > 0.0:
		_draw_fx(s)

func _draw_match_player(pos: Vector2, prim: Color, sec: Color, num: String, is_home: bool) -> void:
	var r = 13.0
	# Ombre portée dynamique
	draw_circle(pos + Vector2(1, 3), r * 0.95, Color(0, 0, 0, 0.35))
	draw_circle(pos, r, prim)
	draw_arc(pos, r, 0, TAU, 24, sec, 2.0)

	var font = ThemeDB.fallback_font
	var font_size = 9
	var t_size = font.get_string_size(num, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	draw_string(font, pos + Vector2(-t_size.x * 0.5, 4), num, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func _draw_fx(s: Vector2) -> void:
	var font = ThemeDB.fallback_font
	var font_size = 15
	var text_col = Color("facc15")

	match fx_type:
		"goal":
			text_col = Color("facc15")
			var wave_r = (1.0 - fx_timer / 0.9) * 45.0
			draw_arc(fx_pos, wave_r, 0, TAU, 32, Color(0.98, 0.8, 0.1, fx_timer), 3.0)
		"save":
			text_col = Color("38bdf8")
			var wave_r = (1.0 - fx_timer / 0.9) * 30.0
			draw_arc(fx_pos, wave_r, 0, TAU, 24, Color(0.2, 0.75, 1.0, fx_timer), 2.5)
		"tackle":
			text_col = Color("34d399")
		"foul":
			text_col = Color("f87171")

	if fx_text != "":
		var t_pos = fx_pos + Vector2(-40, -18)
		t_pos.x = clampf(t_pos.x, 20.0, s.x - 100.0)
		t_pos.y = clampf(t_pos.y, 25.0, s.y - 15.0)

		var bg_rect = Rect2(t_pos - Vector2(6, 14), Vector2(100, 20))
		draw_rect(bg_rect, Color(0.06, 0.09, 0.16, 0.85), true)
		draw_rect(bg_rect, text_col, false, 1.5)
		draw_string(font, t_pos, fx_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_col)
