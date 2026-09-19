extends SceneTree

const SeasonManager = preload("res://scripts/SeasonManager.gd")

func _init():
	print("--- TEST TRANSITION DE SAISON, PROMOTIONS / RELEGATIONS, RETRAITES & MERCATO ---")

	var world = GameWorld.create_default_world()
	var all_leagues: Array[League] = world["all_leagues"]
	var market: TransferMarket = world["market"]

	# Simuler l'ensemble des matchs de saison régulière pour toutes les ligues
	print("Simulation d'une saison complète...")
	for l in all_leagues:
		while not l.is_regular_season_finished():
			l.simulate_ai_matchday()

	# Simuler les playoffs pour toutes les ligues
	for l in all_leagues:
		l.init_playoffs()
		while not l.is_playoffs_finished():
			l.simulate_ai_playoff_step()

	# Trouver les ligues de France (D1, D2, D3)
	var fr_leagues: Array[League] = []
	for l in all_leagues:
		if l.country == "France":
			fr_leagues.append(l)
	fr_leagues.sort_custom(func(a, b): return a.division < b.division)

	var d1 = fr_leagues[0]
	var d2 = fr_leagues[1]
	var d3 = fr_leagues[2]

	var d1_init_size = d1.clubs.size()
	var d2_init_size = d2.clubs.size()
	var d3_init_size = d3.clubs.size()

	var st_d1 = d1.get_sorted_standings()
	var st_d2 = d2.get_sorted_standings()
	var st_d3 = d3.get_sorted_standings()

	var expected_d1_rel = [st_d1[st_d1.size() - 2], st_d1[st_d1.size() - 1]]
	var expected_d2_promo = [st_d2[0], st_d2[1]]
	var expected_d2_rel = [st_d2[st_d2.size() - 2], st_d2[st_d2.size() - 1]]
	var expected_d3_promo = [st_d3[0], st_d3[1]]

	print("D1 Relégués prévus : %s, %s" % [expected_d1_rel[0].club_name, expected_d1_rel[1].club_name])
	print("D2 Promus prévus : %s, %s" % [expected_d2_promo[0].club_name, expected_d2_promo[1].club_name])
	print("D2 Relégués prévus : %s, %s" % [expected_d2_rel[0].club_name, expected_d2_rel[1].club_name])
	print("D3 Promus prévus : %s, %s" % [expected_d3_promo[0].club_name, expected_d3_promo[1].club_name])

	# Ajouter des vieux joueurs pour tester les départs en retraite
	var old_p1 = Player.new()
	old_p1.full_name = "Vieux Briscard 1"
	old_p1.age = 38
	d1.clubs[0].squad.append(old_p1)

	var old_p2 = Player.new()
	old_p2.full_name = "Vieux Briscard 2"
	old_p2.age = 37
	d2.clubs[0].squad.append(old_p2)

	var user_club = d2.clubs[0]
	var initial_user_budget = user_club.budget
	var test_player = user_club.squad[0]
	var initial_age = test_player.age

	# Exécuter la transition de saison
	var report = SeasonManager.execute_season_transition(all_leagues, market, user_club, null, 1)

	# 1. Vérification des promotions / relégations
	assert(d1.clubs.size() == d1_init_size, "D1 doit conserver le même nombre d'équipes")
	assert(d2.clubs.size() == d2_init_size, "D2 doit conserver le même nombre d'équipes")
	assert(d3.clubs.size() == d3_init_size, "D3 doit conserver le même nombre d'équipes")

	for c in expected_d1_rel:
		assert(d2.clubs.has(c), "%s relégué de D1 doit être en D2" % c.club_name)
		assert(c.division == 2, "La division de %s doit être 2" % c.club_name)

	for c in expected_d2_promo:
		assert(d1.clubs.has(c), "%s promu de D2 doit être en D1" % c.club_name)
		assert(c.division == 1, "La division de %s doit être 1" % c.club_name)

	for c in expected_d2_rel:
		assert(d3.clubs.has(c), "%s relégué de D2 doit être en D3" % c.club_name)
		assert(c.division == 3, "La division de %s doit être 3" % c.club_name)

	for c in expected_d3_promo:
		assert(d2.clubs.has(c), "%s promu de D3 doit être en D2" % c.club_name)
		assert(c.division == 2, "La division de %s doit être 2" % c.club_name)

	print("✓ Test 1 OK: Montées et descentes respectées à la perfection (2 promus, 2 relégués)")

	# 2. Vérification des retraites et effectifs minimum
	assert(not d1.clubs[0].squad.has(old_p1), "Le joueur de 38 ans doit être parti à la retraite")
	for l in all_leagues:
		for c in l.clubs:
			assert(c.squad.size() >= 7, "Chaque club doit avoir au moins 7 joueurs")
	print("✓ Test 2 OK: Départs à la retraite traités et effectifs garantis >= 7 joueurs")

	# 3. Vérification du vieillissement et archivage des statistiques
	assert(test_player.age == initial_age + 1, "Le joueur doit avoir vieilli d'un an")
	assert(test_player.stats_history.size() >= 1, "Les stats de la saison passée doivent être archivées")
	assert(test_player.stats_current_season["matches"] == 0, "Les stats de la saison en cours doivent être remises à 0")
	print("✓ Test 3 OK: Joueurs vieillis de 1 an et statistiques archivées dans l'historique")

	# 4. Vérification de l'augmentation du budget et rafraîchissement du marché
	assert(user_club.budget > initial_user_budget, "Le club doit recevoir sa dotation de début de saison")
	assert(market.free_agents.size() >= 15, "Le marché des transferts doit avoir de nouveaux agents libres")
	print("✓ Test 4 OK: Dotations budgétaires versées et marché des transferts rafraîchi")

	# 5. Vérification de la réinitialisation des ligues et calendriers
	for l in all_leagues:
		assert(l.current_matchday_index == 0, "Journée doit être remise à 0")
		assert(l.playoff_phase == 0, "Playoffs réinitialisés")
		assert(l.schedule.size() > 0, "Nouveau calendrier généré")
		for c in l.clubs:
			assert(l.standings[c]["pts"] == 0, "Points remis à zéro")
	print("✓ Test 5 OK: Championnats et calendriers réinitialisés pour la nouvelle saison")

	# 6. Test de sauvegarde et rechargement avec season_number
	var save_path = "user://test_season_save.json"
	var save_ok = SaveManager.save_game(all_leagues, market, user_club, d1, 2, save_path)
	assert(save_ok, "La sauvegarde doit réussir")
	var loaded = SaveManager.load_game(save_path)
	assert(loaded["season_number"] == 2, "La saison sauvegardée (2) doit être restaurée")
	SaveManager.delete_save(save_path)
	print("✓ Test 6 OK: Sauvegarde et rechargement de la saison 2 validés")

	print("--- TOUS LES TESTS DE TRANSITION DE SAISON ONT REUSSI AVEC SUCCES ! ---")
	quit()
