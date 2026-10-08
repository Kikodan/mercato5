class_name DayEconomie
extends VBoxContainer

const Club = preload("res://scripts/Club.gd")
const ClubFinances = preload("res://scripts/ClubFinances.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")

var club: Club = null
var scroll: ScrollContainer
var main_container: VBoxContainer

# Éléments récapitulatifs
var lbl_treasury: Label
var lbl_net: Label
var lbl_dncg_badge: Label
var lbl_dncg_status: Label
var lbl_ticket_price: Label

signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)

	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	main_container = VBoxContainer.new()
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.add_theme_constant_override("separation", 10)
	scroll.add_child(main_container)

func setup(p_club: Club) -> void:
	club = p_club
	refresh_view()

func refresh_view() -> void:
	for c in main_container.get_children():
		c.queue_free()

	if club == null:
		return

	var fin = club.get_finances()
	var wage_bill = club.get_total_wage()
	var sponsor_tot = fin.get_total_sponsor_weekly()
	var tv_rights = fin.weekly_tv_rights
	var maintenance = fin.weekly_maintenance
	var fixed_income = fin.get_total_fixed_income()
	var fixed_expense = wage_bill + maintenance
	var fixed_net = fixed_income - fixed_expense

	# 1. En-tête Bilan de la Semaine
	var p_sum = PanelContainer.new()
	var sb_s = StyleBoxFlat.new()
	sb_s.bg_color = Color(0.06, 0.10, 0.18, 0.95)
	sb_s.border_color = Color("facc15")
	sb_s.set_border_width_all(1)
	sb_s.set_corner_radius_all(10)
	sb_s.content_margin_left = 12
	sb_s.content_margin_right = 12
	sb_s.content_margin_top = 10
	sb_s.content_margin_bottom = 10
	p_sum.add_theme_stylebox_override("panel", sb_s)
	main_container.add_child(p_sum)

	var sum_vbox = VBoxContainer.new()
	sum_vbox.add_theme_constant_override("separation", 6)
	p_sum.add_child(sum_vbox)

	var lbl_title = Label.new()
	lbl_title.text = "📊 BILAN FINANCIER HEBDOMADAIRE"
	lbl_title.add_theme_font_size_override("font_size", 13)
	lbl_title.add_theme_color_override("font_color", Color("facc15"))
	sum_vbox.add_child(lbl_title)

	var hbox_t = HBoxContainer.new()
	sum_vbox.add_child(hbox_t)

	var lbl_t_title = Label.new()
	lbl_t_title.text = "Trésorerie Actuelle :"
	lbl_t_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_t_title.add_theme_font_size_override("font_size", 12)
	lbl_t_title.add_theme_color_override("font_color", Color("94a3b8"))
	hbox_t.add_child(lbl_t_title)

	lbl_treasury = Label.new()
	lbl_treasury.text = FormatUtils.format_money(club.budget)
	lbl_treasury.add_theme_font_size_override("font_size", 14)
	lbl_treasury.add_theme_color_override("font_color", Color("38bdf8"))
	hbox_t.add_child(lbl_treasury)

	var sep = HSeparator.new()
	sum_vbox.add_child(sep)

	# Lignes Recettes & Dépenses
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 4)
	sum_vbox.add_child(grid)

	_add_grid_row(grid, "• Recettes Sponsors fixes :", "+" + FormatUtils.format_money(sponsor_tot), Color("34d399"))
	_add_grid_row(grid, "• Droits Télévision :", "+" + FormatUtils.format_money(tv_rights), Color("34d399"))
	if fin.recent_match_revenue > 0:
		_add_grid_row(grid, "• Recette Match (billetterie/primes) :", "+" + FormatUtils.format_money(fin.recent_match_revenue), Color("34d399"))
	_add_grid_row(grid, "• Masse salariale joueurs :", "-" + FormatUtils.format_money(wage_bill), Color("f87171"))
	_add_grid_row(grid, "• Entretien salle & installations :", "-" + FormatUtils.format_money(maintenance), Color("f87171"))

	var sep2 = HSeparator.new()
	sum_vbox.add_child(sep2)

	var row_net = HBoxContainer.new()
	sum_vbox.add_child(row_net)

	var lbl_n_title = Label.new()
	lbl_n_title.text = "Résultat Net Fixe / semaine :"
	lbl_n_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_n_title.add_theme_font_size_override("font_size", 12)
	row_net.add_child(lbl_n_title)

	lbl_net = Label.new()
	lbl_net.text = ("+" if fixed_net >= 0 else "") + FormatUtils.format_money(fixed_net)
	lbl_net.add_theme_font_size_override("font_size", 14)
	lbl_net.add_theme_color_override("font_color", Color("34d399") if fixed_net >= 0 else Color("f87171"))
	row_net.add_child(lbl_net)

	# 2. Section DNCG / Fair-Play Financier
	var p_dncg = PanelContainer.new()
	var sb_d = StyleBoxFlat.new()
	sb_d.bg_color = Color(0.07, 0.11, 0.18, 0.95)
	sb_d.border_color = Color("34d399") if fixed_net >= 0 else Color("f87171")
	sb_d.set_border_width_all(1)
	sb_d.set_corner_radius_all(8)
	sb_d.content_margin_left = 12
	sb_d.content_margin_right = 12
	sb_d.content_margin_top = 8
	sb_d.content_margin_bottom = 8
	p_dncg.add_theme_stylebox_override("panel", sb_d)
	main_container.add_child(p_dncg)

	var dncg_vbox = VBoxContainer.new()
	dncg_vbox.add_theme_constant_override("separation", 4)
	p_dncg.add_child(dncg_vbox)

	var dncg_hdr = HBoxContainer.new()
	dncg_vbox.add_child(dncg_hdr)

	var lbl_d_t = Label.new()
	lbl_d_t.text = "⚖️ CONTRÔLE DNCG & FAIR-PLAY :"
	lbl_d_t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_d_t.add_theme_font_size_override("font_size", 11)
	lbl_d_t.add_theme_color_override("font_color", Color("facc15"))
	dncg_hdr.add_child(lbl_d_t)

	lbl_dncg_badge = Label.new()
	if fixed_net >= 0:
		lbl_dncg_badge.text = "✅ CONFORME"
		lbl_dncg_badge.add_theme_color_override("font_color", Color("34d399"))
	else:
		lbl_dncg_badge.text = "⚠️ DEFICITAIRE"
		lbl_dncg_badge.add_theme_color_override("font_color", Color("f87171"))
	lbl_dncg_badge.add_theme_font_size_override("font_size", 11)
	dncg_hdr.add_child(lbl_dncg_badge)

	lbl_dncg_status = Label.new()
	if fixed_net >= 0:
		lbl_dncg_status.text = "Votre modèle économique est rentable. Recrutement autorisé sans restriction pour la prochaine saison."
	else:
		lbl_dncg_status.text = "Attention : Vos dépenses fixes dépassent vos recettes fixes. Si la saison se termine en négatif, la DNCG bloquera les recrutements !"
	lbl_dncg_status.add_theme_font_size_override("font_size", 10)
	lbl_dncg_status.add_theme_color_override("font_color", Color("94a3b8"))
	lbl_dncg_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dncg_vbox.add_child(lbl_dncg_status)

	# 3. Billetterie & Palais des Sports
	var p_arena = PanelContainer.new()
	var sb_ar = StyleBoxFlat.new()
	sb_ar.bg_color = Color(0.08, 0.12, 0.20, 0.9)
	sb_ar.border_color = Color(0.20, 0.28, 0.42, 0.6)
	sb_ar.set_border_width_all(1)
	sb_ar.set_corner_radius_all(8)
	sb_ar.content_margin_left = 12
	sb_ar.content_margin_right = 12
	sb_ar.content_margin_top = 8
	sb_ar.content_margin_bottom = 8
	p_arena.add_theme_stylebox_override("panel", sb_ar)
	main_container.add_child(p_arena)

	var ar_vbox = VBoxContainer.new()
	ar_vbox.add_theme_constant_override("separation", 6)
	p_arena.add_child(ar_vbox)

	var lbl_ar_title = Label.new()
	lbl_ar_title.text = "🏟️ SALLE & BILLETTERIE (%s - %d places)" % [fin.arena_name, fin.arena_capacity]
	lbl_ar_title.add_theme_font_size_override("font_size", 11)
	lbl_ar_title.add_theme_color_override("font_color", Color("38bdf8"))
	ar_vbox.add_child(lbl_ar_title)

	var price_row = HBoxContainer.new()
	price_row.alignment = BoxContainer.ALIGNMENT_CENTER
	price_row.add_theme_constant_override("separation", 10)
	ar_vbox.add_child(price_row)

	var btn_minus = Button.new()
	btn_minus.text = "➖ -2€"
	btn_minus.custom_minimum_size = Vector2(60, 32)
	btn_minus.pressed.connect(func():
		fin.ticket_price = maxi(5, fin.ticket_price - 2)
		refresh_view()
		data_changed.emit()
	)
	price_row.add_child(btn_minus)

	lbl_ticket_price = Label.new()
	var att_pct = int(fin.estimate_attendance_percentage(fin.ticket_price, club.division) * 100.0)
	lbl_ticket_price.text = "Prix: %d € (Remplissage estimé : ~%d%%)" % [fin.ticket_price, att_pct]
	lbl_ticket_price.add_theme_font_size_override("font_size", 12)
	price_row.add_child(lbl_ticket_price)

	var btn_plus = Button.new()
	btn_plus.text = "➕ +2€"
	btn_plus.custom_minimum_size = Vector2(60, 32)
	btn_plus.pressed.connect(func():
		fin.ticket_price = mini(50, fin.ticket_price + 2)
		refresh_view()
		data_changed.emit()
	)
	price_row.add_child(btn_plus)

	# 4. Partenariats & Sponsors
	var lbl_sp_h = Label.new()
	lbl_sp_h.text = "🤝 CONTRATS SPONSORS :"
	lbl_sp_h.add_theme_font_size_override("font_size", 12)
	lbl_sp_h.add_theme_color_override("font_color", Color("facc15"))
	main_container.add_child(lbl_sp_h)

	_build_sponsor_card("PRIMARY", "Sponsor Maillot", fin.primary_sponsor_name, fin.primary_sponsor_weekly, fin.primary_sponsor_bonus_win, fin.primary_sponsor_weeks_left)
	_build_sponsor_card("ARENA", "Partenaire Salle", fin.arena_sponsor_name, fin.arena_sponsor_weekly, fin.arena_sponsor_bonus_win, fin.arena_sponsor_weeks_left)
	_build_sponsor_card("KIT", "Équipementier", fin.kit_sponsor_name, fin.kit_sponsor_weekly, fin.kit_sponsor_bonus_win, fin.kit_sponsor_weeks_left)
	_build_sponsor_card("BOARD", "Affichage LED", fin.board_ads_name, fin.board_ads_weekly, fin.board_ads_bonus_win, fin.board_ads_weeks_left)

func _add_grid_row(grid: GridContainer, label_text: String, val_text: String, color: Color) -> void:
	var l = Label.new()
	l.text = label_text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color("cbd5e1"))
	grid.add_child(l)

	var v = Label.new()
	v.text = val_text
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_theme_font_size_override("font_size", 11)
	v.add_theme_color_override("font_color", color)
	grid.add_child(v)

func _build_sponsor_card(category_id: String, type_name: String, brand: String, weekly: int, win_b: int, weeks_left: int) -> void:
	var card = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.10, 0.18, 0.95)
	sb.border_color = Color(0.20, 0.28, 0.42, 0.6)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", sb)
	main_container.add_child(card)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)

	var info_box = VBoxContainer.new()
	info_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_box.add_theme_constant_override("separation", 2)
	hbox.add_child(info_box)

	var title_lbl = Label.new()
	title_lbl.text = "%s : %s" % [type_name, brand]
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	info_box.add_child(title_lbl)

	var det_lbl = Label.new()
	det_lbl.text = "+%s/semaine (+%s prime victoire) • %d sem. restantes" % [
		FormatUtils.format_money(weekly),
		FormatUtils.format_money(win_b),
		weeks_left
	]
	det_lbl.add_theme_font_size_override("font_size", 10)
	det_lbl.add_theme_color_override("font_color", Color("94a3b8"))
	info_box.add_child(det_lbl)

	var btn_renego = Button.new()
	btn_renego.text = "Renégocier"
	btn_renego.custom_minimum_size = Vector2(85, 32)
	btn_renego.add_theme_font_size_override("font_size", 11)
	btn_renego.pressed.connect(func(): _show_renegotiate_dialog(category_id, type_name))
	hbox.add_child(btn_renego)

func _show_renegotiate_dialog(category_id: String, type_name: String) -> void:
	var fin = club.get_finances()
	var proposals = fin.generate_sponsor_proposals(category_id, club.division)

	# Boîte modale simple au sein du conteneur
	for c in main_container.get_children():
		c.queue_free()

	var p_modal = PanelContainer.new()
	var sb_m = StyleBoxFlat.new()
	sb_m.bg_color = Color(0.05, 0.08, 0.14, 0.98)
	sb_m.border_color = Color("facc15")
	sb_m.set_border_width_all(2)
	sb_m.set_corner_radius_all(10)
	sb_m.content_margin_left = 12
	sb_m.content_margin_right = 12
	sb_m.content_margin_top = 12
	sb_m.content_margin_bottom = 12
	p_modal.add_theme_stylebox_override("panel", sb_m)
	main_container.add_child(p_modal)

	var m_vbox = VBoxContainer.new()
	m_vbox.add_theme_constant_override("separation", 10)
	p_modal.add_child(m_vbox)

	var lbl_m_t = Label.new()
	lbl_m_t.text = "✍️ NÉGOCIATION SPONSOR (%s)" % type_name.to_upper()
	lbl_m_t.add_theme_font_size_override("font_size", 13)
	lbl_m_t.add_theme_color_override("font_color", Color("facc15"))
	m_vbox.add_child(lbl_m_t)

	for prop in proposals:
		var p_card = PanelContainer.new()
		var sb_c = StyleBoxFlat.new()
		sb_c.bg_color = Color(0.09, 0.13, 0.22, 0.9)
		sb_c.border_color = Color(0.25, 0.35, 0.50, 0.7)
		sb_c.set_border_width_all(1)
		sb_c.set_corner_radius_all(8)
		sb_c.content_margin_left = 10
		sb_c.content_margin_right = 10
		sb_c.content_margin_top = 8
		sb_c.content_margin_bottom = 8
		p_card.add_theme_stylebox_override("panel", sb_c)
		m_vbox.add_child(p_card)

		var c_vbox = VBoxContainer.new()
		c_vbox.add_theme_constant_override("separation", 4)
		p_card.add_child(c_vbox)

		var lbl_bname = Label.new()
		lbl_bname.text = "%s (%s)" % [prop.get("brand_name", ""), prop.get("description", "")]
		lbl_bname.add_theme_font_size_override("font_size", 12)
		lbl_bname.add_theme_color_override("font_color", Color("38bdf8"))
		c_vbox.add_child(lbl_bname)

		var lbl_payout = Label.new()
		lbl_payout.text = "+%s / sem. • Prime signature: %s • Durée: %d sem." % [
			FormatUtils.format_money(prop.get("weekly_payout", 0)),
			FormatUtils.format_money(prop.get("signing_bonus", 0)),
			prop.get("duration_weeks", 14)
		]
		lbl_payout.add_theme_font_size_override("font_size", 11)
		c_vbox.add_child(lbl_payout)

		var btn_sign = Button.new()
		btn_sign.text = "Signer avec ce partenaire"
		btn_sign.custom_minimum_size.y = 36.0
		btn_sign.pressed.connect(func():
			fin.apply_negotiated_sponsor(category_id, prop)
			club.budget += prop.get("signing_bonus", 0)
			refresh_view()
			data_changed.emit()
		)
		c_vbox.add_child(btn_sign)

	var btn_cancel = Button.new()
	btn_cancel.text = "Annuler"
	btn_cancel.custom_minimum_size.y = 36.0
	btn_cancel.pressed.connect(refresh_view)
	m_vbox.add_child(btn_cancel)
