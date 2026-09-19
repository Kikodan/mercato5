extends SceneTree

func _init():
	print("--- TEST NOUVELLES REGLES ET PLAYOFFS ---")

	# 1. Test Player Country Badge
	var p = Player.new()
	p.nationality = "France"
	assert(p.get_flag_emoji() == "[FRA]", "get_flag_emoji should be [FRA]")
	p.nationality = "Espagne"
	assert(p.get_flag_emoji() == "[ESP]", "get_flag_emoji should be [ESP]")
	print("✓ Test 1 OK: Country badges function correctly without emojis")

	# 2. Test 5-Goal Match Simulation (No draws, shots on target & tackles tracked)
	var world = GameWorld.create_default_world()
	var all_leagues = world["all_leagues"]
	var league: League = all_leagues[0]
	var c1: Club = league.clubs[0]
	var c2: Club = league.clubs[1]

	for i in 10:
		var rep = MatchEngine.simulate_match(c1, c2, 5)
		assert(rep.home_score == 5 or rep.away_score == 5, "One team must reach exactly 5 goals")
		assert(rep.home_score != rep.away_score, "Matches cannot be draws")
		assert(rep.home_shots_on_target >= rep.home_score, "Home shots on target must be >= home score")
		assert(rep.away_shots_on_target >= rep.away_score, "Away shots on target must be >= away score")
		assert(rep.home_possession_pct >= 0 and rep.home_possession_pct <= 100, "Possession must be between 0 and 100")
	print("✓ Test 2 OK: 10/10 matches ended with winner reaching 5 goals, shots on target and possession tracked")

	# 3. Test League Standings (no draws, 3 pts for win, 0 for loss)
	league.initialize_league()
	var rep = MatchEngine.simulate_match(c1, c2, 5)
	league.record_match_result(c1, c2, rep.home_score, rep.away_score)
	var winner = c1 if rep.home_score == 5 else c2
	var loser = c2 if rep.home_score == 5 else c1
	assert(league.standings[winner]["pts"] == 3, "Winner must get 3 pts")
	assert(league.standings[winner]["w"] == 1, "Winner must get 1 win")
	assert(league.standings[loser]["pts"] == 0, "Loser must get 0 pts")
	assert(league.standings[loser]["l"] == 1, "Loser must get 1 loss")
	print("✓ Test 3 OK: Standings correctly credit 3 pts for win and 0 for loss")

	# 4. Test Playoff Stepladder System (7 goals)
	while not league.is_regular_season_finished():
		league.simulate_ai_matchday()

	print("Regular season finished at matchday %d" % league.current_matchday_index)
	assert(league.is_regular_season_finished(), "Regular season must be finished")

	# Init playoffs
	league.init_playoffs()
	assert(league.is_playoffs_active(), "Playoffs must be active")
	assert(league.playoff_phase == 1, "Playoffs phase must be 1 (Semi-final)")
	var semi_h = league.playoff_semi_home
	var semi_a = league.playoff_semi_away
	print("Playoff Semi: %s vs %s" % [semi_h.club_name, semi_a.club_name])

	# Simulate semi-final in 7 goals
	var semi_rep = MatchEngine.simulate_match(semi_h, semi_a, 7)
	assert(semi_rep.home_score == 7 or semi_rep.away_score == 7, "Semi winner must reach 7 goals")
	var semi_winner = league.record_playoff_semi(semi_rep.home_score, semi_rep.away_score)
	print("Semi-final finished: %d - %d, Winner: %s" % [semi_rep.home_score, semi_rep.away_score, semi_winner.club_name])
	assert(league.playoff_phase == 2, "Playoffs phase must be 2 (Final)")
	assert(league.playoff_final_away == semi_winner, "Finalist must be semi winner")

	# Simulate final in 7 goals
	var final_h = league.playoff_final_home
	var final_a = league.playoff_final_away
	print("Playoff Final: %s (1er) vs %s (Vainqueur Semi)" % [final_h.club_name, final_a.club_name])
	var final_rep = MatchEngine.simulate_match(final_h, final_a, 7)
	assert(final_rep.home_score == 7 or final_rep.away_score == 7, "Final winner must reach 7 goals")
	var champion = league.record_playoff_final(final_rep.home_score, final_rep.away_score)
	print("Playoff Final finished: %d - %d, CHAMPION: %s" % [final_rep.home_score, final_rep.away_score, champion.club_name])
	assert(league.is_playoffs_finished(), "Playoffs must be finished")
	assert(league.playoff_champion == champion, "Champion must be recorded")
	assert(champion.palmares.has("Champion %s" % league.league_name), "Palmares must include Championship title")

	print("✓ Test 4 OK: Stepladder playoffs (7 goals) executed flawlessly")
	print("--- TOUS LES TESTS SONT VALIDES AVEC SUCCES ---")
	quit()
