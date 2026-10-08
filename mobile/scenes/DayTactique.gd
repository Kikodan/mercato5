class_name DayTactique
extends VBoxContainer

## Jeudi & Vendredi : Tactique & Formations
## Design tactile épuré avec terrain interactif et onglets rétractables.

const Club = preload("res://scripts/Club.gd")
const Player = preload("res://scripts/Player.gd")
const Tactics = preload("res://scripts/Tactics.gd")
const MobilePitchWidget = preload("res://scenes/widgets/MobilePitchWidget.gd")
const MobileCollapsibleSection = preload("res://scenes/widgets/MobileCollapsibleSection.gd")

var club: Club = null
var pitch: MobilePitchWidget
var btn_form_121: Button
var btn_form_112: Button
var btn_form_211: Button
var lbl_rps_desc: Label
var opt_style: OptionButton
var opt_training: OptionButton
var selected_swap_player: Player = null
var bench_container: VBoxContainer
var section_bench: MobileCollapsibleSection

signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)

	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(content_vbox)

	# 1. Section Rétractable : Formation (Pierre-Feuille-Ciseaux)
	var section_formation = MobileCollapsibleSection.new("📐 CHOIX DE LA FORMATION (PFC)", true)
	content_vbox.add_child(section_formation)

	var form_box = VBoxContainer.new()
	form_box.add_theme_constant_override("separation", 6)
	section_formation.add_content(form_box)

	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 6)
	form_box.add_child(btn_hbox)

	btn_form_121 = Button.new()
	btn_form_121.text = "1-2-1 Losange\n(Bat 2-1-1)"
	btn_form_121.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_form_121.custom_minimum_size.y = 48.0
	btn_form_121.focus_mode = Control.FOCUS_NONE
	btn_form_121.pressed.connect(func(): _select_formation(Tactics.TacticalFormation.FORMATION_1_2_1))
	btn_hbox.add_child(btn_form_121)

	btn_form_112 = Button.new()
	btn_form_112.text = "1-1-2 Attaque\n(Bat 1-2-1)"
	btn_form_112.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_form_112.custom_minimum_size.y = 48.0
	btn_form_112.focus_mode = Control.FOCUS_NONE
	btn_form_112.pressed.connect(func(): _select_formation(Tactics.TacticalFormation.FORMATION_1_1_2))
	btn_hbox.add_child(btn_form_112)

	btn_form_211 = Button.new()
	btn_form_211.text = "2-1-1 Défense\n(Bat 1-1-2)"
	btn_form_211.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_form_211.custom_minimum_size.y = 48.0
	btn_form_211.focus_mode = Control.FOCUS_NONE
	btn_form_211.pressed.connect(func(): _select_formation(Tactics.TacticalFormation.FORMATION_2_1_1))
	btn_hbox.add_child(btn_form_211)

	# Fiche explicative PFC
	var rps_card = PanelContainer.new()
	var sb_rps = StyleBoxFlat.new()
	sb_rps.bg_color = Color(0.06, 0.10, 0.18, 0.90)
	sb_rps.border_color = Color(0.20, 0.30, 0.45, 0.70)
	sb_rps.set_border_width_all(1)
	sb_rps.set_corner_radius_all(6)
	sb_rps.content_margin_left = 10
	sb_rps.content_margin_right = 10
	sb_rps.content_margin_top = 6
	sb_rps.content_margin_bottom = 6
	rps_card.add_theme_stylebox_override("panel", sb_rps)
	form_box.add_child(rps_card)

	lbl_rps_desc = Label.new()
	lbl_rps_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_rps_desc.add_theme_font_size_override("font_size", 11)
	lbl_rps_desc.add_theme_color_override("font_color", Color("94a3b8"))
	rps_card.add_child(lbl_rps_desc)

	# 2. Terrain vertical Futsal interactif
	pitch = MobilePitchWidget.new()
	pitch.custom_minimum_size = Vector2(340, 270)
	pitch.player_clicked.connect(_on_pitch_player_clicked)
	content_vbox.add_child(pitch)

	# Bouton Auto-Lineup tactile
	var btn_auto = Button.new()
	btn_auto.text = "⚡ Aligner le Meilleur 5 selon la Forme"
	btn_auto.custom_minimum_size.y = 46.0
	btn_auto.add_theme_font_size_override("font_size", 13)
	btn_auto.focus_mode = Control.FOCUS_NONE
	var sb_auto = StyleBoxFlat.new()
	sb_auto.bg_color = Color(0.08, 0.22, 0.38, 0.95)
	sb_auto.border_color = Color("38bdf8")
	sb_auto.set_border_width_all(1)
	sb_auto.set_corner_radius_all(8)
	btn_auto.add_theme_stylebox_override("normal", sb_auto)
	btn_auto.pressed.connect(func():
		if club != null:
			club.auto_pick_lineup()
			selected_swap_player = null
			refresh_view()
			data_changed.emit()
	)
	content_vbox.add_child(btn_auto)

	# 3. Section Rétractable : Remplaçants à permuter
	section_bench = MobileCollapsibleSection.new("🪑 REMPLAÇANTS POUR PERMUTATION", false)
	content_vbox.add_child(section_bench)

	bench_container = VBoxContainer.new()
	bench_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bench_container.add_theme_constant_override("separation", 6)
	section_bench.add_content(bench_container)

	# 4. Section Rétractable : Style et Entraînement
	var section_style = MobileCollapsibleSection.new("🧠 STYLE DE JEU & FOCUS ENTRAÎNEMENT", false)
	content_vbox.add_child(section_style)

	var set_vbox = VBoxContainer.new()
	set_vbox.add_theme_constant_override("separation", 10)
	section_style.add_content(set_vbox)

	var v1 = VBoxContainer.new()
	var l1 = Label.new()
	l1.text = "Philosophie de jeu :"
	l1.add_theme_font_size_override("font_size", 12)
	l1.add_theme_color_override("font_color", Color("94a3b8"))
	v1.add_child(l1)
	opt_style = OptionButton.new()
	opt_style.custom_minimum_size.y = 44.0
	opt_style.add_item("Équilibré (Standard)", 0)
	opt_style.add_item("Attaque Totale (Pression haute)", 1)
	opt_style.add_item("Contre-Attaque (Bloc bas & transition)", 2)
	opt_style.item_selected.connect(func(idx: int):
		if club != null:
			club.tactical_style = idx
			data_changed.emit()
	)
	v1.add_child(opt_style)
	set_vbox.add_child(v1)

	var v2 = VBoxContainer.new()
	var l2 = Label.new()
	l2.text = "Focus d'entraînement de la semaine :"
	l2.add_theme_font_size_override("font_size", 12)
	l2.add_theme_color_override("font_color", Color("94a3b8"))
	v2.add_child(l2)
	opt_training = OptionButton.new()
	opt_training.custom_minimum_size.y = 44.0
	opt_training.add_item("Cryo & Récupération physique (+Forme)", 0)
	opt_training.add_item("Finition & Frappes face au gardien", 1)
	opt_training.add_item("Bloc Défensif & Duels 1 contre 1", 2)
	opt_training.item_selected.connect(func(idx: int):
		if club != null:
			club.training_focus = idx
			data_changed.emit()
	)
	v2.add_child(opt_training)
	set_vbox.add_child(v2)

func setup(p_club: Club) -> void:
	club = p_club
	refresh_view()

func refresh_view() -> void:
	if club == null:
		return

	_update_formation_buttons()
	lbl_rps_desc.text = Tactics.get_formation_desc(club.tactical_formation)

	pitch.set_lineup(club.starting_five, selected_swap_player, club.tactical_formation)

	opt_style.selected = club.tactical_style
	opt_training.selected = club.training_focus

	_render_bench_swaps()

func _render_bench_swaps() -> void:
	for c in bench_container.get_children():
		c.queue_free()

	var bench_players = []
	for p in club.squad:
		if not club.starting_five.has(p):
			bench_players.append(p)

	section_bench.set_badge("%d remplaçants" % bench_players.size(), Color("94a3b8"))

	var hint_lbl = Label.new()
	if selected_swap_player:
		hint_lbl.text = "👉 Touchez un remplaçant pour le permuter avec %s :" % selected_swap_player.full_name
		hint_lbl.add_theme_color_override("font_color", Color("facc15"))
	else:
		hint_lbl.text = "Touchez un titulaire sur le terrain puis un remplaçant ci-dessous :"
		hint_lbl.add_theme_color_override("font_color", Color("94a3b8"))
	hint_lbl.add_theme_font_size_override("font_size", 11)
	bench_container.add_child(hint_lbl)

	for p in bench_players:
		var btn = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size.y = 44.0
		btn.focus_mode = Control.FOCUS_NONE
		var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
		btn.text = "[%s] %s  •  %d OVR  •  ⚡ %d%%" % [pos_str, p.full_name, p.get_overall(), int(p.fitness * 100)]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_font_size_override("font_size", 12)

		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.12, 0.20, 0.90)
		sb.border_color = Color(0.20, 0.30, 0.45, 0.6)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 12
		btn.add_theme_stylebox_override("normal", sb)

		var this_p = p
		btn.pressed.connect(func():
			if selected_swap_player != null:
				var idx = club.starting_five.find(selected_swap_player)
				if idx != -1:
					club.starting_five[idx] = this_p
					selected_swap_player = null
					data_changed.emit()
					refresh_view()
		)
		bench_container.add_child(btn)

func _select_formation(f: int) -> void:
	if club != null:
		club.tactical_formation = f
		refresh_view()
		data_changed.emit()

func _update_formation_buttons() -> void:
	var f = club.tactical_formation
	_style_btn(btn_form_121, f == Tactics.TacticalFormation.FORMATION_1_2_1)
	_style_btn(btn_form_112, f == Tactics.TacticalFormation.FORMATION_1_1_2)
	_style_btn(btn_form_211, f == Tactics.TacticalFormation.FORMATION_2_1_1)

func _style_btn(b: Button, active: bool) -> void:
	var sb = StyleBoxFlat.new()
	sb.set_corner_radius_all(8)
	if active:
		sb.bg_color = Color(0.98, 0.80, 0.08, 0.25)
		sb.border_color = Color("facc15")
		sb.set_border_width_all(2)
		b.add_theme_color_override("font_color", Color("facc15"))
	else:
		sb.bg_color = Color(0.08, 0.12, 0.20, 0.90)
		sb.border_color = Color(0.20, 0.28, 0.40, 0.60)
		sb.set_border_width_all(1)
		b.add_theme_color_override("font_color", Color("94a3b8"))
	b.add_theme_stylebox_override("normal", sb)

func _on_pitch_player_clicked(p: Player) -> void:
	if selected_swap_player == null:
		selected_swap_player = p
		section_bench.set_expanded(true)
	elif selected_swap_player == p:
		selected_swap_player = null
	else:
		var idx_a = club.starting_five.find(selected_swap_player)
		var idx_b = club.starting_five.find(p)
		if idx_a != -1 and idx_b != -1:
			club.starting_five[idx_a] = p
			club.starting_five[idx_b] = selected_swap_player
		selected_swap_player = null
		data_changed.emit()
	refresh_view()
