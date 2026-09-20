extends Control

const Tactics = preload("res://scripts/Tactics.gd")
const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")
const PlayerDetailModal = preload("res://scenes/PlayerDetailModal.gd")
const PreMatchModal = preload("res://scenes/PreMatchModal.gd")
const SeasonManager = preload("res://scripts/SeasonManager.gd")
const SeasonEndModal = preload("res://scenes/SeasonEndModal.gd")
const TrophyModal = preload("res://scenes/TrophyModal.gd")
const OptionsMenuModal = preload("res://scenes/OptionsMenuModal.gd")
const HelpModal = preload("res://scenes/HelpModal.gd")
const ClubTransferModal = preload("res://scenes/ClubTransferModal.gd")
const SponsorNegotiationModal = preload("res://scenes/SponsorNegotiationModal.gd")

var player_club: Club
var current_league: League
var viewed_league: League
var viewed_club: Club = null
var all_leagues: Array[League] = []
var market: TransferMarket
var inspected_player: Player = null
var current_season: int = 1
var season_end_modal: SeasonEndModal = null
var trophy_modal: TrophyModal = null
var options_modal: OptionsMenuModal = null
var help_modal: HelpModal = null
var club_transfer_modal: ClubTransferModal = null
var sponsor_negotiation_modal: SponsorNegotiationModal = null

@onready var user_club_badge: ClubBadge = $TopBar/HBoxContainer/UserClubBadge
@onready var label_club: Label = $TopBar/HBoxContainer/ClubNameLabel
@onready var label_budget: Label = $TopBar/HBoxContainer/BudgetLabel
@onready var label_week: Label = $TopBar/HBoxContainer/WeekLabel
@onready var tactic_label: Label = $TopBar/HBoxContainer/TacticLabel
@onready var btn_help: Button = $TopBar/HBoxContainer/BtnHelp
@onready var btn_options: Button = $TopBar/HBoxContainer/BtnOptions
@onready var btn_save: Button = $TopBar/HBoxContainer/BtnSave
@onready var btn_main_menu: Button = $TopBar/HBoxContainer/BtnMainMenu
@onready var btn_advance: Button = $TopBar/HBoxContainer/BtnAdvance

@onready var btn_tab_squad: Button = $Body/SideNav/VBoxContainer/BtnTabSquad
@onready var btn_tab_market: Button = $Body/SideNav/VBoxContainer/BtnTabMarket
@onready var btn_tab_formation: Button = $Body/SideNav/VBoxContainer/BtnTabFormation
@onready var btn_tab_standings: Button = $Body/SideNav/VBoxContainer/BtnTabStandings
@onready var btn_tab_economy: Button = $Body/SideNav/VBoxContainer/BtnTabEconomy
@onready var btn_tab_inbox: Button = $Body/SideNav/VBoxContainer/BtnTabInbox

@onready var tab_squad: Control = $Body/MainContent/TabSquad
@onready var tab_market: Control = $Body/MainContent/TabMarket
@onready var tab_formation: Control = $Body/MainContent/TabFormation
@onready var youth_list: VBoxContainer = $Body/MainContent/TabFormation/ScrollFormation/YouthList
@onready var btn_scout_youth: Button = $Body/MainContent/TabFormation/FormationHeader/BtnScoutYouth
@onready var tab_standings: Control = $Body/MainContent/TabStandings
@onready var tab_economy: Control = $Body/MainContent/TabEconomy
@onready var economy_content: VBoxContainer = $Body/MainContent/TabEconomy/EconomyContent
@onready var tab_inbox: Control = $Body/MainContent/TabInbox

var selected_swap_player: Player = null

@onready var pitch: Control = $Body/MainContent/TabSquad/PitchPanel/VBoxContainer/Pitch
@onready var label_pitch_sub: Label = $Body/MainContent/TabSquad/PitchPanel/VBoxContainer/LabelPitchSub
@onready var bench_list: VBoxContainer = $Body/MainContent/TabSquad/BenchPanel/VBoxContainer/ScrollContainer/BenchList
@onready var label_bench_title: Label = $Body/MainContent/TabSquad/BenchPanel/VBoxContainer/BenchHeader/LabelBenchTitle
@onready var btn_auto_lineup: Button = $Body/MainContent/TabSquad/BenchPanel/VBoxContainer/BenchHeader/BtnAutoLineup

@onready var opt_tactic_style: OptionButton = $Body/MainContent/TabSquad/TacticsPanel/ScrollContainer/VBoxContainer/OptionTacticsStyle
@onready var lbl_style_desc: Label = $Body/MainContent/TabSquad/TacticsPanel/ScrollContainer/VBoxContainer/LabelStyleDesc
@onready var opt_training_focus: OptionButton = $Body/MainContent/TabSquad/TacticsPanel/ScrollContainer/VBoxContainer/OptionTrainingFocus
@onready var lbl_training_desc: Label = $Body/MainContent/TabSquad/TacticsPanel/ScrollContainer/VBoxContainer/LabelTrainingDesc
@onready var inspector_content: VBoxContainer = $Body/MainContent/TabSquad/TacticsPanel/ScrollContainer/VBoxContainer/InspectorCard/InspectorContent

@onready var opt_market_country: OptionButton = $Body/MainContent/TabMarket/MarketHeader/OptMarketCountry
@onready var opt_market_pos: OptionButton = $Body/MainContent/TabMarket/MarketHeader/OptMarketPos

@onready var opt_country: OptionButton = $Body/MainContent/TabStandings/LeagueNavHeader/OptionCountry
@onready var opt_league: OptionButton = $Body/MainContent/TabStandings/LeagueNavHeader/OptionLeague
@onready var btn_european_cup: Button = $Body/MainContent/TabStandings/LeagueNavHeader/BtnEuropeanCup
@onready var btn_my_league: Button = $Body/MainContent/TabStandings/LeagueNavHeader/BtnMyLeague
@onready var label_standings_title: Label = $Body/MainContent/TabStandings/StandingsSplit/StandingsCol/LabelStandings
@onready var standings_tree: Tree = $Body/MainContent/TabStandings/StandingsSplit/StandingsCol/StandingsTree
@onready var club_detail_badge: ClubBadge = $Body/MainContent/TabStandings/StandingsSplit/ClubRosterPanel/VBoxContainer/ClubHeader/ClubDetailBadge
@onready var label_club_detail_name: Label = $Body/MainContent/TabStandings/StandingsSplit/ClubRosterPanel/VBoxContainer/ClubHeader/ClubInfoBox/LabelClubDetailName
@onready var label_club_detail_sub: Label = $Body/MainContent/TabStandings/StandingsSplit/ClubRosterPanel/VBoxContainer/ClubHeader/ClubInfoBox/LabelClubDetailSub
@onready var club_roster_list: VBoxContainer = $Body/MainContent/TabStandings/StandingsSplit/ClubRosterPanel/VBoxContainer/RosterScroll/ClubRosterList

@onready var match_view: Control = $MatchModal/MatchView
@onready var match_modal: Control = $MatchModal
@onready var player_detail_modal: PlayerDetailModal = $PlayerDetailModal
@onready var pre_match_modal: PreMatchModal = $PreMatchModal

const EuropeanCup = preload("res://scripts/EuropeanCup.gd")
var active_european_cup: EuropeanCup = null
var is_viewing_european_cup: bool = false

@onready var notification_toast: PanelContainer = $NotificationToast
@onready var label_toast: Label = $NotificationToast/LabelToast

@onready var negotiation_modal: Control = $NegotiationModal
@onready var nego_badge: ClubBadge = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/PlayerSummaryPanel/HBox/NegoBadge
@onready var label_nego_name: Label = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/PlayerSummaryPanel/HBox/VBox/LabelNegoPlayerName
@onready var label_nego_stats: Label = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/PlayerSummaryPanel/HBox/VBox/LabelNegoPlayerStats
@onready var label_wage_val: Label = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/WageRow/HBox/LabelWageVal
@onready var slider_wage: HSlider = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/WageRow/SliderWage
@onready var label_bonus_val: Label = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/BonusRow/HBox/LabelBonusVal
@onready var slider_bonus: HSlider = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/BonusRow/SliderBonus
@onready var opt_contract_years: OptionButton = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/YearsRow/OptionContractYears
@onready var transfer_fee_row: VBoxContainer = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/TransferFeeRow
@onready var label_fee_val: Label = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/TransferFeeRow/HBox/LabelFeeVal
@onready var slider_fee: HSlider = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/TransferFeeRow/SliderFee
@onready var label_agent_dialogue: Label = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/AgentReactionBox/VBox/HBox/LabelAgentDialogue
@onready var progress_mood: ProgressBar = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/AgentReactionBox/VBox/HBoxMood/ProgressMood
@onready var label_mood_text: Label = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/AgentReactionBox/VBox/HBoxMood/LabelMoodText
@onready var btn_propose_offer: Button = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/ActionButtons/BtnProposeOffer
@onready var btn_accept_demands: Button = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/ActionButtons/BtnAcceptDemands
@onready var btn_cancel_nego: Button = $NegotiationModal/CenterContainer/PanelContainer/VBoxContainer/ActionButtons/BtnCancelNego

var current_nego_player: Player = null
var current_nego_seller: Club = null
var toast_tween: Tween = null

func _ready() -> void:
	PlayerGenerator.reset_registry()
	season_end_modal = SeasonEndModal.new()
	add_child(season_end_modal)
	season_end_modal.new_season_started.connect(_on_new_season_started)
	trophy_modal = TrophyModal.new()
	add_child(trophy_modal)
	trophy_modal.trophy_acknowledged.connect(_on_trophy_acknowledged)
	options_modal = OptionsMenuModal.new()
	add_child(options_modal)
	if btn_options:
		btn_options.pressed.connect(func(): options_modal.open_modal())
	help_modal = HelpModal.new()
	add_child(help_modal)
	if btn_help:
		btn_help.pressed.connect(func(): help_modal.open_modal())
	club_transfer_modal = ClubTransferModal.new()
	add_child(club_transfer_modal)
	club_transfer_modal.transfer_agreed.connect(_on_club_transfer_agreed)
	sponsor_negotiation_modal = SponsorNegotiationModal.new()
	add_child(sponsor_negotiation_modal)
	sponsor_negotiation_modal.sponsor_contract_signed.connect(func(cat, prop):
		_render_economy_view()
		show_toast("🤝 Nouveau contrat sponsor signé avec %s !" % prop.get("brand_name", ""))
	)
	_init_game_world()
	_init_tactics_ui()
	_init_world_browser_ui()
	_init_market_ui()
	_init_negotiation_ui()
	pitch.player_clicked.connect(_on_pitch_player_clicked)
	pitch.player_right_clicked.connect(func(p): player_detail_modal.open_player(p, player_club))
	btn_auto_lineup.pressed.connect(_on_btn_auto_lineup_pressed)
	btn_save.pressed.connect(_on_btn_save_pressed)
	btn_main_menu.pressed.connect(_on_btn_main_menu_pressed)
	btn_european_cup.pressed.connect(_on_btn_european_cup_pressed)
	pre_match_modal.kickoff_requested.connect(_on_pre_match_kickoff)
	pre_match_modal.player_detail_requested.connect(func(p, c): player_detail_modal.open_player(p, c))
	_style_advance_button()
	_update_topbar()
	_update_inbox_badge()
	_render_squad_view()
	_show_tab(tab_squad)

func _get_game_global() -> Node:
	if is_inside_tree() and get_tree() != null and get_tree().root != null:
		return get_tree().root.get_node_or_null("GameGlobal")
	return null

func _init_game_world() -> void:
	all_leagues.clear()

	var global_ref = _get_game_global()
	if global_ref != null and global_ref.loaded_save_data != null and not global_ref.loaded_save_data.is_empty():
		var restored = SaveManager.deserialize_game_data(global_ref.loaded_save_data)
		all_leagues = restored["all_leagues"]
		market = restored["market"]
		player_club = restored["player_club"]
		current_league = restored["current_league"]
		viewed_league = current_league
		viewed_club = player_club
		current_season = int(restored.get("season_number", 1))
	elif global_ref != null and global_ref.new_game_selected_club != null:
		all_leagues = global_ref.new_game_all_leagues
		market = global_ref.new_game_market
		player_club = global_ref.new_game_selected_club
		current_league = global_ref.new_game_selected_league
		viewed_league = current_league
		viewed_club = player_club
	else:
		var world = GameWorld.create_default_world()
		all_leagues = world["all_leagues"]
		market = world["market"]
		current_league = all_leagues[0]
		player_club = current_league.clubs[0]
		viewed_league = current_league
		viewed_club = player_club

	if market.get_parent() == null:
		add_child(market)
	if not market.inbox_updated.is_connected(_update_inbox_badge):
		market.inbox_updated.connect(_update_inbox_badge)
	if not market.transaction_completed.is_connected(_on_market_transaction_completed):
		market.transaction_completed.connect(_on_market_transaction_completed)

	if not match_view.match_ended.is_connected(_on_user_match_finished):
		match_view.match_ended.connect(_on_user_match_finished)

func _on_market_transaction_completed(msg: String) -> void:
	show_toast(msg)

func _on_btn_save_pressed() -> void:
	var ok = SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)
	if ok:
		show_toast("💾 Partie sauvegardée avec succès !")
	else:
		show_toast("❌ Erreur de sauvegarde.", true)

func _on_btn_main_menu_pressed() -> void:
	SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)
	var global_ref = _get_game_global()
	if global_ref != null:
		global_ref.clear_transitions()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _init_tactics_ui() -> void:
	opt_tactic_style.clear()
	opt_tactic_style.add_item("Équilibré", Tactics.Style.BALANCED)
	opt_tactic_style.add_item("Attaque Totale", Tactics.Style.ALL_OUT_ATTACK)
	opt_tactic_style.add_item("Contre-Attaque", Tactics.Style.COUNTER_ATTACK)
	opt_tactic_style.selected = player_club.tactical_style
	lbl_style_desc.text = Tactics.get_style_desc(player_club.tactical_style)

	opt_tactic_style.item_selected.connect(func(idx: int):
		player_club.tactical_style = idx
		lbl_style_desc.text = Tactics.get_style_desc(idx)
		_update_topbar()
	)

	opt_training_focus.clear()
	opt_training_focus.add_item("Cryothérapie & Récupération", Tactics.TrainingFocus.RECOVERY)
	opt_training_focus.add_item("Finition & Frappes", Tactics.TrainingFocus.SHOOTING)
	opt_training_focus.add_item("Bloc & Duels Défensifs", Tactics.TrainingFocus.DEFENDING)
	opt_training_focus.selected = player_club.training_focus
	lbl_training_desc.text = Tactics.get_training_desc(player_club.training_focus)

	opt_training_focus.item_selected.connect(func(idx: int):
		player_club.training_focus = idx
		lbl_training_desc.text = Tactics.get_training_desc(idx)
		_update_topbar()
	)

func _init_world_browser_ui() -> void:
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

	_update_leagues_dropdown_for_country(countries[0])

	opt_country.item_selected.connect(func(idx: int):
		var selected_country_str = countries[idx]
		_update_leagues_dropdown_for_country(selected_country_str)
	)

	btn_my_league.pressed.connect(func():
		viewed_league = current_league
		viewed_club = player_club
		for i in countries.size():
			if countries[i] == current_league.country:
				opt_country.selected = i
				_update_leagues_dropdown_for_country(current_league.country)
				break
	)

	standings_tree.item_selected.connect(_on_standings_item_selected)

func _update_leagues_dropdown_for_country(country: String) -> void:
	opt_league.clear()
	var country_leagues: Array[League] = []
	for l in all_leagues:
		if l.country == country:
			country_leagues.append(l)
			opt_league.add_item("[D%d] %s" % [l.division, l.league_name])

	if opt_league.item_selected.is_connected(_on_league_dropdown_selected):
		opt_league.item_selected.disconnect(_on_league_dropdown_selected)
	opt_league.set_meta("country_leagues", country_leagues)
	opt_league.item_selected.connect(_on_league_dropdown_selected)

	if not country_leagues.is_empty():
		opt_league.selected = 0
		viewed_league = country_leagues[0]
		viewed_club = viewed_league.clubs[0]
		_render_standings_view()

func _on_league_dropdown_selected(idx: int) -> void:
	var country_leagues = opt_league.get_meta("country_leagues") as Array
	if idx >= 0 and idx < country_leagues.size():
		viewed_league = country_leagues[idx]
		viewed_club = viewed_league.clubs[0]
		_render_standings_view()

func _init_market_ui() -> void:
	opt_market_country.clear()
	opt_market_country.add_item("Tous les pays")
	var m_countries = ["France", "Espagne", "Italie", "Portugal", "Angleterre", "Allemagne", "Brésil", "Belgique", "Pays-Bas"]
	for c in m_countries:
		var code = "INT"
		match c:
			"France": code = "FRA"
			"Espagne": code = "ESP"
			"Italie": code = "ITA"
			"Portugal": code = "POR"
			"Angleterre": code = "ENG"
			"Allemagne": code = "ALL"
			"Brésil": code = "BRE"
			"Belgique": code = "BEL"
			"Pays-Bas": code = "P-B"
		opt_market_country.add_item("[%s] %s" % [code, c])

	opt_market_pos.clear()
	opt_market_pos.add_item("Tous les postes")
	opt_market_pos.add_item("Gardien [GK]")
	opt_market_pos.add_item("Défenseur [DEF]")
	opt_market_pos.add_item("Milieu [MID]")
	opt_market_pos.add_item("Attaquant [FWD]")

	opt_market_country.item_selected.connect(func(_idx): _render_market_view())
	opt_market_pos.item_selected.connect(func(_idx): _render_market_view())

func _update_inbox_badge() -> void:
	var count = market.pending_offers.size()
	if count > 0:
		btn_tab_inbox.text = "Boîte de réception (%d)" % count
	else:
		btn_tab_inbox.text = "Boîte de réception"

func _show_tab(target: Control) -> void:
	tab_squad.visible = (target == tab_squad)
	tab_market.visible = (target == tab_market)
	tab_formation.visible = (target == tab_formation)
	tab_standings.visible = (target == tab_standings)
	tab_economy.visible = (target == tab_economy)
	tab_inbox.visible = (target == tab_inbox)

func _on_btn_tab_squad_pressed() -> void:
	_render_squad_view()
	_show_tab(tab_squad)

func _on_btn_tab_market_pressed() -> void:
	_render_market_view()
	_show_tab(tab_market)

func _on_btn_tab_formation_pressed() -> void:
	_render_formation_view()
	_show_tab(tab_formation)

func _on_btn_tab_standings_pressed() -> void:
	_render_standings_view()
	_show_tab(tab_standings)

func _on_btn_tab_economy_pressed() -> void:
	_render_economy_view()
	_show_tab(tab_economy)

func _on_btn_tab_inbox_pressed() -> void:
	_render_inbox_view()
	_show_tab(tab_inbox)

func _create_economy_kpi_card(title: String, val_str: String, val_col: Color, sub_str: String) -> PanelContainer:
	var p = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.09, 0.13, 0.22, 0.95)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.border_color = Color(0.2, 0.28, 0.42, 0.6)
	p.add_theme_stylebox_override("panel", sb)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 3)

	var t_lbl = Label.new()
	t_lbl.text = title
	t_lbl.add_theme_font_size_override("font_size", 12)
	t_lbl.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	vb.add_child(t_lbl)

	var v_lbl = Label.new()
	v_lbl.text = val_str
	v_lbl.add_theme_font_size_override("font_size", 22)
	v_lbl.add_theme_color_override("font_color", val_col)
	vb.add_child(v_lbl)

	var s_lbl = Label.new()
	s_lbl.text = sub_str
	s_lbl.add_theme_font_size_override("font_size", 11)
	s_lbl.add_theme_color_override("font_color", Color(0.55, 0.65, 0.78))
	vb.add_child(s_lbl)

	p.add_child(vb)
	return p

func _create_sponsor_item_card(type_str: String, name_str: String, payout_str: String, bonus_str: String, desc_str: String, category_id: String = "") -> PanelContainer:
	var p = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.09, 0.15, 0.9)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	p.add_theme_stylebox_override("panel", sb)

	var vb = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 4)

	var t = Label.new()
	t.text = type_str
	t.add_theme_font_size_override("font_size", 11)
	t.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	vb.add_child(t)

	var n = Label.new()
	n.text = name_str
	n.add_theme_font_size_override("font_size", 14)
	n.add_theme_color_override("font_color", Color.WHITE)
	vb.add_child(n)

	var val = Label.new()
	val.text = payout_str
	val.add_theme_font_size_override("font_size", 13)
	val.add_theme_color_override("font_color", Color("34d399"))
	vb.add_child(val)

	if bonus_str != "":
		var bon = Label.new()
		bon.text = bonus_str
		bon.add_theme_font_size_override("font_size", 11)
		bon.add_theme_color_override("font_color", Color("facc15"))
		vb.add_child(bon)

	var d = Label.new()
	d.text = desc_str
	d.add_theme_font_size_override("font_size", 10)
	d.add_theme_color_override("font_color", Color(0.55, 0.65, 0.75))
	vb.add_child(d)

	if category_id != "":
		var btn = Button.new()
		btn.text = "🤝 Négocier"
		btn.custom_minimum_size = Vector2(0, 28)
		btn.add_theme_font_size_override("font_size", 11)
		btn.pressed.connect(func():
			if player_club:
				sponsor_negotiation_modal.open_negotiation(player_club, category_id)
		)
		vb.add_child(btn)

	p.add_child(vb)
	return p

func _create_balance_line(label_text: String, value_text: String, val_color: Color, is_bold: bool = false) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	var l = Label.new()
	l.text = label_text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 14 if is_bold else 12)
	if is_bold:
		l.add_theme_color_override("font_color", Color.WHITE)
	else:
		l.add_theme_color_override("font_color", Color(0.75, 0.82, 0.92))
	hbox.add_child(l)

	var v = Label.new()
	v.text = value_text
	v.add_theme_font_size_override("font_size", 15 if is_bold else 13)
	v.add_theme_color_override("font_color", val_color)
	hbox.add_child(v)
	return hbox

func _render_economy_view() -> void:
	for c in economy_content.get_children():
		c.queue_free()

	if player_club == null:
		return

	var fin = player_club.get_finances()
	var total_wage = player_club.get_total_wage()
	var weekly_fixed_income = fin.get_total_fixed_income()
	var weekly_fixed_expense = total_wage + fin.weekly_maintenance
	var weekly_net = weekly_fixed_income - weekly_fixed_expense

	# --- 1. BANNIÈRE RÉSUMÉ KPI ---
	var kpi_hbox = HBoxContainer.new()
	kpi_hbox.add_theme_constant_override("separation", 12)

	var card_budget = _create_economy_kpi_card(
		"💰 TRÉSORERIE ACTUELLE",
		"%s €" % String.num_int64(player_club.budget),
		Color("facc15"),
		"Santé : " + ("Saine et solide ✅" if player_club.budget > 80000 else ("Équilibrée ⚖️" if player_club.budget > 25000 else "Attention, trésorerie faible ⚠️"))
	)
	card_budget.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kpi_hbox.add_child(card_budget)

	var card_wage = _create_economy_kpi_card(
		"👥 MASSE SALARIALE",
		"%s € / sem" % String.num_int64(total_wage),
		Color("38bdf8"),
		"%s € par an (%d joueurs sous contrat)" % [String.num_int64(total_wage * 52), player_club.squad.size()]
	)
	card_wage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kpi_hbox.add_child(card_wage)

	var net_color = Color("34d399") if weekly_net >= 0 else Color("f87171")
	var net_prefix = "+" if weekly_net >= 0 else ""
	var card_net = _create_economy_kpi_card(
		"📊 RÉSULTAT FIXE / SEMAINE",
		"%s%s € / sem" % [net_prefix, String.num_int64(weekly_net)],
		net_color,
		"Hors billetterie des matchs à domicile"
	)
	card_net.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kpi_hbox.add_child(card_net)

	economy_content.add_child(kpi_hbox)

	# --- 2. MODULE BILLETTERIE & REVENUS DU STADE ---
	var ticket_box = PanelContainer.new()
	var t_style = StyleBoxFlat.new()
	t_style.bg_color = Color(0.08, 0.12, 0.20, 0.9)
	t_style.set_corner_radius_all(10)
	t_style.content_margin_left = 16
	t_style.content_margin_right = 16
	t_style.content_margin_top = 14
	t_style.content_margin_bottom = 14
	ticket_box.add_theme_stylebox_override("panel", t_style)

	var ticket_vbox = VBoxContainer.new()
	ticket_vbox.add_theme_constant_override("separation", 10)

	var ticket_title = Label.new()
	ticket_title.text = "🏟️ GESTION DE LA SALLE & PRIX DES BILLETS"
	ticket_title.add_theme_font_size_override("font_size", 16)
	ticket_title.add_theme_color_override("font_color", Color("facc15"))
	ticket_vbox.add_child(ticket_title)

	var arena_sub = Label.new()
	arena_sub.text = "%s • Capacité officielle : %s places (Division %d)" % [
		fin.arena_name, String.num_int64(fin.arena_capacity), player_club.division
	]
	arena_sub.add_theme_font_size_override("font_size", 13)
	arena_sub.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	ticket_vbox.add_child(arena_sub)

	var price_ctrl_box = HBoxContainer.new()
	price_ctrl_box.add_theme_constant_override("separation", 14)
	price_ctrl_box.alignment = BoxContainer.ALIGNMENT_CENTER

	var lbl_price_prompt = Label.new()
	lbl_price_prompt.text = "Prix du billet pour les matchs à domicile :"
	lbl_price_prompt.add_theme_font_size_override("font_size", 14)
	price_ctrl_box.add_child(lbl_price_prompt)

	var btn_minus = Button.new()
	btn_minus.text = "  − 2 €  "
	btn_minus.custom_minimum_size = Vector2(70, 38)
	btn_minus.add_theme_font_size_override("font_size", 14)
	btn_minus.pressed.connect(func():
		fin.ticket_price = maxi(6, fin.ticket_price - 2)
		_render_economy_view()
	)
	price_ctrl_box.add_child(btn_minus)

	var lbl_current_price = Label.new()
	lbl_current_price.text = "%d €" % fin.ticket_price
	lbl_current_price.custom_minimum_size = Vector2(90, 0)
	lbl_current_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_current_price.add_theme_font_size_override("font_size", 22)
	lbl_current_price.add_theme_color_override("font_color", Color("38bdf8"))
	price_ctrl_box.add_child(lbl_current_price)

	var btn_plus = Button.new()
	btn_plus.text = "  + 2 €  "
	btn_plus.custom_minimum_size = Vector2(70, 38)
	btn_plus.add_theme_font_size_override("font_size", 14)
	btn_plus.pressed.connect(func():
		fin.ticket_price = mini(45, fin.ticket_price + 2)
		_render_economy_view()
	)
	price_ctrl_box.add_child(btn_plus)

	ticket_vbox.add_child(price_ctrl_box)

	var est_pct = fin.estimate_attendance_percentage(fin.ticket_price, player_club.division)
	var est_attendance = int(float(fin.arena_capacity) * est_pct)
	var est_revenue = est_attendance * fin.ticket_price

	var live_grid = HBoxContainer.new()
	live_grid.add_theme_constant_override("separation", 20)

	var fill_lbl = Label.new()
	fill_lbl.text = "Remplissage estimé : %d%%" % int(est_pct * 100)
	fill_lbl.add_theme_font_size_override("font_size", 13)
	fill_lbl.add_theme_color_override("font_color", Color("34d399") if est_pct >= 0.75 else Color("facc15"))
	fill_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	live_grid.add_child(fill_lbl)

	var att_lbl = Label.new()
	att_lbl.text = "Affluence attendue : %s spectateurs" % String.num_int64(est_attendance)
	att_lbl.add_theme_font_size_override("font_size", 13)
	att_lbl.add_theme_color_override("font_color", Color(0.8, 0.88, 1.0))
	att_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	live_grid.add_child(att_lbl)

	var rev_lbl = Label.new()
	rev_lbl.text = "Recette estimée : %s € / match" % String.num_int64(est_revenue)
	rev_lbl.add_theme_font_size_override("font_size", 13)
	rev_lbl.add_theme_color_override("font_color", Color("facc15"))
	rev_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	live_grid.add_child(rev_lbl)

	ticket_vbox.add_child(live_grid)

	var advice_lbl = Label.new()
	if fin.ticket_price <= 12:
		advice_lbl.text = "💡 Conseil : Tarif très populaire ! La salle sera pleine et l'ambiance électrique."
		advice_lbl.add_theme_color_override("font_color", Color("34d399"))
	elif fin.ticket_price <= 24:
		advice_lbl.text = "💡 Conseil : Tarif optimal pour cette division. Excellent équilibre affluence / recettes."
		advice_lbl.add_theme_color_override("font_color", Color("38bdf8"))
	else:
		advice_lbl.text = "⚠️ Conseil : Tarif élevé. Baisse d'affluence attendue mais recette par billet maximale."
		advice_lbl.add_theme_color_override("font_color", Color("f87171"))
	advice_lbl.add_theme_font_size_override("font_size", 12)
	ticket_vbox.add_child(advice_lbl)

	ticket_box.add_child(ticket_vbox)
	economy_content.add_child(ticket_box)

	# --- 3. MODULE SPONSORS & PARTENARIATS ---
	var sponsor_box = PanelContainer.new()
	var sp_style = StyleBoxFlat.new()
	sp_style.bg_color = Color(0.08, 0.12, 0.20, 0.9)
	sp_style.set_corner_radius_all(10)
	sp_style.content_margin_left = 16
	sp_style.content_margin_right = 16
	sp_style.content_margin_top = 14
	sp_style.content_margin_bottom = 14
	sponsor_box.add_theme_stylebox_override("panel", sp_style)

	var sp_vbox = VBoxContainer.new()
	sp_vbox.add_theme_constant_override("separation", 10)

	var sp_title = Label.new()
	sp_title.text = "🤝 SPONSORS, RÉGIE PUBLICITAIRE & DROITS DE DIFFUSION"
	sp_title.add_theme_font_size_override("font_size", 16)
	sp_title.add_theme_color_override("font_color", Color("facc15"))
	sp_vbox.add_child(sp_title)

	var sp_cards_row = HBoxContainer.new()
	sp_cards_row.add_theme_constant_override("separation", 10)

	var sp1 = _create_sponsor_item_card(
		"👕 Sponsor Maillot",
		fin.primary_sponsor_name,
		"+%s € / sem" % String.num_int64(fin.primary_sponsor_weekly),
		"+%s € / vic." % String.num_int64(fin.primary_sponsor_bonus_win),
		"%d sem. restantes" % fin.primary_sponsor_weeks_left,
		"PRIMARY"
	)
	sp1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_cards_row.add_child(sp1)

	var sp2 = _create_sponsor_item_card(
		"🏟️ Naming Salle",
		fin.arena_sponsor_name,
		"+%s € / sem" % String.num_int64(fin.arena_sponsor_weekly),
		"+%s € / vic." % String.num_int64(fin.arena_sponsor_bonus_win),
		"%d sem. restantes" % fin.arena_sponsor_weeks_left,
		"ARENA"
	)
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_cards_row.add_child(sp2)

	var sp3 = _create_sponsor_item_card(
		"👟 Équipementier",
		fin.kit_sponsor_name,
		"+%s € / sem" % String.num_int64(fin.kit_sponsor_weekly),
		"+%s € / vic." % String.num_int64(fin.kit_sponsor_bonus_win),
		"%d sem. restantes" % fin.kit_sponsor_weeks_left,
		"KIT"
	)
	sp3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_cards_row.add_child(sp3)

	var sp4 = _create_sponsor_item_card(
		"🪧 Régie Pub & LED",
		fin.board_ads_name,
		"+%s € / sem" % String.num_int64(fin.board_ads_weekly),
		"+%s € / vic." % String.num_int64(fin.board_ads_bonus_win),
		"%d sem. restantes" % fin.board_ads_weeks_left,
		"BOARD"
	)
	sp4.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_cards_row.add_child(sp4)

	var sp5 = _create_sponsor_item_card(
		"📺 Droits TV Ligue",
		"Ligue Nationale Futsal",
		"+%s € / sem" % String.num_int64(fin.weekly_tv_rights),
		"",
		"Dotation officielle fixe",
		""
	)
	sp5.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp_cards_row.add_child(sp5)

	sp_vbox.add_child(sp_cards_row)
	sponsor_box.add_child(sp_vbox)
	economy_content.add_child(sponsor_box)

	# --- 4. GRAND TABLEAU DÉCOMPOSITION : ENTRÉES VS SORTIES ---
	var breakdown_box = PanelContainer.new()
	var bd_style = StyleBoxFlat.new()
	bd_style.bg_color = Color(0.06, 0.09, 0.16, 0.95)
	bd_style.set_corner_radius_all(10)
	bd_style.content_margin_left = 16
	bd_style.content_margin_right = 16
	bd_style.content_margin_top = 14
	bd_style.content_margin_bottom = 14
	breakdown_box.add_theme_stylebox_override("panel", bd_style)

	var bd_vbox = VBoxContainer.new()
	bd_vbox.add_theme_constant_override("separation", 10)

	var bd_title = Label.new()
	bd_title.text = "📑 DÉCOMPOSITION ÉCONOMIQUE (ENTRÉES & SORTIES)"
	bd_title.add_theme_font_size_override("font_size", 15)
	bd_title.add_theme_color_override("font_color", Color.WHITE)
	bd_vbox.add_child(bd_title)

	var cols_hbox = HBoxContainer.new()
	cols_hbox.add_theme_constant_override("separation", 24)

	# Colonne Entrées
	var in_col = VBoxContainer.new()
	in_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	in_col.add_theme_constant_override("separation", 6)

	var in_hdr = Label.new()
	in_hdr.text = "📈 ENTRÉES HEBDOMADAIRES"
	in_hdr.add_theme_font_size_override("font_size", 14)
	in_hdr.add_theme_color_override("font_color", Color("34d399"))
	in_col.add_child(in_hdr)

	in_col.add_child(_create_balance_line("Sponsor Maillot :", "+%s €" % String.num_int64(fin.primary_sponsor_weekly), Color("34d399")))
	in_col.add_child(_create_balance_line("Partenaire Salle :", "+%s €" % String.num_int64(fin.arena_sponsor_weekly), Color("34d399")))
	in_col.add_child(_create_balance_line("Équipementier Officiel :", "+%s €" % String.num_int64(fin.kit_sponsor_weekly), Color("34d399")))
	in_col.add_child(_create_balance_line("Panneaux & Régie LED :", "+%s €" % String.num_int64(fin.board_ads_weekly), Color("34d399")))
	in_col.add_child(_create_balance_line("Droits TV officiels :", "+%s €" % String.num_int64(fin.weekly_tv_rights), Color("34d399")))
	in_col.add_child(_create_balance_line("Billetterie moyenne (domicile) :", "+%s € / match" % String.num_int64(est_revenue), Color("facc15")))
	in_col.add_child(HSeparator.new())
	in_col.add_child(_create_balance_line("TOTAL REVENUS FIXES :", "+%s € / sem" % String.num_int64(weekly_fixed_income), Color("34d399"), true))

	cols_hbox.add_child(in_col)

	# Colonne Sorties
	var out_col = VBoxContainer.new()
	out_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	out_col.add_theme_constant_override("separation", 6)

	var out_hdr = Label.new()
	out_hdr.text = "📉 SORTIES HEBDOMADAIRES"
	out_hdr.add_theme_font_size_override("font_size", 14)
	out_hdr.add_theme_color_override("font_color", Color("f87171"))
	out_col.add_child(out_hdr)

	out_col.add_child(_create_balance_line("Salaires joueurs (%d contrats) :" % player_club.squad.size(), "-%s €" % String.num_int64(total_wage), Color("f87171")))
	out_col.add_child(_create_balance_line("Entretien salle & logistique :", "-%s €" % String.num_int64(fin.weekly_maintenance), Color("f87171")))
	out_col.add_child(_create_balance_line("Déplacements & arbitrage :", "Inclus dans l'entretien", Color(0.7, 0.75, 0.85)))
	out_col.add_child(_create_balance_line("Indemnités de transfert :", "Selon opérations mercato", Color(0.7, 0.75, 0.85)))
	out_col.add_child(HSeparator.new())
	out_col.add_child(_create_balance_line("TOTAL DÉPENSES FIXES :", "-%s € / sem" % String.num_int64(weekly_fixed_expense), Color("f87171"), true))

	cols_hbox.add_child(out_col)

	bd_vbox.add_child(cols_hbox)
	breakdown_box.add_child(bd_vbox)
	economy_content.add_child(breakdown_box)

func _on_btn_auto_lineup_pressed() -> void:
	player_club.auto_pick_lineup()
	selected_swap_player = null
	if not player_club.starting_five.is_empty():
		inspected_player = player_club.starting_five[0]
	_render_squad_view()

func _on_pitch_player_clicked(p: Player) -> void:
	inspected_player = p
	_render_inspector(p)

	if selected_swap_player == null:
		# Sélectionne ce joueur pour un remplacement ou une permutation
		selected_swap_player = p
	elif selected_swap_player == p:
		# Re-cliquer désélectionne
		selected_swap_player = null
	elif player_club.starting_five.has(selected_swap_player):
		# Permutation de deux joueurs sur le terrain
		var idx1 = player_club.starting_five.find(selected_swap_player)
		var idx2 = player_club.starting_five.find(p)
		if idx1 != -1 and idx2 != -1:
			var tmp = player_club.starting_five[idx1]
			player_club.starting_five[idx1] = player_club.starting_five[idx2]
			player_club.starting_five[idx2] = tmp
		selected_swap_player = null
	else:
		# selected_swap_player était un remplaçant du banc : substitution directe !
		var idx = player_club.starting_five.find(p)
		if idx != -1:
			player_club.starting_five[idx] = selected_swap_player
		selected_swap_player = null

	_render_squad_view()

func _render_squad_view() -> void:
	pitch.set_starting_five(player_club.starting_five, selected_swap_player)

	# Consignes dynamiques
	if selected_swap_player != null:
		if player_club.starting_five.has(selected_swap_player):
			label_pitch_sub.text = "⇄ %s sélectionné\nCliquez sur un remplaçant ou un titulaire" % selected_swap_player.full_name
			label_pitch_sub.modulate = Color("facc15")
			label_bench_title.text = "Choisir le joueur entrant :"
			label_bench_title.modulate = Color("facc15")
		else:
			label_pitch_sub.text = "⇄ %s (banc) sélectionné\nCliquez sur le titulaire à sortir" % selected_swap_player.full_name
			label_pitch_sub.modulate = Color("38bdf8")
			label_bench_title.text = "Banc & Réserve"
			label_bench_title.modulate = Color.WHITE
	else:
		label_pitch_sub.text = "Cliquez sur un joueur pour le remplacer ou permuter"
		label_pitch_sub.modulate = Color(0.7, 0.75, 0.85, 1.0)
		label_bench_title.text = "Banc & Réserve (%d remplaçants • Effectif : %d/32)" % [
			player_club.squad.size() - player_club.starting_five.size(),
			player_club.squad.size()
		]
		label_bench_title.modulate = Color.WHITE

	btn_tab_squad.text = "  ⚽ Effectif (%d/32)" % player_club.squad.size()

	for c in bench_list.get_children():
		c.queue_free()

	for p in player_club.squad:
		if not player_club.starting_five.has(p):
			bench_list.add_child(_create_player_card(p, false))

	if inspected_player == null and not player_club.starting_five.is_empty():
		inspected_player = player_club.starting_five[0]
	if inspected_player != null:
		_render_inspector(inspected_player)

func _create_player_card(p: Player, _is_starter: bool) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var is_inspected = (p == inspected_player)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.16, 0.26, 0.85) if is_inspected else Color(0.08, 0.11, 0.19, 0.6)
	if is_inspected:
		sb.border_color = Color("38bdf8")
		sb.set_border_width_all(1)
	sb.set_corner_radius_all(5)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", sb)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)

	var pos_tag = Label.new()
	var pos_names = ["GK", "DEF", "MID", "FWD"]
	pos_tag.text = "[%s]" % pos_names[p.position]
	var pos_color = Color("f59e0b")
	match p.position:
		Player.Position.DEF: pos_color = Color("38bdf8")
		Player.Position.MID: pos_color = Color("10b981")
		Player.Position.FWD: pos_color = Color("f43f5e")
	pos_tag.modulate = pos_color
	pos_tag.add_theme_font_size_override("font_size", 13)

	var info_lbl = Label.new()
	info_lbl.text = "%s %s" % [p.get_flag_emoji(), p.full_name]
	info_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	info_lbl.add_theme_font_size_override("font_size", 14)

	var age_lbl = Label.new()
	age_lbl.text = "%da" % p.age
	age_lbl.modulate = Color(0.75, 0.82, 0.92, 1.0)
	age_lbl.add_theme_font_size_override("font_size", 12)

	var ovr_lbl = Label.new()
	ovr_lbl.text = "OVR %d" % p.get_overall()
	ovr_lbl.modulate = Color("facc15")
	ovr_lbl.add_theme_font_size_override("font_size", 14)

	var form_lbl = Label.new()
	var pct = int(p.fitness * 100)
	form_lbl.text = "%d%%" % pct
	form_lbl.modulate = Color("10b981") if pct >= 75 else (Color("f59e0b") if pct >= 55 else Color("ef4444"))
	form_lbl.add_theme_font_size_override("font_size", 12)

	var btn_action = Button.new()
	btn_action.add_theme_font_size_override("font_size", 12)
	btn_action.custom_minimum_size = Vector2(28, 26)
	if selected_swap_player != null and player_club.starting_five.has(selected_swap_player):
		btn_action.text = "⇄"
		btn_action.tooltip_text = "Faire entrer ce joueur à la place de %s" % selected_swap_player.full_name
		btn_action.modulate = Color("facc15")
		btn_action.pressed.connect(func():
			var idx = player_club.starting_five.find(selected_swap_player)
			if idx != -1:
				player_club.starting_five[idx] = p
			selected_swap_player = null
			inspected_player = p
			_render_squad_view()
		)
	elif selected_swap_player == p:
		btn_action.text = "✕"
		btn_action.tooltip_text = "Annuler la sélection"
		btn_action.modulate = Color("f87171")
		btn_action.pressed.connect(func():
			selected_swap_player = null
			_render_squad_view()
		)
	else:
		if player_club.starting_five.size() < 5:
			btn_action.text = "+"
			btn_action.tooltip_text = "Aligner dans le 5 de départ"
			btn_action.modulate = Color("10b981")
			btn_action.pressed.connect(func():
				player_club.starting_five.append(p)
				inspected_player = p
				_render_squad_view()
			)
		else:
			btn_action.text = "⇄"
			btn_action.tooltip_text = "Remplacer un titulaire par ce joueur"
			btn_action.modulate = Color("38bdf8")
			btn_action.pressed.connect(func():
				selected_swap_player = p
				inspected_player = p
				_render_squad_view()
			)

	var btn_profile = Button.new()
	btn_profile.text = "👤"
	btn_profile.tooltip_text = "Fiche détaillée du joueur"
	btn_profile.add_theme_font_size_override("font_size", 12)
	btn_profile.pressed.connect(func():
		player_detail_modal.open_player(p, player_club)
	)

	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			inspected_player = p
			_render_inspector(p)
			_render_squad_view()
	)

	hbox.add_child(pos_tag)
	hbox.add_child(info_lbl)
	hbox.add_child(age_lbl)
	hbox.add_child(ovr_lbl)
	hbox.add_child(form_lbl)
	hbox.add_child(btn_profile)
	hbox.add_child(btn_action)
	panel.add_child(hbox)
	return panel

func _render_inspector(p: Player) -> void:
	for c in inspector_content.get_children():
		c.queue_free()

	if p == null:
		var empty_lbl = Label.new()
		empty_lbl.text = "Sélectionnez un joueur pour voir sa fiche."
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.modulate = Color(0.7, 0.75, 0.85)
		inspector_content.add_child(empty_lbl)
		return

	var is_starter = player_club.starting_five.has(p)
	var status_text = " [TITULAIRE]" if is_starter else " [REMPLAÇANT]"
	var title = Label.new()
	var pos_names = ["Gardien", "Défenseur", "Milieu", "Attaquant"]
	title.text = "%s %s - %s (%d ans)%s" % [p.get_flag_emoji(), p.full_name, pos_names[p.position], p.age, status_text]
	title.add_theme_font_size_override("font_size", 13)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector_content.add_child(title)

	var val_lbl = Label.new()
	val_lbl.text = "Val: %s € | Sal: %s €/sem | Contrat: %d an(s)" % [String.num_int64(p.market_value), String.num_int64(p.salary), p.contract_years]
	val_lbl.modulate = Color("facc15")
	val_lbl.add_theme_font_size_override("font_size", 12)
	val_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	val_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inspector_content.add_child(val_lbl)

	var stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 8)
	stats_grid.add_theme_constant_override("v_separation", 2)

	var stats = [
		{"name": "Vit", "val": p.speed},
		{"name": "Pas", "val": p.passing},
		{"name": "Tir", "val": p.shooting},
		{"name": "Def", "val": p.defending},
		{"name": "End", "val": p.stamina},
	]

	for s in stats:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 3)
		var s_lbl = Label.new()
		s_lbl.text = "%s:%d" % [s["name"], s["val"]]
		s_lbl.custom_minimum_size = Vector2(44, 0)
		s_lbl.add_theme_font_size_override("font_size", 12)
		var pb = ProgressBar.new()
		pb.max_value = 20
		pb.value = s["val"]
		pb.show_percentage = false
		pb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pb.custom_minimum_size = Vector2(0, 8)
		pb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(s_lbl)
		row.add_child(pb)
		stats_grid.add_child(row)

	inspector_content.add_child(stats_grid)

	var traits_box = HBoxContainer.new()
	traits_box.add_theme_constant_override("separation", 6)
	var trait_pos = Label.new()
	trait_pos.text = "★ %s" % p.trait_positive
	trait_pos.modulate = Color("10b981")
	trait_pos.add_theme_font_size_override("font_size", 12)
	trait_pos.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_pos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var trait_neg = Label.new()
	trait_neg.text = "⚠️ %s" % p.trait_negative
	trait_neg.modulate = Color("f87171")
	trait_neg.add_theme_font_size_override("font_size", 12)
	trait_neg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	trait_neg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	traits_box.add_child(trait_pos)
	traits_box.add_child(trait_neg)
	inspector_content.add_child(traits_box)

	var cur = p.stats_current_season
	var cur_m = cur.get("matches", 0)
	var cur_g = cur.get("goals", 0)
	var cur_a = cur.get("assists", 0)
	var cur_t = cur.get("tackles", 0)
	var cur_s = cur.get("saves", 0)
	var cur_r = p.get_average_rating()
	var cur_r_str = "-" if cur_m == 0 else "%.1f" % cur_r

	var stats_badge = PanelContainer.new()
	var sb_badge = StyleBoxFlat.new()
	sb_badge.bg_color = Color(0.10, 0.16, 0.28, 0.7)
	sb_badge.border_color = Color(0.22, 0.74, 0.97, 0.5)
	sb_badge.set_border_width_all(1)
	sb_badge.set_corner_radius_all(6)
	sb_badge.content_margin_left = 8
	sb_badge.content_margin_right = 8
	sb_badge.content_margin_top = 4
	sb_badge.content_margin_bottom = 4
	stats_badge.add_theme_stylebox_override("panel", sb_badge)

	var lbl_season_stats = Label.new()
	if p.position == Player.Position.GK:
		lbl_season_stats.text = "📊 Stats : %d m | %d arrêts | Note: %s" % [cur_m, cur_s, cur_r_str]
	else:
		lbl_season_stats.text = "📊 Stats : %d m | ⚽ %d buts | 🎯 %d pass. | 🛡️ %d tac. | Note: %s" % [cur_m, cur_g, cur_a, cur_t, cur_r_str]
	lbl_season_stats.add_theme_font_size_override("font_size", 11)
	lbl_season_stats.add_theme_color_override("font_color", Color("38bdf8"))
	lbl_season_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_season_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_badge.add_child(lbl_season_stats)
	inspector_content.add_child(stats_badge)

	var btn_vbox = VBoxContainer.new()
	btn_vbox.add_theme_constant_override("separation", 4)

	var row_actions = HBoxContainer.new()
	row_actions.add_theme_constant_override("separation", 6)

	if is_starter:
		var btn_remove = Button.new()
		btn_remove.text = "Mettre sur le banc"
		btn_remove.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_remove.modulate = Color("f87171")
		btn_remove.add_theme_font_size_override("font_size", 12)
		btn_remove.pressed.connect(func():
			player_club.starting_five.erase(p)
			if selected_swap_player == p:
				selected_swap_player = null
			_render_squad_view()
		)
		row_actions.add_child(btn_remove)
	else:
		if player_club.starting_five.size() < 5:
			var btn_add = Button.new()
			btn_add.text = "Aligner"
			btn_add.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_add.modulate = Color("10b981")
			btn_add.add_theme_font_size_override("font_size", 12)
			btn_add.pressed.connect(func():
				player_club.starting_five.append(p)
				if selected_swap_player == p:
					selected_swap_player = null
				_render_squad_view()
			)
			row_actions.add_child(btn_add)
		else:
			var btn_prep_swap = Button.new()
			btn_prep_swap.text = "⇄ Remplacer"
			btn_prep_swap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn_prep_swap.modulate = Color("facc15")
			btn_prep_swap.add_theme_font_size_override("font_size", 12)
			btn_prep_swap.pressed.connect(func():
				selected_swap_player = p
				_render_squad_view()
			)
			row_actions.add_child(btn_prep_swap)

	if player_club.squad.has(p):
		var severance = p.salary * 4
		var btn_release = Button.new()
		btn_release.text = "Libérer (%s €)" % String.num_int64(severance)
		btn_release.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_release.modulate = Color("f87171")
		btn_release.add_theme_font_size_override("font_size", 12)
		btn_release.pressed.connect(func():
			if market.release_player(player_club, p):
				inspected_player = null
				if selected_swap_player == p:
					selected_swap_player = null
				_render_squad_view()
				_render_inspector(null)
				_update_topbar()
		)
		row_actions.add_child(btn_release)

	btn_vbox.add_child(row_actions)

	var btn_full_profile = Button.new()
	btn_full_profile.text = "👤 Fiche Complète"
	btn_full_profile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_full_profile.modulate = Color("38bdf8")
	btn_full_profile.add_theme_font_size_override("font_size", 12)
	btn_full_profile.pressed.connect(func():
		player_detail_modal.open_player(p, player_club)
	)
	btn_vbox.add_child(btn_full_profile)

	inspector_content.add_child(btn_vbox)


func _on_btn_european_cup_pressed() -> void:
	is_viewing_european_cup = not is_viewing_european_cup
	if is_viewing_european_cup:
		btn_european_cup.text = "⚽ Voir Championnat"
	else:
		btn_european_cup.text = "🏆 Coupe d'Europe"
	_render_standings_view()

func _render_standings_view() -> void:
	if is_viewing_european_cup:
		_render_european_cup_view()
		return

	if viewed_league == null:
		viewed_league = current_league

	var flag = viewed_league.get_country_flag()
	if viewed_league.is_playoffs_finished():
		label_standings_title.text = "%s %s - %s [CHAMPION : %s]" % [
			flag, viewed_league.country, viewed_league.league_name,
			viewed_league.playoff_champion.club_name.to_upper() if viewed_league.playoff_champion else ""
		]
	elif viewed_league.is_playoffs_active():
		var p_name = "1/2 Finale (2e vs 3e)" if viewed_league.playoff_phase == 1 else "GRANDE FINALE"
		label_standings_title.text = "%s %s - %s [PLAYOFFS : %s]" % [
			flag, viewed_league.country, viewed_league.league_name, p_name
		]
	else:
		label_standings_title.text = "%s %s - %s (Journée %d / %d • Matchs en 5 buts)" % [
			flag, viewed_league.country, viewed_league.league_name,
			min(viewed_league.current_matchday_index + 1, viewed_league.schedule.size()),
			viewed_league.schedule.size()
		]

	standings_tree.clear()
	var root = standings_tree.create_item()
	standings_tree.hide_root = true
	standings_tree.columns = 7
	standings_tree.set_column_title(0, "Club")
	standings_tree.set_column_title(1, "Pts")
	standings_tree.set_column_title(2, "J")
	standings_tree.set_column_title(3, "V")
	standings_tree.set_column_title(4, "D")
	standings_tree.set_column_title(5, "Diff")
	standings_tree.set_column_title(6, "Forme")
	standings_tree.set_column_titles_visible(true)

	standings_tree.set_column_expand(0, true)
	standings_tree.set_column_custom_minimum_width(0, 115)
	for col in range(1, 6):
		standings_tree.set_column_expand(col, false)
		standings_tree.set_column_custom_minimum_width(col, 32)
	standings_tree.set_column_expand(6, false)
	standings_tree.set_column_custom_minimum_width(6, 65)

	if viewed_league.is_playoffs_active():
		var po_banner = standings_tree.create_item(root)
		po_banner.set_selectable(0, false)
		if viewed_league.playoff_phase == 1:
			var h_c = viewed_league.playoff_semi_home.club_name if viewed_league.playoff_semi_home else ""
			var a_c = viewed_league.playoff_semi_away.club_name if viewed_league.playoff_semi_away else ""
			po_banner.set_text(0, "🔥 1/2 PLAYOFFS : %s vs %s (1er à 7 buts)" % [h_c, a_c])
			po_banner.set_custom_color(0, Color("facc15"))
		elif viewed_league.playoff_phase == 2:
			var h_c = viewed_league.playoff_final_home.club_name if viewed_league.playoff_final_home else ""
			var a_c = viewed_league.playoff_final_away.club_name if viewed_league.playoff_final_away else ""
			po_banner.set_text(0, "🏆 GRANDE FINALE : %s vs %s (1er à 7 buts)" % [h_c, a_c])
			po_banner.set_custom_color(0, Color("38bdf8"))
	elif viewed_league.is_playoffs_finished():
		var po_banner = standings_tree.create_item(root)
		po_banner.set_selectable(0, false)
		var ch_name = viewed_league.playoff_champion.club_name.to_upper() if viewed_league.playoff_champion else ""
		po_banner.set_text(0, "👑 CHAMPION : %s (Titre Playoffs)" % ch_name)
		po_banner.set_custom_color(0, Color("10b981"))

	var sorted = viewed_league.get_sorted_standings()
	for i in sorted.size():
		var c = sorted[i]
		var d = viewed_league.standings[c]
		var row = standings_tree.create_item(root)
		row.set_metadata(0, c)
		var playoff_tag = ""
		if i == 0:
			playoff_tag = " ⭐ [Finale]"
		elif i == 1 or i == 2:
			playoff_tag = " ⚔️ [Playoff 1/2]"

		row.set_text(0, "%d. %s%s" % [i + 1, c.club_name, playoff_tag])
		row.set_text(1, str(d["pts"]))
		row.set_text(2, str(d["p"]))
		row.set_text(3, str(d["w"]))
		row.set_text(4, str(d["l"]))
		row.set_text(5, "%+d" % d["gd"])
		var f_str = c.get_form_string(5)
		row.set_text(6, f_str if not f_str.is_empty() else "-")
		if c == player_club:
			row.set_custom_color(0, Color("facc15"))
		elif c == viewed_club:
			row.set_custom_color(0, Color("38bdf8"))

	if viewed_club == null or not viewed_league.clubs.has(viewed_club):
		viewed_club = sorted[0]

	_render_club_roster(viewed_club)

func _render_european_cup_view() -> void:
	standings_tree.clear()
	var root = standings_tree.create_item()
	standings_tree.hide_root = true
	standings_tree.columns = 7
	standings_tree.set_column_title(0, "Club")
	standings_tree.set_column_title(1, "Pts")
	standings_tree.set_column_title(2, "J")
	standings_tree.set_column_title(3, "V")
	standings_tree.set_column_title(4, "N")
	standings_tree.set_column_title(5, "D")
	standings_tree.set_column_title(6, "Diff")
	standings_tree.set_column_titles_visible(true)

	standings_tree.set_column_expand(0, true)
	standings_tree.set_column_custom_minimum_width(0, 110)
	for col in range(1, 7):
		standings_tree.set_column_expand(col, false)
		standings_tree.set_column_custom_minimum_width(col, 34)

	if active_european_cup == null:
		label_standings_title.text = "🏆 Coupe d'Europe (Qualifiés en fin de championnat)"
		var d1_leagues = all_leagues.filter(func(l): return l.division == 1)
		var note_item = standings_tree.create_item(root)
		note_item.set_text(0, "Clubs qualifiés (1er & 2e de chaque D1) :")
		note_item.set_custom_color(0, Color("facc15"))
		for l in d1_leagues:
			var st = l.get_sorted_standings()
			if st.size() >= 1:
				var r1 = standings_tree.create_item(root)
				r1.set_metadata(0, st[0])
				r1.set_text(0, "• 1er %s: %s" % [l.country, st[0].club_name])
				if st[0] == player_club:
					r1.set_custom_color(0, Color("facc15"))
			if st.size() >= 2:
				var r2 = standings_tree.create_item(root)
				r2.set_metadata(0, st[1])
				r2.set_text(0, "• 2e %s: %s" % [l.country, st[1].club_name])
				if st[1] == player_club:
					r2.set_custom_color(0, Color("facc15"))
		return

	label_standings_title.text = "🏆 %s" % active_european_cup.get_current_phase_name()

	# Section Groupe A
	var h_a = standings_tree.create_item(root)
	h_a.set_text(0, "=== GROUPE A ===")
	h_a.set_custom_color(0, Color("38bdf8"))
	var st_a = active_european_cup.get_group_standings_sorted(true)
	for i in st_a.size():
		var row_d = st_a[i]
		var c: Club = row_d["club"]
		var r = standings_tree.create_item(root)
		r.set_metadata(0, c)
		r.set_text(0, "%d. %s" % [i + 1, c.club_name])
		r.set_text(1, str(row_d["pts"]))
		r.set_text(2, str(row_d["p"]))
		r.set_text(3, str(row_d["w"]))
		r.set_text(4, str(row_d["d"]))
		r.set_text(5, str(row_d["l"]))
		r.set_text(6, "%+d" % row_d["gd"])
		if c == player_club:
			r.set_custom_color(0, Color("facc15"))
		elif c == viewed_club:
			r.set_custom_color(0, Color("38bdf8"))

	# Section Groupe B
	var h_b = standings_tree.create_item(root)
	h_b.set_text(0, "=== GROUPE B ===")
	h_b.set_custom_color(0, Color("38bdf8"))
	var st_b = active_european_cup.get_group_standings_sorted(false)
	for i in st_b.size():
		var row_d = st_b[i]
		var c: Club = row_d["club"]
		var r = standings_tree.create_item(root)
		r.set_metadata(0, c)
		r.set_text(0, "%d. %s" % [i + 1, c.club_name])
		r.set_text(1, str(row_d["pts"]))
		r.set_text(2, str(row_d["p"]))
		r.set_text(3, str(row_d["w"]))
		r.set_text(4, str(row_d["d"]))
		r.set_text(5, str(row_d["l"]))
		r.set_text(6, "%+d" % row_d["gd"])
		if c == player_club:
			r.set_custom_color(0, Color("facc15"))
		elif c == viewed_club:
			r.set_custom_color(0, Color("38bdf8"))

	if active_european_cup.current_phase >= 4:
		var h_ko = standings_tree.create_item(root)
		h_ko.set_text(0, "=== PHASE FINALE ===")
		h_ko.set_custom_color(0, Color("facc15"))
		if not active_european_cup.semi_final_1.is_empty():
			var semi1 = standings_tree.create_item(root)
			var s1_res = active_european_cup.semi_results.get(active_european_cup.semi_final_1, {})
			var s1_str = " (%s)" % s1_res["score"] if s1_res.has("score") else ""
			semi1.set_text(0, "Demi 1: %s vs %s%s" % [active_european_cup.semi_final_1[0].club_name, active_european_cup.semi_final_1[1].club_name, s1_str])
			semi1.set_metadata(0, active_european_cup.semi_final_1[0])
		if not active_european_cup.semi_final_2.is_empty():
			var semi2 = standings_tree.create_item(root)
			var s2_res = active_european_cup.semi_results.get(active_european_cup.semi_final_2, {})
			var s2_str = " (%s)" % s2_res["score"] if s2_res.has("score") else ""
			semi2.set_text(0, "Demi 2: %s vs %s%s" % [active_european_cup.semi_final_2[0].club_name, active_european_cup.semi_final_2[1].club_name, s2_str])
			semi2.set_metadata(0, active_european_cup.semi_final_2[0])

	if active_european_cup.current_phase >= 5 and not active_european_cup.finalists.is_empty():
		var f_row = standings_tree.create_item(root)
		var f_str = " (%s)" % active_european_cup.final_result["score"] if active_european_cup.final_result != null else ""
		f_row.set_text(0, "FINALE: %s vs %s%s" % [active_european_cup.finalists[0].club_name, active_european_cup.finalists[1].club_name, f_str])
		f_row.set_custom_color(0, Color("facc15"))
		f_row.set_metadata(0, active_european_cup.finalists[0])

	if active_european_cup.winner != null:
		var win_row = standings_tree.create_item(root)
		win_row.set_text(0, "🏆 VAINQUEUR : %s" % active_european_cup.winner.club_name)
		win_row.set_custom_color(0, Color("34d399"))
		win_row.set_metadata(0, active_european_cup.winner)

func _on_standings_item_selected() -> void:
	var selected_item = standings_tree.get_selected()
	if selected_item != null:
		var c = selected_item.get_metadata(0) as Club
		if c != null:
			viewed_club = c
			_render_club_roster(c)

func _render_club_roster(c: Club) -> void:
	if c == null:
		return

	club_detail_badge.shape = c.badge_shape
	club_detail_badge.symbol = c.badge_symbol
	club_detail_badge.primary_color = c.primary_color
	club_detail_badge.secondary_color = c.secondary_color
	club_detail_badge.queue_redraw()

	var flag = "🌍"
	match c.country:
		"France": flag = "🇫🇷"
		"Espagne": flag = "🇪🇸"
		"Italie": flag = "🇮🇹"
		"Portugal": flag = "🇵🇹"
		"Angleterre": flag = "🇬🇧"
		"Allemagne": flag = "🇩🇪"

	label_club_detail_name.text = c.club_name
	label_club_detail_sub.text = "%s %s (Div %d) | Budget: %s €" % [flag, c.country, c.division, String.num_int64(c.budget)]

	for child in club_roster_list.get_children():
		child.queue_free()

	# Section Forme Récente / Dernières Performances
	var form_container = PanelContainer.new()
	var fc_style = StyleBoxFlat.new()
	fc_style.bg_color = Color(0.08, 0.12, 0.2, 0.95)
	fc_style.set_corner_radius_all(8)
	fc_style.border_width_left = 1
	fc_style.border_width_top = 1
	fc_style.border_width_right = 1
	fc_style.border_width_bottom = 1
	fc_style.border_color = Color(0.2, 0.28, 0.4, 0.7)
	fc_style.content_margin_left = 12
	fc_style.content_margin_right = 12
	fc_style.content_margin_top = 8
	fc_style.content_margin_bottom = 8
	form_container.add_theme_stylebox_override("panel", fc_style)

	var form_vbox = VBoxContainer.new()
	form_vbox.add_theme_constant_override("separation", 6)

	var form_header = Label.new()
	form_header.text = "📊 Dernières Performances (5 derniers matchs) :"
	form_header.add_theme_font_size_override("font_size", 12)
	form_header.add_theme_color_override("font_color", Color("94a3b8"))
	form_vbox.add_child(form_header)

	var form_hbox = HBoxContainer.new()
	form_hbox.add_theme_constant_override("separation", 6)

	if c.recent_form.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "Aucun match joué cette saison"
		empty_lbl.add_theme_font_size_override("font_size", 11)
		empty_lbl.add_theme_color_override("font_color", Color("64748b"))
		form_hbox.add_child(empty_lbl)
	else:
		var count = mini(c.recent_form.size(), 5)
		for i in range(count - 1, -1, -1):
			var m = c.recent_form[i]
			var res = m.get("result", "-")
			var sf = m.get("score_for", 0)
			var sa = m.get("score_against", 0)
			var opp = m.get("opponent", "")
			var is_h = m.get("is_home", true)
			var loc = "Dom." if is_h else "Ext."

			var badge = PanelContainer.new()
			var b_style = StyleBoxFlat.new()
			b_style.set_corner_radius_all(6)
			b_style.content_margin_left = 8
			b_style.content_margin_right = 8
			b_style.content_margin_top = 3
			b_style.content_margin_bottom = 3
			badge.tooltip_text = "%s : %d-%d contre %s (%s)" % [
				"Victoire" if res == "V" else "Défaite",
				sf, sa, opp, loc
			]

			var lbl = Label.new()
			lbl.add_theme_font_size_override("font_size", 11)
			if res == "V":
				b_style.bg_color = Color(0.06, 0.35, 0.18, 0.9)
				b_style.border_color = Color("10b981")
				lbl.text = "V %d-%d" % [sf, sa]
				lbl.add_theme_color_override("font_color", Color("34d399"))
			else:
				b_style.bg_color = Color(0.35, 0.08, 0.1, 0.9)
				b_style.border_color = Color("ef4444")
				lbl.text = "D %d-%d" % [sf, sa]
				lbl.add_theme_color_override("font_color", Color("f87171"))

			b_style.border_width_left = 1
			b_style.border_width_top = 1
			b_style.border_width_right = 1
			b_style.border_width_bottom = 1
			badge.add_theme_stylebox_override("panel", b_style)
			badge.add_child(lbl)
			form_hbox.add_child(badge)

	form_vbox.add_child(form_hbox)
	form_container.add_child(form_vbox)
	club_roster_list.add_child(form_container)

	var roster_header = Label.new()
	roster_header.text = "👥 Effectif du Club (%d joueurs) :" % c.squad.size()
	roster_header.add_theme_font_size_override("font_size", 13)
	roster_header.add_theme_color_override("font_color", Color("e2e8f0"))
	club_roster_list.add_child(roster_header)

	for p in c.squad:
		var card = PanelContainer.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.08, 0.11, 0.18, 0.9)
		p_style.set_corner_radius_all(8)
		p_style.border_width_left = 1
		p_style.border_width_top = 1
		p_style.border_width_right = 1
		p_style.border_width_bottom = 1
		p_style.border_color = Color(0.18, 0.24, 0.35, 0.6)
		p_style.content_margin_left = 10
		p_style.content_margin_right = 10
		p_style.content_margin_top = 6
		p_style.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel", p_style)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER

		# 1. Badge Poste
		var pos_panel = PanelContainer.new()
		var pos_style = StyleBoxFlat.new()
		pos_style.set_corner_radius_all(6)
		pos_style.content_margin_left = 6
		pos_style.content_margin_right = 6
		pos_style.content_margin_top = 2
		pos_style.content_margin_bottom = 2

		var pos_text = "MIL"
		var pos_color = Color("10b981")
		match p.position:
			Player.Position.GK:
				pos_text = "GAR"
				pos_color = Color("f59e0b")
			Player.Position.DEF:
				pos_text = "DEF"
				pos_color = Color("38bdf8")
			Player.Position.MID:
				pos_text = "MIL"
				pos_color = Color("10b981")
			Player.Position.FWD:
				pos_text = "ATT"
				pos_color = Color("f43f5e")

		pos_style.bg_color = Color(pos_color.r, pos_color.g, pos_color.b, 0.16)
		pos_style.border_color = pos_color
		pos_style.border_width_left = 1
		pos_style.border_width_top = 1
		pos_style.border_width_right = 1
		pos_style.border_width_bottom = 1
		pos_panel.add_theme_stylebox_override("panel", pos_style)

		var pos_tag = Label.new()
		pos_tag.text = pos_text
		pos_tag.add_theme_color_override("font_color", pos_color)
		pos_tag.add_theme_font_size_override("font_size", 12)
		pos_panel.add_child(pos_tag)
		hbox.add_child(pos_panel)

		# 2. Badge OVR
		var ovr_panel = PanelContainer.new()
		var ovr_style = StyleBoxFlat.new()
		ovr_style.set_corner_radius_all(6)
		ovr_style.bg_color = Color(0.14, 0.18, 0.26, 0.95)
		ovr_style.content_margin_left = 6
		ovr_style.content_margin_right = 6
		ovr_style.content_margin_top = 2
		ovr_style.content_margin_bottom = 2
		ovr_panel.add_theme_stylebox_override("panel", ovr_style)

		var ovr_lbl = Label.new()
		var ovr = p.get_overall()
		ovr_lbl.text = "%d" % ovr
		ovr_lbl.add_theme_font_size_override("font_size", 14)
		if ovr >= 14:
			ovr_lbl.add_theme_color_override("font_color", Color(0.98, 0.85, 0.3))
		elif ovr >= 11:
			ovr_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.95))
		else:
			ovr_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		ovr_panel.add_child(ovr_lbl)
		hbox.add_child(ovr_panel)

		# 3. Nom & Détail
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 1)

		var name_lbl = Label.new()
		name_lbl.text = p.full_name
		name_lbl.add_theme_font_size_override("font_size", 14)
		name_lbl.add_theme_color_override("font_color", Color(0.96, 0.97, 0.99))
		name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		info_vbox.add_child(name_lbl)

		var sub_lbl = Label.new()
		sub_lbl.text = "%s • %d ans" % [p.nationality, p.age]
		sub_lbl.add_theme_font_size_override("font_size", 12)
		sub_lbl.add_theme_color_override("font_color", Color(0.65, 0.75, 0.88))
		info_vbox.add_child(sub_lbl)

		hbox.add_child(info_vbox)

		# 4. Valeur Marchande
		var price_lbl = Label.new()
		price_lbl.text = "%s €" % String.num_int64(p.market_value)
		price_lbl.add_theme_color_override("font_color", Color(0.95, 0.82, 0.28))
		price_lbl.add_theme_font_size_override("font_size", 13)
		hbox.add_child(price_lbl)

		# 5. Bouton Fiche
		var btn_fiche = Button.new()
		btn_fiche.text = "👁️ Fiche"
		btn_fiche.custom_minimum_size = Vector2(76, 32)
		var f_style = StyleBoxFlat.new()
		f_style.bg_color = Color(0.16, 0.23, 0.36)
		f_style.set_corner_radius_all(6)
		btn_fiche.add_theme_stylebox_override("normal", f_style)
		var f_hov = f_style.duplicate()
		f_hov.bg_color = Color(0.24, 0.35, 0.52)
		btn_fiche.add_theme_stylebox_override("hover", f_hov)
		btn_fiche.add_theme_font_size_override("font_size", 12)
		btn_fiche.pressed.connect(func():
			player_detail_modal.open_player(p, c)
		)
		hbox.add_child(btn_fiche)

		if c != player_club:
			var btn_buy = Button.new()
			btn_buy.text = "Négocier"
			btn_buy.custom_minimum_size = Vector2(80, 32)
			var b_style = StyleBoxFlat.new()
			b_style.bg_color = Color(0.12, 0.35, 0.55)
			b_style.set_corner_radius_all(6)
			btn_buy.add_theme_stylebox_override("normal", b_style)
			var b_hov = b_style.duplicate()
			b_hov.bg_color = Color(0.15, 0.45, 0.70)
			btn_buy.add_theme_stylebox_override("hover", b_hov)
			btn_buy.add_theme_font_size_override("font_size", 12)
			btn_buy.pressed.connect(func():
				open_club_transfer_negotiation(p, c)
			)
			hbox.add_child(btn_buy)

		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				player_detail_modal.open_player(p, c)
		)

		card.add_child(hbox)
		club_roster_list.add_child(card)

func _render_market_view() -> void:
	var list = $Body/MainContent/TabMarket/ScrollContainer/FreeAgentList
	for c in list.get_children():
		c.queue_free()

	if player_club and player_club.is_transfer_banned:
		var ban_panel = PanelContainer.new()
		var ban_style = StyleBoxFlat.new()
		ban_style.bg_color = Color(0.4, 0.08, 0.1, 0.95)
		ban_style.border_color = Color("f87171")
		ban_style.border_width_left = 4
		ban_style.set_corner_radius_all(8)
		ban_style.content_margin_left = 14
		ban_style.content_margin_right = 14
		ban_style.content_margin_top = 10
		ban_style.content_margin_bottom = 10
		ban_panel.add_theme_stylebox_override("panel", ban_style)

		var ban_lbl = Label.new()
		ban_lbl.text = "🚫 INTERDICTION DE RECRUTEMENT (FAIR-PLAY FINANCIER)\nVotre club a terminé la saison dernière avec un résultat fixe hebdomadaire déficitaire. Tout recrutement (achats et agents libres) est suspendu pour l'exercice en cours. Assainissez votre masse salariale !"
		ban_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ban_lbl.add_theme_font_size_override("font_size", 12)
		ban_lbl.add_theme_color_override("font_color", Color.WHITE)
		ban_panel.add_child(ban_lbl)
		list.add_child(ban_panel)

	var sel_country_idx = opt_market_country.selected
	var sel_pos_idx = opt_market_pos.selected

	var target_country = ""
	if sel_country_idx > 0:
		var full_str = opt_market_country.get_item_text(sel_country_idx)
		target_country = full_str.split(" ")[-1]

	var target_pos = -1
	if sel_pos_idx > 0:
		target_pos = sel_pos_idx - 1

	# Trier les agents libres par note globale (OVR) décroissante pour une lisibilité optimale
	var sorted_agents: Array[Player] = market.free_agents.duplicate()
	sorted_agents.sort_custom(func(a, b): return a.get_overall() > b.get_overall())

	var count_rendered = 0
	for p in sorted_agents:
		if target_country != "" and p.nationality != target_country:
			continue
		if target_pos != -1 and p.position != target_pos:
			continue

		count_rendered += 1
		var panel = PanelContainer.new()
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.08, 0.11, 0.18, 0.9)
		p_style.set_corner_radius_all(8)
		p_style.border_width_left = 1
		p_style.border_width_top = 1
		p_style.border_width_right = 1
		p_style.border_width_bottom = 1
		p_style.border_color = Color(0.18, 0.24, 0.35, 0.6)
		p_style.content_margin_left = 12
		p_style.content_margin_right = 12
		p_style.content_margin_top = 8
		p_style.content_margin_bottom = 8
		panel.add_theme_stylebox_override("panel", p_style)

		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		# 1. Badge Poste (Coloré et épuré)
		var pos_panel = PanelContainer.new()
		var pos_style = StyleBoxFlat.new()
		pos_style.set_corner_radius_all(6)
		pos_style.content_margin_left = 8
		pos_style.content_margin_right = 8
		pos_style.content_margin_top = 3
		pos_style.content_margin_bottom = 3

		var pos_text = "MIL"
		var pos_col = Color("10b981")
		match p.position:
			Player.Position.GK:
				pos_text = "GAR"
				pos_col = Color("f59e0b")
			Player.Position.DEF:
				pos_text = "DEF"
				pos_col = Color("38bdf8")
			Player.Position.MID:
				pos_text = "MIL"
				pos_col = Color("10b981")
			Player.Position.FWD:
				pos_text = "ATT"
				pos_col = Color("f43f5e")

		pos_style.bg_color = Color(pos_col.r, pos_col.g, pos_col.b, 0.16)
		pos_style.border_color = pos_col
		pos_style.border_width_left = 1
		pos_style.border_width_top = 1
		pos_style.border_width_right = 1
		pos_style.border_width_bottom = 1
		pos_panel.add_theme_stylebox_override("panel", pos_style)

		var pos_lbl = Label.new()
		pos_lbl.text = pos_text
		pos_lbl.add_theme_color_override("font_color", pos_col)
		pos_lbl.add_theme_font_size_override("font_size", 11)
		pos_panel.add_child(pos_lbl)
		row.add_child(pos_panel)

		# 2. Badge OVR (Note globale en évidence)
		var ovr_panel = PanelContainer.new()
		var ovr_style = StyleBoxFlat.new()
		ovr_style.set_corner_radius_all(6)
		ovr_style.bg_color = Color(0.14, 0.18, 0.26, 0.95)
		ovr_style.content_margin_left = 8
		ovr_style.content_margin_right = 8
		ovr_style.content_margin_top = 3
		ovr_style.content_margin_bottom = 3
		ovr_panel.add_theme_stylebox_override("panel", ovr_style)

		var ovr_lbl = Label.new()
		var ovr = p.get_overall()
		ovr_lbl.text = "%d" % ovr
		ovr_lbl.add_theme_font_size_override("font_size", 13)
		if ovr >= 14:
			ovr_lbl.add_theme_color_override("font_color", Color(0.98, 0.85, 0.3)) # Or
		elif ovr >= 11:
			ovr_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.95)) # Cyan
		else:
			ovr_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
		ovr_panel.add_child(ovr_lbl)
		row.add_child(ovr_panel)

		# 3. Nom du Joueur & Nationalité / Âge
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.add_theme_constant_override("separation", 2)

		var name_lbl = Label.new()
		name_lbl.text = p.full_name
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", Color(0.96, 0.97, 0.99))
		name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		info_vbox.add_child(name_lbl)

		var sub_lbl = Label.new()
		sub_lbl.text = "%s • %d ans" % [p.nationality, p.age]
		sub_lbl.add_theme_font_size_override("font_size", 11)
		sub_lbl.add_theme_color_override("font_color", Color(0.62, 0.72, 0.84))
		info_vbox.add_child(sub_lbl)

		row.add_child(info_vbox)

		# 4. Bloc Financier : Salaire demandé & Valeur
		var fin_vbox = VBoxContainer.new()
		fin_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		fin_vbox.add_theme_constant_override("separation", 1)

		var wage_lbl = Label.new()
		wage_lbl.text = "%s €/sem" % String.num_int64(p.wage_demand)
		wage_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		wage_lbl.add_theme_font_size_override("font_size", 14)
		wage_lbl.add_theme_color_override("font_color", Color(0.98, 0.82, 0.28))
		fin_vbox.add_child(wage_lbl)

		var val_lbl = Label.new()
		val_lbl.text = "Val : %s €" % String.num_int64(p.market_value)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		val_lbl.add_theme_font_size_override("font_size", 12)
		val_lbl.add_theme_color_override("font_color", Color(0.60, 0.70, 0.82))
		fin_vbox.add_child(val_lbl)

		row.add_child(fin_vbox)

		# 5. Bouton Fiche (disponible pour tous les agents libres)
		var btn_fiche = Button.new()
		btn_fiche.text = "👁️ Fiche"
		btn_fiche.custom_minimum_size = Vector2(80, 34)
		var f_style = StyleBoxFlat.new()
		f_style.bg_color = Color(0.16, 0.23, 0.36)
		f_style.set_corner_radius_all(6)
		btn_fiche.add_theme_stylebox_override("normal", f_style)
		var f_hov = f_style.duplicate()
		f_hov.bg_color = Color(0.24, 0.35, 0.52)
		btn_fiche.add_theme_stylebox_override("hover", f_hov)
		btn_fiche.add_theme_font_size_override("font_size", 13)
		btn_fiche.pressed.connect(func():
			player_detail_modal.open_player(p, null)
		)
		row.add_child(btn_fiche)

		# 6. Bouton Négocier
		var btn = Button.new()
		btn.text = "Négocier"
		btn.custom_minimum_size = Vector2(90, 34)
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = Color(0.08, 0.45, 0.3)
		b_style.set_corner_radius_all(6)
		btn.add_theme_stylebox_override("normal", b_style)
		var b_hov = b_style.duplicate()
		b_hov.bg_color = Color(0.1, 0.58, 0.38)
		btn.add_theme_stylebox_override("hover", b_hov)
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(func():
			open_negotiation(p, null)
		)
		row.add_child(btn)

		# Interaction : cliquer sur la carte ouvre le profil complet
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		panel.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				player_detail_modal.open_player(p, null)
		)

		panel.add_child(row)
		list.add_child(panel)

	if count_rendered == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = "Aucun joueur libre correspondant aux critères."
		list.add_child(empty_lbl)

func _render_inbox_view() -> void:
	var list = $Body/MainContent/TabInbox/ScrollContainer/InboxList
	for c in list.get_children():
		c.queue_free()
	if market.pending_offers.is_empty():
		var l = Label.new()
		l.text = "Aucune offre en cours."
		list.add_child(l)
		return

	for o in market.pending_offers:
		var panel = PanelContainer.new()
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 15)

		var desc = Label.new()
		desc.size_flags_horizontal = SIZE_EXPAND_FILL
		var btn_accept = Button.new()
		btn_accept.text = "Accepter"
		btn_accept.modulate = Color("10b981")
		var btn_refuse = Button.new()
		btn_refuse.text = "Refuser"
		btn_refuse.modulate = Color("ef4444")

		if o.offer_type == TransferOffer.Type.PLAYER_PURCHASE:
			desc.text = "💰 %s propose %s € pour recruter %s." % [o.sender_club.club_name, String.num_int64(o.transfer_fee), o.target_player.full_name]
			btn_accept.pressed.connect(func():
				market.accept_transfer_offer(o, player_club)
				_update_topbar()
				_render_inbox_view()
				_render_squad_view()
			)
		elif o.offer_type == TransferOffer.Type.JOB_OFFER:
			desc.text = "👔 %s (%s) vous propose le poste de manager (Budget: %s €)." % [o.sender_club.club_name, o.sender_club.country, String.num_int64(o.sender_club.budget)]
			btn_accept.pressed.connect(func():
				player_club = o.sender_club
				for l in all_leagues:
					if l.clubs.has(player_club):
						current_league = l
						viewed_league = l
						break
				market.pending_offers.erase(o)
				market.inbox_updated.emit()
				_update_topbar()
				_init_tactics_ui()
				_render_inbox_view()
				_render_squad_view()
				_render_standings_view()
			)

		btn_refuse.pressed.connect(func():
			market.reject_offer(o)
			_render_inbox_view()
		)

		row.add_child(desc)
		row.add_child(btn_accept)
		row.add_child(btn_refuse)
		panel.add_child(row)
		list.add_child(panel)

func _update_topbar() -> void:
	user_club_badge.shape = player_club.badge_shape
	user_club_badge.symbol = player_club.badge_symbol
	user_club_badge.primary_color = player_club.primary_color
	user_club_badge.secondary_color = player_club.secondary_color
	user_club_badge.queue_redraw()

	label_club.text = "%s (D%d - %s)" % [player_club.club_name, player_club.division, player_club.country]
	label_budget.text = "Budget : %s €" % String.num_int64(player_club.budget)

	var s_names = ["Équilibré", "Attaque", "Contre"]
	var t_names = ["Cryo", "Tir", "Défense"]
	tactic_label.text = "[%s | %s]" % [s_names[player_club.tactical_style], t_names[player_club.training_focus]]

	var total_days = current_league.schedule.size()
	if current_league.current_matchday_index < total_days:
		label_week.text = "Saison %d • J%d/%d (5 buts)" % [current_season, current_league.current_matchday_index + 1, total_days]
		btn_advance.text = "⚡ Avant-Match (J%d) ▶" % [current_league.current_matchday_index + 1]
		btn_advance.disabled = false
	elif not current_league.is_playoffs_finished():
		if not current_league.has_playoffs_started():
			label_week.text = "Saison %d • Playoffs Top 3" % current_season
			btn_advance.text = "🏆 Lancer les Playoffs ▶"
			btn_advance.disabled = false
		elif current_league.playoff_phase == 1:
			var h = current_league.playoff_semi_home
			var a = current_league.playoff_semi_away
			label_week.text = "Playoffs : 1/2 Finale (%s vs %s)" % [h.club_name, a.club_name]
			if player_club == h or player_club == a:
				btn_advance.text = "⚡ Avant-Match (1/2 Finale) ▶"
			else:
				btn_advance.text = "👁️ Assister 1/2 Finale ▶"
			btn_advance.disabled = false
		elif current_league.playoff_phase == 2:
			var h = current_league.playoff_final_home
			var a = current_league.playoff_final_away
			label_week.text = "Playoffs : FINALE (%s vs %s)" % [h.club_name, a.club_name]
			if player_club == h or player_club == a:
				btn_advance.text = "⚡ Avant-Match (FINALE) ▶"
			else:
				btn_advance.text = "👁️ Assister GRANDE FINALE ▶"
			btn_advance.disabled = false
	else:
		var champ_name = current_league.playoff_champion.club_name if current_league.playoff_champion else "Champion"
		if active_european_cup == null:
			label_week.text = "Champion : %s !" % champ_name
			btn_advance.text = "🏆 Lancer Coupe d'Europe ▶"
			btn_advance.disabled = false
		elif active_european_cup.current_phase < 6:
			label_week.text = active_european_cup.get_current_phase_name()
			var user_match = active_european_cup.get_user_match_in_current_phase(player_club)
			if user_match.size() >= 2:
				btn_advance.text = "⚡ Avant-Match (Europe) ▶"
			else:
				btn_advance.text = "👁️ Assister Match Europe ▶"
			btn_advance.disabled = false
		else:
			var win_name = active_european_cup.winner.club_name if active_european_cup.winner else "Terminé"
			label_week.text = "Champion : %s | Europe : %s" % [champ_name, win_name]
			btn_advance.text = "🏁 Bilan & Nouvelle Saison ▶"
			btn_advance.disabled = false

func _style_advance_button() -> void:
	if btn_advance == null:
		return
	btn_advance.custom_minimum_size = Vector2(210, 40)
	btn_advance.add_theme_font_size_override("font_size", 13)

	var normal_box = StyleBoxFlat.new()
	normal_box.bg_color = Color("059669")
	normal_box.border_color = Color("34d399")
	normal_box.border_width_left = 2
	normal_box.border_width_top = 2
	normal_box.border_width_right = 2
	normal_box.border_width_bottom = 2
	normal_box.set_corner_radius_all(8)
	normal_box.content_margin_left = 16
	normal_box.content_margin_right = 16
	normal_box.content_margin_top = 8
	normal_box.content_margin_bottom = 8
	btn_advance.add_theme_stylebox_override("normal", normal_box)

	var hover_box = normal_box.duplicate()
	hover_box.bg_color = Color("10b981")
	hover_box.border_color = Color("a7f3d0")
	btn_advance.add_theme_stylebox_override("hover", hover_box)

	var pressed_box = normal_box.duplicate()
	pressed_box.bg_color = Color("047857")
	btn_advance.add_theme_stylebox_override("pressed", pressed_box)

	btn_advance.add_theme_stylebox_override("focus", hover_box)
	btn_advance.add_theme_color_override("font_color", Color.WHITE)
	btn_advance.add_theme_color_override("font_hover_color", Color.WHITE)
	btn_advance.add_theme_color_override("font_pressed_color", Color("e2e8f0"))

enum MatchContext { REGULAR, PLAYOFF_SEMI, PLAYOFF_FINAL, EUROPEAN }
var current_match_context: MatchContext = MatchContext.REGULAR
var current_user_report: MatchEngine.MatchReport
var pending_user_match: Array = []

func _on_btn_advance_pressed() -> void:
	if match_modal.visible or pre_match_modal.visible:
		return
	if not player_club.is_lineup_valid():
		player_club.auto_pick_lineup()
		_render_squad_view()

	# Cas 1 : Championnat régulier (5 buts gagnants)
	if current_league.current_matchday_index < current_league.schedule.size():
		current_match_context = MatchContext.REGULAR
		var day_matches = current_league.schedule[current_league.current_matchday_index]
		pending_user_match = []
		for pair in day_matches:
			if pair[0] == player_club or pair[1] == player_club:
				pending_user_match = pair
				break

		if pending_user_match.size() >= 2:
			var opp: Club = pending_user_match[1] if pending_user_match[0] == player_club else pending_user_match[0]
			pre_match_modal.setup(player_club, opp, "Journée %d / %d (Premier à 5 buts)" % [current_league.current_matchday_index + 1, current_league.schedule.size()])
		else:
			_on_pre_match_kickoff(true)
		return

	# Cas 2 : Playoffs du Championnat (Top 3 en 7 buts gagnants)
	if not current_league.is_playoffs_finished():
		if not current_league.has_playoffs_started():
			current_league.init_playoffs()
			for l in all_leagues:
				if l != current_league:
					l.init_playoffs()
			show_toast("🏆 Début des Playoffs de la Ligue ! (Matchs en 7 buts gagnants)")
			_update_topbar()
			_render_standings_view()
			return

		if current_league.playoff_phase == 1:
			current_match_context = MatchContext.PLAYOFF_SEMI
			var h = current_league.playoff_semi_home
			var a = current_league.playoff_semi_away
			pending_user_match = [h, a]
			if player_club == h:
				pre_match_modal.setup(player_club, a, "Playoffs : Demi-Finale (1er à 7 buts)", false)
			elif player_club == a:
				pre_match_modal.setup(player_club, h, "Playoffs : Demi-Finale (1er à 7 buts)", false)
			else:
				pre_match_modal.setup(h, a, "Playoffs : Demi-Finale (1er à 7 buts)", true)
			return

		elif current_league.playoff_phase == 2:
			current_match_context = MatchContext.PLAYOFF_FINAL
			var h = current_league.playoff_final_home
			var a = current_league.playoff_final_away
			pending_user_match = [h, a]
			if player_club == h:
				pre_match_modal.setup(player_club, a, "Playoffs : GRANDE FINALE (1er à 7 buts)", false)
			elif player_club == a:
				pre_match_modal.setup(player_club, h, "Playoffs : GRANDE FINALE (1er à 7 buts)", false)
			else:
				pre_match_modal.setup(h, a, "Playoffs : GRANDE FINALE (1er à 7 buts)", true)
			return

	# Cas 3 : Playoffs terminés, Coupe d'Europe
	current_match_context = MatchContext.EUROPEAN
	if active_european_cup == null:
		active_european_cup = EuropeanCup.new()
		var ok = active_european_cup.init_cup(all_leagues)
		if not ok:
			show_toast("Impossible de lancer la Coupe d'Europe.", true)
			return
		show_toast("🏆 Début de la Coupe d'Europe avec les 10 meilleurs clubs européens !")
		is_viewing_european_cup = true
		btn_european_cup.text = "⚽ Voir Championnat"
		_update_topbar()
		_render_standings_view()
		return

	if active_european_cup.current_phase < 6:
		var user_pair = active_european_cup.get_user_match_in_current_phase(player_club)
		if user_pair.size() >= 2:
			pending_user_match = user_pair
			var opp: Club = user_pair[1] if user_pair[0] == player_club else user_pair[0]
			pre_match_modal.setup(player_club, opp, active_european_cup.get_current_phase_name(), false)
		else:
			var fixtures = active_european_cup.get_current_fixtures()
			if fixtures.size() > 0 and fixtures[0].size() >= 2:
				pending_user_match = fixtures[0]
				pre_match_modal.setup(fixtures[0][0], fixtures[0][1], active_european_cup.get_current_phase_name(), true)
			else:
				_simulate_european_phase_ai_only()
		return

	# Cas 4 : Saison complètement terminée -> Bilan & Nouvelle Saison
	_trigger_season_transition()

func _on_pre_match_kickoff(skip_live: bool) -> void:
	match current_match_context:
		MatchContext.REGULAR:
			var day_matches = current_league.schedule[current_league.current_matchday_index]
			for pair in day_matches:
				var h: Club = pair[0]
				var a: Club = pair[1]
				if h != player_club and a != player_club:
					var rep = MatchEngine.simulate_match(h, a, 5)
					current_league.record_match_result(h, a, rep.home_score, rep.away_score)

			if pending_user_match.size() >= 2:
				var h: Club = pending_user_match[0]
				var a: Club = pending_user_match[1]
				current_user_report = MatchEngine.simulate_match(h, a, 5)
				match_modal.visible = true
				if skip_live:
					match_view.show_quick_summary(current_user_report)
				else:
					match_view.setup_match(current_user_report)
			else:
				_finalize_league_matchday()

		MatchContext.PLAYOFF_SEMI:
			if pending_user_match.size() >= 2:
				var h: Club = pending_user_match[0]
				var a: Club = pending_user_match[1]
				current_user_report = MatchEngine.simulate_match(h, a, 7)
				match_modal.visible = true
				if skip_live:
					match_view.show_quick_summary(current_user_report)
				else:
					match_view.setup_match(current_user_report)
			else:
				_finalize_playoff_semi()

		MatchContext.PLAYOFF_FINAL:
			if pending_user_match.size() >= 2:
				var h: Club = pending_user_match[0]
				var a: Club = pending_user_match[1]
				current_user_report = MatchEngine.simulate_match(h, a, 7)
				match_modal.visible = true
				if skip_live:
					match_view.show_quick_summary(current_user_report)
				else:
					match_view.setup_match(current_user_report)
			else:
				_finalize_playoff_final()

		MatchContext.EUROPEAN:
			var fixtures = active_european_cup.get_current_fixtures()
			for pair in fixtures:
				if pair.size() >= 2:
					if pending_user_match.size() >= 2 and pair[0] == pending_user_match[0] and pair[1] == pending_user_match[1]:
						continue
					var rep = MatchEngine.simulate_match(pair[0], pair[1], 5)
					active_european_cup.record_match(pair[0], pair[1], rep.home_score, rep.away_score)

			if pending_user_match.size() >= 2:
				var h: Club = pending_user_match[0]
				var a: Club = pending_user_match[1]
				current_user_report = MatchEngine.simulate_match(h, a, 5)
				match_modal.visible = true
				if skip_live:
					match_view.show_quick_summary(current_user_report)
				else:
					match_view.setup_match(current_user_report)
			else:
				_finalize_european_matchday()

func _on_user_match_finished() -> void:
	match_modal.visible = false
	match current_match_context:
		MatchContext.REGULAR:
			_finalize_league_matchday()
		MatchContext.PLAYOFF_SEMI:
			_finalize_playoff_semi()
		MatchContext.PLAYOFF_FINAL:
			_finalize_playoff_final()
		MatchContext.EUROPEAN:
			_finalize_european_matchday()

func _finalize_playoff_semi() -> void:
	if current_user_report != null:
		var winner = current_league.record_playoff_semi(current_user_report.home_score, current_user_report.away_score)
		if winner == player_club:
			show_toast("🔥 VICTOIRE EN DEMI-FINALE (%d-%d) ! Qualification pour la GRANDE FINALE !" % [current_user_report.home_score, current_user_report.away_score])
		elif current_league.playoff_semi_home == player_club or current_league.playoff_semi_away == player_club:
			show_toast("Défaite en demi-finale (%d-%d). %s se qualifie pour la finale." % [current_user_report.home_score, current_user_report.away_score, winner.club_name], true)
		else:
			show_toast("Playoffs 1/2 : %s %d - %d %s (Qualifié : %s)" % [current_league.playoff_semi_home.club_name, current_user_report.home_score, current_user_report.away_score, current_league.playoff_semi_away.club_name, winner.club_name])

	for c in current_league.clubs: c.recover_fitness()
	for l in all_leagues:
		if l != current_league: l.simulate_ai_playoff_step()

	SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)
	_update_topbar()
	_render_squad_view()
	_render_standings_view()

func _finalize_playoff_final() -> void:
	var champ: Club = null
	var loser: Club = null
	var score_h = 7
	var score_a = 0
	if current_user_report != null:
		champ = current_league.record_playoff_final(current_user_report.home_score, current_user_report.away_score)
		score_h = current_user_report.home_score
		score_a = current_user_report.away_score
	else:
		champ = current_league.playoff_champion

	if champ != null:
		loser = current_league.playoff_final_away if champ == current_league.playoff_final_home else current_league.playoff_final_home
		var is_user = (champ == player_club)
		if is_user:
			player_club.budget += 100_000
			show_toast("👑 CHAMPIONS !!! Votre club remporte les Playoffs et une prime de 100 000 € !")
		else:
			show_toast("Fin des Playoffs : %s est sacré Champion de la Ligue." % champ.club_name)

		trophy_modal.show_league_champion(champ, loser, score_h, score_a, is_user, current_league.league_name)

	for c in current_league.clubs: c.recover_fitness()
	for l in all_leagues:
		if l != current_league: l.simulate_ai_playoff_step()

	SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)
	_update_topbar()
	_render_squad_view()
	_render_standings_view()


func _finalize_league_matchday() -> void:
	if current_user_report != null:
		current_league.record_match_result(
			current_user_report.home_club,
			current_user_report.away_club,
			current_user_report.home_score,
			current_user_report.away_score
		)
	current_league.current_matchday_index += 1

	for c in current_league.clubs:
		c.recover_fitness()

	# Simule la journée pour TOUTES les autres ligues du monde !
	for l in all_leagues:
		if l != current_league:
			l.simulate_ai_matchday()

	for p in market.free_agents:
		p.fitness = minf(1.0, p.fitness + 0.2)

	var all_clubs: Array[Club] = []
	for l in all_leagues:
		for c in l.clubs:
			all_clubs.append(c)

	# Traitement économique hebdomadaire
	var match_rec = 0
	if current_user_report != null:
		var is_home = (current_user_report.home_club == player_club)
		var user_won = (is_home and current_user_report.home_score > current_user_report.away_score) or (not is_home and current_user_report.away_score > current_user_report.home_score)
		if is_home:
			match_rec = player_club.get_finances().process_home_match_receipts(player_club, current_user_report.away_club, false, user_won)
			var bonus_txt = (" • Primes victoire sponsors : +%s €" % String.num_int64(player_club.get_finances().get_total_win_bonus())) if user_won else ""
			show_toast("🏟️ Match à domicile : %d spectateurs • Recettes : +%s €%s" % [
				player_club.get_finances().recent_attendance,
				String.num_int64(match_rec),
				bonus_txt
			])
		elif user_won:
			var win_bonus = player_club.get_finances().get_total_win_bonus()
			player_club.budget += win_bonus
			show_toast("🏆 Victoire à l'extérieur ! Primes sponsors encaissées : +%s €" % String.num_int64(win_bonus))

	player_club.get_finances().process_weekly_cycle(player_club, match_rec)

	# Traitement financier des clubs IA
	for l in all_leagues:
		for c in l.clubs:
			if c != player_club:
				c.get_finances().process_weekly_cycle(c, 0)

	# Évolution hebdomadaire de la formation
	for l in all_leagues:
		for c in l.clubs:
			c.process_weekly_youth_evolution()

	market.process_ai_squad_management(all_clubs, player_club)
	market.trigger_ai_market_activity(player_club, all_clubs)
	SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)
	_update_topbar()
	_update_inbox_badge()
	_render_squad_view()
	_render_standings_view()

func _finalize_european_matchday() -> void:
	if current_user_report != null:
		active_european_cup.record_match(
			current_user_report.home_club,
			current_user_report.away_club,
			current_user_report.home_score,
			current_user_report.away_score
		)
	active_european_cup.advance_phase()

	for l in all_leagues:
		for c in l.clubs:
			c.recover_fitness()
			c.process_weekly_youth_evolution()


	if active_european_cup.current_phase >= 6 and active_european_cup.winner != null:
		var champ = active_european_cup.winner
		var runner_up = active_european_cup.runner_up
		var is_user = (champ == player_club)
		var score_str = "Finale"
		if current_user_report != null:
			score_str = "%d - %d" % [current_user_report.home_score, current_user_report.away_score]
		elif active_european_cup.final_result != null and active_european_cup.final_result.has("score"):
			score_str = active_european_cup.final_result["score"]
		
		trophy_modal.show_european_champion(champ, runner_up, score_str, is_user)
	else:
		show_toast("Coupe d'Europe : Prochaine phase disponible !")

	SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)
	_update_topbar()
	_render_squad_view()
	_render_standings_view()

func _simulate_european_phase_ai_only() -> void:
	var fixtures = active_european_cup.get_current_fixtures()
	for pair in fixtures:
		if pair.size() >= 2:
			var rep = MatchEngine.simulate_match(pair[0], pair[1], 5)
			active_european_cup.record_match(pair[0], pair[1], rep.home_score, rep.away_score)
	active_european_cup.advance_phase()

	for l in all_leagues:
		for c in l.clubs:
			c.recover_fitness()

	if active_european_cup.current_phase >= 6 and active_european_cup.winner != null:
		var champ = active_european_cup.winner
		var runner_up = active_european_cup.runner_up
		var is_user = (champ == player_club)
		var score_str = "Finale"
		if active_european_cup.final_result != null and active_european_cup.final_result.has("score"):
			score_str = active_european_cup.final_result["score"]
		trophy_modal.show_european_champion(champ, runner_up, score_str, is_user)
	else:
		show_toast("Coupe d'Europe : %s terminée." % active_european_cup.get_current_phase_name())

	SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)
	_update_topbar()
	_render_standings_view()

func _on_trophy_acknowledged() -> void:
	if trophy_modal.current_type == TrophyModal.TrophyType.LEAGUE:
		if active_european_cup == null:
			active_european_cup = EuropeanCup.new()
			var ok = active_european_cup.init_cup(all_leagues)
			if ok:
				show_toast("🏆 Début de la Coupe d'Europe avec les 10 meilleurs clubs européens !")
				is_viewing_european_cup = true
				btn_european_cup.text = "⚽ Voir Championnat"
				_update_topbar()
				_render_standings_view()
	elif trophy_modal.current_type == TrophyModal.TrophyType.EUROPEAN:
		_trigger_season_transition()

func _trigger_season_transition() -> void:
	var report = SeasonManager.execute_season_transition(all_leagues, market, player_club, active_european_cup, current_season)
	season_end_modal.setup(report, player_club)

func _on_new_season_started() -> void:
	current_season += 1
	active_european_cup = null
	is_viewing_european_cup = false
	btn_european_cup.text = "🏆 Coupe d'Europe"

	# Retrouver la ligue du joueur (qui peut avoir changé suite aux promotions ou relégations)
	for l in all_leagues:
		if l.clubs.has(player_club):
			current_league = l
			viewed_league = l
			viewed_club = player_club
			break

	# Rafraîchir les menus déroulants de la vue championnat
	_update_leagues_dropdown_for_country(current_league.country)

	SaveManager.save_game(all_leagues, market, player_club, current_league, current_season)

	_update_topbar()
	_render_squad_view()
	_render_standings_view()
	_render_market_view()
	show_toast("🏆 Bienvenue dans la Saison %d ! Bonne chance pour ce nouvel exercice !" % current_season)


func show_toast(msg: String, is_error: bool = false) -> void:
	if toast_tween and toast_tween.is_valid():
		toast_tween.kill()

	var toast_sb = StyleBoxFlat.new()
	toast_sb.bg_color = Color("0f172a")
	toast_sb.border_color = Color("f87171") if is_error else Color("10b981")
	toast_sb.set_border_width_all(2)
	toast_sb.set_corner_radius_all(8)
	toast_sb.content_margin_left = 16
	toast_sb.content_margin_right = 16
	toast_sb.content_margin_top = 8
	toast_sb.content_margin_bottom = 8
	notification_toast.add_theme_stylebox_override("panel", toast_sb)

	notification_toast.visible = true
	notification_toast.modulate = Color(1, 1, 1, 1)
	label_toast.text = msg
	if is_error:
		label_toast.modulate = Color("f87171")
	else:
		label_toast.modulate = Color("34d399")

	toast_tween = create_tween()
	toast_tween.tween_interval(3.2)
	toast_tween.tween_property(notification_toast, "modulate:a", 0.0, 0.5)
	toast_tween.tween_callback(func(): notification_toast.visible = false)

func _init_negotiation_ui() -> void:
	opt_contract_years.clear()
	opt_contract_years.add_item("1 an", 1)
	opt_contract_years.add_item("2 ans", 2)
	opt_contract_years.add_item("3 ans", 3)
	opt_contract_years.add_item("4 ans", 4)

	slider_wage.value_changed.connect(func(_val): _update_negotiation_feedback())
	slider_bonus.value_changed.connect(func(_val): _update_negotiation_feedback())
	slider_fee.value_changed.connect(func(_val): _update_negotiation_feedback())
	opt_contract_years.item_selected.connect(func(_idx): _update_negotiation_feedback())

	btn_propose_offer.pressed.connect(_on_btn_propose_offer_pressed)
	btn_accept_demands.pressed.connect(_on_btn_accept_demands_pressed)
	btn_cancel_nego.pressed.connect(func():
		negotiation_modal.visible = false
		current_nego_player = null
		current_nego_seller = null
	)

func open_club_transfer_negotiation(p: Player, seller: Club) -> void:
	if player_club and player_club.is_transfer_banned:
		show_toast("🚫 Recrutement interdit cette saison par le Fair-Play Financier (DNCG) !")
		return
	if seller == null or seller == player_club:
		open_negotiation(p, null, 0)
		return
	club_transfer_modal.open_modal(player_club, seller, p, market)

func _on_club_transfer_agreed(p: Player, seller: Club, agreed_fee: int) -> void:
	show_toast("🤝 Accord de transfert conclu avec %s pour %s € ! Place aux négociations salariales..." % [
		seller.club_name, String.num_int64(agreed_fee)
	])
	open_negotiation(p, seller, agreed_fee)

func open_negotiation(p: Player, seller: Club = null, agreed_fee: int = 0) -> void:
	if player_club and player_club.is_transfer_banned:
		show_toast("🚫 Recrutement interdit cette saison par le Fair-Play Financier (DNCG) !")
		return
	if p == null:
		return
	current_nego_player = p
	current_nego_seller = seller

	if seller != null:
		nego_badge.shape = seller.badge_shape
		nego_badge.symbol = seller.badge_symbol
		nego_badge.primary_color = seller.primary_color
		nego_badge.secondary_color = seller.secondary_color
		nego_badge.queue_redraw()
	else:
		nego_badge.shape = ClubBadge.ShieldShape.CIRCLE
		nego_badge.symbol = ClubBadge.SymbolType.STAR
		nego_badge.primary_color = Color("334155")
		nego_badge.secondary_color = Color("94a3b8")
		nego_badge.queue_redraw()

	var pos_names = ["Gardien", "Défenseur", "Milieu", "Attaquant"]
	label_nego_name.text = "%s %s (%d ans)" % [p.get_flag_emoji(), p.full_name, p.age]
	var seller_txt = ("Club: %s" % seller.club_name) if seller != null else "Agent Libre"
	label_nego_stats.text = "%s | %s | OVR: %d | Valeur: %s € | Exigence: %s €/sem" % [
		seller_txt, pos_names[p.position], p.get_overall(),
		String.num_int64(p.market_value), String.num_int64(p.wage_demand)
	]

	var vbox_nego = label_nego_name.get_parent()
	var btn_view_nego = vbox_nego.get_node_or_null("BtnViewNegoFiche")
	if btn_view_nego == null:
		btn_view_nego = Button.new()
		btn_view_nego.name = "BtnViewNegoFiche"
		btn_view_nego.text = "👁️ Consulter la Fiche Complète"
		btn_view_nego.custom_minimum_size = Vector2(170, 24)
		btn_view_nego.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		btn_view_nego.add_theme_font_size_override("font_size", 10)
		var b_st = StyleBoxFlat.new()
		b_st.bg_color = Color(0.16, 0.26, 0.42)
		b_st.set_corner_radius_all(6)
		btn_view_nego.add_theme_stylebox_override("normal", b_st)
		vbox_nego.add_child(btn_view_nego)
	for conn in btn_view_nego.pressed.get_connections():
		btn_view_nego.pressed.disconnect(conn["callable"])
	btn_view_nego.pressed.connect(func():
		if current_nego_player != null:
			player_detail_modal.open_player(current_nego_player, current_nego_seller)
	)

	# Configurer sliders
	slider_wage.min_value = max(200, int(p.wage_demand * 0.3))
	slider_wage.max_value = max(10000, int(p.wage_demand * 2.5))
	slider_wage.step = 100
	slider_wage.value = p.wage_demand

	var def_bonus = int(p.market_value * 0.10)
	slider_bonus.min_value = 0
	slider_bonus.max_value = max(30000, def_bonus * 3)
	slider_bonus.step = 500
	slider_bonus.value = def_bonus

	opt_contract_years.selected = clamp(p.contract_years - 1, 0, 3)

	if seller != null:
		transfer_fee_row.visible = true
		slider_fee.editable = false
		slider_fee.min_value = 0
		slider_fee.max_value = max(10000, agreed_fee * 2)
		slider_fee.value = agreed_fee
		label_fee_val.text = "%s € (Accord club validé)" % String.num_int64(agreed_fee)
	else:
		transfer_fee_row.visible = false
		slider_fee.editable = true

	_update_negotiation_feedback()
	negotiation_modal.visible = true

func _update_negotiation_feedback() -> void:
	if current_nego_player == null:
		return
	var p = current_nego_player
	var proposed_wage: int = int(slider_wage.value)
	var proposed_bonus: int = int(slider_bonus.value)

	label_wage_val.text = "%s € / sem" % String.num_int64(proposed_wage)
	label_bonus_val.text = "%s €" % String.num_int64(proposed_bonus)

	var wage_ratio: float = float(proposed_wage) / float(max(1, p.wage_demand))
	var expected_bonus: float = float(p.market_value) * 0.10
	var bonus_ratio: float = float(proposed_bonus) / float(max(500.0, expected_bonus))

	var score: float = 0.0
	if current_nego_seller != null:
		# L'indemnité club étant déjà acceptée, le joueur évalue son salaire et prime
		score = (wage_ratio * 0.70 + bonus_ratio * 0.30) * 100.0
	else:
		score = (wage_ratio * 0.65 + bonus_ratio * 0.35) * 100.0

	score = clampf(score, 5.0, 100.0)
	progress_mood.value = score

	var dialogue: String = ""
	var mood_text: String = ""
	var mood_color: Color = Color("facc15")

	if score >= 80.0:
		dialogue = "« Proposition remarquable ! Mon client et moi-même acceptons sans hésiter. »"
		mood_text = "Très enthousiaste (Accord certain)"
		mood_color = Color("10b981")
	elif score >= 55.0:
		dialogue = "« L'offre est solide et respecte nos exigences. Nous validons l'accord. »"
		mood_text = "Favorable (Accord possible)"
		mood_color = Color("84cc16")
	elif score >= 40.0:
		dialogue = "« C'est en dessous de nos espérances. Faites un effort sur le salaire ou la prime. »"
		mood_text = "Hésitant (Offre insuffisante)"
		mood_color = Color("facc15")
	else:
		dialogue = "« Cette offre est inacceptable ! Mon joueur ne viendra pas dans ces conditions. »"
		mood_text = "Réfractaire (Offre rejetée)"
		mood_color = Color("f87171")

	label_agent_dialogue.text = dialogue
	label_mood_text.text = mood_text
	label_mood_text.modulate = mood_color

func _on_btn_propose_offer_pressed() -> void:
	if current_nego_player == null:
		return
	var p = current_nego_player
	var proposed_wage: int = int(slider_wage.value)
	var proposed_bonus: int = int(slider_bonus.value)
	var proposed_fee: int = int(slider_fee.value) if current_nego_seller != null else 0
	var years: int = opt_contract_years.selected + 1

	if player_club.squad.size() >= TransferMarket.MAX_SQUAD_SIZE:
		show_toast("Effectif complet (%d/%d) : libérez d'abord un joueur." % [player_club.squad.size(), TransferMarket.MAX_SQUAD_SIZE], true)
		return

	if progress_mood.value < 55.0:
		show_toast("Offre refusée par le joueur et son agent (intérêt insuffisant).", true)
		return

	var upfront_cost: int = proposed_bonus + proposed_fee
	if player_club.budget < upfront_cost:
		show_toast("Budget insuffisant : %s € requis immédiatement." % String.num_int64(upfront_cost), true)
		return

	var seller = current_nego_seller
	if market.finalize_signing(player_club, p, proposed_wage, proposed_bonus, years, seller, proposed_fee):
		negotiation_modal.visible = false
		current_nego_player = null
		current_nego_seller = null
		_update_topbar()
		_render_squad_view()
		if seller != null:
			_render_club_roster(seller)
		else:
			_render_market_view()

func _on_btn_accept_demands_pressed() -> void:
	if current_nego_player == null:
		return
	slider_wage.value = current_nego_player.wage_demand
	slider_bonus.value = max(1000, int(current_nego_player.market_value * 0.12))
	_update_negotiation_feedback()
	_on_btn_propose_offer_pressed()

# ==================== CENTRE DE FORMATION & JEUNES ====================

func _render_formation_view() -> void:
	if player_club == null:
		return
	player_club.init_youth_academy_if_empty()
	for c in youth_list.get_children():
		c.queue_free()

	if player_club.youth_academy.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "Aucun jeune espoir dans le centre de formation pour le moment.\nUtilisez le bouton ci-dessus pour lancer une détection !"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.modulate = Color("94a3b8")
		empty_lbl.add_theme_font_size_override("font_size", 14)
		youth_list.add_child(empty_lbl)
		return

	for p in player_club.youth_academy:
		var card = _create_youth_prospect_card(p)
		youth_list.add_child(card)

func _create_youth_prospect_card(p: Player) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.20, 0.9)
	sb.set_corner_radius_all(10)
	sb.border_width_left = 3
	sb.border_color = Color("38bdf8")
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", sb)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 14)

	# Visage
	var fw = PlayerFaceWidget.new()
	fw.custom_minimum_size = Vector2(56, 56)
	fw.setup_player(p, player_club.primary_color, player_club.secondary_color)
	hbox.add_child(fw)

	# Info
	var vbox_info = VBoxContainer.new()
	vbox_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_info.add_theme_constant_override("separation", 3)

	var name_lbl = Label.new()
	name_lbl.text = "%s %s" % [p.get_flag_emoji(), p.full_name]
	name_lbl.add_theme_font_size_override("font_size", 15)
	vbox_info.add_child(name_lbl)

	var pos_names = ["Gardien (GK)", "Défenseur (DEF)", "Milieu (MID)", "Attaquant (FWD)"]
	var sub_lbl = Label.new()
	sub_lbl.text = "%s • %d ans • Actuel : %d OVR" % [pos_names[p.position], p.age, p.get_overall()]
	sub_lbl.modulate = Color("94a3b8")
	sub_lbl.add_theme_font_size_override("font_size", 12)
	vbox_info.add_child(sub_lbl)

	var stats_lbl = Label.new()
	if p.position == Player.Position.GK:
		stats_lbl.text = "RÉF: %d | DEF: %d | PAS: %d | END: %d" % [p.reflexes, p.defending, p.passing, p.stamina]
	else:
		stats_lbl.text = "VIT: %d | TIR: %d | PAS: %d | DÉF: %d | DRI: %d" % [p.speed, p.shooting, p.passing, p.defending, p.dribbling]
	stats_lbl.modulate = Color("38bdf8")
	stats_lbl.add_theme_font_size_override("font_size", 11)
	vbox_info.add_child(stats_lbl)
	hbox.add_child(vbox_info)

	# Potentiel Box
	var pot_box = VBoxContainer.new()
	pot_box.custom_minimum_size = Vector2(160, 0)
	pot_box.alignment = BoxContainer.ALIGNMENT_CENTER

	var pot_title = Label.new()
	pot_title.text = "⭐ Potentiel estimé :"
	pot_title.add_theme_font_size_override("font_size", 11)
	pot_title.modulate = Color("facc15")
	pot_box.add_child(pot_title)

	var pot_val = Label.new()
	pot_val.text = "%d - %d OVR" % [p.potential_min, p.potential_max]
	pot_val.add_theme_font_size_override("font_size", 16)
	pot_val.modulate = Color("facc15")
	pot_box.add_child(pot_val)

	var pot_bar = ProgressBar.new()
	pot_bar.custom_minimum_size = Vector2(130, 8)
	pot_bar.min_value = 50.0
	pot_bar.max_value = 100.0
	pot_bar.value = float((p.potential_min + p.potential_max) / 2)
	pot_bar.show_percentage = false
	pot_box.add_child(pot_bar)
	hbox.add_child(pot_box)

	# Action buttons
	var act_vbox = VBoxContainer.new()
	act_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	act_vbox.add_theme_constant_override("separation", 6)

	var btn_promote = Button.new()
	btn_promote.text = "🎓 Promouvoir Pro"
	btn_promote.custom_minimum_size = Vector2(140, 28)
	btn_promote.add_theme_font_size_override("font_size", 11)
	btn_promote.modulate = Color("10b981")
	btn_promote.pressed.connect(func():
		if player_club.squad.size() >= TransferMarket.MAX_SQUAD_SIZE:
			show_toast("Effectif plein (%d/32) : libérez d'abord un joueur." % player_club.squad.size(), true)
			return
		if player_club.promote_youth_to_senior(p):
			show_toast("🎓 %s a été promu dans l'équipe première avec un contrat de 3 ans !" % p.full_name)
			_render_formation_view()
			_render_squad_view()
			_update_topbar()
	)
	act_vbox.add_child(btn_promote)

	var btn_fiche = Button.new()
	btn_fiche.text = "👁️ Fiche Joueur"
	btn_fiche.custom_minimum_size = Vector2(140, 26)
	btn_fiche.add_theme_font_size_override("font_size", 11)
	btn_fiche.pressed.connect(func():
		player_detail_modal.open_player(p, player_club)
	)
	act_vbox.add_child(btn_fiche)

	hbox.add_child(act_vbox)
	panel.add_child(hbox)
	return panel

func _on_btn_scout_youth_pressed() -> void:
	if player_club == null:
		return
	var cost = 15_000
	if player_club.budget < cost:
		show_toast("Budget insuffisant (15 000 € requis pour la détection).", true)
		return
	if player_club.youth_academy.size() >= 8:
		show_toast("Le centre de formation est plein (limite de 8 jeunes espoirs).", true)
		return
	var scouted = player_club.scout_new_youth_prospect(cost)
	if scouted != null:
		show_toast("🔍 Détection réussie ! %s (%d ans, OVR %d, Pot. %d-%d) a rejoint votre centre !" % [
			scouted.full_name, scouted.age, scouted.get_overall(), scouted.potential_min, scouted.potential_max
		])
		_update_topbar()
		_render_formation_view()




