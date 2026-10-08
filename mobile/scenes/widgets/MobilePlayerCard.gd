class_name MobilePlayerCard
extends PanelContainer

const Player = preload("res://scripts/Player.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")

signal transfer_list_toggled(player: Player)
signal renew_requested(player: Player)
signal detail_requested(player: Player)
signal player_selected(player: Player)

var current_player: Player = null
var is_starter_player: bool = false

func setup(p: Player, is_starter: bool = false, show_actions: bool = true, is_user_player: bool = true) -> void:
	current_player = p
	is_starter_player = is_starter

	for child in get_children():
		child.queue_free()

	custom_minimum_size.y = 66.0
	var sb = StyleBoxFlat.new()
	if is_starter:
		sb.bg_color = Color(0.08, 0.14, 0.24, 0.95)
		sb.border_color = Color("38bdf8")
		sb.set_border_width_all(1)
	else:
		sb.bg_color = Color(0.06, 0.09, 0.16, 0.90)
		sb.border_color = Color(0.18, 0.25, 0.38, 0.60)
		sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	add_theme_stylebox_override("panel", sb)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	add_child(hbox)

	# Pastille Poste
	var pos_lbl = Label.new()
	var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
	pos_lbl.text = pos_str
	pos_lbl.custom_minimum_size = Vector2(36, 26)
	pos_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pos_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pos_lbl.add_theme_font_size_override("font_size", 11)

	var sb_pos = StyleBoxFlat.new()
	sb_pos.set_corner_radius_all(4)
	match p.position:
		Player.Position.GK: sb_pos.bg_color = Color("f59e0b")
		Player.Position.DEF: sb_pos.bg_color = Color("38bdf8")
		Player.Position.MID: sb_pos.bg_color = Color("10b981")
		Player.Position.FWD: sb_pos.bg_color = Color("f43f5e")
	pos_lbl.add_theme_stylebox_override("normal", sb_pos)
	pos_lbl.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(pos_lbl)

	# Info Joueur (Nom, Âge, Forme)
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(info_vbox)

	var name_line = HBoxContainer.new()
	name_line.add_theme_constant_override("separation", 6)
	info_vbox.add_child(name_line)

	var lbl_name = Label.new()
	lbl_name.text = "%s %s" % [p.get_flag_emoji(), p.full_name]
	lbl_name.add_theme_font_size_override("font_size", 13)
	lbl_name.add_theme_color_override("font_color", Color("f1f5f9"))
	name_line.add_child(lbl_name)

	if p.is_transfer_listed:
		var lbl_tag = Label.new()
		lbl_tag.text = "🏷️ LISTÉ"
		lbl_tag.add_theme_font_size_override("font_size", 10)
		lbl_tag.add_theme_color_override("font_color", Color("c084fc"))
		name_line.add_child(lbl_tag)

	var stats_line = HBoxContainer.new()
	stats_line.add_theme_constant_override("separation", 8)
	info_vbox.add_child(stats_line)

	var lbl_age = Label.new()
	lbl_age.text = "%da" % p.age
	lbl_age.add_theme_font_size_override("font_size", 11)
	lbl_age.add_theme_color_override("font_color", Color("94a3b8"))
	stats_line.add_child(lbl_age)

	# Jauge de forme physique
	var fit_pct = int(p.fitness * 100.0)
	var lbl_fit = Label.new()
	lbl_fit.text = "⚡ %d%%" % fit_pct
	lbl_fit.add_theme_font_size_override("font_size", 11)
	if fit_pct >= 85:
		lbl_fit.add_theme_color_override("font_color", Color("34d399"))
	elif fit_pct >= 65:
		lbl_fit.add_theme_color_override("font_color", Color("facc15"))
	else:
		lbl_fit.add_theme_color_override("font_color", Color("f87171"))
	stats_line.add_child(lbl_fit)

	# Contrat
	if is_user_player:
		var lbl_contrat = Label.new()
		lbl_contrat.text = "📄 %dan%s" % [p.contract_years, ("s" if p.contract_years > 1 else "")]
		lbl_contrat.add_theme_font_size_override("font_size", 11)
		lbl_contrat.add_theme_color_override("font_color", Color("f87171") if p.contract_years <= 1 else Color("64748b"))
		stats_line.add_child(lbl_contrat)

	# Note OVR
	var ovr_lbl = Label.new()
	ovr_lbl.text = str(p.get_overall())
	ovr_lbl.custom_minimum_size = Vector2(38, 38)
	ovr_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ovr_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ovr_lbl.add_theme_font_size_override("font_size", 16)
	ovr_lbl.add_theme_color_override("font_color", Color("facc15"))
	var sb_ovr = StyleBoxFlat.new()
	sb_ovr.bg_color = Color(0.12, 0.18, 0.28, 0.90)
	sb_ovr.border_color = Color("facc15")
	sb_ovr.set_border_width_all(1)
	sb_ovr.set_corner_radius_all(6)
	ovr_lbl.add_theme_stylebox_override("normal", sb_ovr)
	hbox.add_child(ovr_lbl)

	# Boutons d'Action
	if show_actions:
		if is_user_player:
			# Bouton Liste de Transfert
			var btn_list = Button.new()
			btn_list.text = "🏷️"
			btn_list.tooltip_text = "Placer / Retirer de la liste des transferts"
			btn_list.custom_minimum_size = Vector2(36, 36)
			btn_list.modulate = Color("f87171") if p.is_transfer_listed else Color("c084fc")
			btn_list.pressed.connect(func(): transfer_list_toggled.emit(p))
			hbox.add_child(btn_list)

			# Bouton Prolonger (si fin de contrat)
			if p.contract_years <= 2:
				var btn_renew = Button.new()
				btn_renew.text = "📝"
				btn_renew.tooltip_text = "Prolonger le contrat"
				btn_renew.custom_minimum_size = Vector2(36, 36)
				btn_renew.modulate = Color("34d399")
				btn_renew.pressed.connect(func(): renew_requested.emit(p))
				hbox.add_child(btn_renew)

		# Bouton Détails
		var btn_detail = Button.new()
		btn_detail.text = "👤"
		btn_detail.tooltip_text = "Fiche détaillée"
		btn_detail.custom_minimum_size = Vector2(36, 36)
		btn_detail.pressed.connect(func(): detail_requested.emit(p))
		hbox.add_child(btn_detail)
