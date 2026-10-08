class_name DayFormation
extends VBoxContainer

## Vendredi : Centre de Formation (Académie des Jeunes) & Surveillance (Scouting & Espionnage)
## Design tactile épuré avec onglets rétractables.

const Club = preload("res://scripts/Club.gd")
const Player = preload("res://scripts/Player.gd")
const League = preload("res://scripts/League.gd")
const Tactics = preload("res://scripts/Tactics.gd")
const ClubBadge = preload("res://scripts/ClubBadge.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")
const MobileCollapsibleSection = preload("res://scenes/widgets/MobileCollapsibleSection.gd")

var club: Club = null
var league: League = null
var opponent_club: Club = null

var btn_tab_formation: Button
var btn_tab_surveillance: Button
var is_surveillance_mode: bool = false

var content_container: VBoxContainer
var scroll: ScrollContainer

signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 10)

	# 1. Barre d'onglets du Vendredi
	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.add_theme_constant_override("separation", 8)
	add_child(tabs_hbox)

	btn_tab_formation = Button.new()
	btn_tab_formation.text = "🎓 Centre de Formation"
	btn_tab_formation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_formation.custom_minimum_size.y = 44.0
	btn_tab_formation.focus_mode = Control.FOCUS_NONE
	btn_tab_formation.pressed.connect(func():
		is_surveillance_mode = false
		_update_tab_buttons()
		refresh_view()
	)
	tabs_hbox.add_child(btn_tab_formation)

	btn_tab_surveillance = Button.new()
	btn_tab_surveillance.text = "🕵️ Surveillance & Espionnage"
	btn_tab_surveillance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_surveillance.custom_minimum_size.y = 44.0
	btn_tab_surveillance.focus_mode = Control.FOCUS_NONE
	btn_tab_surveillance.pressed.connect(func():
		is_surveillance_mode = true
		_update_tab_buttons()
		refresh_view()
	)
	tabs_hbox.add_child(btn_tab_surveillance)

	# 2. Zone scrollable
	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 10)
	scroll.add_child(content_container)

	_update_tab_buttons()

func setup(p_club: Club, p_league: League = null, p_opponent: Club = null) -> void:
	club = p_club
	league = p_league
	opponent_club = p_opponent
	if club != null:
		club.init_youth_academy_if_empty()
	refresh_view()

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

	btn_tab_formation.add_theme_stylebox_override("normal", sb_inact if is_surveillance_mode else sb_act)
	btn_tab_surveillance.add_theme_stylebox_override("normal", sb_act if is_surveillance_mode else sb_inact)

func refresh_view() -> void:
	for c in content_container.get_children():
		c.queue_free()

	if club == null:
		return

	if is_surveillance_mode:
		_render_surveillance_view()
	else:
		_render_formation_view()

# =========================================================================
# VUE 1 : CENTRE DE FORMATION & JEUNES ESPOIRS
# =========================================================================
func _render_formation_view() -> void:
	club.init_youth_academy_if_empty()

	# 1. Section Rétractable : Détection & Scouting de Talents
	var sec_scout = MobileCollapsibleSection.new("🔍 DÉTECTION DE TALENTS (ACADÉMIE)", true)
	sec_scout.set_badge("%d/8 espoirs" % club.youth_academy.size(), Color("38bdf8"))
	content_container.add_child(sec_scout)

	var scout_panel = PanelContainer.new()
	var sb_sp = StyleBoxFlat.new()
	sb_sp.bg_color = Color(0.08, 0.12, 0.20, 0.90)
	sb_sp.border_color = Color(0.20, 0.30, 0.45, 0.6)
	sb_sp.set_border_width_all(1)
	sb_sp.set_corner_radius_all(8)
	sb_sp.content_margin_left = 12
	sb_sp.content_margin_right = 12
	sb_sp.content_margin_top = 10
	sb_sp.content_margin_bottom = 10
	scout_panel.add_theme_stylebox_override("panel", sb_sp)
	sec_scout.add_content(scout_panel)

	var sc_vbox = VBoxContainer.new()
	sc_vbox.add_theme_constant_override("separation", 8)
	scout_panel.add_child(sc_vbox)

	var desc_lbl = Label.new()
	desc_lbl.text = "Envoyez votre réseau d'observateurs détecter une pépite locale. Les jeunes espoirs évoluent chaque semaine au sein de votre académie."
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color("94a3b8"))
	sc_vbox.add_child(desc_lbl)

	var btn_detect = Button.new()
	btn_detect.text = "🔍 Lancer une Détection (Coût : 15 000 €)"
	btn_detect.custom_minimum_size.y = 48.0
	btn_detect.add_theme_font_size_override("font_size", 13)
	btn_detect.focus_mode = Control.FOCUS_NONE
	var sb_d = StyleBoxFlat.new()
	sb_d.bg_color = Color(0.08, 0.50, 0.35, 0.95)
	sb_d.border_color = Color("34d399")
	sb_d.set_border_width_all(1)
	sb_d.set_corner_radius_all(8)
	btn_detect.add_theme_stylebox_override("normal", sb_d)
	btn_detect.disabled = (club.youth_academy.size() >= 8 or club.budget < 15_000)
	btn_detect.pressed.connect(_on_detect_pressed)
	sc_vbox.add_child(btn_detect)

	# 2. Section Rétractable : Liste des Jeunes Espoirs
	var sec_youth = MobileCollapsibleSection.new("⭐ JEUNES ESPOIRS DU CLUB (%d/8)" % club.youth_academy.size(), true)
	content_container.add_child(sec_youth)

	if club.youth_academy.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "Aucun jeune espoir dans le centre de formation. Utilisez le bouton ci-dessus pour lancer une détection !"
		empty_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_lbl.add_theme_font_size_override("font_size", 12)
		empty_lbl.add_theme_color_override("font_color", Color("94a3b8"))
		sec_youth.add_content(empty_lbl)
		return

	for p in club.youth_academy:
		sec_youth.add_content(_create_youth_card(p))

func _create_youth_card(p: Player) -> PanelContainer:
	var card = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.09, 0.16, 0.95)
	sb.border_color = Color(0.20, 0.30, 0.45, 0.7)
	sb.border_width_left = 3
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", sb)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	# Ligne 1 : Poste, Nom, Âge, OVR
	var top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 8)
	vbox.add_child(top_row)

	var pos_lbl = Label.new()
	var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
	pos_lbl.text = pos_str
	pos_lbl.custom_minimum_size = Vector2(34, 26)
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
	top_row.add_child(pos_lbl)

	var name_lbl = Label.new()
	name_lbl.text = "%s %s (%da)" % [p.get_flag_emoji(), p.full_name, p.age]
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", Color("f1f5f9"))
	top_row.add_child(name_lbl)

	var ovr_lbl = Label.new()
	ovr_lbl.text = "%d OVR" % p.get_overall()
	ovr_lbl.add_theme_font_size_override("font_size", 14)
	ovr_lbl.add_theme_color_override("font_color", Color("facc15"))
	top_row.add_child(ovr_lbl)

	# Ligne 2 : Potentiel théorique
	var pot_row = HBoxContainer.new()
	pot_row.add_theme_constant_override("separation", 8)
	vbox.add_child(pot_row)

	var pot_title = Label.new()
	pot_title.text = "⭐ Potentiel : %d - %d OVR" % [p.potential_min, p.potential_max]
	pot_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pot_title.add_theme_font_size_override("font_size", 11)
	pot_title.add_theme_color_override("font_color", Color("facc15"))
	pot_row.add_child(pot_title)

	# Barre visuelle de potentiel
	var pot_bar = ProgressBar.new()
	pot_bar.custom_minimum_size = Vector2(100, 8)
	pot_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pot_bar.min_value = 50.0
	pot_bar.max_value = 100.0
	pot_bar.value = float((p.potential_min + p.potential_max) / 2)
	pot_bar.show_percentage = false
	pot_row.add_child(pot_bar)

	# Ligne 3 : Stats clés
	var stats_lbl = Label.new()
	if p.position == Player.Position.GK:
		stats_lbl.text = "RÉF: %d | DEF: %d | PAS: %d | END: %d" % [p.reflexes, p.defending, p.passing, p.stamina]
	else:
		stats_lbl.text = "VIT: %d | TIR: %d | PAS: %d | DÉF: %d | DRI: %d" % [p.speed, p.shooting, p.passing, p.defending, p.dribbling]
	stats_lbl.add_theme_font_size_override("font_size", 10)
	stats_lbl.add_theme_color_override("font_color", Color("94a3b8"))
	vbox.add_child(stats_lbl)

	# Ligne 4 : Boutons tactiles (Promouvoir & Fiche)
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var btn_promote = Button.new()
	btn_promote.text = "🎓 Promouvoir Pro"
	btn_promote.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_promote.custom_minimum_size.y = 42.0
	btn_promote.add_theme_font_size_override("font_size", 12)
	btn_promote.focus_mode = Control.FOCUS_NONE
	var sb_pr = StyleBoxFlat.new()
	sb_pr.bg_color = Color(0.10, 0.52, 0.35, 0.95)
	sb_pr.border_color = Color("34d399")
	sb_pr.set_border_width_all(1)
	sb_pr.set_corner_radius_all(6)
	btn_promote.add_theme_stylebox_override("normal", sb_pr)
	var target_p = p
	btn_promote.pressed.connect(func(): _promote_player(target_p))
	btn_row.add_child(btn_promote)

	var btn_fiche = Button.new()
	btn_fiche.text = "👁️ Fiche"
	btn_fiche.custom_minimum_size = Vector2(80, 42)
	btn_fiche.add_theme_font_size_override("font_size", 12)
	btn_fiche.focus_mode = Control.FOCUS_NONE
	var sb_fi = StyleBoxFlat.new()
	sb_fi.bg_color = Color(0.14, 0.20, 0.32, 0.90)
	sb_fi.border_color = Color(0.28, 0.38, 0.55, 0.8)
	sb_fi.set_border_width_all(1)
	sb_fi.set_corner_radius_all(6)
	btn_fiche.add_theme_stylebox_override("normal", sb_fi)
	btn_fiche.pressed.connect(func(): _show_youth_details(target_p))
	btn_row.add_child(btn_fiche)

	return card

# =========================================================================
# VUE 2 : SURVEILLANCE & ESPIONNAGE DU PROCHAIN ADVERSAIRE
# =========================================================================
func _render_surveillance_view() -> void:
	# 1. Section Rétractable : Rapport d'Espionnage sur l'adversaire de Samedi
	var sec_scout_opp = MobileCollapsibleSection.new("🕵️ RAPPORT D'ESPIONNAGE — ADVERSAIRE DE SAMEDI", true)
	content_container.add_child(sec_scout_opp)

	if opponent_club == null:
		var empty_lbl = Label.new()
		empty_lbl.text = "Aucun match officiel programmé ce samedi. Vos observateurs sont en veille générale."
		empty_lbl.add_theme_font_size_override("font_size", 12)
		empty_lbl.add_theme_color_override("font_color", Color("94a3b8"))
		sec_scout_opp.add_content(empty_lbl)
	else:
		var opp_panel = PanelContainer.new()
		var sb_op = StyleBoxFlat.new()
		sb_op.bg_color = Color(0.08, 0.12, 0.20, 0.95)
		sb_op.border_color = Color("facc15")
		sb_op.set_border_width_all(1)
		sb_op.set_corner_radius_all(8)
		sb_op.content_margin_left = 12
		sb_op.content_margin_right = 12
		sb_op.content_margin_top = 10
		sb_op.content_margin_bottom = 10
		opp_panel.add_theme_stylebox_override("panel", sb_op)
		sec_scout_opp.add_content(opp_panel)

		var opp_vbox = VBoxContainer.new()
		opp_vbox.add_theme_constant_override("separation", 10)
		opp_panel.add_child(opp_vbox)

		# Header Adversaire
		var h_opp = HBoxContainer.new()
		h_opp.add_theme_constant_override("separation", 10)
		opp_vbox.add_child(h_opp)

		var b_opp = ClubBadge.new()
		b_opp.custom_minimum_size = Vector2(36, 36)
		b_opp.shape = opponent_club.badge_shape
		b_opp.symbol = opponent_club.badge_symbol
		b_opp.primary_color = opponent_club.primary_color
		b_opp.secondary_color = opponent_club.secondary_color
		h_opp.add_child(b_opp)

		var info_opp = VBoxContainer.new()
		info_opp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h_opp.add_child(info_opp)

		var lbl_oname = Label.new()
		lbl_oname.text = "CIBLE : %s" % opponent_club.club_name.to_upper()
		lbl_oname.add_theme_font_size_override("font_size", 14)
		lbl_oname.add_theme_color_override("font_color", Color("facc15"))
		info_opp.add_child(lbl_oname)

		var lbl_osub = Label.new()
		lbl_osub.text = "Div %d • %s  |  Moyenne OVR : %d" % [opponent_club.division, opponent_club.country, opponent_club.get_starting_five_average_ovr()]
		lbl_osub.add_theme_font_size_override("font_size", 11)
		lbl_osub.add_theme_color_override("font_color", Color("94a3b8"))
		info_opp.add_child(lbl_osub)

		# Schéma tactique adverse observé & contre PFC recommandé
		var form_name = Tactics.get_formation_name(opponent_club.tactical_formation)
		var best_counter_name = ""
		match opponent_club.tactical_formation:
			Tactics.TacticalFormation.FORMATION_1_2_1:
				best_counter_name = "1-1-2 Attaque (Bat le 1-2-1 Losange)"
			Tactics.TacticalFormation.FORMATION_1_1_2:
				best_counter_name = "2-1-1 Défense (Bat le 1-1-2 Attaque)"
			Tactics.TacticalFormation.FORMATION_2_1_1:
				best_counter_name = "1-2-1 Losange (Bat le 2-1-1 Défense)"

		var tact_box = PanelContainer.new()
		var sb_tb = StyleBoxFlat.new()
		sb_tb.bg_color = Color(0.04, 0.08, 0.14, 0.9)
		sb_tb.border_color = Color("38bdf8")
		sb_tb.set_border_width_all(1)
		sb_tb.set_corner_radius_all(6)
		sb_tb.content_margin_left = 10
		sb_tb.content_margin_right = 10
		sb_tb.content_margin_top = 8
		sb_tb.content_margin_bottom = 8
		tact_box.add_theme_stylebox_override("panel", sb_tb)
		opp_vbox.add_child(tact_box)

		var tvbox = VBoxContainer.new()
		tvbox.add_theme_constant_override("separation", 4)
		tact_box.add_child(tvbox)

		var lbl_t_obs = Label.new()
		lbl_t_obs.text = "📐 Dispositif adverse espionné : %s" % form_name
		lbl_t_obs.add_theme_font_size_override("font_size", 12)
		lbl_t_obs.add_theme_color_override("font_color", Color("38bdf8"))
		tvbox.add_child(lbl_t_obs)

		var lbl_t_adv = Label.new()
		lbl_t_adv.text = "💡 Contre recommandé pour Samedi : %s" % best_counter_name
		lbl_t_adv.add_theme_font_size_override("font_size", 12)
		lbl_t_adv.add_theme_color_override("font_color", Color("34d399"))
		tvbox.add_child(lbl_t_adv)

		# Joueur adverse n°1 sous surveillance
		var top_opp_player: Player = null
		for p in opponent_club.starting_five:
			if top_opp_player == null or p.get_overall() > top_opp_player.get_overall():
				top_opp_player = p

		if top_opp_player != null:
			var danger_card = PanelContainer.new()
			var sb_dc = StyleBoxFlat.new()
			sb_dc.bg_color = Color(0.20, 0.06, 0.08, 0.85)
			sb_dc.border_color = Color("f87171")
			sb_dc.set_border_width_all(1)
			sb_dc.set_corner_radius_all(6)
			sb_dc.content_margin_left = 10
			sb_dc.content_margin_right = 10
			sb_dc.content_margin_top = 6
			sb_dc.content_margin_bottom = 6
			danger_card.add_theme_stylebox_override("panel", sb_dc)
			opp_vbox.add_child(danger_card)

			var d_vbox = VBoxContainer.new()
			danger_card.add_child(d_vbox)

			var d_title = Label.new()
			d_title.text = "⚠️ JOUEUR CLÉ ADVERSE SOUS HAUTE SURVEILLANCE :"
			d_title.add_theme_font_size_override("font_size", 11)
			d_title.add_theme_color_override("font_color", Color("f87171"))
			d_vbox.add_child(d_title)

			var pos_txt = ["Gardien", "Défenseur", "Milieu", "Attaquant"][top_opp_player.position]
			var d_name = Label.new()
			d_name.text = "%s %s — %s (%d OVR, %da)" % [
				top_opp_player.get_flag_emoji(),
				top_opp_player.full_name,
				pos_txt,
				top_opp_player.get_overall(),
				top_opp_player.age
			]
			d_name.add_theme_font_size_override("font_size", 12)
			d_name.add_theme_color_override("font_color", Color("f1f5f9"))
			d_vbox.add_child(d_name)

	# 2. Section Rétractable : Veille du Marché & Opportunités des Observateurs
	var sec_market_watch = MobileCollapsibleSection.new("📡 VEILLE DU MARCHÉ & OBSERVATEURS", false)
	content_container.add_child(sec_market_watch)

	var mw_panel = PanelContainer.new()
	var sb_mw = StyleBoxFlat.new()
	sb_mw.bg_color = Color(0.06, 0.10, 0.18, 0.90)
	sb_mw.border_color = Color(0.20, 0.30, 0.45, 0.6)
	sb_mw.set_border_width_all(1)
	sb_mw.set_corner_radius_all(8)
	sb_mw.content_margin_left = 12
	sb_mw.content_margin_right = 12
	sb_mw.content_margin_top = 8
	sb_mw.content_margin_bottom = 8
	mw_panel.add_theme_stylebox_override("panel", sb_mw)
	sec_market_watch.add_content(mw_panel)

	var mw_vbox = VBoxContainer.new()
	mw_vbox.add_theme_constant_override("separation", 6)
	mw_panel.add_child(mw_vbox)

	var l_m1 = Label.new()
	l_m1.text = "• Le marché des transferts est très actif en milieu de tableau. Les opportunités d'agents libres se renouvellent chaque semaine."
	l_m1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_m1.add_theme_font_size_override("font_size", 11)
	l_m1.add_theme_color_override("font_color", Color("94a3b8"))
	mw_vbox.add_child(l_m1)

	var l_m2 = Label.new()
	l_m2.text = "• Conseil : Si votre 5 de départ manque de fraîcheur, privilégiez l'intégration d'un jeune de votre académie pour faire souffler vos cadres."
	l_m2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l_m2.add_theme_font_size_override("font_size", 11)
	l_m2.add_theme_color_override("font_color", Color("38bdf8"))
	mw_vbox.add_child(l_m2)

# =========================================================================
# ACTIONS
# =========================================================================
func _on_detect_pressed() -> void:
	if club.budget < 15_000:
		_show_popup("Budget insuffisant", "Il vous faut 15 000 € pour financer la détection.")
		return
	if club.youth_academy.size() >= 8:
		_show_popup("Académie complète", "Votre académie compte déjà 8 jeunes espoirs.")
		return

	var new_p = club.scout_new_youth_prospect(15_000)
	if new_p != null:
		_show_popup("Pépite détectée !", "Félicitations ! %s (%s, %d OVR, Potentiel %d-%d) a rejoint votre centre de formation !" % [
			new_p.full_name,
			["Gardien", "Défenseur", "Milieu", "Attaquant"][new_p.position],
			new_p.get_overall(),
			new_p.potential_min,
			new_p.potential_max
		])
		refresh_view()
		data_changed.emit()

func _promote_player(p: Player) -> void:
	if club.squad.size() >= 32:
		_show_popup("Effectif plein", "Votre effectif compte déjà 32 joueurs pro. Libérez une place avant de promouvoir un jeune.")
		return

	if club.promote_youth_to_senior(p):
		_show_popup("Promotion Pro réussie !", "%s a signé son premier contrat pro (3 ans) et intègre l'équipe première !" % p.full_name)
		refresh_view()
		data_changed.emit()

func _show_youth_details(p: Player) -> void:
	var pos_txt = ["Gardien (GK)", "Défenseur (DEF)", "Milieu (MID)", "Attaquant (FWD)"][p.position]
	var body = "Nom : %s\nPoste : %s\nÂge : %d ans  |  Nationalité : %s\nNote actuelle : %d OVR\nFourchette de potentiel : %d - %d OVR\n\nAttributs :\nVitesse : %d  |  Tir : %d\nPasse : %d  |  Défense : %d\nDribble : %d  |  Endurance : %d" % [
		p.full_name, pos_txt, p.age, p.nationality,
		p.get_overall(), p.potential_min, p.potential_max,
		p.speed, p.shooting, p.passing, p.defending, p.dribbling, p.stamina
	]
	_show_popup("Fiche Espoir — %s" % p.full_name, body)

func _show_popup(title: String, body: String) -> void:
	var d = AcceptDialog.new()
	d.title = title
	d.dialog_text = body
	add_child(d)
	d.popup_centered(Vector2i(420, 240))
