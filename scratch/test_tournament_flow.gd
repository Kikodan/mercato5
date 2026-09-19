extends SceneTree

const GameWorld = preload("res://scripts/GameWorld.gd")
const League = preload("res://scripts/League.gd")
const EuropeanCup = preload("res://scripts/EuropeanCup.gd")
const MatchEngine = preload("res://scripts/MatchEngine.gd")
const TrophyModal = preload("res://scenes/TrophyModal.gd")

func _init() -> void:
	print("--- TEST COMPLET DU FLUX DE TOURNOIS (PLAYOFFS + COUPE D'EUROPE + TROPHEES) ---")
	
	# 1. Génération de l'univers
	var world_data = GameWorld.create_default_world()
	var all_leagues: Array[League] = world_data["all_leagues"]
	var d1_fr: League = null
	for l in all_leagues:
		if l.country == "France" and l.division == 1:
			d1_fr = l
			break
	
	assert(d1_fr != null, "D1 France introuvable")
	var player_club = d1_fr.clubs[0]
	
	# 2. Simuler les 14 journées de saison régulière
	for day in d1_fr.schedule:
		for pair in day:
			var rep = MatchEngine.simulate_match(pair[0], pair[1], 5)
			d1_fr.record_match_result(pair[0], pair[1], rep.home_score, rep.away_score)
		d1_fr.current_matchday_index += 1
	
	for l in all_leagues:
		if l != d1_fr:
			for i in range(14):
				l.simulate_ai_matchday()
	
	print("Saison régulière terminée. Journée index = %d" % d1_fr.current_matchday_index)
	assert(d1_fr.current_matchday_index >= 14, "La saison régulière devrait être terminée")
	
	# 3. Initialiser les playoffs
	d1_fr.init_playoffs()
	assert(d1_fr.has_playoffs_started(), "Les playoffs devraient avoir démarré")
	assert(d1_fr.playoff_phase == 1, "Phase 1 attendue (Demi-finale)")
	
	print("Demi-Finale: %s vs %s" % [d1_fr.playoff_semi_home.club_name, d1_fr.playoff_semi_away.club_name])
	var rep_semi = MatchEngine.simulate_match(d1_fr.playoff_semi_home, d1_fr.playoff_semi_away, 7)
	assert(rep_semi.home_score >= 7 or rep_semi.away_score >= 7, "Score de demi-finale en 7 buts")
	var semi_winner = d1_fr.record_playoff_semi(rep_semi.home_score, rep_semi.away_score)
	print("Vainqueur Demi-Finale : %s (%d - %d)" % [semi_winner.club_name, rep_semi.home_score, rep_semi.away_score])
	
	assert(d1_fr.playoff_phase == 2, "Phase 2 attendue (Finale)")
	print("Grande Finale: %s (1er) vs %s" % [d1_fr.playoff_final_home.club_name, d1_fr.playoff_final_away.club_name])
	var rep_final = MatchEngine.simulate_match(d1_fr.playoff_final_home, d1_fr.playoff_final_away, 7)
	assert(rep_final.home_score >= 7 or rep_final.away_score >= 7, "Score de finale en 7 buts")
	var league_champ = d1_fr.record_playoff_final(rep_final.home_score, rep_final.away_score)
	print("CHAMPION DE LA LIGUE : %s (%d - %d)" % [league_champ.club_name, rep_final.home_score, rep_final.away_score])
	assert(d1_fr.is_playoffs_finished(), "Les playoffs doivent être terminés")
	
	# 4. Instanciation du TrophyModal
	var trophy = TrophyModal.new()
	var loser = d1_fr.playoff_final_away if league_champ == d1_fr.playoff_final_home else d1_fr.playoff_final_home
	trophy.show_league_champion(league_champ, loser, rep_final.home_score, rep_final.away_score, league_champ == player_club, d1_fr.league_name)
	assert(trophy.visible, "Le TrophyModal doit être visible")
	print("✓ Trophée Championnat affiché avec succès : %s" % trophy.lbl_title.text)
	
	# Simuler les playoffs pour les autres ligues
	for l in all_leagues:
		if l != d1_fr:
			l.init_playoffs()
			l.simulate_ai_playoff_step()
			l.simulate_ai_playoff_step()
	
	# 5. Coupe d'Europe
	var euro = EuropeanCup.new()
	var euro_ok = euro.init_cup(all_leagues)
	assert(euro_ok, "La coupe d'Europe doit s'initialiser")
	print("Coupe d'Europe initialisée avec %d clubs" % euro.qualified_clubs.size())
	
	# Simuler 4 journées de poules
	for phase in range(4):
		var fixtures = euro.get_current_fixtures()
		print("Phase %d (%s) : %d matchs" % [euro.current_phase, euro.get_current_phase_name(), fixtures.size()])
		for pair in fixtures:
			var rep = MatchEngine.simulate_match(pair[0], pair[1], 5)
			euro.record_match(pair[0], pair[1], rep.home_score, rep.away_score)
		euro.advance_phase()
	
	assert(euro.current_phase == 4, "Phase 4 attendue (Demi-finales)")
	print("Demi-Finales Coupe d'Europe :")
	var semi_fixtures = euro.get_current_fixtures()
	for pair in semi_fixtures:
		var rep = MatchEngine.simulate_match(pair[0], pair[1], 5)
		euro.record_match(pair[0], pair[1], rep.home_score, rep.away_score)
		print("  %s %d - %d %s" % [pair[0].club_name, rep.home_score, rep.away_score, pair[1].club_name])
	euro.advance_phase()
	
	assert(euro.current_phase == 5, "Phase 5 attendue (Grande Finale)")
	print("GRANDE FINALE COUPE D'EUROPE : %s vs %s" % [euro.finalists[0].club_name, euro.finalists[1].club_name])
	var final_fixtures = euro.get_current_fixtures()
	var rep_euro_final = MatchEngine.simulate_match(final_fixtures[0][0], final_fixtures[0][1], 5)
	euro.record_match(final_fixtures[0][0], final_fixtures[0][1], rep_euro_final.home_score, rep_euro_final.away_score)
	euro.advance_phase()
	
	assert(euro.current_phase >= 6, "Phase 6 attendue (Terminé)")
	assert(euro.winner != null, "Un vainqueur européen doit exister")
	assert(euro.runner_up != null, "Un finaliste européen doit exister")
	print("VAINQUEUR COUPE D'EUROPE : %s (Finaliste : %s)" % [euro.winner.club_name, euro.runner_up.club_name])
	
	trophy.show_european_champion(euro.winner, euro.runner_up, "%d - %d" % [rep_euro_final.home_score, rep_euro_final.away_score], euro.winner == player_club)
	print("✓ Trophée Européen affiché avec succès : %s" % trophy.lbl_title.text)
	
	print("--- TOUS LES TESTS DE TOURNOIS ET TROPHEES SONT VALIDES AVEC SUCCES ! ---")
	quit(0)
