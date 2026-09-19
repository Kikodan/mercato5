class_name PlayerDetailModal
extends Control

signal closed()

const ClubBadge = preload("res://scripts/ClubBadge.gd")
const PlayerFaceWidget = preload("res://scenes/PlayerFaceWidget.gd")

@onready var face_widget: PlayerFaceWidget = $CenterContainer/Panel/VBox/Header/FaceWidget
@onready var lbl_player_name: Label = $CenterContainer/Panel/VBox/Header/InfoBox/HBoxName/LabelPlayerName
@onready var lbl_player_sub: Label = $CenterContainer/Panel/VBox/Header/InfoBox/LabelPlayerSub
@onready var club_badge: ClubBadge = $CenterContainer/Panel/VBox/Header/ClubBox/ClubBadge
@onready var lbl_club_name: Label = $CenterContainer/Panel/VBox/Header/ClubBox/LabelClubName
@onready var btn_close: Button = $CenterContainer/Panel/VBox/Header/BtnClose

# Attributes
@onready var lbl_ovr: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/OvrBadge/LabelOvr
@onready var prog_speed: ProgressBar = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ProgSpeed
@onready var prog_shooting: ProgressBar = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ProgShooting
@onready var prog_passing: ProgressBar = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ProgPassing
@onready var prog_defending: ProgressBar = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ProgDefending
@onready var prog_stamina: ProgressBar = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ProgStamina
@onready var prog_fitness: ProgressBar = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ProgFitness

@onready var lbl_val_speed: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ValSpeed
@onready var lbl_val_shooting: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ValShooting
@onready var lbl_val_passing: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ValPassing
@onready var lbl_val_defending: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ValDefending
@onready var lbl_val_stamina: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ValStamina
@onready var lbl_val_fitness: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/AttrGrid/ValFitness

@onready var lbl_trait_pos: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/TraitsBox/LabelTraitPos
@onready var lbl_trait_neg: Label = $CenterContainer/Panel/VBox/BodySplit/LeftCol/TraitsBox/LabelTraitNeg

# Right col: Value, Contract, Palmarès, Stats
@onready var lbl_market_value: Label = $CenterContainer/Panel/VBox/BodySplit/RightCol/ValueBox/VBox/LabelMarketValue
@onready var lbl_value_breakdown: Label = $CenterContainer/Panel/VBox/BodySplit/RightCol/ValueBox/VBox/LabelValueBreakdown
@onready var lbl_contract_info: Label = $CenterContainer/Panel/VBox/BodySplit/RightCol/ContractBox/LabelContractInfo
@onready var palmares_container: VBoxContainer = $CenterContainer/Panel/VBox/BodySplit/RightCol/PalmaresBox/PalmaresList
@onready var stats_history_container: VBoxContainer = $CenterContainer/Panel/VBox/BodySplit/RightCol/StatsBox/ScrollStats/StatsList

var current_player: Player = null
var current_club: Club = null

func _ready() -> void:
	btn_close.pressed.connect(func():
		visible = false
		closed.emit()
	)

func open_player(p: Player, c: Club = null) -> void:
	if p == null:
		return
	current_player = p
	current_club = c
	visible = true

	# Visage
	var p_col = c.primary_color if c != null else Color("334155")
	var s_col = c.secondary_color if c != null else Color("38bdf8")
	face_widget.setup_player(p, p_col, s_col)

	# Nom & En-tête
	var pos_names = ["Gardien (GK)", "Défenseur (DEF)", "Milieu (MID)", "Attaquant (FWD)"]
	lbl_player_name.text = "%s %s" % [p.get_flag_emoji(), p.full_name]
	lbl_player_sub.text = "%s • %da • Note %d OVR" % [pos_names[p.position], p.age, p.get_overall()]

	# Club
	if c != null:
		club_badge.visible = true
		club_badge.shape = c.badge_shape
		club_badge.symbol = c.badge_symbol
		club_badge.primary_color = c.primary_color
		club_badge.secondary_color = c.secondary_color
		club_badge.queue_redraw()
		lbl_club_name.text = "%s (%s - Div %d)" % [c.club_name, c.country, c.division]
	else:
		club_badge.visible = false
		lbl_club_name.text = "🏃 Joueur Libre (Sans club)"

	# Attributs
	lbl_ovr.text = str(p.get_overall())
	_set_attr(prog_speed, lbl_val_speed, p.speed)
	_set_attr(prog_shooting, lbl_val_shooting, p.shooting)
	_set_attr(prog_passing, lbl_val_passing, p.passing)
	_set_attr(prog_defending, lbl_val_defending, p.defending)
	_set_attr(prog_stamina, lbl_val_stamina, p.stamina)

	var fit_pct = int(p.fitness * 100)
	prog_fitness.value = fit_pct
	lbl_val_fitness.text = "%d%%" % fit_pct
	if fit_pct >= 85:
		lbl_val_fitness.modulate = Color("34d399")
	elif fit_pct >= 65:
		lbl_val_fitness.modulate = Color("facc15")
	else:
		lbl_val_fitness.modulate = Color("f87171")

	# Traits
	lbl_trait_pos.text = "➕ %s" % p.trait_positive
	lbl_trait_neg.text = "➖ %s" % p.trait_negative

	# Valeur & Décomposition
	var div = c.division if c != null else 4
	var bd = p.get_value_breakdown(div)
	lbl_market_value.text = "💰 %s €" % String.num_int64(bd["final_value"])
	lbl_value_breakdown.text = "Base OVR : %s € | Âge (x%.2f) | Division (x%.2f) | Perf (x%.2f) | Palmarès (x%.2f)" % [
		String.num_int64(bd["base"]), bd["age_factor"], bd["div_factor"], bd["perf_factor"], bd["palmares_factor"]
	]

	# Contrat
	lbl_contract_info.text = "Salaire : %s €/semaine  |  Prétention : %s €/semaine  |  Contrat restant : %d an(s)" % [
		String.num_int64(p.salary), String.num_int64(p.wage_demand), p.contract_years
	]

	# Palmarès
	for child in palmares_container.get_children():
		child.queue_free()

	if p.palmares.is_empty():
		var lbl_empty = Label.new()
		lbl_empty.text = "Aucun titre pour l'instant."
		lbl_empty.modulate = Color("94a3b8")
		lbl_empty.add_theme_font_size_override("font_size", 11)
		palmares_container.add_child(lbl_empty)
	else:
		for trophy in p.palmares:
			var t_lbl = Label.new()
			t_lbl.text = "🏆 %s" % trophy
			t_lbl.modulate = Color("facc15")
			t_lbl.add_theme_font_size_override("font_size", 12)
			palmares_container.add_child(t_lbl)

	# Stats
	for child in stats_history_container.get_children():
		child.queue_free()

	# Ligne Saison en cours
	var cur_c_name = c.club_name if c != null else "Libre"
	var cur_stats = p.stats_current_season
	var cur_m = cur_stats.get("matches", 0)
	var cur_g = cur_stats.get("goals", 0)
	var cur_a = cur_stats.get("assists", 0)
	var cur_t = cur_stats.get("tackles", 0)
	var cur_s = cur_stats.get("saves", 0)
	var cur_r = p.get_average_rating()

	var cur_row = _create_stats_row("Saison en cours", cur_c_name, cur_m, cur_g, cur_a, cur_t, cur_s, cur_r, true)
	stats_history_container.add_child(cur_row)

	# Historique
	for h in p.stats_history:
		var row = _create_stats_row(
			"S%d" % h.get("season", 1),
			h.get("club_name", "-"),
			h.get("matches", 0),
			h.get("goals", 0),
			h.get("assists", 0),
			h.get("tackles", 0),
			h.get("saves", 0),
			h.get("avg_rating", 6.0),
			false
		)
		stats_history_container.add_child(row)

func _set_attr(prog: ProgressBar, lbl: Label, val: int) -> void:
	prog.value = val
	lbl.text = str(val)
	if val >= 15:
		lbl.modulate = Color("34d399")
	elif val >= 11:
		lbl.modulate = Color("38bdf8")
	elif val >= 8:
		lbl.modulate = Color("facc15")
	else:
		lbl.modulate = Color("f87171")

func _create_stats_row(season: String, club: String, m: int, g: int, a: int, t: int, s: int, r: float, is_current: bool) -> Control:
	var container = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	if is_current:
		sb.bg_color = Color(0.12, 0.20, 0.35, 0.55)
		sb.border_color = Color(0.22, 0.74, 0.97, 0.7)
		sb.set_border_width_all(1)
	else:
		sb.bg_color = Color(0.06, 0.10, 0.16, 0.35)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	container.add_theme_stylebox_override("panel", sb)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var col_s = Label.new()
	col_s.custom_minimum_size = Vector2(100, 0)
	col_s.text = season
	col_s.add_theme_font_size_override("font_size", 12)
	if is_current:
		col_s.modulate = Color("38bdf8")

	var col_c = Label.new()
	col_c.custom_minimum_size = Vector2(110, 0)
	col_c.text = club
	col_c.add_theme_font_size_override("font_size", 12)

	var col_m = Label.new()
	col_m.custom_minimum_size = Vector2(44, 0)
	col_m.text = str(m)
	col_m.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_m.add_theme_font_size_override("font_size", 12)

	var col_g = Label.new()
	col_g.custom_minimum_size = Vector2(44, 0)
	col_g.text = str(g)
	col_g.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_g.add_theme_font_size_override("font_size", 12)
	if g > 0:
		col_g.modulate = Color("facc15")

	var col_a = Label.new()
	col_a.custom_minimum_size = Vector2(44, 0)
	col_a.text = str(a)
	col_a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_a.add_theme_font_size_override("font_size", 12)
	if a > 0:
		col_a.modulate = Color("38bdf8")

	var col_t = Label.new()
	col_t.custom_minimum_size = Vector2(44, 0)
	col_t.text = str(t)
	col_t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_t.add_theme_font_size_override("font_size", 12)
	if t > 0:
		col_t.modulate = Color("a78bfa")

	var col_s_save = Label.new()
	col_s_save.custom_minimum_size = Vector2(44, 0)
	col_s_save.text = str(s)
	col_s_save.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_s_save.add_theme_font_size_override("font_size", 12)
	if s > 0:
		col_s_save.modulate = Color("34d399")

	var col_r = Label.new()
	col_r.custom_minimum_size = Vector2(45, 0)
	col_r.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col_r.add_theme_font_size_override("font_size", 12)
	if m == 0:
		col_r.text = "-"
		col_r.modulate = Color("64748b")
	else:
		col_r.text = "%.1f" % r
		if r >= 7.0:
			col_r.modulate = Color("34d399")
		elif r <= 5.5:
			col_r.modulate = Color("f87171")

	hbox.add_child(col_s)
	hbox.add_child(col_c)
	hbox.add_child(col_m)
	hbox.add_child(col_g)
	hbox.add_child(col_a)
	hbox.add_child(col_t)
	hbox.add_child(col_s_save)
	hbox.add_child(col_r)

	container.add_child(hbox)
	return container
