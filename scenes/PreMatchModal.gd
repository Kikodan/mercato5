class_name PreMatchModal
extends Control

signal kickoff_requested(skip_live: bool)
signal cancelled()
signal player_detail_requested(player: Player, club: Club)

const ClubBadge = preload("res://scripts/ClubBadge.gd")
const PlayerFaceWidget = preload("res://scenes/PlayerFaceWidget.gd")
const Tactics = preload("res://scripts/Tactics.gd")

# Top Header
@onready var lbl_matchday_title: Label = $CenterContainer/Panel/VBox/Header/LabelMatchdayTitle
@onready var user_badge: ClubBadge = $CenterContainer/Panel/VBox/Header/HBoxMatchup/UserBox/UserBadge
@onready var lbl_user_name: Label = $CenterContainer/Panel/VBox/Header/HBoxMatchup/UserBox/LabelUserName
@onready var opp_badge: ClubBadge = $CenterContainer/Panel/VBox/Header/HBoxMatchup/OppBox/OppBadge
@onready var lbl_opp_name: Label = $CenterContainer/Panel/VBox/Header/HBoxMatchup/OppBox/LabelOppName

# Opponent Scouting
@onready var opp_star_face: PlayerFaceWidget = $CenterContainer/Panel/VBox/BodySplit/OppScoutingCol/VBox/StarCard/HBox/StarFace
@onready var lbl_star_name: Label = $CenterContainer/Panel/VBox/BodySplit/OppScoutingCol/VBox/StarCard/HBox/VBox/LabelStarName
@onready var lbl_star_stats: Label = $CenterContainer/Panel/VBox/BodySplit/OppScoutingCol/VBox/StarCard/HBox/VBox/LabelStarStats
@onready var lbl_star_danger: Label = $CenterContainer/Panel/VBox/BodySplit/OppScoutingCol/VBox/StarCard/HBox/VBox/LabelStarDanger
@onready var lbl_opp_tactic_desc: Label = $CenterContainer/Panel/VBox/BodySplit/OppScoutingCol/VBox/TacticBox/LabelOppTacticDesc
@onready var opp_lineup_list: VBoxContainer = $CenterContainer/Panel/VBox/BodySplit/OppScoutingCol/VBox/ScrollOppLineup/OppLineupList

# User Team Adjustments
@onready var opt_user_tactic: OptionButton = $CenterContainer/Panel/VBox/BodySplit/UserTacticsCol/VBox/TacticControls/OptTactic
@onready var opt_user_training: OptionButton = $CenterContainer/Panel/VBox/BodySplit/UserTacticsCol/VBox/TacticControls/OptTraining
@onready var user_lineup_list: VBoxContainer = $CenterContainer/Panel/VBox/BodySplit/UserTacticsCol/VBox/ScrollUserLineup/UserLineupList
@onready var btn_auto_pick: Button = $CenterContainer/Panel/VBox/BodySplit/UserTacticsCol/VBox/HeaderLineup/BtnAutoPick
@onready var bench_list: VBoxContainer = $CenterContainer/Panel/VBox/BodySplit/UserTacticsCol/VBox/ScrollBench/BenchList

# Action buttons
@onready var btn_cancel: Button = $CenterContainer/Panel/VBox/BottomBar/BtnCancel
@onready var btn_quick_sim: Button = $CenterContainer/Panel/VBox/BottomBar/BtnQuickSim
@onready var btn_kickoff: Button = $CenterContainer/Panel/VBox/BottomBar/BtnKickoff

var user_club: Club = null
var opp_club: Club = null
var selected_starter_for_swap: Player = null

func _ready() -> void:
	btn_cancel.pressed.connect(func():
		visible = false
		cancelled.emit()
	)
	btn_quick_sim.pressed.connect(func():
		visible = false
		kickoff_requested.emit(true)
	)
	btn_kickoff.pressed.connect(func():
		visible = false
		kickoff_requested.emit(false)
	)
	btn_auto_pick.pressed.connect(_on_btn_auto_pick_pressed)

	_init_tactic_options()

func _init_tactic_options() -> void:
	opt_user_tactic.clear()
	opt_user_tactic.add_item("Équilibré", 0)
	opt_user_tactic.add_item("Attaque Totale", 1)
	opt_user_tactic.add_item("Contre-Attaque", 2)

	opt_user_training.clear()
	opt_user_training.add_item("Cryothérapie & Récupération", 0)
	opt_user_training.add_item("Finition & Frappes", 1)
	opt_user_training.add_item("Bloc & Duels Défensifs", 2)

	opt_user_tactic.item_selected.connect(func(idx: int):
		if user_club != null:
			user_club.tactical_style = idx
	)
	opt_user_training.item_selected.connect(func(idx: int):
		if user_club != null:
			user_club.training_focus = idx
	)

func setup(player_c: Club, enemy_c: Club, matchday_title: String, is_spectator: bool = false) -> void:
	user_club = player_c
	opp_club = enemy_c
	selected_starter_for_swap = null
	visible = true

	if is_spectator:
		lbl_matchday_title.text = "👁️ MATCH EN DIRECT (SPECTATEUR) • %s" % matchday_title.to_upper()
		btn_kickoff.text = "👁️ Assister au Match (Direct) >"
		btn_quick_sim.text = "⚡ Simuler le Match"
	else:
		lbl_matchday_title.text = "📋 BRIEFING D'AVANT-MATCH • %s" % matchday_title.to_upper()
		btn_kickoff.text = "⚽ Coup d'Envoi !"
		btn_quick_sim.text = "⚡ Simuler Rapidement"

	# Matchup Header
	user_badge.shape = user_club.badge_shape
	user_badge.symbol = user_club.badge_symbol
	user_badge.primary_color = user_club.primary_color
	user_badge.secondary_color = user_club.secondary_color
	user_badge.queue_redraw()
	lbl_user_name.text = user_club.club_name

	opp_badge.shape = opp_club.badge_shape
	opp_badge.symbol = opp_club.badge_symbol
	opp_badge.primary_color = opp_club.primary_color
	opp_badge.secondary_color = opp_club.secondary_color
	opp_badge.queue_redraw()
	lbl_opp_name.text = opp_club.club_name

	# Opponent Scouting
	_render_opp_scouting()

	# User Team
	opt_user_tactic.selected = user_club.tactical_style
	opt_user_training.selected = user_club.training_focus
	_render_user_lineup_and_bench()

func _render_opp_scouting() -> void:
	if opp_club == null:
		return

	# Style tactique adverse
	var t_name = Tactics.get_style_name(opp_club.tactical_style)
	var t_desc = Tactics.get_style_desc(opp_club.tactical_style)
	lbl_opp_tactic_desc.text = "Dispositif : %s\n%s" % [t_name, t_desc]

	# Identifier le joueur star adverse (meilleur buteur ou OVR le plus élevé)
	var star: Player = null
	var max_score = -1.0
	for p in opp_club.squad:
		var score = float(p.get_overall()) + float(p.stats_current_season.get("goals", 0)) * 2.0
		if score > max_score:
			max_score = score
			star = p

	var current_opp_star: Player = null
	if star != null:
		current_opp_star = star
		opp_star_face.setup_player(star, opp_club.primary_color, opp_club.secondary_color)
		var pos_str = ["GK", "DEF", "MID", "FWD"][star.position]
		lbl_star_name.text = "%s %s [%s]" % [star.get_flag_emoji(), star.full_name, pos_str]
		var goals = star.stats_current_season.get("goals", 0)
		var matches = star.stats_current_season.get("matches", 0)
		lbl_star_stats.text = "Note %d OVR • %da • %d buts en %d matchs" % [star.get_overall(), star.age, goals, matches]

		if goals >= 3:
			lbl_star_danger.text = "⚠️ Danger numéro 1 : Attaquant en grande réussite !"
			lbl_star_danger.modulate = Color("ef4444")
		elif star.position == Player.Position.GK:
			lbl_star_danger.text = "🧤 Mur défensif : Gardien de haut niveau à percer !"
			lbl_star_danger.modulate = Color("f59e0b")
		else:
			lbl_star_danger.text = "⭐ Joueur cadre influent sur tout le terrain."
			lbl_star_danger.modulate = Color("38bdf8")

		var vbox_star = lbl_star_danger.get_parent()
		var btn_star_view = vbox_star.get_node_or_null("BtnStarView")
		if btn_star_view == null:
			btn_star_view = Button.new()
			btn_star_view.name = "BtnStarView"
			btn_star_view.text = "👁️ Consulter la Fiche Star"
			btn_star_view.custom_minimum_size = Vector2(160, 24)
			btn_star_view.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			btn_star_view.add_theme_font_size_override("font_size", 10)
			var b_st = StyleBoxFlat.new()
			b_st.bg_color = Color(0.16, 0.26, 0.42)
			b_st.set_corner_radius_all(6)
			btn_star_view.add_theme_stylebox_override("normal", b_st)
			vbox_star.add_child(btn_star_view)
		for conn in btn_star_view.pressed.get_connections():
			btn_star_view.pressed.disconnect(conn["callable"])
		btn_star_view.pressed.connect(func():
			player_detail_requested.emit(star, opp_club)
		)

		var star_card = opp_star_face.get_parent().get_parent()
		if star_card != null:
			star_card.mouse_filter = Control.MOUSE_FILTER_STOP
			for conn in star_card.gui_input.get_connections():
				star_card.gui_input.disconnect(conn["callable"])
			star_card.gui_input.connect(func(ev: InputEvent):
				if ev is InputEventMouseButton and ev.pressed:
					player_detail_requested.emit(star, opp_club)
			)

	# 5 Majeur adverse
	for child in opp_lineup_list.get_children():
		child.queue_free()

	if not opp_club.is_lineup_valid():
		opp_club.auto_pick_lineup()

	for p in opp_club.starting_five:
		var row = _create_player_row(p, opp_club, false)
		opp_lineup_list.add_child(row)

func _render_user_lineup_and_bench() -> void:
	if user_club == null:
		return

	# Titulaires
	for child in user_lineup_list.get_children():
		child.queue_free()

	for p in user_club.starting_five:
		var row = _create_player_row(p, user_club, true, true)
		user_lineup_list.add_child(row)

	# Banc
	for child in bench_list.get_children():
		child.queue_free()

	for p in user_club.squad:
		if not user_club.starting_five.has(p):
			var row = _create_player_row(p, user_club, true, false)
			bench_list.add_child(row)

func _create_player_row(p: Player, club: Club, is_user: bool, is_starter: bool = false) -> PanelContainer:
	var panel = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	var is_selected = (p == selected_starter_for_swap)

	if is_selected:
		sb.bg_color = Color(0.2, 0.35, 0.6, 0.9)
		sb.border_color = Color("38bdf8")
		sb.set_border_width_all(2)
	elif is_starter:
		sb.bg_color = Color(0.12, 0.17, 0.28, 0.8)
	else:
		sb.bg_color = Color(0.08, 0.11, 0.18, 0.6)

	sb.set_corner_radius_all(6)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", sb)

	var hbox = HBoxContainer.new()
	hbox.theme_override_constants_set("separation", 8)

	var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
	var pos_lbl = Label.new()
	pos_lbl.custom_minimum_size = Vector2(34, 0)
	pos_lbl.text = "[%s]" % pos_str
	pos_lbl.add_theme_font_size_override("font_size", 11)
	match p.position:
		Player.Position.GK: pos_lbl.modulate = Color("f59e0b")
		Player.Position.DEF: pos_lbl.modulate = Color("3b82f6")
		Player.Position.MID: pos_lbl.modulate = Color("10b981")
		Player.Position.FWD: pos_lbl.modulate = Color("ef4444")

	var name_lbl = Label.new()
	name_lbl.text = "%s %s" % [p.get_flag_emoji(), p.full_name]
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 11)

	var ovr_lbl = Label.new()
	ovr_lbl.text = "%d" % p.get_overall()
	ovr_lbl.add_theme_font_size_override("font_size", 11)
	ovr_lbl.modulate = Color("facc15")

	var fit_pct = int(p.fitness * 100)
	var fit_lbl = Label.new()
	fit_lbl.text = "%d%%" % fit_pct
	fit_lbl.add_theme_font_size_override("font_size", 10)
	if fit_pct >= 85:
		fit_lbl.modulate = Color("34d399")
	elif fit_pct >= 65:
		fit_lbl.modulate = Color("facc15")
	else:
		fit_lbl.modulate = Color("f87171")

	hbox.add_child(pos_lbl)
	hbox.add_child(name_lbl)
	hbox.add_child(ovr_lbl)
	hbox.add_child(fit_lbl)

	# Bouton Fiche Dédié pour TOUS les joueurs (adverses comme utilisateur)
	var btn_view = Button.new()
	btn_view.text = "👁️"
	btn_view.tooltip_text = "Consulter la fiche détaillée"
	btn_view.custom_minimum_size = Vector2(28, 22)
	btn_view.add_theme_font_size_override("font_size", 10)
	var b_view_st = StyleBoxFlat.new()
	b_view_st.bg_color = Color(0.18, 0.24, 0.35)
	b_view_st.set_corner_radius_all(4)
	btn_view.add_theme_stylebox_override("normal", b_view_st)
	btn_view.pressed.connect(func():
		player_detail_requested.emit(p, club)
	)
	hbox.add_child(btn_view)

	# Si c'est l'équipe du joueur, bouton d'action tactique
	if is_user:
		var btn_action = Button.new()
		btn_action.custom_minimum_size = Vector2(60, 22)
		btn_action.add_theme_font_size_override("font_size", 10)
		if is_starter:
			btn_action.text = "Choisir" if selected_starter_for_swap != p else "Prêt"
			btn_action.pressed.connect(func():
				if selected_starter_for_swap == p:
					selected_starter_for_swap = null
				else:
					selected_starter_for_swap = p
				_render_user_lineup_and_bench()
			)
		else:
			btn_action.text = "Entrer"
			btn_action.disabled = (selected_starter_for_swap == null)
			btn_action.pressed.connect(func():
				if selected_starter_for_swap != null:
					_swap_players(selected_starter_for_swap, p)
					selected_starter_for_swap = null
					_render_user_lineup_and_bench()
			)
		hbox.add_child(btn_action)

	panel.add_child(hbox)

	# Clic pour ouvrir la fiche détaillée du joueur (clic direct si adversaire, ou double-clic / clic droit)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			if not is_user or event.double_click or event.button_index == MOUSE_BUTTON_RIGHT:
				player_detail_requested.emit(p, club)
	)

	return panel

func _swap_players(starter: Player, bench_p: Player) -> void:
	var idx = user_club.starting_five.find(starter)
	if idx != -1:
		user_club.starting_five[idx] = bench_p

func _on_btn_auto_pick_pressed() -> void:
	if user_club != null:
		user_club.auto_pick_lineup()
		selected_starter_for_swap = null
		_render_user_lineup_and_bench()
