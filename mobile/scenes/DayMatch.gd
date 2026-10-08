class_name DayMatch
extends VBoxContainer

const Club = preload("res://scripts/Club.gd")
const ClubBadge = preload("res://scripts/ClubBadge.gd")
const Tactics = preload("res://scripts/Tactics.gd")
const MatchEngine = preload("res://scripts/MatchEngine.gd")
const League = preload("res://scripts/League.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")

var user_club: Club = null
var opponent_club: Club = null
var is_user_home: bool = true
var match_title: String = "MATCH DE CHAMPIONNAT"
var league: League = null

var report: MatchEngine.MatchReport = null
var is_finished: bool = false
var is_live_running: bool = false
var live_step_index: int = 0
var sim_timer: Timer

# UI Nodes
var pre_match_panel: VBoxContainer
var live_match_panel: VBoxContainer
var post_match_panel: VBoxContainer

# Live UI
var lbl_minute: Label
var lbl_score: Label
var lbl_home_name: Label
var lbl_away_name: Label
var bar_possession: ProgressBar
var events_scroll: ScrollContainer
var events_container: VBoxContainer
var btn_speed: Button
var sim_speed_delay: float = 0.35

signal match_completed(rep: MatchEngine.MatchReport)
signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 10)

	sim_timer = Timer.new()
	sim_timer.one_shot = false
	sim_timer.timeout.connect(_on_sim_timer_tick)
	add_child(sim_timer)

	# 1. Conteneur Pré-Match
	pre_match_panel = VBoxContainer.new()
	pre_match_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pre_match_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pre_match_panel.add_theme_constant_override("separation", 12)
	add_child(pre_match_panel)

	# 2. Conteneur Direct / Live Match
	live_match_panel = VBoxContainer.new()
	live_match_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	live_match_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	live_match_panel.add_theme_constant_override("separation", 10)
	live_match_panel.visible = false
	add_child(live_match_panel)

	# 3. Conteneur Post-Match
	post_match_panel = VBoxContainer.new()
	post_match_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	post_match_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	post_match_panel.add_theme_constant_override("separation", 10)
	post_match_panel.visible = false
	add_child(post_match_panel)

	_build_live_ui()

func setup(p_user_club: Club, p_opponent_club: Club, p_is_home: bool, p_title: String, p_league: League = null) -> void:
	user_club = p_user_club
	opponent_club = p_opponent_club
	is_user_home = p_is_home
	match_title = p_title
	league = p_league
	is_finished = false
	is_live_running = false
	live_step_index = 0
	report = null

	_build_pre_match_ui()
	pre_match_panel.visible = true
	live_match_panel.visible = false
	post_match_panel.visible = false

func _build_pre_match_ui() -> void:
	for c in pre_match_panel.get_children():
		c.queue_free()

	if user_club == null or opponent_club == null:
		var empty_lbl = Label.new()
		empty_lbl.text = "Aucun match programmé pour ce jour."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pre_match_panel.add_child(empty_lbl)
		return

	var home_club = user_club if is_user_home else opponent_club
	var away_club = opponent_club if is_user_home else user_club

	# Titre En-tête
	var p_hdr = PanelContainer.new()
	var sb_h = StyleBoxFlat.new()
	sb_h.bg_color = Color(0.08, 0.12, 0.22, 0.95)
	sb_h.border_color = Color("facc15")
	sb_h.set_border_width_all(1)
	sb_h.set_corner_radius_all(8)
	sb_h.content_margin_top = 8
	sb_h.content_margin_bottom = 8
	p_hdr.add_theme_stylebox_override("panel", sb_h)
	pre_match_panel.add_child(p_hdr)

	var lbl_t = Label.new()
	lbl_t.text = "⚔️ " + match_title.to_upper()
	lbl_t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_t.add_theme_font_size_override("font_size", 14)
	lbl_t.add_theme_color_override("font_color", Color("facc15"))
	p_hdr.add_child(lbl_t)

	# Carte Face à Face
	var p_f2f = PanelContainer.new()
	var sb_f = StyleBoxFlat.new()
	sb_f.bg_color = Color(0.06, 0.09, 0.16, 0.95)
	sb_f.border_color = Color(0.20, 0.28, 0.42, 0.8)
	sb_f.set_border_width_all(1)
	sb_f.set_corner_radius_all(10)
	sb_f.content_margin_left = 12
	sb_f.content_margin_right = 12
	sb_f.content_margin_top = 12
	sb_f.content_margin_bottom = 12
	p_f2f.add_theme_stylebox_override("panel", sb_f)
	pre_match_panel.add_child(p_f2f)

	var f2f_hbox = HBoxContainer.new()
	f2f_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	f2f_hbox.add_theme_constant_override("separation", 12)
	p_f2f.add_child(f2f_hbox)

	# Domicile
	var home_vbox = VBoxContainer.new()
	home_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	home_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	f2f_hbox.add_child(home_vbox)

	var b_home = ClubBadge.new()
	b_home.custom_minimum_size = Vector2(44, 44)
	b_home.shape = home_club.badge_shape
	b_home.symbol = home_club.badge_symbol
	b_home.primary_color = home_club.primary_color
	b_home.secondary_color = home_club.secondary_color
	home_vbox.add_child(b_home)

	var lbl_h_name = Label.new()
	lbl_h_name.text = home_club.club_name + (" (Vous)" if home_club == user_club else "")
	lbl_h_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_h_name.add_theme_font_size_override("font_size", 13)
	lbl_h_name.add_theme_color_override("font_color", Color("38bdf8") if home_club == user_club else Color.WHITE)
	home_vbox.add_child(lbl_h_name)

	var lbl_h_ovr = Label.new()
	lbl_h_ovr.text = "OVR: %d | %s" % [home_club.get_starting_five_average_ovr(), Tactics.get_formation_name(home_club.tactical_formation).substr(0, 5)]
	lbl_h_ovr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_h_ovr.add_theme_font_size_override("font_size", 10)
	lbl_h_ovr.add_theme_color_override("font_color", Color("94a3b8"))
	home_vbox.add_child(lbl_h_ovr)

	# VS
	var vs_lbl = Label.new()
	vs_lbl.text = "VS"
	vs_lbl.add_theme_font_size_override("font_size", 18)
	vs_lbl.add_theme_color_override("font_color", Color("facc15"))
	f2f_hbox.add_child(vs_lbl)

	# Extérieur
	var away_vbox = VBoxContainer.new()
	away_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	away_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	f2f_hbox.add_child(away_vbox)

	var b_away = ClubBadge.new()
	b_away.custom_minimum_size = Vector2(44, 44)
	b_away.shape = away_club.badge_shape
	b_away.symbol = away_club.badge_symbol
	b_away.primary_color = away_club.primary_color
	b_away.secondary_color = away_club.secondary_color
	away_vbox.add_child(b_away)

	var lbl_a_name = Label.new()
	lbl_a_name.text = away_club.club_name + (" (Vous)" if away_club == user_club else "")
	lbl_a_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_a_name.add_theme_font_size_override("font_size", 13)
	lbl_a_name.add_theme_color_override("font_color", Color("38bdf8") if away_club == user_club else Color.WHITE)
	away_vbox.add_child(lbl_a_name)

	var lbl_a_ovr = Label.new()
	lbl_a_ovr.text = "OVR: %d | %s" % [away_club.get_starting_five_average_ovr(), Tactics.get_formation_name(away_club.tactical_formation).substr(0, 5)]
	lbl_a_ovr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_a_ovr.add_theme_font_size_override("font_size", 10)
	lbl_a_ovr.add_theme_color_override("font_color", Color("94a3b8"))
	away_vbox.add_child(lbl_a_ovr)

	# Analyse PFC (Pierre-Feuille-Ciseaux)
	var p_rps = PanelContainer.new()
	var sb_rps = StyleBoxFlat.new()
	sb_rps.bg_color = Color(0.07, 0.10, 0.18, 0.95)
	sb_rps.border_color = Color(0.25, 0.35, 0.52, 0.8)
	sb_rps.set_border_width_all(1)
	sb_rps.set_corner_radius_all(8)
	sb_rps.content_margin_left = 12
	sb_rps.content_margin_right = 12
	sb_rps.content_margin_top = 10
	sb_rps.content_margin_bottom = 10
	p_rps.add_theme_stylebox_override("panel", sb_rps)
	pre_match_panel.add_child(p_rps)

	var rps_vbox = VBoxContainer.new()
	rps_vbox.add_theme_constant_override("separation", 4)
	p_rps.add_child(rps_vbox)

	var user_form = user_club.tactical_formation
	var opp_form = opponent_club.tactical_formation
	var matchup = Tactics.get_formation_matchup(user_form, opp_form)

	var lbl_rps_title = Label.new()
	lbl_rps_title.text = "🧠 ANALYSE TACTIQUE DU DUEL :"
	lbl_rps_title.add_theme_font_size_override("font_size", 11)
	lbl_rps_title.add_theme_color_override("font_color", Color("facc15"))
	rps_vbox.add_child(lbl_rps_title)

	var lbl_rps_res = Label.new()
	if matchup.winner == 1:
		lbl_rps_res.text = "✅ AVANTAGE TACTIQUE MAJEUR !\nVotre formation contre celle de l'adversaire (+15% Puissance, +8% Possession)."
		lbl_rps_res.add_theme_color_override("font_color", Color("34d399"))
	elif matchup.winner == 2:
		lbl_rps_res.text = "⚠️ DÉSAVANTAGE TACTIQUE !\nL'adversaire neutralise votre schéma tactique (+15% pour lui)."
		lbl_rps_res.add_theme_color_override("font_color", Color("f87171"))
	else:
		lbl_rps_res.text = "⚖️ ÉQUILIBRE TACTIQUE\nAucune formation ne prend le dessus direct. Le talent pur fera la différence."
		lbl_rps_res.add_theme_color_override("font_color", Color("94a3b8"))
	lbl_rps_res.add_theme_font_size_override("font_size", 11)
	lbl_rps_res.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rps_vbox.add_child(lbl_rps_res)

	# Boutons d'Action Pré-Match
	var btn_vbox = VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 8)
	btn_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	btn_vbox.alignment = BoxContainer.ALIGNMENT_END
	pre_match_panel.add_child(btn_vbox)

	var btn_start = Button.new()
	btn_start.text = "⚽ Coup d'envoi en direct"
	btn_start.custom_minimum_size.y = 52.0
	btn_start.add_theme_font_size_override("font_size", 15)
	var sb_btn_start = StyleBoxFlat.new()
	sb_btn_start.bg_color = Color(0.08, 0.50, 0.35, 0.95)
	sb_btn_start.border_color = Color("34d399")
	sb_btn_start.set_border_width_all(2)
	sb_btn_start.set_corner_radius_all(10)
	btn_start.add_theme_stylebox_override("normal", sb_btn_start)
	btn_start.pressed.connect(_on_start_live_pressed)
	btn_vbox.add_child(btn_start)

	var btn_quick = Button.new()
	btn_quick.text = "⚡ Simulation instantanée"
	btn_quick.custom_minimum_size.y = 44.0
	btn_quick.add_theme_font_size_override("font_size", 13)
	var sb_btn_quick = StyleBoxFlat.new()
	sb_btn_quick.bg_color = Color(0.12, 0.18, 0.28, 0.90)
	sb_btn_quick.border_color = Color(0.28, 0.38, 0.55, 0.80)
	sb_btn_quick.set_border_width_all(1)
	sb_btn_quick.set_corner_radius_all(10)
	btn_quick.add_theme_stylebox_override("normal", sb_btn_quick)
	btn_quick.pressed.connect(_on_quick_sim_pressed)
	btn_vbox.add_child(btn_quick)

func _build_live_ui() -> void:
	# Tableau des scores en direct
	var sb_board = StyleBoxFlat.new()
	sb_board.bg_color = Color(0.04, 0.07, 0.12, 0.98)
	sb_board.border_color = Color("38bdf8")
	sb_board.set_border_width_all(1)
	sb_board.set_corner_radius_all(10)
	sb_board.content_margin_left = 12
	sb_board.content_margin_right = 12
	sb_board.content_margin_top = 10
	sb_board.content_margin_bottom = 10

	var p_score = PanelContainer.new()
	p_score.add_theme_stylebox_override("panel", sb_board)
	live_match_panel.add_child(p_score)

	var score_vbox = VBoxContainer.new()
	score_vbox.add_theme_constant_override("separation", 6)
	p_score.add_child(score_vbox)

	var row_min = HBoxContainer.new()
	score_vbox.add_child(row_min)

	lbl_minute = Label.new()
	lbl_minute.text = "⏱️ MINUTE 0' / 40'"
	lbl_minute.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_minute.add_theme_font_size_override("font_size", 12)
	lbl_minute.add_theme_color_override("font_color", Color("facc15"))
	row_min.add_child(lbl_minute)

	btn_speed = Button.new()
	btn_speed.text = "Vitesse: 1x"
	btn_speed.custom_minimum_size = Vector2(90, 26)
	btn_speed.add_theme_font_size_override("font_size", 11)
	btn_speed.pressed.connect(_toggle_speed)
	row_min.add_child(btn_speed)

	var btn_skip = Button.new()
	btn_skip.text = "Fin ⏩"
	btn_skip.custom_minimum_size = Vector2(60, 26)
	btn_skip.add_theme_font_size_override("font_size", 11)
	btn_skip.pressed.connect(_skip_to_end)
	row_min.add_child(btn_skip)

	var row_teams = HBoxContainer.new()
	row_teams.alignment = BoxContainer.ALIGNMENT_CENTER
	row_teams.add_theme_constant_override("separation", 10)
	score_vbox.add_child(row_teams)

	lbl_home_name = Label.new()
	lbl_home_name.text = "Domicile"
	lbl_home_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_home_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_home_name.add_theme_font_size_override("font_size", 14)
	row_teams.add_child(lbl_home_name)

	lbl_score = Label.new()
	lbl_score.text = "0 - 0"
	lbl_score.add_theme_font_size_override("font_size", 24)
	lbl_score.add_theme_color_override("font_color", Color("facc15"))
	lbl_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_teams.add_child(lbl_score)

	lbl_away_name = Label.new()
	lbl_away_name.text = "Extérieur"
	lbl_away_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_away_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lbl_away_name.add_theme_font_size_override("font_size", 14)
	row_teams.add_child(lbl_away_name)

	# Jauge de Possession
	var poss_box = VBoxContainer.new()
	poss_box.add_theme_constant_override("separation", 2)
	score_vbox.add_child(poss_box)

	bar_possession = ProgressBar.new()
	bar_possession.value = 50.0
	bar_possession.min_value = 0.0
	bar_possession.max_value = 100.0
	bar_possession.show_percentage = false
	bar_possession.custom_minimum_size.y = 8
	poss_box.add_child(bar_possession)

	# Déroulé des événements (Scrollable)
	events_scroll = ScrollContainer.new()
	events_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	events_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	live_match_panel.add_child(events_scroll)

	events_container = VBoxContainer.new()
	events_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	events_container.add_theme_constant_override("separation", 6)
	events_scroll.add_child(events_container)

func _on_start_live_pressed() -> void:
	pre_match_panel.visible = false
	live_match_panel.visible = true
	post_match_panel.visible = false

	var home_club = user_club if is_user_home else opponent_club
	var away_club = opponent_club if is_user_home else user_club
	lbl_home_name.text = home_club.club_name
	lbl_away_name.text = away_club.club_name
	lbl_score.text = "0 - 0"

	# Simuler le match pour obtenir les événements
	report = MatchEngine.simulate_match(home_club, away_club, 5)
	bar_possession.value = float(report.home_possession_pct)

	for c in events_container.get_children():
		c.queue_free()

	live_step_index = 0
	is_live_running = true
	sim_timer.start(sim_speed_delay)

func _on_quick_sim_pressed() -> void:
	var home_club = user_club if is_user_home else opponent_club
	var away_club = opponent_club if is_user_home else user_club
	report = MatchEngine.simulate_match(home_club, away_club, 5)
	_finish_match()

func _toggle_speed() -> void:
	if sim_speed_delay > 0.25:
		sim_speed_delay = 0.15
		btn_speed.text = "Vitesse: 2x"
	elif sim_speed_delay > 0.10:
		sim_speed_delay = 0.05
		btn_speed.text = "Vitesse: 4x"
	else:
		sim_speed_delay = 0.35
		btn_speed.text = "Vitesse: 1x"
	if is_live_running:
		sim_timer.start(sim_speed_delay)

func _skip_to_end() -> void:
	sim_timer.stop()
	is_live_running = false
	_finish_match()

func _on_sim_timer_tick() -> void:
	if report == null:
		sim_timer.stop()
		return

	if live_step_index < report.events.size():
		var ev = report.events[live_step_index]
		_render_event_row(ev)
		live_step_index += 1
		# Faire défiler vers le bas
		await get_tree().process_frame
		events_scroll.scroll_vertical = int(events_scroll.get_v_scroll_bar().max_value)
	else:
		sim_timer.stop()
		is_live_running = false
		_finish_match()

func _render_event_row(ev: Dictionary) -> void:
	var min_val = ev.get("minute", 0)
	lbl_minute.text = "⏱️ MINUTE %d' / 40'" % min_val

	var card = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6

	var is_goal = ev.get("is_goal", false)
	var ev_type = ev.get("event_type", "")
	var txt = ev.get("text", "")

	if is_goal:
		sb.bg_color = Color(0.08, 0.40, 0.25, 0.9)
		sb.border_color = Color("34d399")
	elif ev_type == "tactical_advantage":
		sb.bg_color = Color(0.20, 0.15, 0.05, 0.9)
		sb.border_color = Color("facc15")
	else:
		sb.bg_color = Color(0.08, 0.12, 0.20, 0.8)
		sb.border_color = Color(0.20, 0.28, 0.42, 0.6)

	card.add_theme_stylebox_override("panel", sb)

	var lbl = Label.new()
	lbl.text = "%d'  %s" % [min_val, txt]
	lbl.add_theme_font_size_override("font_size", 11)
	if is_goal:
		lbl.add_theme_color_override("font_color", Color("fef08a"))
	card.add_child(lbl)
	events_container.add_child(card)

	# Mettre à jour le score courant si c'est un but
	if is_goal:
		var cur_h = 0
		var cur_a = 0
		for i in range(live_step_index + 1):
			var sub_ev = report.events[i]
			if sub_ev.get("is_goal", false):
				if sub_ev.get("club") == report.home_club:
					cur_h += 1
				else:
					cur_a += 1
		lbl_score.text = "%d - %d" % [cur_h, cur_a]

func _finish_match() -> void:
	is_finished = true
	pre_match_panel.visible = false
	live_match_panel.visible = false
	post_match_panel.visible = true

	# Bâtir l'interface de récapitulation
	for c in post_match_panel.get_children():
		c.queue_free()

	# Panneau Score Final
	var p_final = PanelContainer.new()
	var sb_f = StyleBoxFlat.new()
	sb_f.bg_color = Color(0.06, 0.10, 0.18, 0.98)
	sb_f.border_color = Color("facc15")
	sb_f.set_border_width_all(2)
	sb_f.set_corner_radius_all(10)
	sb_f.content_margin_top = 14
	sb_f.content_margin_bottom = 14
	sb_f.content_margin_left = 12
	sb_f.content_margin_right = 12
	p_final.add_theme_stylebox_override("panel", sb_f)
	post_match_panel.add_child(p_final)

	var f_vbox = VBoxContainer.new()
	f_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	f_vbox.add_theme_constant_override("separation", 6)
	p_final.add_child(f_vbox)

	var lbl_fin = Label.new()
	lbl_fin.text = "🏁 SCORE FINAL"
	lbl_fin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_fin.add_theme_font_size_override("font_size", 12)
	lbl_fin.add_theme_color_override("font_color", Color("94a3b8"))
	f_vbox.add_child(lbl_fin)

	var lbl_big_score = Label.new()
	lbl_big_score.text = "%s  %d - %d  %s" % [report.home_club.club_name, report.home_score, report.away_score, report.away_club.club_name]
	lbl_big_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_big_score.add_theme_font_size_override("font_size", 18)
	lbl_big_score.add_theme_color_override("font_color", Color("facc15"))
	f_vbox.add_child(lbl_big_score)

	var is_user_win = false
	if user_club == report.home_club:
		is_user_win = report.home_score > report.away_score
	else:
		is_user_win = report.away_score > report.home_score

	var lbl_outcome = Label.new()
	lbl_outcome.text = "🏆 VICTOIRE !" if is_user_win else "❌ DÉFAITE"
	lbl_outcome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_outcome.add_theme_font_size_override("font_size", 14)
	lbl_outcome.add_theme_color_override("font_color", Color("34d399") if is_user_win else Color("f87171"))
	f_vbox.add_child(lbl_outcome)

	# Buteurs & Faits marquants
	var scroll_recap = ScrollContainer.new()
	scroll_recap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_recap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	post_match_panel.add_child(scroll_recap)

	var recap_list = VBoxContainer.new()
	recap_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recap_list.add_theme_constant_override("separation", 4)
	scroll_recap.add_child(recap_list)

	var lbl_g_title = Label.new()
	lbl_g_title.text = "⚽ BUTEURS & MOMENTS CLÉS :"
	lbl_g_title.add_theme_font_size_override("font_size", 11)
	lbl_g_title.add_theme_color_override("font_color", Color("38bdf8"))
	recap_list.add_child(lbl_g_title)

	var had_goals = false
	for ev in report.events:
		if ev.get("is_goal", false):
			had_goals = true
			var g_lbl = Label.new()
			g_lbl.text = "• %d' %s" % [ev.get("minute", 0), ev.get("text", "")]
			g_lbl.add_theme_font_size_override("font_size", 11)
			g_lbl.add_theme_color_override("font_color", Color("e2e8f0"))
			recap_list.add_child(g_lbl)

	if not had_goals:
		var no_g = Label.new()
		no_g.text = "Aucun but marqué."
		no_g.add_theme_font_size_override("font_size", 11)
		recap_list.add_child(no_g)

	# Stats rapides
	var stats_p = PanelContainer.new()
	var sb_st = StyleBoxFlat.new()
	sb_st.bg_color = Color(0.08, 0.12, 0.20, 0.9)
	sb_st.set_border_width_all(1)
	sb_st.border_color = Color(0.20, 0.28, 0.42, 0.6)
	sb_st.set_corner_radius_all(6)
	sb_st.content_margin_left = 10
	sb_st.content_margin_right = 10
	sb_st.content_margin_top = 8
	sb_st.content_margin_bottom = 8
	stats_p.add_theme_stylebox_override("panel", sb_st)
	post_match_panel.add_child(stats_p)

	var st_lbl = Label.new()
	st_lbl.text = "📊 Possession: %d%% - %d%% | Tirs: %d - %d | Tacles: %d - %d" % [
		report.home_possession_pct, 100 - report.home_possession_pct,
		report.home_shots_on_target, report.away_shots_on_target,
		report.home_tackles, report.away_tackles
	]
	st_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	st_lbl.add_theme_font_size_override("font_size", 10)
	st_lbl.add_theme_color_override("font_color", Color("94a3b8"))
	stats_p.add_child(st_lbl)

	match_completed.emit(report)
	data_changed.emit()
