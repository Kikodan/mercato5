class_name HelpModal
extends Control

signal closed()

func _ready() -> void:
	visible = false
	z_index = 60
	_build_ui()

func open_modal() -> void:
	visible = true
	move_to_front()

func close_modal() -> void:
	visible = false
	closed.emit()

func _build_ui() -> void:
	for c in get_children():
		c.queue_free()

	# Overlay sombre
	var overlay = ColorRect.new()
	overlay.color = Color(0.04, 0.06, 0.1, 0.8)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(660, 520)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.11, 0.19, 0.98)
	sb.set_corner_radius_all(14)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color("38bdf8")
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	panel.add_child(main_vbox)

	# En-tête
	var header_hbox = HBoxContainer.new()
	var title_lbl = Label.new()
	title_lbl.text = "📖 Guide du Manager • Mercato 5"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color("38bdf8"))
	header_hbox.add_child(title_lbl)

	var btn_x = Button.new()
	btn_x.text = "✕"
	btn_x.custom_minimum_size = Vector2(32, 32)
	btn_x.pressed.connect(close_modal)
	header_hbox.add_child(btn_x)
	main_vbox.add_child(header_hbox)

	var sep = HSeparator.new()
	main_vbox.add_child(sep)

	# Scroll pour le contenu
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 14)

	# 1. Règles du Jeu & Buts
	_add_section(content_vbox, "⚽ Règles des Matchs & Victoire",
		"• Futsal 5 contre 5 avec 1 Gardien obligatoire.\n" +
		"• Course aux buts : le premier club à inscrire 5 buts remporte le match en saison régulière (aucun match nul possible !).\n" +
		"• En Playoffs et en Coupe d'Europe, la victoire se joue au premier à 7 buts pour un suspense maximal !"
	)

	# 2. Forme, Fatigue & Rotation
	_add_section(content_vbox, "🔋 Forme, Fatigue & Rotation Obligatoire",
		"• Chaque match use l'énergie de vos 5 titulaires. L'usure augmente si le joueur a une faible note d'endurance ou le trait 'Fumeur' / 'Fragile'.\n" +
		"• Enchaîner les titularisations sans repos accumule de la fatigue résiduelle.\n" +
		"• Les joueurs au repos sur le banc récupèrent très rapidement (+35% de forme par journée).\n" +
		"• ⚠️ Pensez à faire tourner votre effectif : un joueur épuisé perd énormément en efficacité et en précision !"
	)

	# 3. Tactique & Entraînement
	_add_section(content_vbox, "📋 Styles Tactiques & Entraînement",
		"• Équilibré : style standard polyvalent sans bonus ni malus physique.\n" +
		"• Attaque Totale : pressing haut et projection offensive. Marque plus mais fatigue énormément vos joueurs !\n" +
		"• Contre-Attaque : bloc défensif solide, préserve l'énergie et exploite les espaces.\n" +
		"• Programmes de la semaine : la Cryothérapie booste la récupération, tandis que Tir et Défense ciblent l'efficacité."
	)

	# 4. Marché des Transferts & Négociations
	_add_section(content_vbox, "💼 Marché des Transferts",
		"• Recrutez des joueurs libres ou négociez des transferts avec d'autres clubs.\n" +
		"• Proposez un salaire hebdomadaire, une prime à la signature et une durée de contrat adaptée aux exigences du joueur.\n" +
		"• Attention à la limite de 12 joueurs par effectif (5 joueurs minimum)."
	)

	# 5. Économie & Billetterie
	_add_section(content_vbox, "💶 Finances & Billetterie",
		"• Chaque match à domicile remplit les caisses grâce aux ventes de billets (affluence selon votre réputation et l'affiche du match).\n" +
		"• Vos sponsors vous versent des primes hebdomadaires. Veillez à garder une masse salariale soutenable !"
	)

	# 6. Playoffs & Compétitions
	_add_section(content_vbox, "🏆 Championnat, Playoffs & Europe",
		"• Toutes les D1 européennes comptent 8 clubs pour 14 journées régulières.\n" +
		"• Le 1er est qualifié directement pour la Grande Finale. Le 2e et le 3e s'affrontent en Demi-finale de Playoffs.\n" +
		"• Les 2 premiers de chaque D1 se qualifient pour la grande Coupe d'Europe en fin de saison !"
	)

	scroll.add_child(content_vbox)
	main_vbox.add_child(scroll)

	var close_btn = Button.new()
	close_btn.text = "Compris, fermer le guide"
	close_btn.custom_minimum_size = Vector2(0, 36)
	close_btn.modulate = Color("10b981")
	close_btn.pressed.connect(close_modal)
	main_vbox.add_child(close_btn)

func _add_section(parent: VBoxContainer, title_text: String, body_text: String) -> void:
	var sec_panel = PanelContainer.new()
	var sec_style = StyleBoxFlat.new()
	sec_style.bg_color = Color(0.12, 0.16, 0.25, 0.9)
	sec_style.set_corner_radius_all(8)
	sec_style.border_width_left = 1
	sec_style.border_width_top = 1
	sec_style.border_width_right = 1
	sec_style.border_width_bottom = 1
	sec_style.border_color = Color(0.22, 0.3, 0.45, 0.6)
	sec_style.content_margin_left = 14
	sec_style.content_margin_right = 14
	sec_style.content_margin_top = 10
	sec_style.content_margin_bottom = 10
	sec_panel.add_theme_stylebox_override("panel", sec_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)

	var stitle = Label.new()
	stitle.text = title_text
	stitle.add_theme_font_size_override("font_size", 14)
	stitle.add_theme_color_override("font_color", Color("facc15"))
	vbox.add_child(stitle)

	var sbody = Label.new()
	sbody.text = body_text
	sbody.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sbody.add_theme_font_size_override("font_size", 12)
	sbody.add_theme_color_override("font_color", Color("e2e8f0"))
	vbox.add_child(sbody)

	sec_panel.add_child(vbox)
	parent.add_child(sec_panel)
