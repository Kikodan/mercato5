extends SceneTree

const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")

func _init():
	print("--- Starting Integration Test ---")
	
	# Test 1: Load and instantiate MainMenu
	var main_menu_res = load("res://scenes/MainMenu.tscn")
	if not main_menu_res:
		printerr("FAILED to load MainMenu.tscn")
		quit(1)
		return
	var main_menu = main_menu_res.instantiate()
	root.add_child(main_menu)
	print("SUCCESS: MainMenu instantiated and mounted.")
	
	# Test 2: Verify GameWorld creation
	var world = GameWorld.create_default_world()
	var leagues = world["all_leagues"]
	var market = world["market"]
	print("SUCCESS: World created with %d leagues and %d free agents." % [leagues.size(), market.free_agents.size()])
	
	# Test 3: Save and Load
	var test_club = leagues[0].clubs[0]
	var test_league = leagues[0]
	var ok = SaveManager.save_game(leagues, market, test_club, test_league)
	if not ok:
		printerr("FAILED: SaveManager.save_game returned false")
		quit(1)
		return
	print("SUCCESS: Save file written.")
	
	var has_save = SaveManager.has_save()
	var info = SaveManager.get_save_info()
	print("SUCCESS: Save detected. Club: %s, J%d" % [info.get("club_name"), info.get("matchday")])
	
	var loaded_data = SaveManager.load_game()
	var restored = SaveManager.deserialize_game_data(loaded_data)
	var restored_club: Club = restored["player_club"]
	var restored_leagues: Array[League] = restored["all_leagues"]
	print("SUCCESS: Deserialized club %s, %d players in squad." % [restored_club.club_name, restored_club.squad.size()])
	
	# Test 4: Instantiate Dashboard
	var gg = load("res://scripts/GameGlobal.gd").new()
	gg.name = "GameGlobal"
	root.add_child(gg)
	gg.loaded_save_data = loaded_data
	var dashboard_res = load("res://scenes/Dashboard.tscn")
	if not dashboard_res:
		printerr("FAILED to load Dashboard.tscn")
		quit(1)
		return
	var dashboard = dashboard_res.instantiate()
	root.add_child(dashboard)
	print("SUCCESS: Dashboard instantiated with restored save data!")
	
	print("--- ALL INTEGRATION TESTS PASSED ---")
	quit(0)
