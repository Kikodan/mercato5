class_name SponsorNegotiationModal
extends Control

signal sponsor_contract_signed(category_id: String, proposal: Dictionary)

var current_club: Club = null
var current_category: String = "PRIMARY"
var proposals: Array[Dictionary] = []
var selected_index: int = 0
var negotiated_flags: Dictionary = {}

var panel: PanelContainer
var vbox_content: VBoxContainer
var lbl_title: Label
var lbl_current_contract: Label
var cards_container: HBoxContainer
var lbl_feedback: Label

func _ready() -> void:
	visible = false
	z_index = 65
	_build_ui()

func open_negotiation(club: Club, category_id: String) -> void:
	if panel == null:
		_build_ui()
	current_club = club
	current_category = category_id
	negotiated_flags.clear()
	selected_index = 0
	
	var div = club.division if club else 1
	var rep = club.reputation if club else 50
	proposals = ClubFinances.generate_sponsor_proposals(category_id, div, rep)
	
	_update_header()
	_render_proposals()
	lbl_feedback.text = "Sélectionnez une proposition de sponsor. Vous pouvez signer immédiatement ou tenter de négocier un bonus supérieur !"
	lbl_feedback.modulate = Color("94a3b8")
	
	visible = true
	move_to_front()

func close_modal() -> void:
	visible = false

func _build_ui() -> void:
	for c in get_children():
		c.queue_free()

	var overlay = ColorRect.new()
	overlay.color = Color(0.03, 0.05, 0.1, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(860, 560)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.10, 0.18, 0.98)
	sb.set_corner_radius_all(14)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color("facc15")
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	vbox_content = VBoxContainer.new()
	vbox_content.add_theme_constant_override("separation", 14)
	panel.add_child(vbox_content)

	# En-tête
	var header_hbox = HBoxContainer.new()
	lbl_title = Label.new()
	lbl_title.text = "🤝 NÉGOCIATION COMMERCIALE • NOUVEAU SPONSOR"
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_title.add_theme_font_size_override("font_size", 18)
	lbl_title.add_theme_color_override("font_color", Color("facc15"))
	header_hbox.add_child(lbl_title)

	var btn_close = Button.new()
	btn_close.text = "✕"
	btn_close.custom_minimum_size = Vector2(34, 34)
	btn_close.pressed.connect(close_modal)
	header_hbox.add_child(btn_close)
	vbox_content.add_child(header_hbox)

	lbl_current_contract = Label.new()
	lbl_current_contract.add_theme_font_size_override("font_size", 13)
	lbl_current_contract.add_theme_color_override("font_color", Color("38bdf8"))
	vbox_content.add_child(lbl_current_contract)

	var sep = HSeparator.new()
	vbox_content.add_child(sep)

	# Zone des 3 cartes d'offres
	cards_container = HBoxContainer.new()
	cards_container.add_theme_constant_override("separation", 16)
	cards_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox_content.add_child(cards_container)

	# Message de feedback / négociation
	lbl_feedback = Label.new()
	lbl_feedback.text = ""
	lbl_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_feedback.add_theme_font_size_override("font_size", 13)
	lbl_feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox_content.add_child(lbl_feedback)

	# Bouton quitter / retour
	var btm_hbox = HBoxContainer.new()
	btm_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var btn_cancel = Button.new()
	btn_cancel.text = "Conserver le contrat actuel et fermer"
	btn_cancel.custom_minimum_size = Vector2(260, 38)
	btn_cancel.pressed.connect(close_modal)
	btm_hbox.add_child(btn_cancel)
	vbox_content.add_child(btm_hbox)

func _update_header() -> void:
	if current_club == null:
		return
	var fin = current_club.get_finances()
	var cat_label = ""
	var cur_name = ""
	var cur_pay = 0
	var cur_bonus = 0
	var cur_weeks = 0

	match current_category:
		"PRIMARY":
			cat_label = "👕 Sponsor Maillot Principal"
			cur_name = fin.primary_sponsor_name
			cur_pay = fin.primary_sponsor_weekly
			cur_bonus = fin.primary_sponsor_bonus_win
			cur_weeks = fin.primary_sponsor_weeks_left
		"ARENA":
			cat_label = "🏟️ Naming & Partenaire Salle"
			cur_name = fin.arena_sponsor_name
			cur_pay = fin.arena_sponsor_weekly
			cur_bonus = fin.arena_sponsor_bonus_win
			cur_weeks = fin.arena_sponsor_weeks_left
		"KIT":
			cat_label = "👟 Équipementier Officiel"
			cur_name = fin.kit_sponsor_name
			cur_pay = fin.kit_sponsor_weekly
			cur_bonus = fin.kit_sponsor_bonus_win
			cur_weeks = fin.kit_sponsor_weeks_left
		"BOARD":
			cat_label = "🪧 Panneaux & Régie Publicitaire LED"
			cur_name = fin.board_ads_name
			cur_pay = fin.board_ads_weekly
			cur_bonus = fin.board_ads_bonus_win
			cur_weeks = fin.board_ads_weeks_left

	lbl_title.text = "🤝 NÉGOCIATION • %s" % cat_label
	lbl_current_contract.text = "Contrat actif : %s (+%s €/semaine | +%s €/victoire | %d semaines restantes)" % [
		cur_name, String.num_int64(cur_pay), String.num_int64(cur_bonus), cur_weeks
	]

func _render_proposals() -> void:
	for c in cards_container.get_children():
		c.queue_free()

	for i in range(proposals.size()):
		var prop = proposals[i]
		var card = _create_proposal_card(prop, i)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards_container.add_child(card)

func _create_proposal_card(prop: Dictionary, index: int) -> PanelContainer:
	var pc = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.15, 0.24, 0.95)
	style.set_corner_radius_all(10)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("38bdf8") if index == 0 else (Color("a855f7") if index == 1 else Color("34d399"))
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	pc.add_theme_stylebox_override("panel", style)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)

	var name_lbl = Label.new()
	name_lbl.text = prop["brand_name"]
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(name_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = "« %s »" % prop["description"]
	desc_lbl.add_theme_font_size_override("font_size", 12)
	desc_lbl.add_theme_color_override("font_color", Color("94a3b8"))
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(desc_lbl)

	var sep = HSeparator.new()
	vb.add_child(sep)

	# Détails de l'offre
	var grid = VBoxContainer.new()
	grid.add_theme_constant_override("separation", 6)

	grid.add_child(_create_detail_row("Versement fixe :", "+%s € / sem" % String.num_int64(prop["weekly_payout"]), Color("34d399")))
	grid.add_child(_create_detail_row("Prime de victoire :", "+%s € / match" % String.num_int64(prop["win_bonus"]), Color("facc15")))
	grid.add_child(_create_detail_row("Prime signature :", "+%s € cash" % String.num_int64(prop["signing_bonus"]), Color("38bdf8")))
	grid.add_child(_create_detail_row("Engagement :", "%d semaines" % prop["duration_weeks"], Color("e2e8f0")))
	vb.add_child(grid)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(spacer)

	# Bouton Négocier (+12%)
	var is_negotiated = negotiated_flags.get(index, false)
	var btn_nego = Button.new()
	btn_nego.text = "💬 Négocier (+15%)" if not is_negotiated else "✅ Offre déjà négociée"
	btn_nego.disabled = is_negotiated
	btn_nego.custom_minimum_size = Vector2(0, 34)
	btn_nego.pressed.connect(func(): _on_negotiate_pressed(index))
	vb.add_child(btn_nego)

	# Bouton Signer
	var btn_sign = Button.new()
	btn_sign.text = "✍️ Signer ce Contrat"
	btn_sign.custom_minimum_size = Vector2(0, 38)
	btn_sign.modulate = Color("10b981")
	btn_sign.pressed.connect(func(): _on_sign_pressed(index))
	vb.add_child(btn_sign)

	pc.add_child(vb)
	return pc

func _create_detail_row(label_text: String, value_text: String, val_color: Color) -> HBoxContainer:
	var row = HBoxContainer.new()
	var l = Label.new()
	l.text = label_text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color("cbd5e1"))
	row.add_child(l)

	var v = Label.new()
	v.text = value_text
	v.add_theme_font_size_override("font_size", 13)
	v.add_theme_color_override("font_color", val_color)
	row.add_child(v)
	return row

func _on_negotiate_pressed(index: int) -> void:
	if negotiated_flags.get(index, false):
		return
	negotiated_flags[index] = true
	var prop = proposals[index]
	var rep = current_club.reputation if current_club else 50

	# Probabilité d'accord selon la réputation
	var success_chance = clampf(0.40 + (float(rep) - 50.0) * 0.01, 0.30, 0.85)
	if randf() < success_chance:
		var bonus_mult = randf_range(1.12, 1.20)
		var old_pay = prop["weekly_payout"]
		prop["weekly_payout"] = int(old_pay * bonus_mult)
		prop["win_bonus"] = int(prop["win_bonus"] * bonus_mult)
		prop["signing_bonus"] = int(prop["signing_bonus"] * 1.15)
		lbl_feedback.text = "🎉 Négociation réussie avec %s ! Le versement passe de %s € à %s € / semaine !" % [
			prop["brand_name"], String.num_int64(old_pay), String.num_int64(prop["weekly_payout"])
		]
		lbl_feedback.modulate = Color("34d399")
	else:
		lbl_feedback.text = "❌ %s a refusé votre surenchère mais maintient son offre initiale sans modification." % prop["brand_name"]
		lbl_feedback.modulate = Color("fbbf24")

	_render_proposals()

func _on_sign_pressed(index: int) -> void:
	var prop = proposals[index]
	if current_club == null:
		return
	var fin = current_club.get_finances()
	fin.apply_negotiated_sponsor(current_category, prop)
	
	# Créditer la prime à la signature
	var sign_bonus = prop.get("signing_bonus", 0)
	current_club.budget += sign_bonus

	sponsor_contract_signed.emit(current_category, prop)
	close_modal()
