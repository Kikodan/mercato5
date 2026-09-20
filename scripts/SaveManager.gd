class_name SaveManager
extends RefCounted

const ClubFinances = preload("res://scripts/ClubFinances.gd")

const SAVE_PATH: String = "user://savegame.json"

static func has_save(path: String = SAVE_PATH) -> bool:
	return FileAccess.file_exists(path)

static func delete_save(path: String = SAVE_PATH) -> bool:
	if FileAccess.file_exists(path):
		var dir = DirAccess.open("user://")
		if dir:
			return dir.remove(path.replace("user://", "")) == OK
	return false

static func get_save_info(path: String = SAVE_PATH) -> Dictionary:
	if not has_save(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(text) != OK:
		return {}
	var data = json.data as Dictionary
	if not data:
		return {}

	return {
		"club_name": data.get("user_club_name", "Mon Club"),
		"country": data.get("current_country", "France"),
		"division": data.get("current_division", 1),
		"budget": data.get("user_budget", 100_000),
		"matchday": data.get("current_matchday", 1),
		"total_matchdays": data.get("total_matchdays", 14),
		"saved_at": data.get("saved_at", ""),
		"primary_color": data.get("user_primary_color", "#1e293b"),
		"secondary_color": data.get("user_secondary_color", "#38bdf8"),
		"badge_shape": data.get("user_badge_shape", 0),
		"badge_symbol": data.get("user_badge_symbol", 1)
	}

static func save_game(arg1, arg2, arg3, arg4, arg5 = null, path: String = SAVE_PATH) -> bool:
	var player_club: Club = null
	var current_league: League = null
	var all_leagues: Array[League] = []
	var market: TransferMarket = null
	var season_number: int = 1

	var list = [arg1, arg2, arg3, arg4, arg5]
	for item in list:
		if item is Club:
			player_club = item
		elif item is League:
			current_league = item
		elif item is TransferMarket:
			market = item
		elif item is int:
			season_number = item
		elif item is String and item.begins_with("user://"):
			path = item
		elif item is Array:
			for elem in item:
				if elem is League:
					all_leagues.append(elem)

	if player_club == null or current_league == null:
		return false

	var save_dict: Dictionary = {
		"version": 1,
		"saved_at": Time.get_datetime_string_from_system(false, true),
		"user_club_name": player_club.club_name,
		"user_budget": player_club.budget,
		"user_primary_color": player_club.primary_color.to_html(false),
		"user_secondary_color": player_club.secondary_color.to_html(false),
		"user_badge_shape": player_club.badge_shape,
		"user_badge_symbol": player_club.badge_symbol,
		"current_country": current_league.country,
		"current_division": current_league.division,
		"current_matchday": current_league.current_matchday_index + 1,
		"total_matchdays": current_league.schedule.size(),
		"season_number": season_number
	}

	# Serialiser toutes les ligues
	var leagues_arr: Array = []
	for l in all_leagues:
		leagues_arr.append(_serialize_league(l))
	save_dict["leagues"] = leagues_arr

	# Serialiser le marché des transferts
	var market_dict: Dictionary = {"free_agents": []}
	if market != null:
		for fa in market.free_agents:
			market_dict["free_agents"].append(_serialize_player(fa))
	save_dict["market"] = market_dict

	var file = FileAccess.open(path, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(save_dict, "\t"))
	file.close()
	return true

static func load_game(path: String = SAVE_PATH) -> Dictionary:
	if not has_save(path):
		return {}

	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(text) != OK:
		return {}
	var data = json.data as Dictionary
	if not data:
		return {}

	return deserialize_game_data(data)

static func deserialize_game_data(data: Dictionary) -> Dictionary:
	if data.has("player_club") and data.has("all_leagues"):
		return data
	var all_leagues: Array[League] = []
	var club_map: Dictionary = {}

	# 1ère passe : créer les ligues et leurs clubs
	for l_data in data.get("leagues", []):
		var l = _deserialize_league(l_data, club_map)
		all_leagues.append(l)

	# Identifier le club du joueur et sa ligue
	var user_club_name: String = data.get("user_club_name", "")
	var user_club: Club = club_map.get(user_club_name, null)
	var current_league: League = null

	for l in all_leagues:
		if l.clubs.has(user_club):
			current_league = l
			break

	if current_league == null and not all_leagues.is_empty():
		current_league = all_leagues[0]
		if not current_league.clubs.is_empty():
			user_club = current_league.clubs[0]

	# Restaurer le marché des transferts
	var m = TransferMarket.new()
	var free_agents: Array[Player] = []
	var market_data = data.get("market", {})
	for fa_data in market_data.get("free_agents", []):
		free_agents.append(_deserialize_player(fa_data))
	m.free_agents = free_agents

	return {
		"player_club": user_club,
		"user_club": user_club,
		"current_league": current_league,
		"all_leagues": all_leagues,
		"market": m,
		"free_agents": free_agents,
		"season_number": int(data.get("season_number", 1)),
		"raw_data": data
	}

# ==================== HELPERS DE SÉRIALISATION ====================

static func _serialize_player(p: Player) -> Dictionary:
	return {
		"name": p.full_name,
		"nat": p.nationality,
		"age": p.age,
		"pos": p.position,
		"spd": p.speed,
		"sho": p.shooting,
		"pas": p.passing,
		"def": p.defending,
		"drib": p.dribbling,
		"sta": p.stamina,
		"ref": p.reflexes,
		"pot_min": p.potential_min,
		"pot_max": p.potential_max,
		"is_youth": p.is_youth_prospect,
		"fit": p.fitness,
		"val": p.market_value,
		"sal": p.salary,
		"wage_dem": p.wage_demand,
		"years": p.contract_years,
		"greed": p.greed,
		"t_pos": p.trait_positive,
		"t_neg": p.trait_negative,
		"face": p.face_data,
		"stats_cur": p.stats_current_season,
		"stats_hist": p.stats_history,
		"palmares": p.palmares,
		"c_starts": p.consecutive_starts
	}

static func _deserialize_player(d: Dictionary) -> Player:
	var p = Player.new()
	p.full_name = d.get("name", "Joueur")
	p.nationality = d.get("nat", "France")
	p.age = d.get("age", 22)
	p.position = d.get("pos", 2)
	p.speed = d.get("spd", 65)
	p.shooting = d.get("sho", 60)
	p.passing = d.get("pas", 65)
	p.defending = d.get("def", 60)
	p.dribbling = d.get("drib", 65)
	p.stamina = d.get("sta", 70)
	p.reflexes = d.get("ref", 60)
	p.potential_min = d.get("pot_min", 65)
	p.potential_max = d.get("pot_max", 80)
	p.is_youth_prospect = d.get("is_youth", false)
	p.fitness = d.get("fit", 1.0)
	p.consecutive_starts = int(d.get("c_starts", 0))
	p.market_value = d.get("val", 50_000)
	p.salary = d.get("sal", 2_000)
	p.wage_demand = d.get("wage_dem", 2_000)
	p.contract_years = d.get("years", 2)
	p.greed = d.get("greed", 1.0)
	p.trait_positive = d.get("t_pos", "Aucun")
	p.trait_negative = d.get("t_neg", "Aucun")
	p.face_data = d.get("face", {
		"skin_tone": randi_range(0, 6),
		"hair_style": randi_range(0, 7),
		"hair_color": randi_range(0, 4),
		"eye_style": randi_range(0, 2),
		"beard_style": 0,
		"expression": 0
	})
	p.stats_current_season = d.get("stats_cur", {
		"matches": 0, "goals": 0, "assists": 0, "tackles": 0, "saves": 0, "clean_sheets": 0, "rating_sum": 0.0
	})
	p.stats_history.clear()
	for h in d.get("stats_hist", []):
		if h is Dictionary:
			p.stats_history.append(h)
	p.palmares.clear()
	for palm in d.get("palmares", []):
		p.palmares.append(str(palm))

	# Migration automatique si sauvegarde sur ancienne échelle (1-20)
	if p.speed <= 20 and p.shooting <= 20 and p.defending <= 20:
		var conv = func(val: int): return clampi(int(val * 3.8 + 24), 35, 95)
		p.speed = conv.call(p.speed)
		p.shooting = conv.call(p.shooting)
		p.passing = conv.call(p.passing)
		p.defending = conv.call(p.defending)
		p.stamina = conv.call(p.stamina)
		p.dribbling = p.passing
		p.reflexes = p.defending if p.position == Player.Position.GK else 45
		var actual_ovr = p.get_overall()
		p.potential_min = clampi(actual_ovr - 2, 50, 92)
		p.potential_max = clampi(p.potential_min + 10, p.potential_min, 99)

	return p

static func _serialize_club(c: Club) -> Dictionary:
	var squad_arr: Array = []
	for p in c.squad:
		squad_arr.append(_serialize_player(p))

	var youth_arr: Array = []
	for p in c.youth_academy:
		youth_arr.append(_serialize_player(p))

	var starters: Array = []
	for p in c.starting_five:
		starters.append(p.full_name)

	return {
		"name": c.club_name,
		"country": c.country,
		"div": c.division,
		"budget": c.budget,
		"style": c.tactical_style,
		"training": c.training_focus,
		"p_col": c.primary_color.to_html(false),
		"s_col": c.secondary_color.to_html(false),
		"b_shape": c.badge_shape,
		"b_sym": c.badge_symbol,
		"palmares": c.palmares,
		"reputation": c.reputation,
		"finances": c.get_finances().to_dict(),
		"recent_form": c.recent_form,
		"is_transfer_banned": c.is_transfer_banned,
		"squad": squad_arr,
		"youth_academy": youth_arr,
		"starters": starters
	}

static func _deserialize_club(d: Dictionary) -> Club:
	var c = Club.new()
	c.club_name = d.get("name", "Club")
	c.country = d.get("country", "France")
	c.division = d.get("div", 1)
	c.budget = d.get("budget", 100_000)
	c.tactical_style = d.get("style", 0)
	c.training_focus = d.get("training", 0)
	c.primary_color = Color(d.get("p_col", "1e293b"))
	c.secondary_color = Color(d.get("s_col", "e2e8f0"))
	c.badge_shape = d.get("b_shape", 0)
	c.reputation = int(d.get("reputation", 50))
	c.is_transfer_banned = bool(d.get("is_transfer_banned", false))
	c.finances = ClubFinances.from_dict(d.get("finances", {}), c.division, c.club_name)
	c.palmares.clear()
	for palm in d.get("palmares", []):
		c.palmares.append(str(palm))
	c.recent_form.clear()
	for f in d.get("recent_form", []):
		if f is Dictionary:
			c.recent_form.append(f)

	var starters_names: Array = d.get("starters", [])
	for p_data in d.get("squad", []):
		var p = _deserialize_player(p_data)
		c.squad.append(p)
		if starters_names.has(p.full_name):
			c.starting_five.append(p)

	c.youth_academy.clear()
	for y_data in d.get("youth_academy", []):
		c.youth_academy.append(_deserialize_player(y_data))
	c.init_youth_academy_if_empty()

	if c.starting_five.is_empty():
		c.auto_pick_lineup()

	return c

static func _serialize_league(l: League) -> Dictionary:
	var clubs_arr: Array = []
	for c in l.clubs:
		clubs_arr.append(_serialize_club(c))

	var standings_dict: Dictionary = {}
	for c in l.clubs:
		if l.standings.has(c):
			standings_dict[c.club_name] = l.standings[c]

	var sched_arr: Array = []
	for day in l.schedule:
		var day_arr: Array = []
		for pair in day:
			day_arr.append([pair[0].club_name, pair[1].club_name])
		sched_arr.append(day_arr)

	return {
		"name": l.league_name,
		"country": l.country,
		"div": l.division,
		"matchday_index": l.current_matchday_index,
		"clubs": clubs_arr,
		"standings": standings_dict,
		"schedule": sched_arr,
		"playoff_phase": l.playoff_phase,
		"playoff_semi_h": l.playoff_semi_home.club_name if l.playoff_semi_home else "",
		"playoff_semi_a": l.playoff_semi_away.club_name if l.playoff_semi_away else "",
		"playoff_semi_score": l.playoff_semi_score,
		"playoff_final_h": l.playoff_final_home.club_name if l.playoff_final_home else "",
		"playoff_final_a": l.playoff_final_away.club_name if l.playoff_final_away else "",
		"playoff_final_score": l.playoff_final_score,
		"playoff_champ": l.playoff_champion.club_name if l.playoff_champion else ""
	}

static func _deserialize_league(d: Dictionary, club_map: Dictionary) -> League:
	var l = League.new()
	l.league_name = d.get("name", "Ligue")
	l.country = d.get("country", "France")
	l.division = d.get("div", 1)
	l.current_matchday_index = d.get("matchday_index", 0)

	var league_clubs: Array[Club] = []
	for c_data in d.get("clubs", []):
		var c = _deserialize_club(c_data)
		league_clubs.append(c)
		club_map[c.club_name] = c
	l.clubs = league_clubs

	l.standings.clear()
	var raw_standings: Dictionary = d.get("standings", {})
	for c in l.clubs:
		if raw_standings.has(c.club_name):
			var rec = raw_standings[c.club_name]
			l.standings[c] = {
				"pts": int(rec.get("pts", 0)),
				"p": int(rec.get("p", 0)),
				"w": int(rec.get("w", 0)),
				"d": int(rec.get("d", 0)),
				"l": int(rec.get("l", 0)),
				"gf": int(rec.get("gf", 0)),
				"ga": int(rec.get("ga", 0)),
				"gd": int(rec.get("gd", 0))
			}
		else:
			l.standings[c] = {"pts": 0, "p": 0, "w": 0, "d": 0, "l": 0, "gf": 0, "ga": 0, "gd": 0}

	l.schedule.clear()
	var raw_sched: Array = d.get("schedule", [])
	for day in raw_sched:
		var day_arr: Array = []
		for pair in day:
			var h = club_map.get(pair[0], null)
			var a = club_map.get(pair[1], null)
			if h and a:
				day_arr.append([h, a])
		if not day_arr.is_empty():
			l.schedule.append(day_arr)

	l.playoff_phase = d.get("playoff_phase", 0)
	l.playoff_semi_home = club_map.get(d.get("playoff_semi_h", ""), null)
	l.playoff_semi_away = club_map.get(d.get("playoff_semi_a", ""), null)
	l.playoff_semi_score = d.get("playoff_semi_score", [0, 0])
	l.playoff_final_home = club_map.get(d.get("playoff_final_h", ""), null)
	l.playoff_final_away = club_map.get(d.get("playoff_final_a", ""), null)
	l.playoff_final_score = d.get("playoff_final_score", [0, 0])
	l.playoff_champion = club_map.get(d.get("playoff_champ", ""), null)

	if l.schedule.is_empty():
		l.initialize_league()

	return l
