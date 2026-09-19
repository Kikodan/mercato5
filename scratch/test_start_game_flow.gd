extends SceneTree

func _init() -> void:
	print("--- TEST DEBUT DE PARTIE COMPLETE ---")
	var main_menu_res = load("res://scenes/MainMenu.tscn")
	var main_menu = main_menu_res.instantiate()
	root.add_child(main_menu)
	await process_frame
	print("MainMenu instancié et ready")
	
	# Simuler clic Nouvelle Partie
	main_menu._on_btn_new_game_pressed()
	print("Nouvelle partie cliquée, club sélectionné: ", main_menu.current_selected_club.club_name if main_menu.current_selected_club else "NONE")
	
	# Simuler clic Prendre les rênes
	main_menu._on_btn_start_with_club_pressed()
	print("Prendre les rênes cliqué !")
	
	# Attendre un frame pour le change_scene
	await process_frame
	await process_frame
	
	print("Current scene après transition: ", current_scene)
	var dash = current_scene
	if dash != null and dash.has_method("_on_btn_tab_economy_pressed"):
		dash._on_btn_tab_economy_pressed()
		print("✓ Onglet Économie ouvert avec succès !")
		assert(dash.tab_economy.visible == true, "L'onglet économie doit être visible")
		print("Enfants de economy_content: ", dash.economy_content.get_child_count())
		assert(dash.economy_content.get_child_count() >= 4, "L'onglet économie doit avoir au moins 4 modules")
		print("✓ Modules d'économie vérifiés avec succès !")
	print("--- FIN DU TEST DEBUT DE PARTIE & ECONOMIE ---")
	quit(0)
