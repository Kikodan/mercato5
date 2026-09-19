extends SceneTree

const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")

func _init():
	print("--- Starting New Game Choice Test ---")
	
	var world = GameWorld.create_default_world()
	var leagues: Array[League] = world["all_leagues"]
	var market: TransferMarket = world["market"]
	
	# Find an English D3 club: "Leeds Futsal"
	var selected_club: Club = null
	var selected_league: League = null
	for l in leagues:
		if l.country == "Angleterre" and l.division == 3:
			selected_league = l
			for c in l.clubs:
				if c.club_name == "Leeds Futsal":
					selected_club = c
					break
			break
			
	if not selected_club or not selected_league:
		printerr("Could not find Leeds Futsal!")
		quit(1)
		return
		
	print("Selected club: %s (%s, Div %d, Budget %s €)" % [
		selected_club.club_name, selected_club.country, selected_club.division, String.num_int64(selected_club.budget)
	])
	
	# Setup GameGlobal
	var gg = load("res://scripts/GameGlobal.gd").new()
	gg.name = "GameGlobal"
	root.add_child(gg)
	gg.new_game_selected_club = selected_club
	gg.new_game_selected_league = selected_league
	gg.new_game_all_leagues = leagues
	gg.new_game_market = market
	
	# Instantiate Dashboard
	var dashboard_res = load("res://scenes/Dashboard.tscn")
	var dashboard = dashboard_res.instantiate()
	root.add_child(dashboard)
	
	print("Dashboard initialized! Active player club: %s, Current League: %s (%s)" % [
		dashboard.player_club.club_name, dashboard.current_league.league_name, dashboard.current_league.country
	])
	
	if dashboard.player_club.club_name != "Leeds Futsal":
		printerr("FAILED: player_club was not Leeds Futsal!")
		quit(1)
		return
		
	print("SUCCESS: Player club correctly initialized to Leeds Futsal!")
	
	# Test saving this game
	var ok = SaveManager.save_game(dashboard.player_club, dashboard.current_league, dashboard.all_leagues, dashboard.market)
	if not ok:
		printerr("FAILED: Save game failed")
		quit(1)
		return
		
	var info = SaveManager.get_save_info()
	print("SUCCESS: Save file updated with: %s (%s, Div %d)" % [info.club_name, info.country, info.division])
	
	print("--- NEW GAME CHOICE TEST PASSED ---")
	quit(0)
