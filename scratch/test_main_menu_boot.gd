extends Node

func _ready() -> void:
	print("--- Testing MainMenu.tscn Boot Node ---")
	var scene = load("res://scenes/MainMenu.tscn")
	assert(scene != null)
	var instance = scene.instantiate()
	add_child(instance)
	print("MainMenu successfully instantiated and added as child!")
	
	# Verify save state display
	var save_summary = instance.get_node("MainView/VBox/MenuButtons/ContinueInfoCard/HBox/VBox/LabelSaveSummary")
	print("Continue card summary text: %s" % save_summary.text)
	
	# Verify button state
	var btn_continue = instance.get_node("MainView/VBox/MenuButtons/BtnContinue")
	print("Continue button disabled? %s" % btn_continue.disabled)
	
	# Simulate clicking New Game
	var btn_new_game = instance.get_node("MainView/VBox/MenuButtons/BtnNewGame")
	btn_new_game.pressed.emit()
	
	var club_select_view = instance.get_node("ClubSelectView")
	assert(club_select_view.visible == true)
	print("Club select view opened successfully!")
	
	var clubs_list = instance.get_node("ClubSelectView/VBox/Split/ClubsListScroll/ClubsList")
	print("Clubs displayed in list: %d" % clubs_list.get_child_count())
	assert(clubs_list.get_child_count() > 0)
	
	print("--- MAIN MENU BOOT TEST PASSED ---")
	get_tree().quit(0)
