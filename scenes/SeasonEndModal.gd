class_name SeasonEndModal
extends Control

signal new_season_started

const SeasonManager = preload("res://scripts/SeasonManager.gd")
const ClubBadge = preload("res://scripts/ClubBadge.gd")

var panel_bg: PanelContainer
var content_box: VBoxContainer
var lbl_title: Label
var lbl_subtitle: Label
var user_status_box: PanelContainer
var lbl_user_status: Label
var scroll_container: ScrollContainer
var dynamic_content: VBoxContainer
var btn_start_new_season: Button

var current_report: SeasonManager.SeasonTransitionReport = null

func _init() -> void:
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 50

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	# Dark backdrop
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.1, 0.94)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel_bg = PanelContainer.new()
	panel_bg.custom_minimum_size = Vector2(920, 580)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.11, 0.18, 0.98)
	style.set_corner_radius_all(14)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.2, 0.3, 0.45, 0.8)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel_bg.add_theme_stylebox_override("panel", style)
	center.add_child(panel_bg)

	content_box = VBoxContainer.new()
	content_box.add_theme_constant_override("separation", 14)
	panel_bg.add_child(content_box)

	# Header
	var header_box = VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 2)
	content_box.add_child(header_box)

	lbl_title = Label.new()
	lbl_title.text = "🏁 BILAN DE FIN DE SAISON"
	lbl_title.add_theme_font_size_override("font_size", 22)
	lbl_title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.3))
	header_box.add_child(lbl_title)

	lbl_subtitle = Label.new()
	lbl_subtitle.text = "Palmarès, montées & descentes, départs à la retraite et budget de la saison suivante."
	lbl_subtitle.add_theme_font_size_override("font_size", 13)
	lbl_subtitle.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85))
	header_box.add_child(lbl_subtitle)

	# User status box
	user_status_box = PanelContainer.new()
	var u_style = StyleBoxFlat.new()
	u_style.bg_color = Color(0.12, 0.18, 0.28, 0.9)
	u_style.set_corner_radius_all(8)
	u_style.content_margin_left = 16
	u_style.content_margin_right = 16
	u_style.content_margin_top = 10
	u_style.content_margin_bottom = 10
	user_status_box.add_theme_stylebox_override("panel", u_style)
	content_box.add_child(user_status_box)

	lbl_user_status = Label.new()
	lbl_user_status.text = "Statut du Club..."
	lbl_user_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_user_status.add_theme_font_size_override("font_size", 14)
	user_status_box.add_child(lbl_user_status)

	# Scrollable content for the details
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.custom_minimum_size = Vector2(870, 320)
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_box.add_child(scroll_container)

	dynamic_content = VBoxContainer.new()
	dynamic_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dynamic_content.add_theme_constant_override("separation", 16)
	scroll_container.add_child(dynamic_content)

	# Bottom bar with button
	var bottom_bar = HBoxContainer.new()
	bottom_bar.alignment = BoxContainer.ALIGNMENT_END
	content_box.add_child(bottom_bar)

	btn_start_new_season = Button.new()
	btn_start_new_season.text = "🚀 Démarrer la Nouvelle Saison >"
	btn_start_new_season.custom_minimum_size = Vector2(280, 42)
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.1, 0.55, 0.35)
	btn_style.set_corner_radius_all(8)
	btn_start_new_season.add_theme_stylebox_override("normal", btn_style)
	var btn_hover = btn_style.duplicate()
	btn_hover.bg_color = Color(0.12, 0.68, 0.42)
	btn_start_new_season.add_theme_stylebox_override("hover", btn_hover)
	btn_start_new_season.add_theme_font_size_override("font_size", 15)
	btn_start_new_season.pressed.connect(_on_btn_start_new_season_pressed)
	bottom_bar.add_child(btn_start_new_season)

func setup(report: SeasonManager.SeasonTransitionReport, player_club: Club) -> void:
	current_report = report
	visible = true

	lbl_title.text = "🏁 BILAN DE CLÔTURE • SAISON %d" % report.season_ended
	btn_start_new_season.text = "🚀 Démarrer la Saison %d >" % report.next_season

	# User Status Styling
	var u_style = StyleBoxFlat.new()
	u_style.set_corner_radius_all(8)
	u_style.content_margin_left = 16
	u_style.content_margin_right = 16
	u_style.content_margin_top = 10
	u_style.content_margin_bottom = 10

	var status_text = ""
	if report.user_status == "PROMOTED":
		u_style.bg_color = Color(0.06, 0.32, 0.18, 0.95)
		u_style.border_color = Color(0.2, 0.8, 0.4)
		u_style.border_width_left = 3
		status_text = "🎉 MONSTRE PERFORMANCE ! %s EST PROMU EN DIVISION %d !\n💰 Dotation de début de saison reçue : +%s €" % [
			player_club.club_name.to_upper(), report.user_new_division, String.num_int64(report.user_budget_gain)
		]
	elif report.user_status == "RELEGATED":
		u_style.bg_color = Color(0.38, 0.1, 0.12, 0.95)
		u_style.border_color = Color(0.9, 0.25, 0.3)
		u_style.border_width_left = 3
		status_text = "⚠️ SAISON DIFFICILE : %s EST RELÉGUÉ EN DIVISION %d.\n💰 Dotation de réorganisation reçue : +%s €" % [
			player_club.club_name.to_upper(), report.user_new_division, String.num_int64(report.user_budget_gain)
		]
	else:
		u_style.bg_color = Color(0.1, 0.2, 0.35, 0.95)
		u_style.border_color = Color(0.3, 0.6, 0.9)
		u_style.border_width_left = 3
		status_text = "⚖️ OBJECTIF ATTEINT : %s SE MAINTIENT EN DIVISION %d !\n💰 Dotation financière de nouvelle saison reçue : +%s €" % [
			player_club.club_name.to_upper(), report.user_new_division, String.num_int64(report.user_budget_gain)
		]

	user_status_box.add_theme_stylebox_override("panel", u_style)
	lbl_user_status.text = status_text

	# Clear dynamic content
	for child in dynamic_content.get_children():
		child.queue_free()

	# 1. Section Retraites du club utilisateur (si existantes)
	if report.user_retirees.size() > 0:
		var v_ret = VBoxContainer.new()
		v_ret.add_theme_constant_override("separation", 6)
		for p in report.user_retirees:
			var l = Label.new()
			l.text = "• %s (%d ans, %s) a décidé de raccrocher les crampons. Un jeune espoir du centre de formation intègre le groupe." % [
				p.full_name, p.age - 1, ["Gardien", "Défenseur", "Milieu", "Attaquant"][p.position]
			]
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.add_theme_color_override("font_color", Color(0.95, 0.65, 0.35))
			l.add_theme_font_size_override("font_size", 13)
			v_ret.add_child(l)
		var ret_card = _create_section_card("🧓 DÉPARTS À LA RETRAITE DANS VOTRE EFFECTIF", v_ret)
		dynamic_content.add_child(ret_card)

	# 2. Section Montées et Descentes
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 6)

	# Colonne Montées
	var col_up = VBoxContainer.new()
	col_up.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var lbl_up_head = Label.new()
	lbl_up_head.text = "🟢 PROMOTIONS (Montées en division supérieure) :"
	lbl_up_head.add_theme_color_override("font_color", Color(0.3, 0.85, 0.45))
	lbl_up_head.add_theme_font_size_override("font_size", 13)
	col_up.add_child(lbl_up_head)

	if report.promotions.size() == 0:
		var none_lbl = Label.new()
		none_lbl.text = "Aucune promotion cette saison."
		none_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		col_up.add_child(none_lbl)
	else:
		for item in report.promotions:
			var l = Label.new()
			var c: Club = item["club"]
			var star = " ⭐ (Votre Club)" if c == player_club else ""
			l.text = "• %s (%s) : D%d ➔ D%d%s" % [c.club_name, item["country"], item["from_div"], item["to_div"], star]
			l.add_theme_color_override("font_color", Color(0.7, 0.95, 0.75) if c != player_club else Color(1.0, 0.9, 0.3))
			l.add_theme_font_size_override("font_size", 12)
			col_up.add_child(l)
	grid.add_child(col_up)

	# Colonne Descentes
	var col_down = VBoxContainer.new()
	col_down.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var lbl_down_head = Label.new()
	lbl_down_head.text = "🔴 RELÉGATIONS (Descentes en division inférieure) :"
	lbl_down_head.add_theme_color_override("font_color", Color(0.95, 0.4, 0.4))
	lbl_down_head.add_theme_font_size_override("font_size", 13)
	col_down.add_child(lbl_down_head)

	if report.relegations.size() == 0:
		var none_lbl = Label.new()
		none_lbl.text = "Aucune relégation cette saison."
		none_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		col_down.add_child(none_lbl)
	else:
		for item in report.relegations:
			var l = Label.new()
			var c: Club = item["club"]
			var star = " ⚠️ (Votre Club)" if c == player_club else ""
			l.text = "• %s (%s) : D%d ➔ D%d%s" % [c.club_name, item["country"], item["from_div"], item["to_div"], star]
			l.add_theme_color_override("font_color", Color(0.95, 0.7, 0.7) if c != player_club else Color(1.0, 0.3, 0.3))
			l.add_theme_font_size_override("font_size", 12)
			col_down.add_child(l)
	grid.add_child(col_down)

	var promo_card = _create_section_card("⬆️ MONTÉES & ⬇️ DESCENTES OFFICIELLES", grid)
	dynamic_content.add_child(promo_card)

	# 3. Section Marché & Nouveaux Joueurs
	var m_lbl = Label.new()
	m_lbl.text = "• Le marché des transferts est désormais réactualisé pour la nouvelle saison !\n• %d nouveaux agents libres et jeunes pépites ont été ajoutés sur le marché.\n• L'ensemble des joueurs ont vieilli d'un an et leurs valeurs marchandes ont été actualisées en fonction de leurs performances." % [
		report.new_free_agents_count
	]
	m_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	m_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	m_lbl.add_theme_font_size_override("font_size", 12)
	var mercato_card = _create_section_card("💼 RENOUVELLEMENT DU MERCATO", m_lbl)
	dynamic_content.add_child(mercato_card)

	# 4. Section Contrôle du Fair-Play Financier (DNCG)
	var ffp_vbox = VBoxContainer.new()
	ffp_vbox.add_theme_constant_override("separation", 6)
	var ffp_status_lbl = Label.new()
	ffp_status_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ffp_status_lbl.add_theme_font_size_override("font_size", 12)

	if report.ffp_transfer_sanction:
		ffp_status_lbl.text = "❌ SANCTION PRONONCÉE : Résultat fixe hebdomadaire déficitaire (%s € / sem).\n• Le gendarme financier vous interdit tout recrutement de joueurs pour la Saison %d !\n• Vous ne pouvez ni acheter de joueurs ni signer d'agents libres. Vous devez vous appuyer sur vos jeunes du centre de formation et assainir votre masse salariale." % [
			String.num_int64(report.ffp_fixed_net), report.next_season
		]
		ffp_status_lbl.add_theme_color_override("font_color", Color("f87171"))
	else:
		ffp_status_lbl.text = "✅ BILAN VALIDÉ : Votre résultat fixe hebdomadaire est sain (%s%s € / sem).\n• La commission de contrôle valide vos comptes.\n• Autorisation totale accordée pour négocier et recruter sur le marché des transferts." % [
			"+" if report.ffp_fixed_net >= 0 else "", String.num_int64(report.ffp_fixed_net)
		]
		ffp_status_lbl.add_theme_color_override("font_color", Color("34d399"))

	ffp_vbox.add_child(ffp_status_lbl)
	var ffp_card = _create_section_card("⚖️ CONTRÔLE DE GESTION & FAIR-PLAY FINANCIER", ffp_vbox)
	dynamic_content.add_child(ffp_card)

func _create_section_card(title_text: String, content_node: Control = null) -> PanelContainer:
	var p = PanelContainer.new()
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.06, 0.09, 0.14, 0.8)
	s.set_corner_radius_all(6)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	p.add_theme_stylebox_override("panel", s)

	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)

	var t = Label.new()
	t.text = title_text
	t.add_theme_font_size_override("font_size", 13)
	t.add_theme_color_override("font_color", Color(0.95, 0.85, 0.35))
	v.add_child(t)

	if content_node != null:
		v.add_child(content_node)

	return p

func _on_btn_start_new_season_pressed() -> void:
	visible = false
	new_season_started.emit()
