extends SceneTree

func _init() -> void:
	print("--- TEST SELECTION JOUEUR & STABILITE DU LAYOUT ---")
	var main_menu_res = load("res://scenes/MainMenu.tscn")
	var main_menu = main_menu_res.instantiate()
	root.add_child(main_menu)
	await process_frame

	main_menu._on_btn_new_game_pressed()
	main_menu._on_btn_start_with_club_pressed()

	await process_frame
	await process_frame

	var dash = current_scene
	assert(dash != null, "Dashboard non chargé")

	var body = dash.get_node("Body")
	var side_nav = dash.get_node("Body/SideNav")

	print("Avant sélection:")
	print("  Body offset_left: ", body.offset_left)
	print("  Body grow_horizontal: ", body.grow_horizontal)
	print("  SideNav custom_minimum_size: ", side_nav.custom_minimum_size)
	assert(body.offset_left == 10.0, "Body offset_left doit être 10.0")
	assert(body.grow_horizontal == 1, "Body grow_horizontal doit être 1 (GROW_DIRECTION_END)")

	# Clic sur un joueur titulaire du pitch
	var starter = dash.player_club.starting_five[0]
	print("Simulation clic sur le titulaire: ", starter.full_name)
	dash._on_pitch_player_clicked(starter)

	await process_frame

	print("Après sélection:")
	print("  Body offset_left: ", body.offset_left)
	print("  LabelPitchSub text:\n", dash.label_pitch_sub.text)
	print("  LabelBenchTitle text: ", dash.label_bench_title.text)

	assert(body.offset_left == 10.0, "Body offset_left NE DOIT PAS avoir bougé !")
	assert(dash.inspector_content.get_child_count() > 0, "L'inspecteur doit afficher la fiche joueur")

	# Re-clic pour désélectionner
	print("Simulation second clic pour désélectionner")
	dash._on_pitch_player_clicked(starter)
	await process_frame
	print("Après désélection:")
	print("  Body offset_left: ", body.offset_left)
	assert(body.offset_left == 10.0, "Body offset_left doit rester stable !")

	print("✓ Test de stabilité de mise en page validé avec succès !")
	quit(0)
