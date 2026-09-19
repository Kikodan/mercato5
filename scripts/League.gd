class_name League
extends Resource

@export var league_name: String = "Division 1 Élite"
@export var country: String = "France"
@export var division: int = 1
@export var clubs: Array[Club] = []

func get_country_flag() -> String:
	match country:
		"France": return "[FRA]"
		"Espagne": return "[ESP]"
		"Italie": return "[ITA]"
		"Angleterre": return "[ENG]"
		"Portugal": return "[POR]"
		"Allemagne": return "[ALL]"
		"Brésil": return "[BRE]"
		"Belgique": return "[BEL]"
		"Pays-Bas": return "[P-B]"
		_: return "[INT]"

var standings: Dictionary = {}
var schedule: Array[Array] = []
var current_matchday_index: int = 0

# --- PLAYOFFS DU CHAMPIONNAT (Top 3 en 7 buts gagnants) ---
# Phase 0: Non commencés
# Phase 1: Demi-finale (2e vs 3e)
# Phase 2: Finale (1er vs vainqueur demi)
# Phase 3: Terminé (Champion officiel couronné)
var playoff_phase: int = 0
var playoff_semi_home: Club = null
var playoff_semi_away: Club = null
var playoff_semi_score: Array = [0, 0]
var playoff_semi_winner: Club = null

var playoff_final_home: Club = null
var playoff_final_away: Club = null
var playoff_final_score: Array = [0, 0]
var playoff_champion: Club = null

func is_regular_season_finished() -> bool:
	return current_matchday_index >= schedule.size()

func is_playoffs_active() -> bool:
	return playoff_phase == 1 or playoff_phase == 2

func has_playoffs_started() -> bool:
	return playoff_phase > 0

func is_playoffs_finished() -> bool:
	return playoff_phase >= 3

func init_playoffs() -> void:
	var sorted = get_sorted_standings()
	if sorted.size() < 3:
		return
	playoff_phase = 1
	# 2e vs 3e : le 2e a l'avantage du terrain
	playoff_semi_home = sorted[1]
	playoff_semi_away = sorted[2]
	playoff_semi_score = [0, 0]
	playoff_semi_winner = null

	# Le 1er de la saison régulière attend directement en Grande Finale
	playoff_final_home = sorted[0]
	playoff_final_away = null
	playoff_final_score = [0, 0]
	playoff_champion = null

func record_playoff_semi(home_goals: int, away_goals: int) -> Club:
	playoff_semi_score = [home_goals, away_goals]
	if home_goals > away_goals:
		playoff_semi_winner = playoff_semi_home
	else:
		playoff_semi_winner = playoff_semi_away
	playoff_final_away = playoff_semi_winner
	playoff_phase = 2
	return playoff_semi_winner

func record_playoff_final(home_goals: int, away_goals: int) -> Club:
	playoff_final_score = [home_goals, away_goals]
	if home_goals > away_goals:
		playoff_champion = playoff_final_home
	else:
		playoff_champion = playoff_final_away
	playoff_phase = 3

	# Ajouter le titre au palmarès du club champion et de ses joueurs
	var title = "Champion %s" % league_name
	if not playoff_champion.palmares.has(title):
		playoff_champion.palmares.append(title)
	for p in playoff_champion.squad:
		if not p.palmares.has(title):
			p.palmares.append(title)
		p.recalculate_value(playoff_champion.division)

	return playoff_champion

func initialize_league() -> void:
	standings.clear()
	playoff_phase = 0
	playoff_semi_winner = null
	playoff_champion = null
	for c in clubs:
		standings[c] = {"pts": 0, "p": 0, "w": 0, "d": 0, "l": 0, "gf": 0, "ga": 0, "gd": 0}
	_generate_schedule()

func _generate_schedule() -> void:
	schedule.clear()
	var teams: Array[Club] = clubs.duplicate()
	var n: int = teams.size()
	var rounds: int = n - 1
	var first_leg: Array[Array] = []

	for round_idx in rounds:
		var day_matches: Array = []
		for i in n / 2:
			var home = teams[i]
			var away = teams[n - 1 - i]
			if round_idx % 2 == 1:
				day_matches.append([away, home])
			else:
				day_matches.append([home, away])
		first_leg.append(day_matches)

		var last_team: Club = teams.pop_back()
		teams.insert(1, last_team)

	for day in first_leg:
		schedule.append(day)
	for day in first_leg:
		var return_day: Array = []
		for pair in day:
			return_day.append([pair[1], pair[0]])
		schedule.append(return_day)

func record_match_result(home: Club, away: Club, h_goals: int, a_goals: int) -> void:
	var h = standings[home]
	var a = standings[away]
	h["p"] += 1
	a["p"] += 1
	h["gf"] += h_goals
	h["ga"] += a_goals
	a["gf"] += a_goals
	a["ga"] += h_goals
	h["gd"] = h["gf"] - h["ga"]
	a["gd"] = a["gf"] - a["ga"]

	# Règle du premier à 4 buts : aucun match nul !
	if h_goals > a_goals:
		h["pts"] += 3
		h["w"] += 1
		a["l"] += 1
	else:
		a["pts"] += 3
		a["w"] += 1
		h["l"] += 1

func get_sorted_standings() -> Array[Club]:
	var sorted: Array[Club] = clubs.duplicate()
	sorted.sort_custom(func(a, b):
		var da = standings[a]
		var db = standings[b]
		if da["pts"] != db["pts"]:
			return da["pts"] > db["pts"]
		if da["gd"] != db["gd"]:
			return da["gd"] > db["gd"]
		return da["gf"] > db["gf"]
	)
	return sorted

func simulate_ai_matchday() -> void:
	if current_matchday_index < schedule.size():
		var day_matches = schedule[current_matchday_index]
		for pair in day_matches:
			var home: Club = pair[0]
			var away: Club = pair[1]
			var rep = MatchEngine.simulate_match(home, away, 5)
			record_match_result(home, away, rep.home_score, rep.away_score)

		for c in clubs:
			c.recover_fitness()

		current_matchday_index += 1
	elif is_playoffs_active():
		simulate_ai_playoff_step()

func simulate_ai_playoff_step() -> void:
	if playoff_phase == 1:
		var rep = MatchEngine.simulate_match(playoff_semi_home, playoff_semi_away, 7)
		record_playoff_semi(rep.home_score, rep.away_score)
		for c in clubs: c.recover_fitness()
	elif playoff_phase == 2:
		var rep = MatchEngine.simulate_match(playoff_final_home, playoff_final_away, 7)
		record_playoff_final(rep.home_score, rep.away_score)
		for c in clubs: c.recover_fitness()


