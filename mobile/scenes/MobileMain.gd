class_name MobileMain
extends Control

const Club = preload("res://scripts/Club.gd")
const League = preload("res://scripts/League.gd")
const TransferMarket = preload("res://scripts/TransferMarket.gd")
const MatchEngine = preload("res://scripts/MatchEngine.gd")
const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")

const MobileTopBar = preload("res://scenes/widgets/MobileTopBar.gd")
const MobileBottomBar = preload("res://scenes/widgets/MobileBottomBar.gd")
const MobileOptionsMenuModal = preload("res://scenes/widgets/MobileOptionsMenuModal.gd")
const DayEffectif = preload("res://scenes/DayEffectif.gd")
const DayMercato = preload("res://scenes/DayMercato.gd")
const DayTactique = preload("res://scenes/DayTactique.gd")
const DayFormation = preload("res://scenes/DayFormation.gd")
const DayMatch = preload("res://scenes/DayMatch.gd")
const DayEconomie = preload("res://scenes/DayEconomie.gd")

# Données de la partie
var user_club: Club = null
var current_league: League = null
var all_leagues: Array[League] = []
var market: TransferMarket = null
var current_day_index: int = 0 # 0=LUN, 1=MAR, 2=MER, 3=JEU, 4=VEN, 5=SAM, 6=DIM
var week_number: int = 1
var is_match_played_this_week: bool = false

# UI Nodes
var top_bar: MobileTopBar
var bottom_bar: MobileBottomBar
var options_modal: MobileOptionsMenuModal
var content_container: MarginContainer
var day_effectif: DayEffectif
var day_mercato: DayMercato
var day_tactique: DayTactique
var day_formation: DayFormation
var day_match: DayMatch
var day_economie: DayEconomie

var toast_panel: PanelContainer
var toast_label: Label
var toast_tween: Tween

func _ready() -> void:
	_init_ui_layout()
	_init_or_load_game()
	_setup_top_bar()
	_switch_to_day(0)

func _init_ui_layout() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	# Fond sombre avec dégradé futsal
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.11, 1.0)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	add_child(bg)

	var main_vbox = VBoxContainer.new()
	main_vbox.anchor_right = 1.0
	main_vbox.anchor_bottom = 1.0
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)

	# 1. Barre Supérieure avec roulette d'options ⚙️
	top_bar = MobileTopBar.new()
	top_bar.options_requested.connect(_on_options_requested)
	main_vbox.add_child(top_bar)

	# 2. Zone de Contenu Principale
	content_container = MarginContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("margin_left", 10)
	content_container.add_theme_constant_override("margin_right", 10)
	content_container.add_theme_constant_override("margin_top", 10)
	content_container.add_theme_constant_override("margin_bottom", 10)
	main_vbox.add_child(content_container)

	# Instanciation des 5 vues spécialisées
	day_effectif = DayEffectif.new()
	day_effectif.data_changed.connect(_on_child_data_changed)
	content_container.add_child(day_effectif)

	day_mercato = DayMercato.new()
	day_mercato.data_changed.connect(_on_child_data_changed)
	content_container.add_child(day_mercato)

	day_tactique = DayTactique.new()
	day_tactique.data_changed.connect(_on_child_data_changed)
	content_container.add_child(day_tactique)

	day_formation = DayFormation.new()
	day_formation.data_changed.connect(_on_child_data_changed)
	content_container.add_child(day_formation)

	day_match = DayMatch.new()
	day_match.match_completed.connect(_on_match_completed)
	day_match.data_changed.connect(_on_child_data_changed)
	content_container.add_child(day_match)

	day_economie = DayEconomie.new()
	day_economie.data_changed.connect(_on_child_data_changed)
	content_container.add_child(day_economie)

	# 3. Barre Inférieure (Action / Avancer / Sauvegarde)
	bottom_bar = MobileBottomBar.new()
	bottom_bar.advance_requested.connect(_on_advance_requested)
	bottom_bar.save_requested.connect(_on_save_requested)
	main_vbox.add_child(bottom_bar)

	# 4. Modale Options Mobile (Roulette d'options)
	options_modal = MobileOptionsMenuModal.new()
	options_modal.return_to_main_menu_requested.connect(_on_return_to_main_menu)
	add_child(options_modal)

	# 5. Toast Overlay (notifications flottantes)
	toast_panel = PanelContainer.new()
	var sb_t = StyleBoxFlat.new()
	sb_t.bg_color = Color(0.08, 0.15, 0.28, 0.95)
	sb_t.border_color = Color("38bdf8")
	sb_t.set_border_width_all(1)
	sb_t.set_corner_radius_all(16)
	sb_t.content_margin_left = 16
	sb_t.content_margin_right = 16
	sb_t.content_margin_top = 8
	sb_t.content_margin_bottom = 8
	toast_panel.add_theme_stylebox_override("panel", sb_t)
	toast_panel.anchor_left = 0.5
	toast_panel.anchor_right = 0.5
	toast_panel.anchor_top = 0.88
	toast_panel.anchor_bottom = 0.88
	toast_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	toast_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	toast_panel.modulate.a = 0.0
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_panel)

	toast_label = Label.new()
	toast_label.add_theme_font_size_override("font_size", 12)
	toast_label.add_theme_color_override("font_color", Color("f8fafc"))
	toast_panel.add_child(toast_label)

func _init_or_load_game() -> void:
	# 1. Vérifier si une nouvelle partie a été paramétrée depuis le menu d'accueil
	if GameGlobal.new_game_selected_club != null:
		user_club = GameGlobal.new_game_selected_club
		current_league = GameGlobal.new_game_selected_league
		all_leagues = GameGlobal.new_game_all_leagues
		market = GameGlobal.new_game_market
		GameGlobal.clear_transitions()
		# Enregistrer directement la nouvelle carrière
		SaveManager.save_game(user_club, current_league, all_leagues, market, 1)
		return

	# 2. Sinon charger la sauvegarde existante
	if SaveManager.has_save():
		var data = SaveManager.load_game()
		user_club = data.get("player_club", null)
		current_league = data.get("current_league", null)
		all_leagues = data.get("all_leagues", [])
		market = data.get("market", null)

	# 3. Fallback : Créer un monde par défaut
	if user_club == null or current_league == null or all_leagues.is_empty():
		var default_data = GameWorld.create_default_world()
		all_leagues = default_data["all_leagues"]
		market = default_data["market"]
		current_league = all_leagues[0]
		user_club = current_league.clubs[0]
		user_club.is_user_controlled = true

func _setup_top_bar() -> void:
	if user_club == null:
		return
	top_bar.setup_club(user_club, current_league.league_name if current_league else "Division 1")
	top_bar.set_active_day(current_day_index)

func _switch_to_day(day_idx: int) -> void:
	current_day_index = day_idx

	# Masquer tous les conteneurs
	day_effectif.visible = false
	day_mercato.visible = false
	day_tactique.visible = false
	day_formation.visible = false
	day_match.visible = false
	day_economie.visible = false

	# Mettre à jour l'en-tête (indicateur linéaire)
	top_bar.set_active_day(current_day_index)
	top_bar.update_budget(user_club.budget)

	# Afficher le jour sélectionné
	match current_day_index:
		0: # LUNDI : Effectif & Classement
			day_effectif.visible = true
			day_effectif.setup(user_club, current_league)
			bottom_bar.set_advance_text("Mardi : Marché des Transferts ➡️", false, false)

		1, 2: # MARDI / MERCREDI : Mercato
			day_mercato.visible = true
			day_mercato.setup(user_club, market, _get_other_clubs())
			if current_day_index == 1:
				bottom_bar.set_advance_text("Mercredi : Poursuivre le Mercato ➡️", false, false)
			else:
				bottom_bar.set_advance_text("Jeudi : Préparer la Tactique ➡️", false, false)

		3: # JEUDI : Tactique & Formations
			day_tactique.visible = true
			day_tactique.setup(user_club)
			bottom_bar.set_advance_text("Vendredi : Formation & Surveillance ➡️", false, false)

		4: # VENDREDI : Formation & Surveillance
			day_formation.visible = true
			day_formation.setup(user_club, current_league, _get_saturday_opponent())
			bottom_bar.set_advance_text("Samedi : JOUR DE MATCH ! ⚽", true, false)

		5: # SAMEDI : Match
			day_match.visible = true
			_prepare_saturday_match()
			if is_match_played_this_week:
				bottom_bar.set_advance_text("Dimanche : Bilan Économique ➡️", false, false)
			else:
				bottom_bar.set_advance_text("⚽ Jouer ou Simuler le Match", true, false)

		6: # DIMANCHE : Économie & Clôture
			day_economie.visible = true
			day_economie.setup(user_club)
			bottom_bar.set_advance_text("Clôturer la Semaine (Passer au Lundi) 🔄", false, true)

func _get_other_clubs() -> Array[Club]:
	var others: Array[Club] = []
	for l in all_leagues:
		for c in l.clubs:
			if c != user_club:
				others.append(c)
	return others

func _get_saturday_opponent() -> Club:
	if user_club == null or current_league == null:
		return null

	var opp: Club = null
	if current_league.current_matchday_index < current_league.schedule.size():
		var day_matches = current_league.schedule[current_league.current_matchday_index]
		for pair in day_matches:
			if pair[0] == user_club:
				opp = pair[1]
				break
			elif pair[1] == user_club:
				opp = pair[0]
				break
	elif current_league.is_playoffs_active():
		if current_league.playoff_phase == 1:
			opp = current_league.playoff_semi_away if current_league.playoff_semi_home == user_club else current_league.playoff_semi_home
		elif current_league.playoff_phase == 2:
			opp = current_league.playoff_final_away if current_league.playoff_final_home == user_club else current_league.playoff_final_home

	if opp == null:
		for c in current_league.clubs:
			if c != user_club:
				opp = c
				break
	return opp

func _prepare_saturday_match() -> void:
	if user_club == null or current_league == null:
		return

	if is_match_played_this_week and day_match.is_finished:
		return

	var opp_club: Club = _get_saturday_opponent()
	var is_home = true
	var match_title = "JOURNÉE DE CHAMPIONNAT"

	if current_league.current_matchday_index < current_league.schedule.size():
		var day_matches = current_league.schedule[current_league.current_matchday_index]
		for pair in day_matches:
			if pair[0] == user_club:
				is_home = true
				break
			elif pair[1] == user_club:
				is_home = false
				break
		match_title = "Ligue %s - Journée %d / %d" % [current_league.league_name, current_league.current_matchday_index + 1, current_league.schedule.size()]
	elif current_league.is_playoffs_active():
		if current_league.playoff_phase == 1:
			is_home = (current_league.playoff_semi_home == user_club)
			match_title = "DEMI-FINALE PLAYOFFS"
		elif current_league.playoff_phase == 2:
			is_home = (current_league.playoff_final_home == user_club)
			match_title = "GRANDE FINALE PLAYOFFS"

	if opp_club == null:
		match_title = "MATCH AMICAL DE GALA"

	day_match.setup(user_club, opp_club, is_home, match_title, current_league)

## Progression strictement vers l'avant (impossible de revenir en arrière)
func _on_advance_requested() -> void:
	if current_day_index == 5:
		if not is_match_played_this_week:
			show_toast("⚠️ Veuillez d'abord jouer ou simuler le match de Samedi !")
			return
		_switch_to_day(6)
	elif current_day_index == 6:
		_process_weekly_rollover()
		is_match_played_this_week = false
		week_number += 1
		_switch_to_day(0)
		show_toast("✨ Semaine %d validée ! Bilan comptabilisé." % week_number)
	else:
		_switch_to_day(current_day_index + 1)

func _on_match_completed(report: MatchEngine.MatchReport) -> void:
	is_match_played_this_week = true

	if current_league.current_matchday_index < current_league.schedule.size():
		var day_matches = current_league.schedule[current_league.current_matchday_index]
		for pair in day_matches:
			var h: Club = pair[0]
			var a: Club = pair[1]
			if h == user_club and a == report.away_club:
				current_league.record_match_result(h, a, report.home_score, report.away_score)
			elif a == user_club and h == report.home_club:
				current_league.record_match_result(h, a, report.home_score, report.away_score)
			else:
				var ai_rep = MatchEngine.simulate_match(h, a, 5)
				current_league.record_match_result(h, a, ai_rep.home_score, ai_rep.away_score)

		current_league.current_matchday_index += 1

	if report.home_club == user_club:
		var fin = user_club.get_finances()
		var won = report.home_score > report.away_score
		var receipts = fin.process_home_match_receipts(user_club, report.away_club, false, won)
		top_bar.update_budget(user_club.budget)
		show_toast("🏁 Match terminé ! Recette billetterie : +%s" % FormatUtils.format_money(receipts))
	else:
		show_toast("🏁 Match terminé ! Résultat enregistré.")

	bottom_bar.set_advance_text("Dimanche : Bilan Économique ➡️", false, false)

func _process_weekly_rollover() -> void:
	for l in all_leagues:
		for c in l.clubs:
			c.recover_fitness()
			c.process_weekly_youth_evolution()
			c.get_finances().process_weekly_cycle(c, 0)

	top_bar.update_budget(user_club.budget)
	SaveManager.save_game(user_club, current_league, all_leagues, market, 1)

func _on_save_requested() -> void:
	var success = SaveManager.save_game(user_club, current_league, all_leagues, market, 1)
	if success:
		show_toast("💾 Partie sauvegardée avec succès !")
	else:
		show_toast("❌ Erreur lors de la sauvegarde.")

func _on_options_requested() -> void:
	options_modal.open_modal(true)

func _on_return_to_main_menu() -> void:
	# Sauvegarder l'état actuel avant de retourner au menu d'accueil
	SaveManager.save_game(user_club, current_league, all_leagues, market, 1)
	get_tree().change_scene_to_file("res://scenes/MobileStartMenu.tscn")

func _on_child_data_changed() -> void:
	top_bar.update_budget(user_club.budget)

func show_toast(msg: String) -> void:
	toast_label.text = msg
	if toast_tween and toast_tween.is_valid():
		toast_tween.kill()

	toast_tween = create_tween()
	toast_tween.tween_property(toast_panel, "modulate:a", 1.0, 0.2)
	toast_tween.tween_interval(2.5)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
