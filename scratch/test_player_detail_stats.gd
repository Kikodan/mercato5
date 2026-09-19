extends SceneTree

func _init() -> void:
	print("--- TEST PLAYER DETAIL MODAL STATS ---")
	await process_frame
	
	var modal_res = load("res://scenes/PlayerDetailModal.tscn")
	var modal = modal_res.instantiate()
	root.add_child(modal)
	await process_frame
	
	var p = Player.new()
	p.full_name = "Marco Barbieri"
	p.stats_current_season = {
		"matches": 5,
		"goals": 3,
		"assists": 2,
		"tackles": 7,
		"saves": 0,
		"clean_sheets": 0,
		"rating_sum": 36.5
	}
	
	var c = Club.new()
	c.club_name = "Paris RG"
	c.country = "France"
	c.division = 1
	
	print("Opening player modal...")
	modal.open_player(p, c)
	await process_frame
	
	var list = modal.stats_history_container
	print("Stats container children count: ", list.get_child_count())
	for child in list.get_children():
		print("Child: ", child, " visible=", child.visible, " size=", child.size)
		if child is HBoxContainer:
			for col in child.get_children():
				if col is Label:
					print("   Col text: '", col.text, "'")
	
	modal.queue_free()
	print("--- TEST TERMINE ---")
	quit(0)
