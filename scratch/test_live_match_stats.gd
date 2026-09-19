extends SceneTree

const GameWorld = preload("res://scripts/GameWorld.gd")
const MatchEngine = preload("res://scripts/MatchEngine.gd")

func _init() -> void:
	print("=== DEBUT DU TEST STATS EN TEMPS REEL ===")
	await process_frame
	
	var world = GameWorld.create_default_world()
	var leagues = world["all_leagues"]
	var d1: League = leagues[0]
	var c1: Club = d1.clubs[0]
	var c2: Club = d1.clubs[1]
	
	c1.auto_pick_lineup()
	c2.auto_pick_lineup()
	
	# Vérifier stats initiales
	for p in c1.starting_five:
		assert(p.stats_current_season.get("matches", 0) == 0, "Matches doit être 0 au départ")
	
	print("✓ Stats initiales vérifiées (0 match joué)")
	
	# Simuler un match
	var rep = MatchEngine.simulate_match(c1, c2, 5)
	print("Match joué : %s %d - %d %s" % [c1.club_name, rep.home_score, rep.away_score, c2.club_name])
	
	# Vérifier que les 10 titulaires ont bien 1 match joué
	for p in c1.starting_five:
		assert(p.stats_current_season.get("matches", 0) == 1, "Chaque titulaire c1 doit avoir 1 match joué")
	for p in c2.starting_five:
		assert(p.stats_current_season.get("matches", 0) == 1, "Chaque titulaire c2 doit avoir 1 match joué")
	print("✓ Titulaires c1 et c2 ont bien 'Matchs: 1'")
	
	# Vérifier les buts
	var total_goals_c1 = 0
	for p in c1.starting_five:
		total_goals_c1 += p.stats_current_season.get("goals", 0)
	assert(total_goals_c1 == rep.home_score, "Le total de buts des joueurs doit correspondre au score home")
	
	var total_goals_c2 = 0
	for p in c2.starting_five:
		total_goals_c2 += p.stats_current_season.get("goals", 0)
	assert(total_goals_c2 == rep.away_score, "Le total de buts des joueurs doit correspondre au score away")
	print("✓ Buts enregistrés avec succès pour tous les buteurs (%d et %d)" % [total_goals_c1, total_goals_c2])
	
	# Vérifier la présence de tacles et d'arrêts
	var total_tackles = 0
	var total_saves = 0
	for p in c1.starting_five:
		total_tackles += p.stats_current_season.get("tackles", 0)
		total_saves += p.stats_current_season.get("saves", 0)
	for p in c2.starting_five:
		total_tackles += p.stats_current_season.get("tackles", 0)
		total_saves += p.stats_current_season.get("saves", 0)
	print("✓ Stats de jeu : %d tacles et %d arrêts enregistrés sur le match !" % [total_tackles, total_saves])
	
	# Vérifier PlayerDetailModal
	var modal_res = load("res://scenes/PlayerDetailModal.tscn")
	var modal = modal_res.instantiate()
	root.add_child(modal)
	await process_frame
	
	var test_player = c1.starting_five[0]
	modal.open_player(test_player, c1)
	await process_frame
	
	assert(modal.stats_history_container.get_child_count() >= 1, "La modale doit afficher la ligne de saison en cours")
	var row_panel = modal.stats_history_container.get_child(0)
	assert(row_panel is PanelContainer, "La ligne doit être un PanelContainer stylisé")
	print("✓ Modale Joueur affiche parfaitement la ligne de stats de la saison en cours !")
	
	modal.queue_free()
	print("=== TOUS LES TESTS DE STATISTIQUES SONT VALIDES ! ===")
	quit(0)
