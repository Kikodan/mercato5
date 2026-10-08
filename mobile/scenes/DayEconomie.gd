class_name DayEconomie
extends VBoxContainer

## Dimanche : Bilan Économique, Billetterie, DNCG & Sponsors
## Design tactile épuré avec onglets rétractables (accordéons).

const Club = preload("res://scripts/Club.gd")
const ClubFinances = preload("res://scripts/ClubFinances.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")
const MobileCollapsibleSection = preload("res://scenes/widgets/MobileCollapsibleSection.gd")

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

	# 1. Section Rétractable : Bilan Financier Hebdomadaire
	var sec_bilan = MobileCollapsibleSection.new("📊 BILAN FINANCIER DE LA SEMAINE", true)
	sec_bilan.set_badge(FormatUtils.format_money(club.budget), Color("38bdf8"))
	main_container.add_child(sec_bilan)

	var p_sum = PanelContainer.new()
	var sb_s = StyleBoxFlat.new()
	sb_s.bg_color = Color(0.06, 0.10, 0.18, 0.95)
	sb_s.border_color = Color("facc15")
	sb_s.set_border_width_all(1)
	sb_s.set_corner_radius_all(10)
	sb_s.content_margin_left = 14
	sb_s.content_margin_right = 14
	sb_s.content_margin_top = 10
	sb_s.content_margin_bottom = 10
	p_sum.add_theme_stylebox_override("panel", sb_s)
	sec_bilan.add_content(p_sum)

	var sum_vbox = VBoxContainer.new()
	sum_vbox.add_theme_constant_override("separation", 8)
	p_sum.add_child(sum_vbox)

	var hbox_t = HBoxContainer.new()
	sum_vbox.add_child(hbox_t)

	var lbl_t_title = Label.new()
	lbl_t_title.text = "Trésorerie disponible :"
	lbl_t_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_t_title.add_theme_font_size_override("font_size", 13)
	lbl_t_title.add_theme_color_override("font_color", Color("94a3b8"))
	hbox_t.add_child(lbl_t_title)

	lbl_treasury = Label.new()
	lbl_treasury.text = FormatUtils.format_money(club.budget)
	lbl_treasury.add_theme_font_size_override("font_size", 16)
	lbl_treasury.add_theme_color_override("font_color", Color("38bdf8"))
	hbox_t.add_child(lbl_treasury)

	sum_vbox.add_child(HSeparator.new())

	# Lignes Recettes & Dépenses
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 4)
	sum_vbox.add_child(grid)

	_add_grid_row(grid, "• Recettes Sponsors fixes :", "+" + FormatUtils.format_money(sponsor_tot), Color("34d399"))
	_add_grid_row(grid, "• Droits Télévision Ligue :", "+" + FormatUtils.format_money(tv_rights), Color("34d399"))
	if fin.recent_match_revenue > 0:
		_add_grid_row(grid, "• Recette Match (billetterie) :", "+" + FormatUtils.format_money(fin.recent_match_revenue), Color("34d399"))
	_add_grid_row(grid, "• Masse salariale joueurs :", "-" + FormatUtils.format_money(wage_bill), Color("f87171"))
	_add_grid_row(grid, "• Entretien salle & installations :", "-" + FormatUtils.format_money(maintenance), Color("f87171"))

	sum_vbox.add_child(HSeparator.new())

	var row_net = HBoxContainer.new()
	sum_vbox.add_child(row_net)

	var lbl_n_title = Label.new()
	lbl_n_title.text = "Résultat Net Fixe / semaine :"
	lbl_n_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_n_title.add_theme_font_size_override("font_size", 13)
	row_net.add_child(lbl_n_title)

	lbl_net = Label.new()
	lbl_net.text = ("+" if fixed_net >= 0 else "") + FormatUtils.format_money(fixed_net)
	lbl_net.add_theme_font_size_override("font_size", 15)
	lbl_net.add_theme_color_override("font_color", Color("34d399") if fixed_net >= 0 else Color("f87171"))
	row_net.add_child(lbl_net)

	# 2. Section Rétractable : Billetterie & Salle
	var sec_arena = MobileCollapsibleSection.new("🏟️ SALLE & BILLETTERIE TACTILE", true)
	var att_pct = int(fin.estimate_attendance_percentage(fin.ticket_price, club.division) * 100.0)
	sec_arena.set_badge("%d € • ~%d%%" % [fin.ticket_price, att_pct], Color("38bdf8"))
	main_container.add_child(sec_arena)

	var p_arena = PanelContainer.new()
	var sb_ar = StyleBoxFlat.new()
	sb_ar.bg_color = Color(0.08, 0.12, 0.20, 0.90)
	sb_ar.border_color = Color(0.20, 0.28, 0.42, 0.6)
	sb_ar.set_border_width_all(1)
	sb_ar.set_corner_radius_all(8)
	sb_ar.content_margin_left = 12
	sb_ar.content_margin_right = 12
	sb_ar.content_margin_top = 10
	sb_ar.content_margin_bottom = 10
	p_arena.add_theme_stylebox_override("panel", sb_ar)
	sec_arena.add_content(p_arena)

	var ar_vbox = VBoxContainer.new()
	ar_vbox.add_theme_constant_override("separation", 8)
	p_arena.add_child(ar_vbox)

	var lbl_ar_title = Label.new()
	lbl_ar_title.text = "Palais : %s (%d places)" % [fin.arena_name, fin.arena_capacity]
	lbl_ar_title.add_theme_font_size_override("font_size", 12)
	lbl_ar_title.add_theme_color_override("font_color", Color("38bdf8"))
	ar_vbox.add_child(lbl_ar_title)

	var price_row = HBoxContainer.new()
	price_row.alignment = BoxContainer.ALIGNMENT_CENTER
	price_row.add_theme_constant_override("separation", 12)
	ar_vbox.add_child(price_row)

	var btn_minus = Button.new()
	btn_minus.text = "➖ -2 €"
	btn_minus.custom_minimum_size = Vector2(80, 44)
	btn_minus.add_theme_font_size_override("font_size", 13)
	btn_minus.focus_mode = Control.FOCUS_NONE
	btn_minus.pressed.connect(func():
		fin.ticket_price = maxi(5, fin.ticket_price - 2)
		refresh_view()
		data_changed.emit()
	)
	price_row.add_child(btn_minus)

	lbl_ticket_price = Label.new()
	lbl_ticket_price.text = "Prix : %d €\n(Remplissage ~%d%%)" % [fin.ticket_price, att_pct]
	lbl_ticket_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_ticket_price.add_theme_font_size_override("font_size", 13)
	lbl_ticket_price.add_theme_color_override("font_color", Color("facc15"))
	price_row.add_child(lbl_ticket_price)

	var btn_plus = Button.new()
	btn_plus.text = "➕ +2 €"
	btn_plus.custom_minimum_size = Vector2(80, 44)
	btn_plus.add_theme_font_size_override("font_size", 13)
	btn_plus.focus_mode = Control.FOCUS_NONE
	btn_plus.pressed.connect(func():
		fin.ticket_price = mini(50, fin.ticket_price + 2)
		refresh_view()
		data_changed.emit()
	)
	price_row.add_child(btn_plus)

	# 3. Section Rétractable : Contrôle Financier & DNCG
	var sec_dncg = MobileCollapsibleSection.new("⚖️ CONTRÔLE DNCG & FAIR-PLAY", false)
	sec_dncg.set_badge("CONFORME" if fixed_net >= 0 else "DÉFICITAIRE", Color("34d399") if fixed_net >= 0 else Color("f87171"))
	main_container.add_child(sec_dncg)

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
	sec_dncg.add_content(p_dncg)

	var dncg_vbox = VBoxContainer.new()
	dncg_vbox.add_theme_constant_override("separation", 6)
	p_dncg.add_child(dncg_vbox)

	lbl_dncg_status = Label.new()
	if fixed_net >= 0:
		lbl_dncg_status.text = "✅ Votre modèle économique est rentable. Recrutement autorisé sans restriction par la DNCG."
		lbl_dncg_status.add_theme_color_override("font_color", Color("34d399"))
	else:
		lbl_dncg_status.text = "⚠️ Vos dépenses fixes dépassent vos recettes fixes. Réduisez votre masse salariale ou augmentez vos recettes billetterie."
		lbl_dncg_status.add_theme_color_override("font_color", Color("f87171"))
	lbl_dncg_status.add_theme_font_size_override("font_size", 11)
	lbl_dncg_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dncg_vbox.add_child(lbl_dncg_status)

	# 4. Section Rétractable : Sponsors
	var sec_sp = MobileCollapsibleSection.new("🤝 CONTRATS SPONSORS ACTIFS", false)
	sec_sp.set_badge("4 contrats", Color("94a3b8"))
	main_container.add_child(sec_sp)

	var p_sp = PanelContainer.new()
	var sb_sp = StyleBoxFlat.new()
	sb_sp.bg_color = Color(0.08, 0.12, 0.20, 0.90)
	sb_sp.set_corner_radius_all(8)
	sb_sp.content_margin_left = 12
	sb_sp.content_margin_right = 12
	sb_sp.content_margin_top = 8
	sb_sp.content_margin_bottom = 8
	p_sp.add_theme_stylebox_override("panel", sb_sp)
	sec_sp.add_content(p_sp)

	var sp_vbox = VBoxContainer.new()
	sp_vbox.add_theme_constant_override("separation", 6)
	p_sp.add_child(sp_vbox)

	_add_sponsor_row(sp_vbox, "👕 Maillot", fin.primary_sponsor_name, fin.primary_sponsor_weekly, fin.primary_sponsor_weeks_left)
	_add_sponsor_row(sp_vbox, "🏟️ Naming", fin.arena_sponsor_name, fin.arena_sponsor_weekly, fin.arena_sponsor_weeks_left)
	_add_sponsor_row(sp_vbox, "👟 Équipementier", fin.kit_sponsor_name, fin.kit_sponsor_weekly, fin.kit_sponsor_weeks_left)
	_add_sponsor_row(sp_vbox, "🪧 LED Bord terrain", fin.board_ads_name, fin.board_ads_weekly, fin.board_ads_weeks_left)

func _add_grid_row(grid: GridContainer, label_text: String, val_text: String, val_col: Color) -> void:
	var l = Label.new()
	l.text = label_text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color("94a3b8"))
	grid.add_child(l)

	var v = Label.new()
	v.text = val_text
	v.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_theme_font_size_override("font_size", 12)
	v.add_theme_color_override("font_color", val_col)
	grid.add_child(v)

func _add_sponsor_row(vbox: VBoxContainer, type_str: String, sp_name: String, payout: int, weeks_left: int) -> void:
	var row = HBoxContainer.new()
	var l = Label.new()
	l.text = "%s : %s" % [type_str, sp_name]
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", Color("f1f5f9"))
	row.add_child(l)

	var r = Label.new()
	r.text = "+%s €/sem (%d sem)" % [FormatUtils.format_number(payout), weeks_left]
	r.add_theme_font_size_override("font_size", 11)
	r.add_theme_color_override("font_color", Color("34d399"))
	row.add_child(r)
	vbox.add_child(row)
