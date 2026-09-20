extends Control

const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")
const ClubBadge = preload("res://scripts/ClubBadge.gd")
const OptionsMenuModal = preload("res://scenes/OptionsMenuModal.gd")

@onready var main_view: Control = $MainView
@onready var btn_continue: Button = $MainView/VBox/MenuButtons/BtnContinue
@onready var card_continue_info: PanelContainer = $MainView/VBox/MenuButtons/ContinueInfoCard
@onready var lbl_save_summary: Label = $MainView/VBox/MenuButtons/ContinueInfoCard/HBox/VBox/LabelSaveSummary
@onready var save_badge: ClubBadge = $MainView/VBox/MenuButtons/ContinueInfoCard/HBox/SaveBadge
@onready var btn_new_game: Button = $MainView/VBox/MenuButtons/BtnNewGame
@onready var btn_load: Button = $MainView/VBox/MenuButtons/BtnLoad
@onready var btn_options: Button = $MainView/VBox/MenuButtons/BtnOptions
@onready var btn_quit: Button = $MainView/VBox/MenuButtons/BtnQuit
@onready var options_modal: OptionsMenuModal = $OptionsMenuModal

@onready var club_select_view: Control = $ClubSelectView
@onready var btn_back_to_menu: Button = $ClubSelectView/VBox/Header/BtnBackToMenu
@onready var opt_country: OptionButton = $ClubSelectView/VBox/Header/OptCountry
@onready var opt_division: OptionButton = $ClubSelectView/VBox/Header/OptDivision

@onready var club_list_container: VBoxContainer = $ClubSelectView/VBox/Split/ClubsListScroll/ClubsList
@onready var preview_badge: ClubBadge = $ClubSelectView/VBox/Split/ClubDetailPanel/VBox/Header/PreviewBadge
@onready var lbl_preview_name: Label = $ClubSelectView/VBox/Split/ClubDetailPanel/VBox/Header/Info/LabelClubName
@onready var lbl_preview_sub: Label = $ClubSelectView/VBox/Split/ClubDetailPanel/VBox/Header/Info/LabelClubSub
@onready var lbl_preview_budget: Label = $ClubSelectView/VBox/Split/ClubDetailPanel/VBox/Header/Info/LabelClubBudget
@onready var preview_squad_list: VBoxContainer = $ClubSelectView/VBox/Split/ClubDetailPanel/VBox/RosterScroll/RosterList
@onready var btn_start_with_club: Button = $ClubSelectView/VBox/Split/ClubDetailPanel/VBox/BtnStartWithClub

var generated_world: Dictionary = {}
var all_leagues: Array[League] = []
var market: TransferMarket = null
var current_selected_club: Club = null
var current_selected_league: League = null

func _ready() -> void:
	_check_save_state()
	_show_main_view()

	btn_continue.pressed.connect(_on_btn_continue_pressed)
	btn_new_game.pressed.connect(_on_btn_new_game_pressed)
	btn_load.pressed.connect(_on_btn_continue_pressed)
	btn_options.pressed.connect(func(): options_modal.open_modal())
	btn_quit.pressed.connect(func(): get_tree().quit())

	btn_back_to_menu.pressed.connect(_show_main_view)
	btn_start_with_club.pressed.connect(_on_btn_start_with_club_pressed)

func _check_save_state() -> void:
	if SaveManager.has_save():
		var info = SaveManager.get_save_info()
		btn_continue.disabled = false
		btn_load.disabled = false
		card_continue_info.visible = true
		lbl_save_summary.text = "%s (%s, Div %d) - J%d | Budget: %s €" % [
			info.get("club_name", "Mon Club"),
			info.get("country", "France"),
			info.get("division", 1),
			info.get("matchday", 1),
			FormatUtils.format_number(info.get("budget", 100_000))
		]
		save_badge.shape = info.get("badge_shape", 0)
		save_badge.symbol = info.get("badge_symbol", 1)
		save_badge.primary_color = Color(info.get("primary_color", "#1e293b"))
		save_badge.secondary_color = Color(info.get("secondary_color", "#38bdf8"))
		save_badge.queue_redraw()
	else:
		btn_continue.disabled = true
		btn_load.disabled = true
		card_continue_info.visible = false

func _show_main_view() -> void:
	main_view.visible = true
	club_select_view.visible = false
	_check_save_state()

func _get_game_global() -> Node:
	if is_inside_tree() and get_tree() != null and get_tree().root != null:
		return get_tree().root.get_node_or_null("GameGlobal")
	return null

func _on_btn_continue_pressed() -> void:
	if not SaveManager.has_save():
		return
	var save_data = SaveManager.load_game()
	if save_data.is_empty():
		return
	var global_ref = _get_game_global()
	if global_ref != null:
		global_ref.clear_transitions()
		global_ref.loaded_save_data = save_data
	get_tree().change_scene_to_file("res://scenes/Dashboard.tscn")

func _on_btn_new_game_pressed() -> void:
	if all_leagues.is_empty():
		generated_world = GameWorld.create_default_world()
		all_leagues = generated_world["all_leagues"]
		market = generated_world["market"]

	main_view.visible = false
	club_select_view.visible = true
	_init_club_selection_filters()

func _init_club_selection_filters() -> void:
	opt_country.clear()
	var countries = ["France", "Espagne", "Italie", "Portugal", "Angleterre", "Allemagne"]
	for c in countries:
		var fl = "🌍"
		match c:
			"France": fl = "🇫🇷"
			"Espagne": fl = "🇪🇸"
			"Italie": fl = "🇮🇹"
			"Portugal": fl = "🇵🇹"
			"Angleterre": fl = "🇬🇧"
			"Allemagne": fl = "🇩🇪"
		opt_country.add_item("%s %s" % [fl, c])

	opt_division.clear()
	opt_division.add_item("Division 1 Élite")
	opt_division.add_item("Division 2 Pro")
	opt_division.add_item("Division 3 Régionale")

	opt_country.select(0)
	opt_division.select(0)

	if not opt_country.item_selected.is_connected(_on_filter_changed):
		opt_country.item_selected.connect(_on_filter_changed)
	if not opt_division.item_selected.is_connected(_on_filter_changed):
		opt_division.item_selected.connect(_on_filter_changed)

	_update_clubs_list()

func _on_filter_changed(_idx: int) -> void:
	_update_clubs_list()

func _update_clubs_list() -> void:
	for child in club_list_container.get_children():
		child.queue_free()

	var countries = ["France", "Espagne", "Italie", "Portugal", "Angleterre", "Allemagne"]
	var selected_country = countries[clamp(opt_country.selected, 0, countries.size() - 1)]
	var target_div = clamp(opt_division.selected + 1, 1, 3)

	var matching_league: League = null
	for l in all_leagues:
		if l.country == selected_country and l.division == target_div:
			matching_league = l
			break

	if matching_league == null and not all_leagues.is_empty():
		matching_league = all_leagues[0]

	current_selected_league = matching_league
	if matching_league == null or matching_league.clubs.is_empty():
		return

	for c in matching_league.clubs:
		var card = _create_club_card(c)
		club_list_container.add_child(card)

	# Sélectionner par défaut le premier club
	_select_club(matching_league.clubs[0])

func _create_club_card(c: Club) -> PanelContainer:
	var panel = PanelContainer.new()
	var is_selected = (c == current_selected_club)

	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.17, 0.28, 0.85) if is_selected else Color(0.08, 0.11, 0.19, 0.6)
	if is_selected:
		sb.border_color = Color("38bdf8")
		sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	var badge = ClubBadge.new()
	badge.custom_minimum_size = Vector2(32, 32)
	badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	badge.shape = c.badge_shape
	badge.symbol = c.badge_symbol
	badge.primary_color = c.primary_color
	badge.secondary_color = c.secondary_color

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_lbl = Label.new()
	name_lbl.text = c.club_name
	name_lbl.add_theme_font_size_override("font_size", 15)

	var sub_lbl = Label.new()
	sub_lbl.text = "Budget: %s € | %d joueurs" % [FormatUtils.format_number(c.budget), c.squad.size()]
	sub_lbl.modulate = Color(0.75, 0.82, 0.92)
	sub_lbl.add_theme_font_size_override("font_size", 12)

	vbox.add_child(name_lbl)
	vbox.add_child(sub_lbl)

	hbox.add_child(badge)
	hbox.add_child(vbox)
	panel.add_child(hbox)

	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_select_club(c)
	)

	return panel

func _select_club(c: Club) -> void:
	current_selected_club = c

	preview_badge.shape = c.badge_shape
	preview_badge.symbol = c.badge_symbol
	preview_badge.primary_color = c.primary_color
	preview_badge.secondary_color = c.secondary_color
	preview_badge.queue_redraw()

	lbl_preview_name.text = c.club_name
	var fl = "🇫🇷"
	match c.country:
		"France": fl = "🇫🇷"
		"Espagne": fl = "🇪🇸"
		"Italie": fl = "🇮🇹"
		"Portugal": fl = "🇵🇹"
		"Angleterre": fl = "🇬🇧"

	lbl_preview_sub.text = "%s %s (Division %d)" % [fl, c.country, c.division]
	lbl_preview_budget.text = "💰 Budget de départ : %s €" % FormatUtils.format_number(c.budget)

	# Afficher l'effectif
	for ch in preview_squad_list.get_children():
		ch.queue_free()

	for p in c.squad:
		var p_lbl = Label.new()
		var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
		p_lbl.text = "[%s] %s (%da) - OVR %d" % [pos_str, p.full_name, p.age, p.get_overall()]
		p_lbl.add_theme_font_size_override("font_size", 13)
		if c.starting_five.has(p):
			p_lbl.modulate = Color("facc15")
		else:
			p_lbl.modulate = Color("94a3b8")
		preview_squad_list.add_child(p_lbl)

	btn_start_with_club.text = "🚀 Prendre les rênes de %s" % c.club_name

func _on_btn_start_with_club_pressed() -> void:
	if current_selected_club == null:
		return

	var global_ref = _get_game_global()
	if global_ref != null:
		global_ref.clear_transitions()
		global_ref.new_game_selected_club = current_selected_club
		global_ref.new_game_selected_league = current_selected_league
		global_ref.new_game_all_leagues = all_leagues
		global_ref.new_game_market = market

	get_tree().change_scene_to_file("res://scenes/Dashboard.tscn")
