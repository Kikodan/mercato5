extends SceneTree

func _init() -> void:
	print("=== DEBUT DU TEST MUSIC & OPTIONS ===")
	await process_frame
	
	# Test 1: MusicManager singleton / autoload
	var MM_script = load("res://scripts/MusicManager.gd")
	assert(MM_script != null, "MusicManager.gd doit charger")
	
	var mm = MM_script.new()
	root.add_child(mm)
	await process_frame
	
	print("✓ MusicManager initialisé avec %d pistes" % mm.TRACK_PATHS.size())
	assert(mm.TRACK_PATHS.size() == 3, "Il doit y avoir exactement 3 musiques")
	for i in range(mm.TRACK_PATHS.size()):
		print("  Piste %d: %s (%s)" % [i, mm.TRACK_TITLES[i], mm.TRACK_PATHS[i]])
		
	# Test 2: Lecture et changement de pistes
	mm._load_and_play_track(1)
	assert(mm.current_track_index == 1, "Piste active doit être 1")
	print("✓ Lecture piste 1 OK: ", mm.get_current_track_title())
	
	mm.next_track()
	assert(mm.current_track_index == 2, "next_track doit passer à la piste 2")
	print("✓ Suivant -> piste 2 OK: ", mm.get_current_track_title())
	
	mm.next_track()
	assert(mm.current_track_index == 0, "next_track doit boucler sur la piste 0")
	print("✓ Suivant (boucle) -> piste 0 OK: ", mm.get_current_track_title())
	
	mm.previous_track()
	assert(mm.current_track_index == 2, "previous_track doit reculer à la piste 2")
	print("✓ Précédent -> piste 2 OK: ", mm.get_current_track_title())
	
	# Test 3: Contrôle du volume et muet
	mm.set_volume(0.45)
	assert(abs(mm.volume_percent - 0.45) < 0.01, "Volume doit être réglé à 45%")
	print("✓ Volume réglé à 45% OK")
	
	var is_muted = mm.toggle_mute()
	assert(is_muted and mm.is_muted, "toggle_mute doit couper le son")
	print("✓ Muet activé OK")
	
	is_muted = mm.toggle_mute()
	assert(not is_muted and not mm.is_muted, "toggle_mute doit réactiver le son")
	print("✓ Son réactivé OK")
	
	# Test 4: Modal des Options
	var OptionsModal_script = load("res://scenes/OptionsMenuModal.gd")
	var modal = OptionsModal_script.new()
	root.add_child(modal)
	await process_frame
	
	modal.open_modal()
	assert(modal.visible == true, "La modale d'options doit être visible après open_modal()")
	print("✓ Modale d'options ouverte OK")
	
	modal.close_modal()
	assert(modal.visible == false, "La modale d'options doit être masquée après close_modal()")
	print("✓ Modale d'options fermée OK")
	
	# Test 5: Vérifier Dashboard et son bouton Options
	var dash_res = load("res://scenes/Dashboard.tscn")
	var dash = dash_res.instantiate()
	root.add_child(dash)
	await process_frame
	
	assert(dash.btn_options != null, "Dashboard doit avoir un btn_options")
	assert(dash.options_modal != null, "Dashboard doit avoir options_modal initialisé")
	print("✓ Dashboard TopBar Options bouton et modale connectés OK")
	
	dash.options_modal.open_modal()
	assert(dash.options_modal.visible == true, "Options dans Dashboard doit s'ouvrir")
	dash.options_modal.close_modal()
	assert(dash.options_modal.visible == false, "Options dans Dashboard doit se fermer")
	print("✓ Clic Options depuis Dashboard fonctionne parfaitement !")
	
	mm.queue_free()
	modal.queue_free()
	dash.queue_free()
	
	print("=== TOUS LES TESTS MUSIQUE & OPTIONS SONT VALIDÉS ! ===")
	quit(0)
