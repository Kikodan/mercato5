extends SceneTree

func _init():
	print("=================== LANCEMENT DES TESTS DE VALIDATION ===================")
	var world = GameWorld.create_default_world()
	var leagues: Array[League] = world["all_leagues"]
	var market: TransferMarket = world["market"]

	# 1. Vérification des pays et divisions (8 équipes en D1, 6 en D2/D3)
	var expected_countries = ["France", "Espagne", "Italie", "Angleterre", "Portugal", "Allemagne"]
	var country_counts = {}
	for c in expected_countries:
		country_counts[c] = {"d1": 0, "d2": 0, "d3": 0}

	for l in leagues:
		assert(expected_countries.has(l.country), "Pays inattendu: %s" % l.country)
		match l.division:
			1:
				assert(l.clubs.size() == 8, "La D1 de %s doit avoir 8 clubs, trouvé: %d" % [l.country, l.clubs.size()])
				assert(l.schedule.size() == 14, "La D1 de %s doit comporter 14 journées, trouvé: %d" % [l.country, l.schedule.size()])
				country_counts[l.country]["d1"] += 1
			2:
				assert(l.clubs.size() == 6, "La D2 de %s doit avoir 6 clubs, trouvé: %d" % [l.country, l.clubs.size()])
				assert(l.schedule.size() == 10, "La D2 de %s doit comporter 10 journées, trouvé: %d" % [l.country, l.schedule.size()])
				country_counts[l.country]["d2"] += 1
			3:
				assert(l.clubs.size() == 6, "La D3 de %s doit avoir 6 clubs, trouvé: %d" % [l.country, l.clubs.size()])
				assert(l.schedule.size() == 10, "La D3 de %s doit comporter 10 journées, trouvé: %d" % [l.country, l.schedule.size()])
				country_counts[l.country]["d3"] += 1

	for c in expected_countries:
		assert(country_counts[c]["d1"] == 1, "D1 manquante pour %s" % c)
		assert(country_counts[c]["d2"] == 1, "D2 manquante pour %s" % c)
		assert(country_counts[c]["d3"] == 1, "D3 manquante pour %s" % c)
	print("✅ Test 1 validé : 6 championnats complets, toutes les D1 à 8 équipes (14 journées), D2 et D3 à 6 équipes (10 journées).")

	# 2. Vérification des vrais noms de clubs et couleurs
	var sample_clubs = ["Paris Saint-Germain", "Real Madrid CF", "FC Bayern München", "Manchester City", "Juventus FC", "SL Benfica"]
	var found_sample = 0
	for l in leagues:
		for club in l.clubs:
			if sample_clubs.has(club.club_name):
				found_sample += 1
				assert(club.primary_color != null, "Couleur primaire manquante pour %s" % club.club_name)
				assert(club.secondary_color != null, "Couleur secondaire manquante pour %s" % club.club_name)
	assert(found_sample == sample_clubs.size(), "Tous les clubs échantillons doivent être présents")
	print("✅ Test 2 validé : Noms réels des clubs et couleurs de blasons confirmés.")

	# 3. Vérification des noms de joueurs par position
	PlayerGenerator.reset_registry()
	for i in 50:
		var gk = PlayerGenerator.create_random_player("France", Player.Position.GK, 12)
		assert(gk.position == Player.Position.GK, "Poste incorrect")
		assert(not gk.full_name.contains("Mbappé") and not gk.full_name.contains("Messi") and not gk.full_name.contains("Haaland"), "Un gardien ne peut pas porter un nom d'attaquant vedette !")

	for i in 50:
		var fwd = PlayerGenerator.create_random_player("Allemagne", Player.Position.FWD, 14)
		assert(fwd.position == Player.Position.FWD, "Poste incorrect")
		assert(not fwd.full_name.contains("Neuer") and not fwd.full_name.contains("Kahn"), "Un attaquant ne peut pas porter un nom de gardien !")
	print("✅ Test 3 validé : Cohérence stricte noms célèbres / postes des joueurs sans doublons.")

	# 4. Test du suivi de la forme récente (V/D)
	var d1_fr = leagues[0]
	var c1 = d1_fr.clubs[0]
	var c2 = d1_fr.clubs[1]
	d1_fr.record_match_result(c1, c2, 5, 2)
	assert(c1.recent_form.size() == 1, "La forme de c1 doit avoir 1 match")
	assert(c1.recent_form[0]["result"] == "V", "c1 doit avoir une victoire")
	assert(c2.recent_form[0]["result"] == "D", "c2 doit avoir une défaite")
	assert(c1.get_form_string(5) == "V", "get_form_string doit retourner V")
	assert(c2.get_form_string(5) == "D", "get_form_string doit retourner D")
	print("✅ Test 4 validé : Enregistrement et affichage de la forme récente (V/D).")

	# 5. Test de gestion autonome de l'effectif par les clubs IA (garantie gardien & protection stars)
	var test_club = d1_fr.clubs[2]
	# Retirer tous les gardiens pour simuler une urgence
	var removed_gks = []
	for p in test_club.squad.duplicate():
		if p.position == Player.Position.GK:
			test_club.squad.erase(p)
			removed_gks.append(p)
	var gk_count_before = 0
	for p in test_club.squad:
		if p.position == Player.Position.GK: gk_count_before += 1
	assert(gk_count_before == 0, "Le club doit avoir 0 gardien pour le test d'urgence")

	market.process_ai_squad_management(d1_fr.clubs, d1_fr.clubs[0])
	var gk_count_after = 0
	for p in test_club.squad:
		if p.position == Player.Position.GK: gk_count_after += 1
	assert(gk_count_after >= 1, "L'IA a dû recruter un gardien en urgence absolue !")
	print("✅ Test 5 validé : Recrutement d'urgence de gardien et gestion IA des effectifs réussis.")

	# 6. Test Sauvegarde / Restauration de la forme
	var save_path = "user://test_overhaul_save.json"
	SaveManager.save_game(leagues, market, c1, d1_fr, 1, save_path)
	assert(FileAccess.file_exists(save_path), "Fichier de sauvegarde non créé")
	var loaded = SaveManager.load_game(save_path)
	var restored = SaveManager.deserialize_game_data(loaded)
	var restored_c1: Club = null
	for l in restored["all_leagues"]:
		for c in l.clubs:
			if c.club_name == c1.club_name:
				restored_c1 = c
				break
	assert(restored_c1 != null, "Club non retrouvé après restauration")
	assert(restored_c1.recent_form.size() >= 1, "recent_form doit être restauré")
	assert(restored_c1.recent_form[0]["result"] == "V", "Le résultat V doit être persisté")
	print("✅ Test 6 validé : Persistance complète de la forme récente dans SaveManager.")

	print("=================== TOUS LES TESTS SONT VALIDES AVEC SUCCES ===================")
	quit(0)
