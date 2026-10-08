class_name DayTactique
extends VBoxContainer

const Club = preload("res://scripts/Club.gd")
const Player = preload("res://scripts/Player.gd")
const Tactics = preload("res://scripts/Tactics.gd")
const MobilePitchWidget = preload("res://scenes/widgets/MobilePitchWidget.gd")

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

signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)

	# 1. Sélecteur de Formation (3 gros boutons tactiles)
	var form_box = VBoxContainer.new()
	form_box.add_theme_constant_override("separation", 4)
	add_child(form_box)

	var lbl_f_title = Label.new()
	lbl_f_title.text = "📐 CHOIX DE LA FORMATION (PIERRE-FEUILLE-CISEAUX) :"
	lbl_f_title.add_theme_font_size_override("font_size", 11)
	lbl_f_title.add_theme_color_override("font_color", Color("facc15"))
	form_box.add_child(lbl_f_title)

	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 6)
	form_box.add_child(btn_hbox)

	btn_form_121 = Button.new()
	btn_form_121.text = "1-2-1 Losange\n(Bat 2-1-1)"
	btn_form_121.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_form_121.custom_minimum_size.y = 44.0
	btn_form_121.pressed.connect(func(): _select_formation(Tactics.TacticalFormation.FORMATION_1_2_1))
	btn_hbox.add_child(btn_form_121)

	btn_form_112 = Button.new()
	btn_form_112.text = "1-1-2 Attaque\n(Bat 1-2-1)"
	btn_form_112.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_form_112.custom_minimum_size.y = 44.0
	btn_form_112.pressed.connect(func(): _select_formation(Tactics.TacticalFormation.FORMATION_1_1_2))
	btn_hbox.add_child(btn_form_112)

	btn_form_211 = Button.new()
	btn_form_211.text = "2-1-1 Défense\n(Bat 1-1-2)"
	btn_form_211.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_form_211.custom_minimum_size.y = 44.0
	btn_form_211.pressed.connect(func(): _select_formation(Tactics.TacticalFormation.FORMATION_2_1_1))
	btn_hbox.add_child(btn_form_211)

	# Fiche explicative PFC
	var rps_card = PanelContainer.new()
	var sb_rps = StyleBoxFlat.new()
	sb_rps.bg_color = Color(0.06, 0.10, 0.18, 0.90)
	sb_rps.border_color = Color(0.20, 0.30, 0.45, 0.70)
	sb_rps.set_border_width_all(1)
	sb_rps.set_corner_radius_all(6)
	sb_rps.content_margin_left = 8
	sb_rps.content_margin_right = 8
	sb_rps.content_margin_top = 4
	sb_rps.content_margin_bottom = 4
	rps_card.add_theme_stylebox_override("panel", sb_rps)
	form_box.add_child(rps_card)

	lbl_rps_desc = Label.new()
	lbl_rps_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_rps_desc.add_theme_font_size_override("font_size", 10)
	lbl_rps_desc.add_theme_color_override("font_color", Color("94a3b8"))
	rps_card.add_child(lbl_rps_desc)

	# 2. Terrain vertical mobile
	pitch = MobilePitchWidget.new()
	pitch.custom_minimum_size = Vector2(340, 260)
	pitch.player_clicked.connect(_on_pitch_player_clicked)
	add_child(pitch)

	# Bouton Auto-Lineup
	var btn_auto = Button.new()
	btn_auto.text = "⚡ Aligner le Meilleur 5 selon Forme & Rôles"
	btn_auto.custom_minimum_size.y = 38.0
	btn_auto.modulate = Color("38bdf8")
	btn_auto.pressed.connect(func():
		if club != null:
			club.auto_pick_lineup()
			refresh_view()
			data_changed.emit()
	)
	add_child(btn_auto)

	# 3. Paramètres de Style et Entraînement
	var set_hbox = HBoxContainer.new()
	set_hbox.add_theme_constant_override("separation", 8)
	add_child(set_hbox)

	var v1 = VBoxContainer.new()
	v1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var l1 = Label.new()
	l1.text = "Style Tactique :"
	l1.add_theme_font_size_override("font_size", 11)
	v1.add_child(l1)
	opt_style = OptionButton.new()
	opt_style.add_item("Équilibré", 0)
	opt_style.add_item("Attaque Totale", 1)
	opt_style.add_item("Contre-Attaque", 2)
	opt_style.item_selected.connect(func(idx: int):
		if club != null:
			club.tactical_style = idx
			data_changed.emit()
	)
	v1.add_child(opt_style)
	set_hbox.add_child(v1)

	var v2 = VBoxContainer.new()
	v2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var l2 = Label.new()
	l2.text = "Focus Entraînement :"
	l2.add_theme_font_size_override("font_size", 11)
	v2.add_child(l2)
	opt_training = OptionButton.new()
	opt_training.add_item("Cryo & Récupération", 0)
	opt_training.add_item("Finition & Frappes", 1)
	opt_training.add_item("Bloc Défensif", 2)
	opt_training.item_selected.connect(func(idx: int):
		if club != null:
			club.training_focus = idx
			data_changed.emit()
	)
	v2.add_child(opt_training)
	set_hbox.add_child(v2)

func setup(p_club: Club) -> void:
	club = p_club
	refresh_view()

func refresh_view() -> void:
	if club == null:
		return

	# Style des boutons de formation
	_update_formation_buttons()
	lbl_rps_desc.text = Tactics.get_formation_desc(club.tactical_formation)

	# Mettre à jour le terrain
	pitch.set_lineup(club.starting_five, selected_swap_player, club.tactical_formation)

	opt_style.selected = club.tactical_style
	opt_training.selected = club.training_focus

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
	sb.set_corner_radius_all(6)
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
	elif selected_swap_player == p:
		selected_swap_player = null
	else:
		# Permuter dans starting_five
		var idx_a = club.starting_five.find(selected_swap_player)
		var idx_b = club.starting_five.find(p)
		if idx_a != -1 and idx_b != -1:
			club.starting_five[idx_a] = p
			club.starting_five[idx_b] = selected_swap_player
		selected_swap_player = null
		data_changed.emit()
	refresh_view()
