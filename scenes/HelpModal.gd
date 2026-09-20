class_name HelpModal
extends Control

signal closed()

var active_tab_index: int = 0
var tab_buttons: Array[Button] = []
var tab_content_container: PanelContainer = null
var scroll_container: ScrollContainer = null

const TABS = [
	{"id": "HOME", "label": "🏠 Accueil & Calendrier"},
	{"id": "SQUAD", "label": "👥 Effectif & Forme"},
	{"id": "TACTICS", "label": "📋 Tactique & Entraînement"},
	{"id": "MERCATO", "label": "💼 Mercato & Transferts"},
	{"id": "FORMATION", "label": "🎓 Centre de Formation"},
	{"id": "STANDINGS", "label": "📊 Championnats & Europe"},
	{"id": "ECONOMY", "label": "💶 Économie & Sponsors"},
	{"id": "MATCH", "label": "⚽ Matchs en Direct 2D"},
	{"id": "FFP", "label": "⚖️ Fair-Play Financier"}
]

func _ready() -> void:
	visible = false
	z_index = 60
	_build_ui()

func open_modal(initial_tab: int = 0) -> void:
	active_tab_index = initial_tab
	_switch_tab(active_tab_index)
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
	overlay.color = Color(0.04, 0.06, 0.1, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(880, 580)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.10, 0.17, 0.98)
	sb.set_corner_radius_all(14)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color("38bdf8")
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 16
	sb.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	panel.add_child(main_vbox)

	# En-tête
	var header_hbox = HBoxContainer.new()
	var title_lbl = Label.new()
	title_lbl.text = "📖 Manuel du Manager • Mercato 5"
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

	# Barre de sélection des Onglets (Barre horizontale avec défilement fluide)
	var tab_scroll = ScrollContainer.new()
	tab_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tab_scroll.custom_minimum_size = Vector2(0, 40)
	
	var tab_bar = HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 6)
	tab_buttons.clear()

	for i in range(TABS.size()):
		var t_info = TABS[i]
		var btn = Button.new()
		btn.text = t_info["label"]
		btn.custom_minimum_size = Vector2(0, 34)
		btn.add_theme_font_size_override("font_size", 12)
		var idx = i
		btn.pressed.connect(func(): _switch_tab(idx))
		tab_bar.add_child(btn)
		tab_buttons.append(btn)

	tab_scroll.add_child(tab_bar)
	main_vbox.add_child(tab_scroll)

	# Zone de contenu défilable
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	tab_content_container = PanelContainer.new()
	tab_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content_sb = StyleBoxFlat.new()
	content_sb.bg_color = Color(0.05, 0.07, 0.12, 0.6)
	content_sb.set_corner_radius_all(8)
	content_sb.content_margin_left = 14
	content_sb.content_margin_right = 14
	content_sb.content_margin_top = 14
	content_sb.content_margin_bottom = 14
	tab_content_container.add_theme_stylebox_override("panel", content_sb)

	scroll_container.add_child(tab_content_container)
	main_vbox.add_child(scroll_container)

	# Bas de page
	var btm_hbox = HBoxContainer.new()
	btm_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	var close_btn = Button.new()
	close_btn.text = "Fermer le guide"
	close_btn.custom_minimum_size = Vector2(180, 36)
	close_btn.modulate = Color("10b981")
	close_btn.pressed.connect(close_modal)
	btm_hbox.add_child(close_btn)
	main_vbox.add_child(btm_hbox)

	_switch_tab(0)

func _switch_tab(index: int) -> void:
	if tab_content_container == null:
		_build_ui()
	active_tab_index = index
	for i in range(tab_buttons.size()):
		var b = tab_buttons[i]
		if i == index:
			b.modulate = Color("38bdf8")
		else:
			b.modulate = Color("94a3b8")

	for child in tab_content_container.get_children():
		child.queue_free()

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	match TABS[index]["id"]:
		"HOME":
			_build_home_help(vbox)
		"SQUAD":
			_build_squad_help(vbox)
		"TACTICS":
			_build_tactics_help(vbox)
		"MERCATO":
			_build_mercato_help(vbox)
		"FORMATION":
			_build_formation_help(vbox)
		"STANDINGS":
			_build_standings_help(vbox)
		"ECONOMY":
			_build_economy_help(vbox)
		"MATCH":
			_build_match_help(vbox)
		"FFP":
			_build_ffp_help(vbox)

	tab_content_container.add_child(vbox)
	scroll_container.scroll_vertical = 0

# --- DÉTAIL DES ONGLETS ---

func _build_home_help(parent: VBoxContainer) -> void:
	_add_section(parent, "🗓️ Calendrier & Déroulement de la Saison",
		"• Chaque championnat européen compte 8 équipes pour 14 journées intenses (aller-retour).\n" +
		"• Le bouton « Avancer ▶ » simule la journée de championnat pour l'ensemble des ligues européennes.\n" +
		"• En fin de journée, les recettes billetterie sont versées si vous jouiez à domicile, la fatigue de vos joueurs est actualisée et le marché des transferts vit de nouveaux mouvements."
	)
	_add_section(parent, "🏆 Phase Finale : Playoffs Top 3",
		"• À l'issue des 14 journées régulières, les 3 meilleures équipes accèdent aux Playoffs.\n" +
		"• Le 1er est qualifié d'office pour la Grande Finale !\n" +
		"• Le 2e et le 3e s'affrontent en Demi-finale éliminatoire pour décrocher leur ticket en finale."
	)
	_add_section(parent, "🌍 Coupe d'Europe des Clubs",
		"• Les 2 premiers de chaque division 1 européenne se qualifient pour la Coupe d'Europe en clôture de saison.\n" +
		"• Phase à élimination directe au premier à 7 buts pour décrocher le titre suprême continental !"
	)

func _build_squad_help(parent: VBoxContainer) -> void:
	_add_section(parent, "💯 Échelle des Notes de 20 à 99 & Nouvelles Statistiques",
		"• Les caractéristiques des joueurs sont désormais notées sur 100 pour une grande finesse tactique.\n" +
		"• Vitesse, Tir, Passe, Défense, Endurance sont complétées par deux caractéristiques majeures :\n" +
		"  - ⚡ Dribble : capacité des joueurs de champ à éliminer l'adversaire et créer des brèches.\n" +
		"  - 🧤 Réflexes : attribut fondamental des Gardiens pour réaliser des arrêts spectaculaires sur leur ligne."
	)
	_add_section(parent, "🔋 Gestion de la Forme & Rotation Obligatoire",
		"• Chaque match use l'énergie des 5 titulaires. L'usure augmente selon le style de jeu (l'Attaque Totale fatigue énormément) et l'Endurance.\n" +
		"• ⚠️ Un joueur épuisé commet plus d'erreurs, rate ses tirs et s'expose aux blessures.\n" +
		"• Les remplaçants au repos sur le banc récupèrent jusqu'à +35% de forme par journée. Pensez à faire tourner votre effectif !"
	)
	_add_section(parent, "👥 Taille d'Effectif (jusqu'à 32 Joueurs)",
		"• Vous pouvez désormais gérer un effectif jusqu'à 32 joueurs sous contrat (minimum 5 joueurs pour pouvoir jouer).\n" +
		"• Vous pouvez libérer un joueur sous contrat contre une indemnité de départ correspondant à 4 semaines de salaire."
	)

func _build_tactics_help(parent: VBoxContainer) -> void:
	_add_section(parent, "📋 Les 3 Styles Tactiques",
		"• ⚖️ Équilibré : style standard polyvalent sans consommation excessive d'énergie.\n" +
		"• ⚔️ Attaque Totale : pressing haut tout terrain et prise de risque maximale. Marque énormément mais épuise très vite vos joueurs.\n" +
		"• 🛡️ Contre-Attaque : bloc bas rigoureux, préserve le physique et exploite les moindres espaces laissés par l'adversaire."
	)
	_add_section(parent, "🏋️ Focus d'Entraînement de la Semaine",
		"• Équilibré : entretien global du groupe.\n" +
		"• Tir & Finition : augmente le pourcentage de concrétisation offensive pour le prochain match.\n" +
		"• Défense & Tacles : renforce l'efficacité des interventions défensives et des interceptions.\n" +
		"• Cryothérapie : récupération physique accélérée pour régénérer la barre d'endurance de vos joueurs fatigués."
	)
	_add_section(parent, "🔄 Le 5 de Départ",
		"• 1 Gardien (G) est obligatoirement requis dans le 5 de départ.\n" +
		"• Utilisez le bouton 'Sélection Auto' pour aligner automatiquement vos meilleurs joueurs en forme."
	)

func _build_mercato_help(parent: VBoxContainer) -> void:
	_add_section(parent, "🤝 Négociation en 2 Temps (Club Vendeur puis Joueur)",
		"• Phase 1 : Négociation de l'indemnité avec le club vendeur en 4 tentatives maximum.\n" +
		"  Le président adverse peut accepter votre offre, faire une contre-proposition ou rompre définitivement les négociations si l'offre est jugée dérisoire !\n" +
		"• Phase 2 : Négociation du contrat personnel avec le joueur (salaire hebdomadaire, prime à la signature et durée du contrat)."
	)
	_add_section(parent, "🆓 Joueurs Libres (Agents Libres)",
		"• Les agents libres ne nécessitent aucune indemnité de transfert : vous négociez directement leur contrat personnel.\n" +
		"• Entre chaque journée, le marché est rafraîchi dynamiquement avec de nouvelles opportunités !"
	)

func _build_formation_help(parent: VBoxContainer) -> void:
	_add_section(parent, "🎓 Centre de Formation & Détection",
		"• Chaque club dispose d'un centre de formation intégrant des jeunes espoirs prometteurs âgés de 15 à 18 ans.\n" +
		"• Vous pouvez recruter de nouveaux jeunes talents en envoyant vos recruteurs via le bouton '🔍 Détecter un nouvel espoir (50 000 €)'."
	)
	_add_section(parent, "⭐ Évolution du Potentiel & Promotion Pro",
		"• Chaque semaine de championnat, le niveau général et l'estimation du potentiel (ex: 82-94 ⭐) de vos jeunes évoluent en coulisses.\n" +
		"• À tout moment, vous pouvez promouvoir gratuitement un jeune talent directement dans l'effectif professionnel avec un contrat pro de 3 ans."
	)

func _build_standings_help(parent: VBoxContainer) -> void:
	_add_section(parent, "📊 Ligues Européennes & Bundesliga",
		"• L'ensemble des 1ères divisions européennes (France, Espagne, Italie, Angleterre, Allemagne, etc.) compte 8 clubs chacune.\n" +
		"• Consultez les résultats récents sous forme de pastilles de victoires et défaites pour évaluer la dynamique de vos prochains adversaires.\n" +
		"• Vous pouvez également inspecter la composition de tous les clubs du monde entier."
	)

func _build_economy_help(parent: VBoxContainer) -> void:
	_add_section(parent, "💰 Finances Saines & Résultat Fixe Hebdomadaire",
		"• Au début du jeu, vos finances sont équilibrées : les salaires sont soutenables et vos entrées fixes garantissent un résultat positif.\n" +
		"• Résultat Net Fixe = (Sponsors + Droits TV) − (Masse Salariale + Maintenance du club)."
	)
	_add_section(parent, "🤝 Négociation des Sponsors & Publicités",
		"• Dans l'onglet Économie, vous pouvez sélectionner et négocier 4 catégories de contrats :\n" +
		"  1. 👕 Sponsor Maillot Principal : fort versement fixe et prime à la signature.\n" +
		"  2. 🏟️ Naming Salle & Arena : versement hebdomadaire pour l'appellation officielle de votre salle.\n" +
		"  3. 👟 Équipementier Officiel : marques de sport spécialisées avec primes régulières.\n" +
		"  4. 🪧 Panneaux & Régie LED : affichage publicitaire dynamique en bord de parquet.\n" +
		"• Chaque marque propose un versement hebdomadaire, un bonus par victoire et une durée de contrat. Vous pouvez tenter de négocier une bonification !"
	)
	_add_section(parent, "🏟️ Billetterie des Matchs à Domicile",
		"• Ajustez le prix du billet pour vos rencontres à domicile. Un tarif adapté à votre réputation maximise le taux de remplissage et les revenus !"
	)

func _build_match_help(parent: VBoxContainer) -> void:
	_add_section(parent, "⚽ Course aux 5 Buts (7 Buts en Playoffs/Europe)",
		"• Les matchs de championnat se jouent à la course aux buts : la première équipe à inscrire 5 buts remporte immédiatement la victoire (aucun match nul !).\n" +
		"• En Playoffs et Coupe d'Europe, la victoire se dispute au premier à 7 buts !"
	)
	_add_section(parent, "🎯 Affichage 2D, Visages & Notes OVR",
		"• Les jetons de match affichent le visage circulaire de vos joueurs ainsi que leur note globale (OVR).\n" +
		"• Les bannières d'événements (buts, arrêts décisifs réflexes, tacles salvateurs) affichent la photo miniature du joueur en action !"
	)

func _build_ffp_help(parent: VBoxContainer) -> void:
	_add_section(parent, "⚖️ Règlement du Fair-Play Financier (DNCG)",
		"• L'organisme de contrôle financier veille à la pérennité économique de tous les clubs.\n" +
		"• Règle d'or : Vos revenus fixes hebdomadaires garantis (sponsors + droits TV) doivent couvrir votre masse salariale et les frais d'entretien."
	)
	_add_section(parent, "🚫 Sanction : Interdiction Totale de Recrutement",
		"• Si vous terminez la saison avec un résultat fixe hebdomadaire négatif (déficit), le gendarme financier prononce une interdiction de recrutement pour toute la saison suivante !\n" +
		"• Durant cette sanction, vous ne pouvez ni acheter de joueurs ni signer d'agents libres.\n" +
		"• Vous devrez alors vous appuyer sur les jeunes de votre centre de formation et dégraisser votre masse salariale pour assainir vos comptes et lever la sanction la saison d'après."
	)

func _add_section(parent: VBoxContainer, title_text: String, body_text: String) -> void:
	var sec_panel = PanelContainer.new()
	var sec_style = StyleBoxFlat.new()
	sec_style.bg_color = Color(0.10, 0.14, 0.22, 0.95)
	sec_style.set_corner_radius_all(8)
	sec_style.border_width_left = 2
	sec_style.border_width_top = 1
	sec_style.border_width_right = 1
	sec_style.border_width_bottom = 1
	sec_style.border_color = Color(0.22, 0.32, 0.48, 0.7)
	sec_style.content_margin_left = 14
	sec_style.content_margin_right = 14
	sec_style.content_margin_top = 10
	sec_style.content_margin_bottom = 10
	sec_panel.add_theme_stylebox_override("panel", sec_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

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
