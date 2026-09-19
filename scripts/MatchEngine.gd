class_name MatchEngine
extends RefCounted

class MatchReport:
	var home_club: Club
	var away_club: Club
	var home_score: int = 0
	var away_score: int = 0
	var target_goals: int = 5
	var home_possession_pct: int = 50
	var home_shots_on_target: int = 0
	var away_shots_on_target: int = 0
	var home_tackles: int = 0
	var away_tackles: int = 0
	var events: Array[Dictionary] = []

static func simulate_match(home: Club, away: Club, target_goals: int = 5) -> MatchReport:
	var report = MatchReport.new()
	report.home_club = home
	report.away_club = away
	report.target_goals = target_goals


	if not home.is_lineup_valid():
		home.auto_pick_lineup()
	if not away.is_lineup_valid():
		away.auto_pick_lineup()

	# Initialiser les matchs joués et notes pour les 10 titulaires
	var match_ratings: Dictionary = {}
	for p in home.starting_five:
		p.stats_current_season["matches"] = p.stats_current_season.get("matches", 0) + 1
		match_ratings[p] = 6.0
	for p in away.starting_five:
		p.stats_current_season["matches"] = p.stats_current_season.get("matches", 0) + 1
		match_ratings[p] = 6.0

	var poss = _calc_possession(home, away)
	report.home_possession_pct = int(poss * 100.0)

	var minute: int = 1
	var safety_counter: int = 0

	# La partie se termine immédiatement dès qu'une équipe atteint target_goals (4 en ligue, 7 en playoffs)
	while report.home_score < target_goals and report.away_score < target_goals and safety_counter < 150:
		safety_counter += 1
		minute += randi_range(2, 4)
		var atk = home if randf() < poss else away
		var def_c = away if atk == home else home
		_resolve_phase(minute, atk, def_c, report, match_ratings, target_goals)

	# Garantie absolue : pas de match nul, la première équipe à target_goals gagne
	while report.home_score < target_goals and report.away_score < target_goals:
		minute += 2
		var atk = home if randf() < poss else away
		var def_c = away if atk == home else home
		_force_goal(minute, atk, def_c, report, match_ratings, target_goals)

	# Clean sheets pour les gardiens
	if report.away_score == 0:
		var h_gk = _get_gk(home.starting_five)
		if h_gk != null:
			h_gk.stats_current_season["clean_sheets"] = h_gk.stats_current_season.get("clean_sheets", 0) + 1
			match_ratings[h_gk] = match_ratings.get(h_gk, 6.0) + 0.5
	if report.home_score == 0:
		var a_gk = _get_gk(away.starting_five)
		if a_gk != null:
			a_gk.stats_current_season["clean_sheets"] = a_gk.stats_current_season.get("clean_sheets", 0) + 1
			match_ratings[a_gk] = match_ratings.get(a_gk, 6.0) + 0.5

	# Mettre à jour les notes moyennes et recalculer les valeurs marchandes
	for p in home.starting_five:
		var r = clampf(match_ratings.get(p, 6.0), 3.0, 10.0)
		p.stats_current_season["rating_sum"] = p.stats_current_season.get("rating_sum", 0.0) + r
		p.recalculate_value(home.division)

	for p in away.starting_five:
		var r = clampf(match_ratings.get(p, 6.0), 3.0, 10.0)
		p.stats_current_season["rating_sum"] = p.stats_current_season.get("rating_sum", 0.0) + r
		p.recalculate_value(away.division)

	_apply_fatigue(home)
	_apply_fatigue(away)
	return report


static func _calc_possession(c1: Club, c2: Club) -> float:
	var m1 = _get_stat(c1.starting_five, "passing") * _get_fitness(c1.starting_five)
	var m2 = _get_stat(c2.starting_five, "passing") * _get_fitness(c2.starting_five)

	if c1.tactical_style == 1:
		m1 *= 1.15
	elif c1.tactical_style == 2:
		m1 *= 0.85

	if c2.tactical_style == 1:
		m2 *= 1.15
	elif c2.tactical_style == 2:
		m2 *= 0.85

	return clampf(m1 / max(1.0, m1 + m2), 0.25, 0.75)

static func _resolve_phase(minute: int, atk: Club, def_c: Club, rep: MatchReport, match_ratings: Dictionary, target_goals: int) -> void:
	var attacker: Player = _pick_outfield(atk.starting_five)
	var defender: Player = _pick_outfield(def_c.starting_five)
	var keeper: Player = _get_gk(def_c.starting_five)

	var fat_atk = attacker.fitness if minute <= 20 else attacker.fitness * (0.6 if attacker.trait_negative == "Fumeur" else 0.85)
	var fat_def = defender.fitness if minute <= 20 else defender.fitness * 0.85

	var atk_power = (attacker.speed + attacker.passing) * 0.5 * fat_atk
	var def_power = (defender.speed + defender.defending) * 0.5 * fat_def

	if atk.tactical_style == 1:
		atk_power *= 1.15
	if def_c.tactical_style == 2:
		def_power *= 1.20

	if attacker.trait_negative == "Individualiste" and randf() < 0.3:
		atk_power *= 0.6

	if randf() * (atk_power + def_power) < def_power:
		if defender.trait_negative == "Nerfs fragiles" and randf() < 0.2:
			match_ratings[defender] = match_ratings.get(defender, 6.0) - 0.3
			rep.events.append({
				"minute": minute, "club": def_c, "is_goal": false,
				"event_type": "foul", "attacker": attacker, "defender": defender, "keeper": keeper,
				"atk_club": atk, "def_club": def_c,
				"text": "%d' 🟨 Faute rugueuse de %s sur %s." % [minute, defender.full_name, attacker.full_name]
			})
		else:
			defender.stats_current_season["tackles"] = defender.stats_current_season.get("tackles", 0) + 1
			match_ratings[defender] = match_ratings.get(defender, 6.0) + 0.35
			if def_c == rep.home_club:
				rep.home_tackles += 1
			else:
				rep.away_tackles += 1
			rep.events.append({
				"minute": minute, "club": def_c, "is_goal": false,
				"event_type": "tackle", "attacker": attacker, "defender": defender, "keeper": keeper,
				"atk_club": atk, "def_club": def_c,
				"text": "%d' ⚔️ Tacle glissé décisif de %s." % [minute, defender.full_name]
			})
		return

	var shot_bonus = 2.0 if atk.training_focus == 1 else 0.0
	var def_bonus = 2.0 if def_c.training_focus == 2 else 0.0

	var shot_rating = float(attacker.shooting) + shot_bonus + (4.0 if attacker.trait_positive == "Renard des surfaces" else 0.0)
	var save_rating = float(keeper.defending if keeper else 5) + def_bonus + (4.0 if keeper and keeper.trait_positive == "Mur" else 0.0)

	# Tir cadré (vers le but)
	if atk == rep.home_club:
		rep.home_shots_on_target += 1
	else:
		rep.away_shots_on_target += 1

	if randf() < (shot_rating / max(1.0, shot_rating + save_rating)):
		if atk == rep.home_club:
			rep.home_score += 1
		else:
			rep.away_score += 1

		# Stats du buteur
		attacker.stats_current_season["goals"] = attacker.stats_current_season.get("goals", 0) + 1
		match_ratings[attacker] = match_ratings.get(attacker, 6.0) + 1.2

		# Passe décisive
		var assist_cands = atk.starting_five.filter(func(p): return p != attacker and p.position != Player.Position.GK)
		var assister: Player = assist_cands.pick_random() if not assist_cands.is_empty() else null
		var assist_str = ""
		if assister != null:
			assister.stats_current_season["assists"] = assister.stats_current_season.get("assists", 0) + 1
			match_ratings[assister] = match_ratings.get(assister, 6.0) + 0.7
			assist_str = " (passe de %s)" % assister.full_name

		# Malus défenseur et gardien sur but encaissé
		match_ratings[defender] = match_ratings.get(defender, 6.0) - 0.15
		if keeper != null:
			match_ratings[keeper] = match_ratings.get(keeper, 6.0) - 0.20

		var is_win_goal = (rep.home_score >= target_goals or rep.away_score >= target_goals)
		var win_tag = " 🏆 BUT DE LA VICTOIRE !" if is_win_goal else ""

		rep.events.append({
			"minute": minute, "club": atk, "is_goal": true,
			"is_winning_goal": is_win_goal,
			"event_type": "goal", "attacker": attacker, "defender": defender, "keeper": keeper,
			"assister": assister, "atk_club": atk, "def_club": def_c,
			"text": "%d' ⚽ BUT !%s Frappe limpide de %s%s (%d - %d)." % [
				minute, win_tag, attacker.full_name, assist_str, rep.home_score, rep.away_score
			]
		})
	else:
		if keeper != null:
			keeper.stats_current_season["saves"] = keeper.stats_current_season.get("saves", 0) + 1
			match_ratings[keeper] = match_ratings.get(keeper, 6.0) + 0.45

		rep.events.append({
			"minute": minute, "club": def_c, "is_goal": false,
			"event_type": "save", "attacker": attacker, "defender": defender, "keeper": keeper,
			"atk_club": atk, "def_club": def_c,
			"text": "%d' 🧤 Parade réflexe de %s face à %s !" % [minute, keeper.full_name if keeper else "la défense", attacker.full_name]
		})

static func _force_goal(minute: int, atk: Club, def_c: Club, rep: MatchReport, match_ratings: Dictionary, target_goals: int) -> void:
	var attacker: Player = _pick_outfield(atk.starting_five)
	var defender: Player = _pick_outfield(def_c.starting_five)
	var keeper: Player = _get_gk(def_c.starting_five)

	if atk == rep.home_club:
		rep.home_shots_on_target += 1
		rep.home_score += 1
	else:
		rep.away_shots_on_target += 1
		rep.away_score += 1

	attacker.stats_current_season["goals"] = attacker.stats_current_season.get("goals", 0) + 1
	match_ratings[attacker] = match_ratings.get(attacker, 6.0) + 1.2
	var is_win = (rep.home_score >= target_goals or rep.away_score >= target_goals)
	var win_tag = " 🏆 BUT DE LA VICTOIRE !" if is_win else ""

	rep.events.append({
		"minute": minute, "club": atk, "is_goal": true,
		"is_winning_goal": is_win,
		"event_type": "goal", "attacker": attacker, "defender": defender, "keeper": keeper,
		"assister": null, "atk_club": atk, "def_club": def_c,
		"text": "%d' ⚽ BUT !%s Finition chirurgicale de %s ! (%d - %d)." % [
			minute, win_tag, attacker.full_name, rep.home_score, rep.away_score
		]
	})


static func _pick_outfield(lineup: Array[Player]) -> Player:
	var out = lineup.filter(func(p): return p.position != Player.Position.GK)
	return out.pick_random() if not out.is_empty() else lineup.pick_random()

static func _get_gk(lineup: Array[Player]) -> Player:
	for p in lineup:
		if p.position == Player.Position.GK:
			return p
	return null

static func _get_stat(lineup: Array[Player], stat: String) -> float:
	if lineup.is_empty():
		return 10.0
	var sum = 0.0
	for p in lineup:
		sum += float(p.get(stat))
	return sum / float(lineup.size())

static func _get_fitness(lineup: Array[Player]) -> float:
	if lineup.is_empty():
		return 1.0
	var sum = 0.0
	for p in lineup:
		sum += p.fitness
	return sum / float(lineup.size())

static func _apply_fatigue(club: Club) -> void:
	for p in club.starting_five:
		var drain = 0.07 if p.trait_positive == "Poumon" else 0.15
		if club.tactical_style == 1:
			drain += 0.04
		elif club.tactical_style == 2:
			drain = maxf(0.04, drain - 0.03)
		p.fitness = max(0.4, p.fitness - drain)

