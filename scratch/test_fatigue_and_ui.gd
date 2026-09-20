extends SceneTree

func _init():
	print("=================== TESTS FATIGUE, NOMS & ERGONOMIE ===================")
	
	# 1. Test du format des noms (Nom de famille en MAJUSCULE en priorité)
	PlayerGenerator.reset_registry()
	for i in 20:
		var p = PlayerGenerator.create_random_player("France", Player.Position.FWD, 14)
		var parts = p.full_name.split(" ")
		assert(parts.size() >= 2, "Le nom complet doit comporter au moins 2 parties: %s" % p.full_name)
		var last_name_part = parts[0]
		assert(last_name_part == last_name_part.to_upper(), "Le nom de famille doit être en MAJUSCULE en première position: %s" % p.full_name)
	print("✅ Test 1 validé : Les noms célèbres sont affichés en MAJUSCULE et en priorité (ex: MBAPPÉ Kylian).")

	# 2. Test du drain de fatigue selon les tactiques
	var c_attack = Club.new()
	c_attack.tactical_style = 1 # Attaque Totale
	var p_atk = PlayerGenerator.create_random_player("France", Player.Position.FWD, 14)
	p_atk.fitness = 1.0
	p_atk.stamina = 12
	c_attack.squad.append(p_atk)
	c_attack.starting_five.append(p_atk)

	var c_counter = Club.new()
	c_counter.tactical_style = 2 # Contre-Attaque
	var p_cnt = PlayerGenerator.create_random_player("France", Player.Position.FWD, 14)
	p_cnt.fitness = 1.0
	p_cnt.stamina = 12
	c_counter.squad.append(p_cnt)
	c_counter.starting_five.append(p_cnt)

	MatchEngine._apply_fatigue(c_attack)
	MatchEngine._apply_fatigue(c_counter)

	assert(p_atk.fitness < p_cnt.fitness, "L'Attaque Totale doit drainer plus d'énergie que la Contre-Attaque !")
	print("✅ Test 2 validé : L'Attaque Totale fatigue significativement plus (forme: %.2f vs %.2f)." % [p_atk.fitness, p_cnt.fitness])

	# 3. Test de l'enchaînement des matchs (consecutive_starts)
	var prev_drain = 1.0 - p_atk.fitness
	MatchEngine._apply_fatigue(c_attack)
	var second_drain = (1.0 - prev_drain) - p_atk.fitness
	assert(p_atk.consecutive_starts == 2, "consecutive_starts doit valoir 2 après 2 matchs")
	assert(second_drain > prev_drain, "Le deuxième match consécutif doit drainer davantage d'énergie !")
	print("✅ Test 3 validé : L'enchaînement de matchs consécutifs amplifie la fatigue (titularisations consécutives: %d)." % p_atk.consecutive_starts)

	# 4. Test de la rotation : Récupération forte sur le banc vs faible pour les titulaires
	# p_atk est titulaire, créons un remplaçant p_bench fatigué à 50%
	var p_bench = PlayerGenerator.create_random_player("France", Player.Position.MID, 12)
	p_bench.fitness = 0.50
	p_bench.consecutive_starts = 2
	c_attack.squad.append(p_bench)
	# p_bench n'est PAS dans c_attack.starting_five

	# Avant matchday, p_atk joue et p_bench reste sur le banc
	MatchEngine._apply_fatigue(c_attack)
	assert(p_bench.consecutive_starts == 0, "Les remplaçants doivent voir leur compteur consécutif réinitialisé à 0")

	var fit_atk_before_rec = p_atk.fitness
	var fit_bench_before_rec = p_bench.fitness

	c_attack.recover_fitness()

	var rec_atk = p_atk.fitness - fit_atk_before_rec
	var rec_bench = p_bench.fitness - fit_bench_before_rec

	assert(rec_bench > rec_atk * 2.0, "Le joueur sur le banc doit récupérer beaucoup plus vite que le titulaire !")
	print("✅ Test 4 validé : La rotation permet une récupération rapide (+%.2f remplaçant vs +%.2f titulaire)." % [rec_bench, rec_atk])

	# 5. Test Sauvegarde consecutive_starts dans SaveManager
	var save_path = "user://test_fatigue_save.json"
	var l = League.new()
	l.country = "France"
	l.division = 1
	l.clubs.append(c_attack)
	var m = TransferMarket.new()
	SaveManager.save_game([l], m, c_attack, l, 1, save_path)
	var loaded = SaveManager.load_game(save_path)
	var restored = SaveManager.deserialize_game_data(loaded)
	var restored_club: Club = restored["player_club"]
	var restored_p_atk: Player = restored_club.squad[0]
	assert(restored_p_atk.consecutive_starts == p_atk.consecutive_starts, "consecutive_starts doit être persisté")
	print("✅ Test 5 validé : Persistance SaveManager de consecutive_starts confirmée.")

	print("=================== TOUS LES TESTS SONT VALIDES AVEC SUCCES ===================")
	quit(0)
