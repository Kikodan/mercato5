class_name DayEffectif
extends VBoxContainer

## Lundi : Gestion de l'Effectif & Consultation du Classement officiel de la Ligue
## Design épuré tactile avec onglets rétractables (accordéons).

const Club = preload("res://scripts/Club.gd")
const Player = preload("res://scripts/Player.gd")
const League = preload("res://scripts/League.gd")
const ClubBadge = preload("res://scripts/ClubBadge.gd")
const MobilePlayerCard = preload("res://scenes/widgets/MobilePlayerCard.gd")
const MobileCollapsibleSection = preload("res://scenes/widgets/MobileCollapsibleSection.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")

var club: Club = null
var league: League = null

var btn_tab_effectif: Button
var btn_tab_classement: Button
var is_classement_mode: bool = false

var effectif_container: VBoxContainer
var classement_container: VBoxContainer

var section_starters: MobileCollapsibleSection
var section_bench: MobileCollapsibleSection
var section_inspected_club: MobileCollapsibleSection

var inspected_club: Club = null

signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 10)

	# 1. Barre de bascule tactile Effectif / Classement
	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.add_theme_constant_override("separation", 8)
	add_child(tabs_hbox)

	btn_tab_effectif = Button.new()
	btn_tab_effectif.text = "📋 Mon Effectif"
	btn_tab_effectif.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_effectif.custom_minimum_size.y = 44.0
	btn_tab_effectif.focus_mode = Control.FOCUS_NONE
	btn_tab_effectif.pressed.connect(func():
		is_classement_mode = false
		_update_tab_buttons()
		_render_active_view()
	)
	tabs_hbox.add_child(btn_tab_effectif)

	btn_tab_classement = Button.new()
	btn_tab_classement.text = "🏆 Classement Ligue"
	btn_tab_classement.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_classement.custom_minimum_size.y = 44.0
	btn_tab_classement.focus_mode = Control.FOCUS_NONE
	btn_tab_classement.pressed.connect(func():
		is_classement_mode = true
		_update_tab_buttons()
		_render_active_view()
	)
	tabs_hbox.add_child(btn_tab_classement)

	# 2. Conteneurs scrollables
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	var wrapper = VBoxContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.add_theme_constant_override("separation", 10)
	scroll.add_child(wrapper)

	effectif_container = VBoxContainer.new()
	effectif_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	effectif_container.add_theme_constant_override("separation", 10)
	wrapper.add_child(effectif_container)

	classement_container = VBoxContainer.new()
	classement_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	classement_container.add_theme_constant_override("separation", 10)
	wrapper.add_child(classement_container)

	_update_tab_buttons()

func setup(p_club: Club, p_league: League = null) -> void:
	club = p_club
	league = p_league
	if inspected_club == null:
		inspected_club = club
	_render_active_view()

func _update_tab_buttons() -> void:
	var sb_act = StyleBoxFlat.new()
	sb_act.bg_color = Color(0.12, 0.22, 0.38, 0.95)
	sb_act.border_color = Color("38bdf8")
	sb_act.set_border_width_all(2)
	sb_act.set_corner_radius_all(8)

	var sb_inact = StyleBoxFlat.new()
	sb_inact.bg_color = Color(0.06, 0.09, 0.16, 0.85)
	sb_inact.border_color = Color(0.18, 0.25, 0.38, 0.5)
	sb_inact.set_border_width_all(1)
	sb_inact.set_corner_radius_all(8)

	btn_tab_effectif.add_theme_stylebox_override("normal", sb_inact if is_classement_mode else sb_act)
	btn_tab_classement.add_theme_stylebox_override("normal", sb_act if is_classement_mode else sb_inact)

func _render_active_view() -> void:
	if is_classement_mode:
		effectif_container.visible = false
		classement_container.visible = true
		_render_classement()
	else:
		effectif_container.visible = true
		classement_container.visible = false
		_render_effectif()

# =========================================================================
# VUE 1 : MON EFFECTIF (AVEC ONGLETS RÉTRACTABLES)
# =========================================================================
func _render_effectif() -> void:
	for c in effectif_container.get_children():
		c.queue_free()

	if club == null:
		return

	# Header résumé
	var sum_panel = PanelContainer.new()
	var sb_s = StyleBoxFlat.new()
	sb_s.bg_color = Color(0.06, 0.10, 0.18, 0.90)
	sb_s.border_color = Color(0.20, 0.30, 0.45, 0.6)
	sb_s.set_border_width_all(1)
	sb_s.set_corner_radius_all(8)
	sb_s.content_margin_left = 12
	sb_s.content_margin_right = 12
	sb_s.content_margin_top = 8
	sb_s.content_margin_bottom = 8
	sum_panel.add_theme_stylebox_override("panel", sb_s)
	effectif_container.add_child(sum_panel)

	var hbox_s = HBoxContainer.new()
	sum_panel.add_child(hbox_s)

	var l_t = Label.new()
	l_t.text = "📋 EFFECTIF GLOBAL (%d/32)" % club.squad.size()
	l_t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l_t.add_theme_font_size_override("font_size", 13)
	l_t.add_theme_color_override("font_color", Color("facc15"))
	hbox_s.add_child(l_t)

	var l_sal = Label.new()
	l_sal.text = "Masse salariale : %s €/sem" % FormatUtils.format_number(club.get_total_wage())
	l_sal.add_theme_font_size_override("font_size", 11)
	l_sal.add_theme_color_override("font_color", Color("94a3b8"))
	hbox_s.add_child(l_sal)

	# 1. Section Rétractable : 5 de départ
	section_starters = MobileCollapsibleSection.new("🟢 5 DE DÉPART ALIGNÉ", true)
	section_starters.set_badge("%d joueurs" % club.starting_five.size(), Color("34d399"))
	effectif_container.add_child(section_starters)

	for p in club.starting_five:
		var card = MobilePlayerCard.new()
		card.setup(p, true, true, true)
		card.transfer_list_toggled.connect(_on_transfer_list_toggled)
		card.renew_requested.connect(_on_renew_requested)
		card.detail_requested.connect(_on_detail_requested)
		section_starters.add_content(card)

	# 2. Section Rétractable : Remplaçants & Réserve
	var bench_count = club.squad.size() - club.starting_five.size()
	section_bench = MobileCollapsibleSection.new("🪑 REMPLAÇANTS & RÉSERVE", true)
	section_bench.set_badge("%d joueurs" % bench_count, Color("94a3b8"))
	effectif_container.add_child(section_bench)

	for p in club.squad:
		if not club.starting_five.has(p):
			var card = MobilePlayerCard.new()
			card.setup(p, false, true, true)
			card.transfer_list_toggled.connect(_on_transfer_list_toggled)
			card.renew_requested.connect(_on_renew_requested)
			card.detail_requested.connect(_on_detail_requested)
			section_bench.add_content(card)

# =========================================================================
# VUE 2 : CLASSEMENT DU LUNDI (AVEC INSPECTION RÉTRACTABLE DU CLUB)
# =========================================================================
func _render_classement() -> void:
	for c in classement_container.get_children():
		c.queue_free()

	if league == null:
		var empty_lbl = Label.new()
		empty_lbl.text = "Aucune ligue active associée."
		classement_container.add_child(empty_lbl)
		return

	# Header Titre Ligue
	var league_header = PanelContainer.new()
	var sb_lh = StyleBoxFlat.new()
	sb_lh.bg_color = Color(0.08, 0.12, 0.20, 0.95)
	sb_lh.border_color = Color("38bdf8")
	sb_lh.set_border_width_all(1)
	sb_lh.set_corner_radius_all(8)
	sb_lh.content_margin_left = 12
	sb_lh.content_margin_right = 12
	sb_lh.content_margin_top = 8
	sb_lh.content_margin_bottom = 8
	league_header.add_theme_stylebox_override("panel", sb_lh)
	classement_container.add_child(league_header)

	var hbox_lh = HBoxContainer.new()
	league_header.add_child(hbox_lh)

	var lbl_lt = Label.new()
	lbl_lt.text = "🏆 %s (%s) — J%d/%d" % [
		league.league_name,
		league.country,
		league.current_matchday_index + 1,
		league.schedule.size()
	]
	lbl_lt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_lt.add_theme_font_size_override("font_size", 13)
	lbl_lt.add_theme_color_override("font_color", Color("facc15"))
	hbox_lh.add_child(lbl_lt)

	var lbl_hint = Label.new()
	lbl_hint.text = "Touchez un club pour inspecter"
	lbl_hint.add_theme_font_size_override("font_size", 10)
	lbl_hint.add_theme_color_override("font_color", Color("94a3b8"))
	hbox_lh.add_child(lbl_hint)

	# Fiche rétractable du club inspecté
	if inspected_club != null:
		_render_inspected_club_card()

	# Tableau du classement (Ligne d'en-tête)
	var table_header = PanelContainer.new()
	var sb_th = StyleBoxFlat.new()
	sb_th.bg_color = Color(0.04, 0.07, 0.12, 0.90)
	sb_th.content_margin_left = 8
	sb_th.content_margin_right = 8
	sb_th.content_margin_top = 6
	sb_th.content_margin_bottom = 6
	table_header.add_theme_stylebox_override("panel", sb_th)
	classement_container.add_child(table_header)

	var h_row = HBoxContainer.new()
	h_row.add_theme_constant_override("separation", 6)
	table_header.add_child(h_row)

	_add_header_col(h_row, "#", 28, HORIZONTAL_ALIGNMENT_CENTER)
	_add_header_col(h_row, "CLUB", 0, HORIZONTAL_ALIGNMENT_LEFT, true)
	_add_header_col(h_row, "PTS", 38, HORIZONTAL_ALIGNMENT_CENTER)
	_add_header_col(h_row, "J", 26, HORIZONTAL_ALIGNMENT_CENTER)
	_add_header_col(h_row, "V", 26, HORIZONTAL_ALIGNMENT_CENTER)
	_add_header_col(h_row, "D", 26, HORIZONTAL_ALIGNMENT_CENTER)
	_add_header_col(h_row, "DIFF", 36, HORIZONTAL_ALIGNMENT_CENTER)

	# Lignes des clubs du classement
	var sorted = league.get_sorted_standings()
	for i in sorted.size():
		var cl = sorted[i]
		var data = league.standings.get(cl, {"pts": 0, "p": 0, "w": 0, "l": 0, "gd": 0})
		var is_user = (cl == club)
		var is_inspected = (cl == inspected_club)

		var row_btn = Button.new()
		row_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_btn.custom_minimum_size.y = 44.0
		row_btn.focus_mode = Control.FOCUS_NONE

		var sb_r = StyleBoxFlat.new()
		sb_r.set_corner_radius_all(6)
		sb_r.content_margin_left = 8
		sb_r.content_margin_right = 8

		if is_user:
			sb_r.bg_color = Color(0.98, 0.80, 0.08, 0.15)
			sb_r.border_color = Color("facc15")
			sb_r.set_border_width_all(1)
		elif is_inspected:
			sb_r.bg_color = Color(0.12, 0.24, 0.40, 0.90)
			sb_r.border_color = Color("38bdf8")
			sb_r.set_border_width_all(1)
		else:
			sb_r.bg_color = Color(0.06, 0.09, 0.16, 0.85) if i % 2 == 0 else Color(0.08, 0.12, 0.20, 0.85)
			sb_r.border_color = Color(0.18, 0.24, 0.35, 0.40)
			sb_r.set_border_width_all(1)

		row_btn.add_theme_stylebox_override("normal", sb_r)

		var r_hbox = HBoxContainer.new()
		r_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		r_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r_hbox.add_theme_constant_override("separation", 6)
		row_btn.add_child(r_hbox)

		# 1. Rang
		var rank_lbl = Label.new()
		rank_lbl.text = str(i + 1)
		rank_lbl.custom_minimum_size.x = 28
		rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rank_lbl.add_theme_font_size_override("font_size", 12)
		rank_lbl.add_theme_color_override("font_color", Color("facc15") if is_user else Color("94a3b8"))
		r_hbox.add_child(rank_lbl)

		# 2. Club Nom + Blason
		var c_name_box = HBoxContainer.new()
		c_name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c_name_box.add_theme_constant_override("separation", 6)
		r_hbox.add_child(c_name_box)

		var c_badge = ClubBadge.new()
		c_badge.custom_minimum_size = Vector2(22, 22)
		c_badge.shape = cl.badge_shape
		c_badge.symbol = cl.badge_symbol
		c_badge.primary_color = cl.primary_color
		c_badge.secondary_color = cl.secondary_color
		c_name_box.add_child(c_badge)

		var c_name_lbl = Label.new()
		var po_tag = ""
		if i == 0: po_tag = " ⭐"
		elif i == 1 or i == 2: po_tag = " ⚔️"
		c_name_lbl.text = "%s%s" % [cl.club_name, po_tag]
		c_name_lbl.add_theme_font_size_override("font_size", 12)
		c_name_lbl.add_theme_color_override("font_color", Color("facc15") if is_user else Color("f8fafc"))
		c_name_box.add_child(c_name_lbl)

		# 3. Pts
		_add_cell_col(r_hbox, str(data["pts"]), 38, Color("facc15") if is_user else Color("38bdf8"), true)
		# 4. J
		_add_cell_col(r_hbox, str(data["p"]), 26, Color("94a3b8"))
		# 5. V
		_add_cell_col(r_hbox, str(data["w"]), 26, Color("34d399"))
		# 6. D
		_add_cell_col(r_hbox, str(data["l"]), 26, Color("f87171"))
		# 7. Diff
		var gd_str = ("%+d" % data["gd"]) if data["gd"] != 0 else "0"
		_add_cell_col(r_hbox, gd_str, 36, Color("cbd5e1"))

		var target_c = cl
		row_btn.pressed.connect(func():
			inspected_club = target_c
			_render_classement()
		)
		classement_container.add_child(row_btn)

func _render_inspected_club_card() -> void:
	if inspected_club == null:
		return

	section_inspected_club = MobileCollapsibleSection.new("🔍 DÉTAILS DU CLUB : %s" % inspected_club.club_name.to_upper(), true)
	section_inspected_club.set_badge("Div %d • %s" % [inspected_club.division, inspected_club.country], Color("38bdf8"))
	classement_container.add_child(section_inspected_club)

	var p_panel = PanelContainer.new()
	var sb_p = StyleBoxFlat.new()
	sb_p.bg_color = Color(0.06, 0.10, 0.18, 0.95)
	sb_p.set_corner_radius_all(8)
	sb_p.content_margin_left = 12
	sb_p.content_margin_right = 12
	sb_p.content_margin_top = 8
	sb_p.content_margin_bottom = 8
	p_panel.add_theme_stylebox_override("panel", sb_p)
	section_inspected_club.add_content(p_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	p_panel.add_child(vbox)

	# Stats rapides
	var row1 = HBoxContainer.new()
	vbox.add_child(row1)

	var lbl_b = Label.new()
	lbl_b.text = "Budget : %s €" % FormatUtils.format_number(inspected_club.budget)
	lbl_b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_b.add_theme_font_size_override("font_size", 12)
	lbl_b.add_theme_color_override("font_color", Color("34d399"))
	row1.add_child(lbl_b)

	var lbl_sq = Label.new()
	lbl_sq.text = "Effectif : %d joueurs" % inspected_club.squad.size()
	lbl_sq.add_theme_font_size_override("font_size", 12)
	lbl_sq.add_theme_color_override("font_color", Color("94a3b8"))
	row1.add_child(lbl_sq)

	# Forme récente (5 derniers matchs)
	var form_row = HBoxContainer.new()
	form_row.add_theme_constant_override("separation", 6)
	vbox.add_child(form_row)

	var lbl_f_title = Label.new()
	lbl_f_title.text = "Forme : "
	lbl_f_title.add_theme_font_size_override("font_size", 11)
	lbl_f_title.add_theme_color_override("font_color", Color("94a3b8"))
	form_row.add_child(lbl_f_title)

	if inspected_club.recent_form.is_empty():
		var empty_f = Label.new()
		empty_f.text = "Aucun match joué"
		empty_f.add_theme_font_size_override("font_size", 11)
		empty_f.add_theme_color_override("font_color", Color("64748b"))
		form_row.add_child(empty_f)
	else:
		var cnt = mini(inspected_club.recent_form.size(), 5)
		for j in range(cnt - 1, -1, -1):
			var m = inspected_club.recent_form[j]
			var is_v = m.get("result", "") == "V"
			var tag = Label.new()
			tag.text = "V" if is_v else "D"
			tag.custom_minimum_size = Vector2(24, 20)
			tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tag.add_theme_font_size_override("font_size", 10)
			var sb_t = StyleBoxFlat.new()
			sb_t.set_corner_radius_all(4)
			sb_t.bg_color = Color(0.06, 0.40, 0.20, 0.90) if is_v else Color(0.50, 0.10, 0.15, 0.90)
			tag.add_theme_stylebox_override("normal", sb_t)
			tag.add_theme_color_override("font_color", Color.WHITE)
			form_row.add_child(tag)

	# Aperçu des titulaires du club
	var l_starters = Label.new()
	l_starters.text = "5 Majeur Titulaire :"
	l_starters.add_theme_font_size_override("font_size", 11)
	l_starters.add_theme_color_override("font_color", Color("38bdf8"))
	vbox.add_child(l_starters)

	var starters_grid = GridContainer.new()
	starters_grid.columns = 2
	starters_grid.add_theme_constant_override("h_separation", 8)
	starters_grid.add_theme_constant_override("v_separation", 4)
	vbox.add_child(starters_grid)

	for p in inspected_club.starting_five:
		var p_lbl = Label.new()
		var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
		p_lbl.text = "[%s] %s (%d OVR)" % [pos_str, p.full_name, p.get_overall()]
		p_lbl.add_theme_font_size_override("font_size", 11)
		p_lbl.add_theme_color_override("font_color", Color("f1f5f9"))
		starters_grid.add_child(p_lbl)

func _add_header_col(row: HBoxContainer, title: String, width: int, align: HorizontalAlignment, expand: bool = false) -> void:
	var l = Label.new()
	l.text = title
	l.horizontal_alignment = align
	l.add_theme_font_size_override("font_size", 10)
	l.add_theme_color_override("font_color", Color("94a3b8"))
	if expand:
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	else:
		l.custom_minimum_size.x = width
	row.add_child(l)

func _add_cell_col(row: HBoxContainer, text: String, width: int, col: Color, is_bold: bool = false) -> void:
	var l = Label.new()
	l.text = text
	l.custom_minimum_size.x = width
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 12 if not is_bold else 13)
	l.add_theme_color_override("font_color", col)
	row.add_child(l)

# =========================================================================
# ACTIONS JOUEUR EFFECTIF
# =========================================================================
func _on_transfer_list_toggled(p: Player) -> void:
	p.is_transfer_listed = not p.is_transfer_listed
	_render_effectif()
	data_changed.emit()

func _on_renew_requested(p: Player) -> void:
	var prime = int(p.market_value * 0.10)
	if club.budget < prime:
		_show_popup("Budget insuffisant", "Il vous faut %s € de prime pour prolonger %s." % [FormatUtils.format_number(prime), p.full_name])
		return

	club.budget -= prime
	p.contract_years += 2
	p.salary = int(p.salary * 1.15)
	_show_popup("Contrat prolongé !", "Contrat de %s prolongé de 2 ans !\nNouveau salaire : %s €/sem.\nPrime versée : %s €." % [
		p.full_name, FormatUtils.format_number(p.salary), FormatUtils.format_number(prime)
	])
	_render_effectif()
	data_changed.emit()

func _on_detail_requested(p: Player) -> void:
	var msg = "Position : %s\nÂge : %da  |  Nationalité : %s\nNote : %d OVR  |  Forme : %d%%\nValeur marchande : %s €\nSalaire : %s €/semaine\nContrat restant : %d an(s)" % [
		["Gardien (GK)", "Défenseur (DEF)", "Milieu (MID)", "Attaquant (FWD)"][p.position],
		p.age, p.nationality,
		p.get_overall(), int(p.fitness * 100.0),
		FormatUtils.format_number(p.market_value),
		FormatUtils.format_number(p.salary),
		p.contract_years
	]
	_show_popup("Fiche de %s" % p.full_name, msg)

func _show_popup(title: String, body: String) -> void:
	var d = AcceptDialog.new()
	d.title = title
	d.dialog_text = body
	add_child(d)
	d.popup_centered(Vector2i(420, 220))
