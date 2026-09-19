extends Control

signal match_ended

const MatchPitch2D = preload("res://scenes/MatchPitch2D.gd")

@onready var label_home: Label = $HeaderPanel/TopBar/LabelHomeClub
@onready var label_away: Label = $HeaderPanel/TopBar/LabelAwayClub
@onready var label_score: Label = $HeaderPanel/TopBar/LabelScore
@onready var label_clock: Label = $HeaderPanel/TopBar/MatchClock
@onready var home_badge: ClubBadge = $HeaderPanel/TopBar/HomeBadge
@onready var away_badge: ClubBadge = $HeaderPanel/TopBar/AwayBadge
@onready var label_home_poss: Label = $HeaderPanel/PossessionBox/LabelHomePoss
@onready var label_away_poss: Label = $HeaderPanel/PossessionBox/LabelAwayPoss
@onready var possession_bar: ProgressBar = $HeaderPanel/PossessionBox/PossessionBar
@onready var banner: Label = $CenterArea/ActionBanner
@onready var pitch_2d: MatchPitch2D = $CenterArea/PitchCenter/Pitch2D
@onready var event_list: VBoxContainer = $BottomLog/ScrollContainer/EventList
@onready var scroll_container: ScrollContainer = $BottomLog/ScrollContainer

const SECONDS_PER_VIRTUAL_MINUTE: float = 0.85

var match_report: MatchEngine.MatchReport
var current_minute: int = 0
var time_accumulator: float = 0.0
var simulation_speed: float = 1.0
var is_finished: bool = false
var next_event_index: int = 0
var home_score: int = 0
var away_score: int = 0

func _resolve_nodes() -> void:
	if label_home == null:
		label_home = $HeaderPanel/TopBar/LabelHomeClub
		label_away = $HeaderPanel/TopBar/LabelAwayClub
		label_score = $HeaderPanel/TopBar/LabelScore
		label_clock = $HeaderPanel/TopBar/MatchClock
		home_badge = $HeaderPanel/TopBar/HomeBadge
		away_badge = $HeaderPanel/TopBar/AwayBadge
		label_home_poss = $HeaderPanel/PossessionBox/LabelHomePoss
		label_away_poss = $HeaderPanel/PossessionBox/LabelAwayPoss
		possession_bar = $HeaderPanel/PossessionBox/PossessionBar
		banner = $CenterArea/ActionBanner
		pitch_2d = $CenterArea/PitchCenter/Pitch2D
		event_list = $BottomLog/ScrollContainer/EventList
		scroll_container = $BottomLog/ScrollContainer

var target_goals: int = 5
var post_match_overlay: Control = null

func setup_match(report: MatchEngine.MatchReport) -> void:
	_resolve_nodes()
	if post_match_overlay != null and is_instance_valid(post_match_overlay):
		post_match_overlay.queue_free()
		post_match_overlay = null

	match_report = report
	target_goals = report.target_goals
	current_minute = 0
	time_accumulator = 0.0
	simulation_speed = 1.0
	is_finished = false
	next_event_index = 0
	home_score = 0
	away_score = 0

	for c in event_list.get_children():
		c.queue_free()
	label_home.text = report.home_club.club_name
	label_away.text = report.away_club.club_name

	home_badge.shape = report.home_club.badge_shape
	home_badge.symbol = report.home_club.badge_symbol
	home_badge.primary_color = report.home_club.primary_color
	home_badge.secondary_color = report.home_club.secondary_color
	home_badge.queue_redraw()

	away_badge.shape = report.away_club.badge_shape
	away_badge.symbol = report.away_club.badge_symbol
	away_badge.primary_color = report.away_club.primary_color
	away_badge.secondary_color = report.away_club.secondary_color
	away_badge.queue_redraw()

	var hp = report.home_possession_pct
	var ap = 100 - hp
	label_home_poss.text = "%d%%" % hp
	label_away_poss.text = "%d%%" % ap
	possession_bar.value = hp

	pitch_2d.setup(report.home_club, report.away_club)
	pitch_2d.set_speed(simulation_speed)

	banner.text = "Coup d'envoi ! (Premier à %d buts)" % target_goals
	banner.modulate = Color("facc15")

	_update_display()
	_update_clock()

func show_quick_summary(report: MatchEngine.MatchReport) -> void:
	_resolve_nodes()
	match_report = report
	target_goals = report.target_goals
	home_score = report.home_score
	away_score = report.away_score
	is_finished = true
	_update_display()
	_show_post_match_modal()

func _process(delta: float) -> void:
	if is_finished or match_report == null or simulation_speed == 0.0:
		return

	time_accumulator += delta * simulation_speed
	if time_accumulator >= SECONDS_PER_VIRTUAL_MINUTE:
		time_accumulator = 0.0
		current_minute += 1
		_on_minute_tick()

func _on_minute_tick() -> void:
	_update_clock()

	var has_event_this_minute = false
	while next_event_index < match_report.events.size() and match_report.events[next_event_index]["minute"] == current_minute:
		has_event_this_minute = true
		_trigger_event(match_report.events[next_event_index])
		next_event_index += 1

	if not has_event_this_minute and current_minute % 2 == 0:
		var home_has_ball = randf() < (float(match_report.home_possession_pct) / 100.0)
		pitch_2d.trigger_idle_possession(home_has_ball)

	if home_score >= target_goals or away_score >= target_goals or (next_event_index >= match_report.events.size() and current_minute >= 10):
		_end_match()

func _trigger_event(evt: Dictionary) -> void:
	var row = Label.new()
	row.text = evt["text"]
	row.add_theme_font_size_override("font_size", 12)

	if evt["is_goal"]:
		row.modulate = Color("facc15")
		if evt["club"] == match_report.home_club:
			home_score += 1
		else:
			away_score += 1
		_update_display()

		if home_score >= target_goals or away_score >= target_goals:
			var winner = match_report.home_club if home_score >= target_goals else match_report.away_club
			banner.text = "🏆 VICTOIRE DE %s ! (Objectif %d buts atteint)" % [winner.club_name.to_upper(), target_goals]
			banner.modulate = Color("facc15")
		else:
			banner.text = "⚽ BUT ! (%d - %d) [Course à %d buts]" % [home_score, away_score, target_goals]
			banner.modulate = Color("facc15")
	else:
		row.modulate = Color("94a3b8")
		if not (home_score >= target_goals or away_score >= target_goals):
			banner.text = ""

	pitch_2d.play_event_animation(evt)

	event_list.add_child(row)
	if is_inside_tree():
		await get_tree().process_frame
		scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

func _update_clock() -> void:
	label_clock.text = "%02d:00" % current_minute

func _update_display() -> void:
	label_score.text = "%d - %d (Obj: %d)" % [home_score, away_score, target_goals]

func _end_match() -> void:
	if is_finished:
		return
	is_finished = true
	var winner = match_report.home_club if home_score >= target_goals else match_report.away_club
	banner.text = "FIN DU MATCH - VICTOIRE DE %s !" % winner.club_name.to_upper()
	banner.modulate = Color("38bdf8")
	_show_post_match_modal()

func _show_post_match_modal() -> void:
	if post_match_overlay != null and is_instance_valid(post_match_overlay):
		post_match_overlay.queue_free()

	post_match_overlay = PanelContainer.new()
	post_match_overlay.name = "PostMatchOverlay"
	post_match_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg_sb = StyleBoxFlat.new()
	bg_sb.bg_color = Color(0.03, 0.05, 0.10, 0.94)
	post_match_overlay.add_theme_stylebox_override("panel", bg_sb)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	post_match_overlay.add_child(center)

	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(560, 390)
	var card_sb = StyleBoxFlat.new()
	card_sb.bg_color = Color("0f172a")

	var is_home_win = (match_report.home_score >= target_goals)
	var winner = match_report.home_club if is_home_win else match_report.away_club

	card_sb.border_color = Color("10b981")
	card_sb.set_border_width_all(2)
	card_sb.set_corner_radius_all(14)
	card_sb.content_margin_left = 28
	card_sb.content_margin_right = 28
	card_sb.content_margin_top = 22
	card_sb.content_margin_bottom = 22
	card.add_theme_stylebox_override("panel", card_sb)
	center.add_child(card)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	card.add_child(vbox)

	# 1. En-tête : Résultat
	var title_lbl = Label.new()
	title_lbl.text = "RÉSUMÉ ET STATISTIQUES DU MATCH"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.modulate = Color("94a3b8")
	title_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(title_lbl)

	var win_lbl = Label.new()
	win_lbl.text = "🏆 VICTOIRE DE %s !" % winner.club_name.to_upper()
	win_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_lbl.modulate = Color("facc15")
	win_lbl.add_theme_font_size_override("font_size", 21)
	vbox.add_child(win_lbl)

	# 2. Score et Clubs
	var score_box = HBoxContainer.new()
	score_box.alignment = BoxContainer.ALIGNMENT_CENTER
	score_box.add_theme_constant_override("separation", 18)

	var h_lbl = Label.new()
	h_lbl.text = match_report.home_club.club_name
	h_lbl.add_theme_font_size_override("font_size", 16)
	h_lbl.modulate = Color("facc15") if is_home_win else Color("94a3b8")
	score_box.add_child(h_lbl)

	var score_val = Label.new()
	score_val.text = "%d  -  %d" % [match_report.home_score, match_report.away_score]
	score_val.add_theme_font_size_override("font_size", 30)
	score_val.modulate = Color("ffffff")
	score_box.add_child(score_val)

	var a_lbl = Label.new()
	a_lbl.text = match_report.away_club.club_name
	a_lbl.add_theme_font_size_override("font_size", 16)
	a_lbl.modulate = Color("facc15") if not is_home_win else Color("94a3b8")
	score_box.add_child(a_lbl)

	vbox.add_child(score_box)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# 3. Statistiques : Possession, Tirs Cadrés, Tacles
	var stats_box = VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", 6)

	var hp = match_report.home_possession_pct
	var ap = 100 - hp
	var poss_row = HBoxContainer.new()
	var poss_h = Label.new()
	poss_h.text = "%d%%" % hp
	poss_h.custom_minimum_size = Vector2(45, 0)
	var poss_title = Label.new()
	poss_title.text = "Possession du ballon"
	poss_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	poss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	poss_title.modulate = Color("cbd5e1")
	var poss_a = Label.new()
	poss_a.text = "%d%%" % ap
	poss_a.custom_minimum_size = Vector2(45, 0)
	poss_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	poss_row.add_child(poss_h)
	poss_row.add_child(poss_title)
	poss_row.add_child(poss_a)
	stats_box.add_child(poss_row)

	var p_bar = ProgressBar.new()
	p_bar.custom_minimum_size = Vector2(0, 6)
	p_bar.value = hp
	p_bar.show_percentage = false
	stats_box.add_child(p_bar)

	# Tirs cadrés
	var shots_row = HBoxContainer.new()
	var shots_h = Label.new()
	shots_h.text = str(match_report.home_shots_on_target)
	shots_h.custom_minimum_size = Vector2(45, 0)
	shots_h.add_theme_font_size_override("font_size", 14)
	var shots_title = Label.new()
	shots_title.text = "Tirs Cadrés"
	shots_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shots_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shots_title.modulate = Color("cbd5e1")
	var shots_a = Label.new()
	shots_a.text = str(match_report.away_shots_on_target)
	shots_a.custom_minimum_size = Vector2(45, 0)
	shots_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	shots_a.add_theme_font_size_override("font_size", 14)
	shots_row.add_child(shots_h)
	shots_row.add_child(shots_title)
	shots_row.add_child(shots_a)
	stats_box.add_child(shots_row)

	# Tacles réussis
	var tac_row = HBoxContainer.new()
	var tac_h = Label.new()
	tac_h.text = str(match_report.home_tackles)
	tac_h.custom_minimum_size = Vector2(45, 0)
	var tac_title = Label.new()
	tac_title.text = "Tacles Réussis"
	tac_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tac_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tac_title.modulate = Color("cbd5e1")
	var tac_a = Label.new()
	tac_a.text = str(match_report.away_tackles)
	tac_a.custom_minimum_size = Vector2(45, 0)
	tac_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	tac_row.add_child(tac_h)
	tac_row.add_child(tac_title)
	tac_row.add_child(tac_a)
	stats_box.add_child(tac_row)

	vbox.add_child(stats_box)

	# 4. Buteurs
	var goals_box = VBoxContainer.new()
	goals_box.add_theme_constant_override("separation", 2)
	for evt in match_report.events:
		if evt.get("is_goal", false):
			var g_lbl = Label.new()
			var atk_c = evt.get("atk_club")
			var atk_name = atk_c.club_name if atk_c else ""
			var p_name = evt.get("attacker").full_name if evt.get("attacker") else "Buteur"
			var m = evt.get("minute", 0)
			g_lbl.text = "⚽ %d' %s (%s)" % [m, p_name, atk_name]
			g_lbl.add_theme_font_size_override("font_size", 11)
			g_lbl.modulate = Color("facc15") if atk_c == winner else Color("94a3b8")
			goals_box.add_child(g_lbl)

	if goals_box.get_child_count() > 0:
		var scroll_goals = ScrollContainer.new()
		scroll_goals.custom_minimum_size = Vector2(0, 58)
		scroll_goals.add_child(goals_box)
		vbox.add_child(scroll_goals)

	# 5. Bouton Continuer
	var btn_cont = Button.new()
	btn_cont.text = "Continuer vers le Dashboard >"
	btn_cont.custom_minimum_size = Vector2(0, 42)
	btn_cont.modulate = Color("10b981")
	btn_cont.add_theme_font_size_override("font_size", 14)
	btn_cont.pressed.connect(func():
		if post_match_overlay != null and is_instance_valid(post_match_overlay):
			post_match_overlay.queue_free()
			post_match_overlay = null
		match_ended.emit()
	)
	vbox.add_child(btn_cont)

	add_child(post_match_overlay)

func _on_speed_1x_pressed() -> void:
	simulation_speed = 1.0
	pitch_2d.set_speed(simulation_speed)

func _on_speed_2x_pressed() -> void:
	simulation_speed = 2.0
	pitch_2d.set_speed(simulation_speed)

func _on_speed_4x_pressed() -> void:
	simulation_speed = 4.0
	pitch_2d.set_speed(simulation_speed)

func _on_skip_pressed() -> void:
	while next_event_index < match_report.events.size():
		var evt = match_report.events[next_event_index]
		var row = Label.new()
		row.text = evt["text"]
		row.add_theme_font_size_override("font_size", 12)
		if evt["is_goal"]:
			row.modulate = Color("facc15")
			if evt["club"] == match_report.home_club: home_score += 1
			else: away_score += 1
		else:
			row.modulate = Color("94a3b8")
		event_list.add_child(row)
		next_event_index += 1
	current_minute = 40
	_update_clock()
	_update_display()
	_end_match()
	if is_inside_tree():
		await get_tree().process_frame
		scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)

