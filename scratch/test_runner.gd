extends Node

const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")

func _ready() -> void:
	print("--- Running Full Flow Node Test ---")
	
	# 1. World setup
	var world = GameWorld.create_default_world()
	var leagues: Array[League] = world["all_leagues"]
	var market: TransferMarket = world["market"]
	
	# 2. Select Leeds Futsal in England D3
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
			
	assert(selected_club != null)
	assert(selected_league != null)
	print("Selected club: %s (%s, Div %d)" % [selected_club.club_name, selected_club.country, selected_club.division])
	
	# 3. Simulate Main Menu setting GameGlobal
	var gg = get_node_or_null("/root/GameGlobal")
	if gg != null:
		gg.new_game_selected_club = selected_club
		gg.new_game_selected_league = selected_league
		gg.new_game_all_leagues = leagues
		gg.new_game_market = market
	
	# 4. Instantiate Dashboard
	var dashboard_res = load("res://scenes/Dashboard.tscn")
	var dashboard = dashboard_res.instantiate()
	add_child(dashboard)
	
	print("Dashboard mounted! Player club: %s, League: %s" % [
		dashboard.player_club.club_name, dashboard.current_league.league_name
	])
	assert(dashboard.player_club == selected_club)
	
	# 5. Simulate Saving
	var ok = SaveManager.save_game(dashboard.player_club, dashboard.current_league, dashboard.all_leagues, dashboard.market)
	assert(ok)
	print("Save verified successfully!")
	
	var info = SaveManager.get_save_info()
	print("Save info check: %s, %s, Div %d" % [info.club_name, info.country, info.division])
	assert(info.club_name == "Leeds Futsal")
	
	# 6. Simulate Loading
	var loaded = SaveManager.load_game()
	var restored = SaveManager.deserialize_game_data(loaded)
	var restored_club: Club = restored["player_club"]
	assert(restored_club.club_name == "Leeds Futsal")
	print("Restored club check: %s (%d players)" % [restored_club.club_name, restored_club.squad.size()])
	
	print("--- ALL TESTS COMPLETED WITH 100% SUCCESS ---")
	get_tree().quit(0)
