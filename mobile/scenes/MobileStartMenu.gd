class_name MobileStartMenu
extends Control

const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")
const ClubBadge = preload("res://scripts/ClubBadge.gd")
const AppVersion = preload("res://scripts/AppVersion.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")
const MobileOptionsMenuModal = preload("res://scenes/widgets/MobileOptionsMenuModal.gd")

var options_modal: MobileOptionsMenuModal
var new_game_panel: PanelContainer

# Données pour Nouvelle Carrière
var generated_world: Dictionary = {}
var all_leagues: Array[League] = []
var market: TransferMarket = null
var current_selected_club: Club = null
var current_selected_league: League = null

var opt_country: OptionButton
var opt_division: OptionButton
var clubs_container: VBoxContainer
var lbl_selected_club: Label
var btn_launch_new_game: Button

func _ready() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	_build_ui()

	options_modal = MobileOptionsMenuModal.new()
	add_child(options_modal)

func _build_ui() -> void:
	for c in get_children():
		c.queue_free()

	# Fond Futsal sombre
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.11, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 20)
	main_vbox.add_theme_constant_override("margin_left", 20)
	main_vbox.add_theme_constant_override("margin_right", 20)
	main_vbox.add_theme_constant_override("margin_top", 16)
	main_vbox.add_theme_constant_override("margin_bottom", 20)

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)
	margin.add_child(main_vbox)

	# 1. En-tête supérieur : Version Git & Roulette d'options ⚙️
	var top_row = HBoxContainer.new()
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(top_row)

	var ver_badge = AppVersion.create_version_badge(true)
	ver_badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(ver_badge)

	# Bouton Roulette d'options ⚙️
	var btn_options_cog = Button.new()
	btn_options_cog.text = "⚙️"
	btn_options_cog.tooltip_text = "Options audio & musique"
	btn_options_cog.custom_minimum_size = Vector2(48, 44)
	btn_options_cog.add_theme_font_size_override("font_size", 18)
	var sb_cog = StyleBoxFlat.new()
	sb_cog.bg_color = Color(0.10, 0.16, 0.26, 0.90)
	sb_cog.border_color = Color("38bdf8")
	sb_cog.set_border_width_all(1)
	sb_cog.set_corner_radius_all(8)
	btn_options_cog.add_theme_stylebox_override("normal", sb_cog)
	btn_options_cog.pressed.connect(func(): options_modal.open_modal(false))
	top_row.add_child(btn_options_cog)

	# Espace vertical
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size.y = 20
	main_vbox.add_child(spacer_top)

	# 2. Hero Title & Logo Mercato 5
	var hero_box = VBoxContainer.new()
	hero_box.add_theme_constant_override("separation", 6)
	hero_box.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(hero_box)

	var lbl_hero_badge = Label.new()
	lbl_hero_badge.text = "⚡ FUTSAL MANAGEMENT"
	lbl_hero_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hero_badge.add_theme_font_size_override("font_size", 13)
	lbl_hero_badge.add_theme_color_override("font_color", Color("38bdf8"))
	hero_box.add_child(lbl_hero_badge)

	var lbl_title = Label.new()
	lbl_title.text = "MERCATO 5"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 38)
	lbl_title.add_theme_color_override("font_color", Color("facc15"))
	hero_box.add_child(lbl_title)

	var lbl_subtitle = Label.new()
	lbl_subtitle.text = "Bâtissez votre 5 majeur de légende"
	lbl_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_subtitle.add_theme_font_size_override("font_size", 13)
	lbl_subtitle.add_theme_color_override("font_color", Color("94a3b8"))
	hero_box.add_child(lbl_subtitle)

	# Espace
	var spacer_mid = Control.new()
	spacer_mid.custom_minimum_size.y = 15
	main_vbox.add_child(spacer_mid)

	# 3. Section Sauvegarde Existante (si disponible)
	if SaveManager.has_save():
		var save_info = SaveManager.get_save_info()
		var card = PanelContainer.new()
		var sb_c = StyleBoxFlat.new()
		sb_c.bg_color = Color(0.08, 0.13, 0.22, 0.95)
		sb_c.border_color = Color("34d399")
		sb_c.set_border_width_all(2)
		sb_c.set_corner_radius_all(14)
		sb_c.content_margin_left = 16
		sb_c.content_margin_right = 16
		sb_c.content_margin_top = 14
		sb_c.content_margin_bottom = 14
		card.add_theme_stylebox_override("panel", sb_c)
		main_vbox.add_child(card)

		var card_vbox = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 10)
		card.add_child(card_vbox)

		var save_row = HBoxContainer.new()
		save_row.add_theme_constant_override("separation", 12)
		card_vbox.add_child(save_row)

		var badge = ClubBadge.new()
		badge.custom_minimum_size = Vector2(48, 48)
		badge.shape = save_info.get("badge_shape", 0)
		badge.symbol = save_info.get("badge_symbol", 1)
		badge.primary_color = Color(save_info.get("primary_color", "#1e293b"))
		badge.secondary_color = Color(save_info.get("secondary_color", "#38bdf8"))
		save_row.add_child(badge)

		var info_col = VBoxContainer.new()
		info_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		save_row.add_child(info_col)

		var lbl_cname = Label.new()
		lbl_cname.text = save_info.get("club_name", "Mon Club")
		lbl_cname.add_theme_font_size_override("font_size", 16)
		lbl_cname.add_theme_color_override("font_color", Color("f8fafc"))
		info_col.add_child(lbl_cname)

		var lbl_csub = Label.new()
		lbl_csub.text = "%s • Division %d • J%d" % [
			save_info.get("country", "France"),
			save_info.get("division", 1),
			save_info.get("matchday", 1)
		]
		lbl_csub.add_theme_font_size_override("font_size", 12)
		lbl_csub.add_theme_color_override("font_color", Color("94a3b8"))
		info_col.add_child(lbl_csub)

		var lbl_cbudget = Label.new()
		lbl_cbudget.text = "Trésorerie : %s €" % FormatUtils.format_number(save_info.get("budget", 100_000))
		lbl_cbudget.add_theme_font_size_override("font_size", 12)
		lbl_cbudget.add_theme_color_override("font_color", Color("34d399"))
		info_col.add_child(lbl_cbudget)

		# Gros Bouton Tactile "CONTINUER"
		var btn_continue = Button.new()
		btn_continue.text = "▶ CONTINUER LA CARRIÈRE"
		btn_continue.custom_minimum_size.y = 54.0
		btn_continue.add_theme_font_size_override("font_size", 16)
		var sb_cont = StyleBoxFlat.new()
		sb_cont.bg_color = Color(0.08, 0.52, 0.35, 0.95)
		sb_cont.border_color = Color("34d399")
		sb_cont.set_border_width_all(2)
		sb_cont.set_corner_radius_all(10)
		btn_continue.add_theme_stylebox_override("normal", sb_cont)
		btn_continue.pressed.connect(_on_continue_pressed)
		card_vbox.add_child(btn_continue)

	# 4. Boutons Principaux
	var menu_vbox = VBoxContainer.new()
	menu_vbox.add_theme_constant_override("separation", 12)
	menu_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(menu_vbox)

	var btn_new = _create_menu_button("⚡ NOUVELLE CARRIÈRE", Color(0.12, 0.25, 0.45, 0.95), Color("38bdf8"))
	btn_new.pressed.connect(_open_new_game_picker)
	menu_vbox.add_child(btn_new)

	var btn_options = _create_menu_button("⚙️ OPTIONS & AUDIO", Color(0.10, 0.15, 0.25, 0.90), Color(0.30, 0.42, 0.60))
	btn_options.pressed.connect(func(): options_modal.open_modal(false))
	menu_vbox.add_child(btn_options)

	var btn_quit = _create_menu_button("❌ QUITTER", Color(0.20, 0.08, 0.10, 0.90), Color("f87171"))
	btn_quit.pressed.connect(func(): get_tree().quit())
	menu_vbox.add_child(btn_quit)

	# 5. Overlay Sélecteur de Club pour Nouvelle Carrière
	_build_new_game_modal()

func _create_menu_button(text: String, bg_col: Color, border_col: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size.y = 52.0
	btn.add_theme_font_size_override("font_size", 15)
	btn.focus_mode = Control.FOCUS_NONE

	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_col
	sb.border_color = border_col
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("normal", sb)

	var sbp = StyleBoxFlat.new()
	sbp.bg_color = bg_col.lightened(0.15)
	sbp.border_color = border_col
	sbp.set_border_width_all(2)
	sbp.set_corner_radius_all(10)
	btn.add_theme_stylebox_override("pressed", sbp)

	return btn

func _build_new_game_modal() -> void:
	new_game_panel = PanelContainer.new()
	new_game_panel.visible = false
	new_game_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var sb_overlay = StyleBoxFlat.new()
	sb_overlay.bg_color = Color(0.04, 0.06, 0.11, 0.98)
	sb_overlay.content_margin_left = 16
	sb_overlay.content_margin_right = 16
	sb_overlay.content_margin_top = 16
	sb_overlay.content_margin_bottom = 16
	new_game_panel.add_theme_stylebox_override("panel", sb_overlay)
	add_child(new_game_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	new_game_panel.add_child(vbox)

	# Header
	var h_row = HBoxContainer.new()
	vbox.add_child(h_row)

	var t_lbl = Label.new()
	t_lbl.text = "⚡ NOUVELLE CARRIÈRE — CHOIX DU CLUB"
	t_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t_lbl.add_theme_font_size_override("font_size", 14)
	t_lbl.add_theme_color_override("font_color", Color("facc15"))
	h_row.add_child(t_lbl)

	var btn_close_ng = Button.new()
	btn_close_ng.text = "✖ Fermer"
	btn_close_ng.custom_minimum_size = Vector2(80, 36)
	btn_close_ng.pressed.connect(func(): new_game_panel.visible = false)
	h_row.add_child(btn_close_ng)

	# Sélecteurs Pays & Division
	var filter_row = HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 8)
	vbox.add_child(filter_row)

	opt_country = OptionButton.new()
	opt_country.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt_country.custom_minimum_size.y = 44.0
	opt_country.item_selected.connect(_on_country_or_div_changed)
	filter_row.add_child(opt_country)

	opt_division = OptionButton.new()
	opt_division.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opt_division.custom_minimum_size.y = 44.0
	opt_division.add_item("Division 1")
	opt_division.add_item("Division 2")
	opt_division.item_selected.connect(_on_country_or_div_changed)
	filter_row.add_child(opt_division)

	# Club sélectionné en surbrillance
	lbl_selected_club = Label.new()
	lbl_selected_club.text = "Sélectionnez un club ci-dessous pour démarrer :"
	lbl_selected_club.add_theme_font_size_override("font_size", 12)
	lbl_selected_club.add_theme_color_override("font_color", Color("38bdf8"))
	vbox.add_child(lbl_selected_club)

	# Liste des clubs scrollable
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	clubs_container = VBoxContainer.new()
	clubs_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clubs_container.add_theme_constant_override("separation", 6)
	scroll.add_child(clubs_container)

	# Bouton Démarrer
	btn_launch_new_game = Button.new()
	btn_launch_new_game.text = "⚽ DÉMARRER LA NOUVELLE CARRIÈRE"
	btn_launch_new_game.custom_minimum_size.y = 52.0
	btn_launch_new_game.disabled = true
	var sb_start = StyleBoxFlat.new()
	sb_start.bg_color = Color(0.08, 0.52, 0.35, 0.95)
	sb_start.border_color = Color("34d399")
	sb_start.set_border_width_all(2)
	sb_start.set_corner_radius_all(10)
	btn_launch_new_game.add_theme_stylebox_override("normal", sb_start)
	btn_launch_new_game.pressed.connect(_on_launch_new_game_pressed)
	vbox.add_child(btn_launch_new_game)

func _open_new_game_picker() -> void:
	if generated_world.is_empty():
		generated_world = GameWorld.create_default_world()
		all_leagues = generated_world["all_leagues"]
		market = generated_world["market"]

	opt_country.clear()
	var countries = []
	for l in all_leagues:
		if not countries.has(l.country):
			countries.append(l.country)

	for c in countries:
		var code = "INT"
		match c:
			"France": code = "FRA"
			"Espagne": code = "ESP"
			"Italie": code = "ITA"
			"Portugal": code = "POR"
			"Angleterre": code = "ENG"
			"Allemagne": code = "ALL"
		opt_country.add_item("[%s] %s" % [code, c])

	_update_clubs_list()
	new_game_panel.visible = true

func _on_country_or_div_changed(_idx: int) -> void:
	_update_clubs_list()

func _update_clubs_list() -> void:
	for c in clubs_container.get_children():
		c.queue_free()

	if all_leagues.is_empty():
		return

	var country_idx = opt_country.selected
	var country_name = opt_country.get_item_text(country_idx).split(" ")[-1]
	var div_num = opt_division.selected + 1

	var target_league: League = null
	for l in all_leagues:
		if l.country == country_name and l.division == div_num:
			target_league = l
			break

	if target_league == null:
		target_league = all_leagues[0]

	current_selected_league = target_league

	for cl in target_league.clubs:
		var btn = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size.y = 50.0
		btn.text = "%s  —  Trésorerie: %s €  (%d joueurs)" % [
			cl.club_name,
			FormatUtils.format_number(cl.budget),
			cl.squad.size()
		]
		btn.add_theme_font_size_override("font_size", 13)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.12, 0.20, 0.90)
		sb.border_color = Color(0.20, 0.30, 0.45, 0.6)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 12
		btn.add_theme_stylebox_override("normal", sb)

		var this_club = cl
		btn.pressed.connect(func():
			current_selected_club = this_club
			lbl_selected_club.text = "Club choisi : %s (Div %d • %s)" % [this_club.club_name, this_club.division, this_club.country]
			btn_launch_new_game.disabled = false
		)
		clubs_container.add_child(btn)

func _on_continue_pressed() -> void:
	GameGlobal.clear_transitions()
	get_tree().change_scene_to_file("res://scenes/MobileMain.tscn")

func _on_launch_new_game_pressed() -> void:
	if current_selected_club == null or current_selected_league == null:
		return

	# Configurer le club joueur
	current_selected_club.is_user_controlled = true

	GameGlobal.clear_transitions()
	GameGlobal.new_game_selected_club = current_selected_club
	GameGlobal.new_game_selected_league = current_selected_league
	GameGlobal.new_game_all_leagues = all_leagues
	GameGlobal.new_game_market = market

	get_tree().change_scene_to_file("res://scenes/MobileMain.tscn")
