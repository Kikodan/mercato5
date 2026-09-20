class_name HelpModal
extends Control

signal closed()

var active_category_index: int = 0
var category_buttons: Array[Button] = []
var search_line_edit: LineEdit = null
var current_search_query: String = ""

var content_scroll: ScrollContainer = null
var content_container: VBoxContainer = null

const CATEGORIES = [
	{"id": "HOME", "label": "🏠 Accueil & Calendrier"},
	{"id": "SQUAD", "label": "👥 Effectif & Forme"},
	{"id": "TACTICS", "label": "📋 Tactique & 5 Majeur"},
	{"id": "MERCATO", "label": "💼 Mercato & Transferts"},
	{"id": "FORMATION", "label": "🎓 Centre de Formation"},
	{"id": "STANDINGS", "label": "📊 Championnats & Europe"},
	{"id": "ECONOMY", "label": "💶 Économie & Sponsors"},
	{"id": "MATCH", "label": "⚽ Matchs en Direct 2D"},
	{"id": "FFP", "label": "⚖️ Fair-Play Financier"}
]

const HELP_SECTIONS = [
	# HOME
	{
		"category_id": "HOME",
		"category_label": "🏠 Accueil & Calendrier",
		"title": "🗓️ Calendrier & Déroulement de la Saison",
		"body": "• Chaque championnat européen compte 8 équipes pour 14 journées intenses (aller-retour).\n" +
			"• Le bouton « Avancer ▶ » simule la journée de championnat pour l'ensemble des ligues européennes.\n" +
			"• En fin de journée, les recettes billetterie sont versées si vous jouiez à domicile, la fatigue de vos joueurs est actualisée et le marché des transferts vit de nouveaux mouvements."
	},
	{
		"category_id": "HOME",
		"category_label": "🏠 Accueil & Calendrier",
		"title": "🏆 Phase Finale : Playoffs Top 3",
		"body": "• À l'issue des 14 journées régulières, les 3 meilleures équipes accèdent aux Playoffs.\n" +
			"• Le 1er est qualifié d'office pour la Grande Finale !\n" +
			"• Le 2e et le 3e s'affrontent en Demi-finale éliminatoire pour décrocher leur ticket en finale."
	},
	{
		"category_id": "HOME",
		"category_label": "🏠 Accueil & Calendrier",
		"title": "🌍 Coupe d'Europe des Clubs",
		"body": "• Les 2 premiers de chaque division 1 européenne se qualifient pour la Coupe d'Europe en clôture de saison.\n" +
			"• Phase à élimination directe au premier à 7 buts pour décrocher le titre suprême continental !"
	},
	# SQUAD
	{
		"category_id": "SQUAD",
		"category_label": "👥 Effectif & Forme",
		"title": "🟢 Joueurs Alignés sur le Terrain & Liseré de Séparation",
		"body": "• Dans le listing de l'effectif, les joueurs titulaires (5 Majeur aligné sur le terrain) apparaissent distinctement en tête avec un liseré vert émeraude.\n" +
			"• Un liseré de démarcation sépare clairement les 5 titulaires des remplaçants et joueurs en réserve.\n" +
			"• Vous pouvez permuter n'importe quel joueur en cliquant sur le bouton ⇄ du joueur puis sur sa cible."
	},
	{
		"category_id": "SQUAD",
		"category_label": "👥 Effectif & Forme",
		"title": "💯 Échelle des Notes de 20 à 99 & Nouvelles Statistiques",
		"body": "• Les caractéristiques des joueurs sont désormais notées sur 100 pour une grande finesse tactique.\n" +
			"• Vitesse, Tir, Passe, Défense, Endurance sont complétées par deux caractéristiques majeures :\n" +
			"  - ⚡ Dribble : capacité des joueurs de champ à éliminer l'adversaire et créer des brèches.\n" +
			"  - 🧤 Réflexes : attribut fondamental des Gardiens pour réaliser des arrêts spectaculaires sur leur ligne."
	},
	{
		"category_id": "SQUAD",
		"category_label": "👥 Effectif & Forme",
		"title": "🔋 Gestion de la Forme & Rotation Obligatoire",
		"body": "• Chaque match use l'énergie des 5 titulaires. L'usure augmente selon le style de jeu (l'Attaque Totale fatigue énormément) et l'Endurance.\n" +
			"• ⚠️ Un joueur épuisé commet plus d'erreurs, rate ses tirs et s'expose aux blessures.\n" +
			"• Les remplaçants au repos sur le banc récupèrent jusqu'à +35% de forme par journée. Pensez à faire tourner votre effectif !"
	},
	{
		"category_id": "SQUAD",
		"category_label": "👥 Effectif & Forme",
		"title": "👥 Taille d'Effectif (jusqu'à 32 Joueurs)",
		"body": "• Vous pouvez gérer un effectif jusqu'à 32 joueurs sous contrat (minimum 5 joueurs pour pouvoir jouer).\n" +
			"• Vous pouvez libérer un joueur sous contrat contre une indemnité de départ correspondant à 4 semaines de salaire."
	},
	# TACTICS
	{
		"category_id": "TACTICS",
		"category_label": "📋 Tactique & 5 Majeur",
		"title": "📋 Les 3 Styles Tactiques",
		"body": "• ⚖️ Équilibré : style standard polyvalent sans consommation excessive d'énergie.\n" +
			"• ⚔️ Attaque Totale : pressing haut tout terrain et prise de risque maximale. Marque énormément mais épuise très vite vos joueurs.\n" +
			"• 🛡️ Contre-Attaque : bloc bas rigoureux, préserve le physique et exploite les moindres espaces laissés par l'adversaire."
	},
	{
		"category_id": "TACTICS",
		"category_label": "📋 Tactique & 5 Majeur",
		"title": "🏋️ Focus d'Entraînement de la Semaine",
		"body": "• Équilibré : entretien global du groupe.\n" +
			"• Tir & Finition : augmente le pourcentage de concrétisation offensive pour le prochain match.\n" +
			"• Défense & Tacles : renforce l'efficacité des interventions défensives et des interceptions.\n" +
			"• Cryothérapie : récupération physique accélérée pour régénérer la barre d'endurance de vos joueurs fatigués."
	},
	{
		"category_id": "TACTICS",
		"category_label": "📋 Tactique & 5 Majeur",
		"title": "🔄 Le 5 de Départ & Remplacements",
		"body": "• 1 Gardien (GK) est obligatoirement requis dans le 5 de départ.\n" +
			"• Utilisez le bouton 'Sélection Auto' pour aligner automatiquement vos meilleurs joueurs en forme.\n" +
			"• Cliquez sur un joueur sur le terrain ou dans la liste pour le permuter."
	},
	# MERCATO
	{
		"category_id": "MERCATO",
		"category_label": "💼 Mercato & Transferts",
		"title": "🤝 Négociation en 2 Temps (Club Vendeur puis Joueur)",
		"body": "• Phase 1 : Négociation de l'indemnité avec le club vendeur en 4 tentatives maximum.\n" +
			"  Le président adverse peut accepter votre offre, faire une contre-proposition ou rompre définitivement les négociations si l'offre est jugée dérisoire !\n" +
			"• Phase 2 : Négociation du contrat personnel avec le joueur (salaire hebdomadaire, prime à la signature et durée du contrat)."
	},
	{
		"category_id": "MERCATO",
		"category_label": "💼 Mercato & Transferts",
		"title": "🆓 Joueurs Libres (Agents Libres)",
		"body": "• Les agents libres ne nécessitent aucune indemnité de transfert : vous négociez directement leur contrat personnel.\n" +
			"• Entre chaque journée, le marché est rafraîchi dynamiquement avec de nouvelles opportunités !"
	},
	{
		"category_id": "MERCATO",
		"category_label": "💼 Mercato & Transferts",
		"title": "🔄 Renouvellement Continu du Mercato",
		"body": "• Le marché des transferts est continuellement approvisionné en jeunes pépites et joueurs d'expérience issus de toute l'Europe et du monde.\n" +
			"• Tous les montants financiers (valeur marchande, salaire, budget) sont clairement formatés avec espacement des milliers et millions."
	},
	# FORMATION
	{
		"category_id": "FORMATION",
		"category_label": "🎓 Centre de Formation",
		"title": "🎓 Centre de Formation & Détection",
		"body": "• Chaque club dispose d'un centre de formation intégrant des jeunes espoirs prometteurs âgés de 15 à 18 ans.\n" +
			"• Vous pouvez recruter de nouveaux jeunes talents en envoyant vos recruteurs via le bouton '🔍 Détecter un nouvel espoir (50 000 €)'."
	},
	{
		"category_id": "FORMATION",
		"category_label": "🎓 Centre de Formation",
		"title": "⭐ Évolution du Potentiel & Promotion Pro",
		"body": "• Chaque semaine de championnat, le niveau général et l'estimation du potentiel (ex: 82-94 ⭐) de vos jeunes évoluent en coulisses.\n" +
			"• À tout moment, vous pouvez promouvoir gratuitement un jeune talent directement dans l'effectif professionnel avec un contrat pro de 3 ans."
	},
	# STANDINGS
	{
		"category_id": "STANDINGS",
		"category_label": "📊 Championnats & Europe",
		"title": "📊 Ligues Européennes & Bundesliga",
		"body": "• L'ensemble des 1ères divisions européennes (France, Espagne, Italie, Angleterre, Allemagne, etc.) compte 8 clubs chacune.\n" +
			"• Consultez les résultats récents sous forme de pastilles de victoires et défaites pour évaluer la dynamique de vos prochains adversaires."
	},
	{
		"category_id": "STANDINGS",
		"category_label": "📊 Championnats & Europe",
		"title": "🔍 Consultation des Effectifs Mondiaux",
		"body": "• En cliquant sur n'importe quel club dans le classement ou l'explorateur, vous pouvez inspecter l'intégralité de son effectif avec les 5 titulaires démarqués par un liseré et ses remplaçants.\n" +
			"• Vous pouvez tenter de négocier l'achat de n'importe quel joueur sous contrat !"
	},
	# ECONOMY
	{
		"category_id": "ECONOMY",
		"category_label": "💶 Économie & Sponsors",
		"title": "💰 Finances Saines & Résultat Fixe Hebdomadaire",
		"body": "• Au début du jeu, vos finances sont équilibrées : les salaires sont soutenables et vos entrées fixes garantissent un résultat positif.\n" +
			"• Résultat Net Fixe = (Sponsors + Droits TV) − (Masse Salariale + Maintenance du club).\n" +
			"• Ce montant s'affiche en grand avec espacement des milliers pour un suivi limpide."
	},
	{
		"category_id": "ECONOMY",
		"category_label": "💶 Économie & Sponsors",
		"title": "🤝 Négociation des Sponsors & Publicités",
		"body": "• Dans l'onglet Économie, vous pouvez sélectionner et négocier 4 catégories de contrats :\n" +
			"  1. 👕 Sponsor Maillot Principal : fort versement fixe et prime à la signature.\n" +
			"  2. 🏟️ Naming Salle & Arena : versement hebdomadaire pour l'appellation officielle de votre salle.\n" +
			"  3. 👟 Équipementier Officiel : marques de sport spécialisées avec primes régulières.\n" +
			"  4. 🪧 Panneaux & Régie LED : affichage publicitaire dynamique en bord de parquet.\n" +
			"• Chaque marque propose un versement hebdomadaire, un bonus par victoire et une durée de contrat. Vous pouvez tenter de négocier une bonification !"
	},
	{
		"category_id": "ECONOMY",
		"category_label": "💶 Économie & Sponsors",
		"title": "🏟️ Billetterie des Matchs à Domicile",
		"body": "• Ajustez le prix du billet pour vos rencontres à domicile. Un tarif adapté à votre réputation maximise le taux de remplissage et les revenus !"
	},
	# MATCH
	{
		"category_id": "MATCH",
		"category_label": "⚽ Matchs en Direct 2D",
		"title": "⚽ Course aux 5 Buts (7 Buts en Playoffs/Europe)",
		"body": "• Les matchs de championnat se jouent à la course aux buts : la première équipe à inscrire 5 buts remporte immédiatement la victoire (aucun match nul !).\n" +
			"• En Playoffs et Coupe d'Europe, la victoire se dispute au premier à 7 buts !"
	},
	{
		"category_id": "MATCH",
		"category_label": "⚽ Matchs en Direct 2D",
		"title": "🎯 Affichage 2D, Visages & Notes OVR",
		"body": "• Les jetons de match affichent le visage circulaire de vos joueurs ainsi que leur note globale (OVR).\n" +
			"• Les bannières d'événements (buts, arrêts décisifs réflexes, tacles salvateurs) affichent la photo miniature du joueur en action !"
	},
	# FFP
	{
		"category_id": "FFP",
		"category_label": "⚖️ Fair-Play Financier",
		"title": "⚖️ Règlement du Fair-Play Financier (DNCG)",
		"body": "• L'organisme de contrôle financier veille à la pérennité économique de tous les clubs.\n" +
			"• Règle d'or : Vos revenus fixes hebdomadaires garantis (sponsors + droits TV) doivent couvrir votre masse salariale et les frais d'entretien."
	},
	{
		"category_id": "FFP",
		"category_label": "⚖️ Fair-Play Financier",
		"title": "🚫 Sanction : Interdiction Totale de Recrutement",
		"body": "• Si vous terminez la saison avec un résultat fixe hebdomadaire négatif (déficit), le gendarme financier prononce une interdiction de recrutement pour toute la saison suivante !\n" +
			"• Durant cette sanction, vous ne pouvez ni acheter de joueurs ni signer d'agents libres.\n" +
			"• Vous devrez alors vous appuyer sur les jeunes de votre centre de formation et dégraisser votre masse salariale pour assainir vos comptes et lever la sanction la saison d'après."
	}
]

func _ready() -> void:
	visible = false
	z_index = 60
	_build_ui()

func open_modal(initial_category: int = 0) -> void:
	active_category_index = initial_category
	current_search_query = ""
	if search_line_edit != null:
		search_line_edit.text = ""
	_switch_category(active_category_index)
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
	panel.custom_minimum_size = Vector2(920, 600)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.10, 0.17, 0.98)
	sb.set_corner_radius_all(12)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color("38bdf8")
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 14
	sb.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	panel.add_child(main_vbox)

	# --- EN-TÊTE : Titre + Barre de Recherche + Bouton Fermer ---
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)
	header_hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var title_lbl = Label.new()
	title_lbl.text = "📖 Guide & Aide de Jeu • Mercato 5"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color("38bdf8"))
	header_hbox.add_child(title_lbl)

	# Champ de Recherche
	search_line_edit = LineEdit.new()
	search_line_edit.placeholder_text = "🔍 Rechercher un terme (ex: forme, ffp, sponsor...)"
	search_line_edit.clear_button_enabled = true
	search_line_edit.custom_minimum_size = Vector2(320, 32)
	search_line_edit.add_theme_font_size_override("font_size", 12)
	var search_sb = StyleBoxFlat.new()
	search_sb.bg_color = Color(0.11, 0.16, 0.25, 0.9)
	search_sb.border_color = Color(0.24, 0.35, 0.52, 0.8)
	search_sb.border_width_left = 1
	search_sb.border_width_top = 1
	search_sb.border_width_right = 1
	search_sb.border_width_bottom = 1
	search_sb.set_corner_radius_all(6)
	search_sb.content_margin_left = 10
	search_sb.content_margin_right = 10
	search_line_edit.add_theme_stylebox_override("normal", search_sb)
	search_line_edit.text_changed.connect(_on_search_text_changed)
	header_hbox.add_child(search_line_edit)

	var btn_x = Button.new()
	btn_x.text = "✕"
	btn_x.custom_minimum_size = Vector2(32, 32)
	btn_x.pressed.connect(close_modal)
	header_hbox.add_child(btn_x)
	main_vbox.add_child(header_hbox)

	var sep = HSeparator.new()
	main_vbox.add_child(sep)

	# --- CORPS DU MODAL : Catégories à gauche + Contenu à droite ---
	var body_hbox = HBoxContainer.new()
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.add_theme_constant_override("separation", 14)

	# Colonne Gauche : Navigation des Catégories
	var left_scroll = ScrollContainer.new()
	left_scroll.custom_minimum_size = Vector2(215, 0)
	left_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	var cat_vbox = VBoxContainer.new()
	cat_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cat_vbox.add_theme_constant_override("separation", 5)

	var cat_title = Label.new()
	cat_title.text = "CATÉGORIES"
	cat_title.add_theme_font_size_override("font_size", 10)
	cat_title.add_theme_color_override("font_color", Color(0.5, 0.6, 0.75))
	cat_vbox.add_child(cat_title)

	category_buttons.clear()
	for i in range(CATEGORIES.size()):
		var cat_info = CATEGORIES[i]
		var btn = Button.new()
		btn.text = cat_info["label"]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 30)
		btn.add_theme_font_size_override("font_size", 11)
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		# Styles compacts et discrets
		var b_norm = StyleBoxFlat.new()
		b_norm.bg_color = Color(0.09, 0.13, 0.20, 0.7)
		b_norm.border_width_left = 3
		b_norm.border_color = Color.TRANSPARENT
		b_norm.set_corner_radius_all(4)
		b_norm.content_margin_left = 8
		b_norm.content_margin_right = 6
		btn.add_theme_stylebox_override("normal", b_norm)

		var b_hov = b_norm.duplicate()
		b_hov.bg_color = Color(0.14, 0.20, 0.32, 0.9)
		b_hov.border_color = Color("38bdf8")
		btn.add_theme_stylebox_override("hover", b_hov)

		var idx = i
		btn.pressed.connect(func():
			if not current_search_query.is_empty():
				current_search_query = ""
				if search_line_edit != null:
					search_line_edit.text = ""
			_switch_category(idx)
		)
		cat_vbox.add_child(btn)
		category_buttons.append(btn)

	left_scroll.add_child(cat_vbox)
	body_hbox.add_child(left_scroll)

	# Séparateur Vertical
	var v_sep = VSeparator.new()
	var v_style = StyleBoxLine.new()
	v_style.vertical = true
	v_style.color = Color(0.20, 0.28, 0.42, 0.6)
	v_style.thickness = 1
	v_sep.add_theme_stylebox_override("separator", v_style)
	body_hbox.add_child(v_sep)

	# Colonne Droite : Contenu / Résultats de Recherche
	content_scroll = ScrollContainer.new()
	content_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 10)
	content_scroll.add_child(content_container)

	body_hbox.add_child(content_scroll)
	main_vbox.add_child(body_hbox)

	# Bas de page
	var btm_hbox = HBoxContainer.new()
	btm_hbox.alignment = BoxContainer.ALIGNMENT_END
	var close_btn = Button.new()
	close_btn.text = "Fermer le guide"
	close_btn.custom_minimum_size = Vector2(140, 32)
	close_btn.modulate = Color("10b981")
	close_btn.pressed.connect(close_modal)
	btm_hbox.add_child(close_btn)
	main_vbox.add_child(btm_hbox)

	_switch_category(0)

func _on_search_text_changed(new_text: String) -> void:
	current_search_query = new_text.strip_edges()
	if current_search_query.is_empty():
		_switch_category(active_category_index)
	else:
		_render_search_results(current_search_query)

func _switch_category(index: int) -> void:
	if content_container == null:
		_build_ui()
	active_category_index = index

	# Mettre à jour l'apparence des boutons de catégorie
	for i in range(category_buttons.size()):
		var b = category_buttons[i]
		if i == index and current_search_query.is_empty():
			b.modulate = Color("38bdf8")
			var b_act = StyleBoxFlat.new()
			b_act.bg_color = Color(0.12, 0.20, 0.32, 0.95)
			b_act.border_width_left = 4
			b_act.border_color = Color("38bdf8")
			b_act.set_corner_radius_all(4)
			b_act.content_margin_left = 8
			b_act.content_margin_right = 6
			b.add_theme_stylebox_override("normal", b_act)
		else:
			b.modulate = Color("94a3b8")
			var b_norm = StyleBoxFlat.new()
			b_norm.bg_color = Color(0.09, 0.13, 0.20, 0.7)
			b_norm.border_width_left = 3
			b_norm.border_color = Color.TRANSPARENT
			b_norm.set_corner_radius_all(4)
			b_norm.content_margin_left = 8
			b_norm.content_margin_right = 6
			b.add_theme_stylebox_override("normal", b_norm)

	# Nettoyer le conteneur de contenu
	for child in content_container.get_children():
		child.queue_free()

	var cat_id = CATEGORIES[index]["id"]
	var cat_label = CATEGORIES[index]["label"]

	# En-tête de catégorie
	var cat_hdr = Label.new()
	cat_hdr.text = cat_label.to_upper()
	cat_hdr.add_theme_font_size_override("font_size", 14)
	cat_hdr.add_theme_color_override("font_color", Color("38bdf8"))
	content_container.add_child(cat_hdr)

	# Filtrer et afficher les sections de la catégorie
	for sec in HELP_SECTIONS:
		if sec["category_id"] == cat_id:
			_add_section(content_container, sec["title"], sec["body"])

	if content_scroll != null:
		content_scroll.scroll_vertical = 0

func _render_search_results(query: String) -> void:
	for child in content_container.get_children():
		child.queue_free()

	# Désactiver la surbrillance des catégories lors d'une recherche
	for b in category_buttons:
		b.modulate = Color("94a3b8")

	var q = query.to_lower()
	var matches: Array[Dictionary] = []

	for sec in HELP_SECTIONS:
		var match_title = sec["title"].to_lower().contains(q)
		var match_body = sec["body"].to_lower().contains(q)
		var match_cat = sec["category_label"].to_lower().contains(q)
		if match_title or match_body or match_cat:
			matches.append(sec)

	# En-tête des résultats
	var res_hdr = Label.new()
	if matches.is_empty():
		res_hdr.text = "❌ Aucun résultat trouvé pour « %s »" % query
		res_hdr.add_theme_color_override("font_color", Color("f87171"))
	else:
		res_hdr.text = "🔍 %d sujet%s trouvé%s pour « %s » :" % [
			matches.size(),
			("s" if matches.size() > 1 else ""),
			("s" if matches.size() > 1 else ""),
			query
		]
		res_hdr.add_theme_color_override("font_color", Color("facc15"))
	res_hdr.add_theme_font_size_override("font_size", 14)
	content_container.add_child(res_hdr)

	if matches.is_empty():
		var empty_panel = PanelContainer.new()
		var ep_style = StyleBoxFlat.new()
		ep_style.bg_color = Color(0.10, 0.14, 0.22, 0.8)
		ep_style.set_corner_radius_all(8)
		ep_style.content_margin_left = 14
		ep_style.content_margin_right = 14
		ep_style.content_margin_top = 14
		ep_style.content_margin_bottom = 14
		empty_panel.add_theme_stylebox_override("panel", ep_style)

		var empty_vbox = VBoxContainer.new()
		empty_vbox.add_theme_constant_override("separation", 8)

		var hint_lbl = Label.new()
		hint_lbl.text = "Aucun article de l'aide ne correspond à votre mot-clé.\nEssayez avec des termes courants tels que :\n• 'forme', 'rotation', 'tactique', 'notes'\n• 'sponsor', 'budget', 'billetterie', 'ffp'\n• 'mercato', 'transfert', 'centre', 'playoff'"
		hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hint_lbl.add_theme_font_size_override("font_size", 12)
		hint_lbl.add_theme_color_override("font_color", Color("cbd5e1"))
		empty_vbox.add_child(hint_lbl)

		var btn_clear = Button.new()
		btn_clear.text = "Effacer la recherche et revenir aux catégories"
		btn_clear.custom_minimum_size = Vector2(250, 32)
		btn_clear.pressed.connect(func():
			if search_line_edit != null:
				search_line_edit.text = ""
			current_search_query = ""
			_switch_category(active_category_index)
		)
		empty_vbox.add_child(btn_clear)
		empty_panel.add_child(empty_vbox)
		content_container.add_child(empty_panel)
	else:
		for sec in matches:
			_add_section(content_container, sec["title"], sec["body"], sec["category_label"])

	if content_scroll != null:
		content_scroll.scroll_vertical = 0

func _add_section(parent: VBoxContainer, title_text: String, body_text: String, category_tag: String = "") -> void:
	var sec_panel = PanelContainer.new()
	var sec_style = StyleBoxFlat.new()
	sec_style.bg_color = Color(0.10, 0.14, 0.22, 0.95)
	sec_style.set_corner_radius_all(8)
	sec_style.border_width_left = 3
	sec_style.border_width_top = 1
	sec_style.border_width_right = 1
	sec_style.border_width_bottom = 1
	sec_style.border_color = Color("38bdf8") if not category_tag.is_empty() else Color(0.22, 0.32, 0.48, 0.7)
	sec_style.content_margin_left = 14
	sec_style.content_margin_right = 14
	sec_style.content_margin_top = 10
	sec_style.content_margin_bottom = 10
	sec_panel.add_theme_stylebox_override("panel", sec_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)

	if not category_tag.is_empty():
		var tag_lbl = Label.new()
		tag_lbl.text = "📁 %s" % category_tag
		tag_lbl.add_theme_font_size_override("font_size", 10)
		tag_lbl.add_theme_color_override("font_color", Color("38bdf8"))
		vbox.add_child(tag_lbl)

	var stitle = Label.new()
	stitle.text = title_text
	stitle.add_theme_font_size_override("font_size", 13)
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
