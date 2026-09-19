class_name EuropeanCup
extends RefCounted

var qualified_clubs: Array[Club] = []
var group_a: Array[Club] = []
var group_b: Array[Club] = []

# Classements de groupes : {club: {"pts": 0, "p": 0, "w": 0, "d": 0, "l": 0, "gf": 0, "ga": 0, "gd": 0}}
var group_a_standings: Dictionary = {}
var group_b_standings: Dictionary = {}

var group_a_fixtures: Array[Array] = [] # Par journée (0..3)
var group_b_fixtures: Array[Array] = []

# Knockout
var current_phase: int = 0 # 0..3: Groupes J1..J4, 4: Demi-Finales, 5: Finale, 6: Terminé
var semi_final_1: Array[Club] = []
var semi_final_2: Array[Club] = []
var semi_results: Dictionary = {} # {match_idx: MatchReport}
var finalists: Array[Club] = []
var final_result = null
var winner: Club = null
var runner_up: Club = null

func init_cup(all_leagues: Array[League]) -> bool:
	qualified_clubs.clear()
	group_a.clear()
	group_b.clear()
	group_a_standings.clear()
	group_b_standings.clear()
	group_a_fixtures.clear()
	group_b_fixtures.clear()
	current_phase = 0
	winner = null
	runner_up = null

	var d1_leagues = all_leagues.filter(func(l): return l.division == 1)
	if d1_leagues.is_empty():
		return false

	var champions: Array[Club] = []
	var runners: Array[Club] = []

	for l in d1_leagues:
		var st = l.get_sorted_standings()
		if st.size() >= 1:
			champions.append(st[0])
			qualified_clubs.append(st[0])
		if st.size() >= 2:
			runners.append(st[1])
			qualified_clubs.append(st[1])

	if champions.size() + runners.size() < 6:
		return false

	# Répartir équitablement dans les Groupes A et B
	champions.shuffle()
	runners.shuffle()

	for i in champions.size():
		if i % 2 == 0:
			group_a.append(champions[i])
		else:
			group_b.append(champions[i])

	for i in runners.size():
		if i % 2 == 0:
			group_b.append(runners[i])
		else:
			group_a.append(runners[i])

	for c in group_a:
		group_a_standings[c] = {"pts": 0, "p": 0, "w": 0, "d": 0, "l": 0, "gf": 0, "ga": 0, "gd": 0}
	for c in group_b:
		group_b_standings[c] = {"pts": 0, "p": 0, "w": 0, "d": 0, "l": 0, "gf": 0, "ga": 0, "gd": 0}

	group_a_fixtures = _generate_group_schedule(group_a)
	group_b_fixtures = _generate_group_schedule(group_b)

	return true

func is_user_participating(user_club: Club) -> bool:
	return group_a.has(user_club) or group_b.has(user_club) or finalists.has(user_club) or semi_final_1.has(user_club) or semi_final_2.has(user_club)

func get_current_phase_name() -> String:
	match current_phase:
		0: return "Coupe d'Europe • Phase de Groupes (J1/4)"
		1: return "Coupe d'Europe • Phase de Groupes (J2/4)"
		2: return "Coupe d'Europe • Phase de Groupes (J3/4)"
		3: return "Coupe d'Europe • Phase de Groupes (J4/4)"
		4: return "Coupe d'Europe • Demi-Finales"
		5: return "Coupe d'Europe • GRANDE FINALE"
		_: return "Coupe d'Europe • Tournoi Terminé"

func _generate_group_schedule(clubs: Array[Club]) -> Array[Array]:
	# 5 équipes = chaque équipe joue 4 matchs sur 4 journées
	var list = clubs.duplicate()
	var schedule: Array[Array] = []
	if list.size() < 5:
		return schedule

	# Round robin pour 5 équipes
	schedule.append([[list[0], list[1]], [list[2], list[3]]])
	schedule.append([[list[0], list[2]], [list[3], list[4]]])
	schedule.append([[list[1], list[3]], [list[0], list[4]]])
	schedule.append([[list[1], list[4]], [list[2], list[0]]])
	return schedule

func get_group_standings_sorted(is_group_a: bool) -> Array[Dictionary]:
	var st = group_a_standings if is_group_a else group_b_standings
	var arr: Array[Dictionary] = []
	for c in st.keys():
		var row = st[c].duplicate()
		row["club"] = c
		arr.append(row)

	arr.sort_custom(func(x, y):
		if x["pts"] != y["pts"]:
			return x["pts"] > y["pts"]
		if x["gd"] != y["gd"]:
			return x["gd"] > y["gd"]
		return x["gf"] > y["gf"]
	)
	return arr

func record_group_result(is_group_a: bool, h: Club, a: Club, h_score: int, a_score: int) -> void:
	var st = group_a_standings if is_group_a else group_b_standings
	if not st.has(h) or not st.has(a):
		return

	var h_row = st[h]
	var a_row = st[a]

	h_row["p"] += 1
	a_row["p"] += 1
	h_row["gf"] += h_score
	h_row["ga"] += a_score
	a_row["gf"] += a_score
	a_row["ga"] += h_score
	h_row["gd"] = h_row["gf"] - h_row["ga"]
	a_row["gd"] = a_row["gf"] - a_row["ga"]

	if h_score > a_score:
		h_row["w"] += 1
		h_row["pts"] += 3
		a_row["l"] += 1
	elif h_score < a_score:
		a_row["w"] += 1
		a_row["pts"] += 3
		h_row["l"] += 1
	else:
		h_row["d"] += 1
		h_row["pts"] += 1
		a_row["d"] += 1
		a_row["pts"] += 1

func setup_semi_finals() -> void:
	var st_a = get_group_standings_sorted(true)
	var st_b = get_group_standings_sorted(false)

	var a1: Club = st_a[0]["club"]
	var a2: Club = st_a[1]["club"]
	var b1: Club = st_b[0]["club"]
	var b2: Club = st_b[1]["club"]

	semi_final_1 = [a1, b2]
	semi_final_2 = [b1, a2]

func award_trophy(winning_club: Club, losing_club: Club, season_num: int = 1) -> void:
	winner = winning_club
	runner_up = losing_club

	var trophy_title = "Vainqueur Coupe d'Europe (Saison %d)" % season_num
	var runner_title = "Finaliste Coupe d'Europe (Saison %d)" % season_num

	if not winning_club.palmares.has(trophy_title):
		winning_club.palmares.append(trophy_title)
	winning_club.budget += 250_000

	if not losing_club.palmares.has(runner_title):
		losing_club.palmares.append(runner_title)
	losing_club.budget += 100_000

	for p in winning_club.squad:
		if not p.palmares.has(trophy_title):
			p.palmares.append(trophy_title)
		p.recalculate_value(winning_club.division)

	for p in losing_club.squad:
		p.recalculate_value(losing_club.division)

func get_current_fixtures() -> Array[Array]:
	if current_phase < 4:
		var fixtures: Array[Array] = []
		if current_phase < group_a_fixtures.size():
			fixtures.append_array(group_a_fixtures[current_phase])
		if current_phase < group_b_fixtures.size():
			fixtures.append_array(group_b_fixtures[current_phase])
		return fixtures
	elif current_phase == 4:
		var s: Array[Array] = []
		if not semi_final_1.is_empty():
			s.append(semi_final_1)
		if not semi_final_2.is_empty():
			s.append(semi_final_2)
		return s
	elif current_phase == 5:
		var f: Array[Array] = []
		if not finalists.is_empty():
			f.append(finalists)
		return f
	return []

func get_user_match_in_current_phase(user_c: Club) -> Array:
	for pair in get_current_fixtures():
		if pair.size() >= 2 and (pair[0] == user_c or pair[1] == user_c):
			return pair
	return []

func record_match(h: Club, a: Club, h_score: int, a_score: int) -> void:
	if current_phase < 4:
		if group_a.has(h):
			record_group_result(true, h, a, h_score, a_score)
		else:
			record_group_result(false, h, a, h_score, a_score)
	elif current_phase == 4:
		var winner_club = h if h_score > a_score else a
		if h_score == a_score:
			winner_club = h if randf() < 0.5 else a
		semi_results[[h, a]] = {"winner": winner_club, "score": "%d-%d" % [h_score, a_score]}
	elif current_phase == 5:
		var winner_club = h if h_score > a_score else a
		var loser_club = a if winner_club == h else h
		if h_score == a_score:
			winner_club = h if randf() < 0.5 else a
			loser_club = a if winner_club == h else h
		final_result = {"winner": winner_club, "loser": loser_club, "score": "%d-%d" % [h_score, a_score]}
		award_trophy(winner_club, loser_club, 1)

func advance_phase() -> void:
	if current_phase < 3:
		current_phase += 1
	elif current_phase == 3:
		current_phase = 4
		setup_semi_finals()
	elif current_phase == 4:
		var w1 = semi_results.get(semi_final_1, {}).get("winner", semi_final_1[0] if not semi_final_1.is_empty() else null)
		var w2 = semi_results.get(semi_final_2, {}).get("winner", semi_final_2[0] if not semi_final_2.is_empty() else null)
		if w1 != null and w2 != null:
			finalists = [w1, w2]
		current_phase = 5
	elif current_phase == 5:
		current_phase = 6

