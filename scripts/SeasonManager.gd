class_name SeasonManager
extends RefCounted

const PlayerGenerator = preload("res://scripts/PlayerGenerator.gd")

class SeasonTransitionReport:
	var season_ended: int = 1
	var next_season: int = 2
	var champions: Array[Dictionary] = [] # {"league": String, "country": String, "club": Club}
	var european_winner: Club = null
	var promotions: Array[Dictionary] = [] # {"club": Club, "country": String, "from_div": int, "to_div": int}
	var relegations: Array[Dictionary] = [] # {"club": Club, "country": String, "from_div": int, "to_div": int}
	var user_status: String = "STABLE" # "PROMOTED", "RELEGATED", "STABLE"
	var user_new_division: int = 1
	var user_budget_gain: int = 0
	var retirees: Array[Dictionary] = [] # {"player": Player, "club_name": String, "age": int, "is_user": bool}
	var user_retirees: Array[Player] = []
	var new_free_agents_count: int = 0
	var ffp_transfer_sanction: bool = false
	var ffp_fixed_net: int = 0
	var user_expired_contracts: Array[Player] = []

static func execute_season_transition(
	all_leagues: Array[League],
	market: TransferMarket,
	player_club: Club,
	active_european_cup: EuropeanCup,
	current_season: int
) -> SeasonTransitionReport:
	var report = SeasonTransitionReport.new()
	report.season_ended = current_season
	report.next_season = current_season + 1

	# 0. Contrôle du Fair-Play Financier (DNCG)
	for l in all_leagues:
		for c in l.clubs:
			var fixed_net = c.get_fixed_net_result()
			c.is_transfer_banned = (fixed_net < 0)
			if c == player_club:
				report.ffp_transfer_sanction = (fixed_net < 0)
				report.ffp_fixed_net = fixed_net

	# 1. Collecter les vainqueurs et champions
	if active_european_cup != null and active_european_cup.winner != null:
		report.european_winner = active_european_cup.winner

	for l in all_leagues:
		if l.division == 1:
			var champ = l.playoff_champion if l.playoff_champion != null else (l.get_sorted_standings()[0] if l.clubs.size() > 0 else null)
			if champ != null:
				report.champions.append({
					"league": l.league_name,
					"country": l.country,
					"club": champ
				})

	# 2. Montées et Descentes (Promotions & Relégations)
	_process_promotions_and_relegations(all_leagues, player_club, report)

	# 3. Retraites des vieux joueurs
	_process_retirements(all_leagues, market, player_club, report)

	# 4. Vieillissement (+1 an), évolution et archivage des statistiques
	_process_aging_and_stats(all_leagues, market, current_season)

	# 5. Gestion des contrats (décrémentation, renouvellement IA et départs libres)
	_process_contracts(all_leagues, market, player_club, report)

	# 6. Renouvellement du Mercato & Budgets de nouvelle saison
	_process_market_and_budgets(all_leagues, market, player_club, report)

	# 6. Réinitialisation des championnats et calendriers
	for l in all_leagues:
		l.current_matchday_index = 0
		l.initialize_league()
		for c in l.clubs:
			c.recover_fitness()
			c.auto_pick_lineup()

	return report

static func _process_promotions_and_relegations(
	all_leagues: Array[League],
	player_club: Club,
	report: SeasonTransitionReport
) -> void:
	# Regrouper les ligues par pays
	var countries_map: Dictionary = {}
	for l in all_leagues:
		if not countries_map.has(l.country):
			countries_map[l.country] = []
		countries_map[l.country].append(l)

	for country in countries_map.keys():
		var country_leagues: Array = countries_map[country]
		country_leagues.sort_custom(func(a, b): return a.division < b.division)

		if country_leagues.size() < 2:
			continue

		# Cas avec 3 divisions (D1, D2, D3)
		var d1: League = country_leagues[0]
		var d2: League = country_leagues[1]
		var d3: League = country_leagues[2] if country_leagues.size() >= 3 else null

		# Standings
		var standings_d1 = d1.get_sorted_standings()
		var standings_d2 = d2.get_sorted_standings()

		# D1 : 2 derniers descendent en D2
		var to_relegate_d1_to_d2: Array[Club] = []
		if standings_d1.size() >= 2:
			to_relegate_d1_to_d2.append(standings_d1[standings_d1.size() - 2])
			to_relegate_d1_to_d2.append(standings_d1[standings_d1.size() - 1])

		# D2 : 2 premiers montent en D1
		var to_promote_d2_to_d1: Array[Club] = []
		if standings_d2.size() >= 2:
			to_promote_d2_to_d1.append(standings_d2[0])
			to_promote_d2_to_d1.append(standings_d2[1])

		var to_relegate_d2_to_d3: Array[Club] = []
		var to_promote_d3_to_d2: Array[Club] = []

		if d3 != null:
			var standings_d3 = d3.get_sorted_standings()
			# D2 : 2 derniers descendent en D3
			if standings_d2.size() >= 4:
				to_relegate_d2_to_d3.append(standings_d2[standings_d2.size() - 2])
				to_relegate_d2_to_d3.append(standings_d2[standings_d2.size() - 1])
			elif standings_d2.size() >= 2:
				to_relegate_d2_to_d3.append(standings_d2[standings_d2.size() - 1])

			# D3 : 2 premiers montent en D2
			if standings_d3.size() >= 2:
				to_promote_d3_to_d2.append(standings_d3[0])
				to_promote_d3_to_d2.append(standings_d3[1])

		# Appliquer D1 <-> D2
		for c in to_relegate_d1_to_d2:
			d1.clubs.erase(c)
			d2.clubs.append(c)
			c.division = 2
			report.relegations.append({"club": c, "country": country, "from_div": 1, "to_div": 2})
			if c == player_club:
				report.user_status = "RELEGATED"
				report.user_new_division = 2

		for c in to_promote_d2_to_d1:
			d2.clubs.erase(c)
			d1.clubs.append(c)
			c.division = 1
			report.promotions.append({"club": c, "country": country, "from_div": 2, "to_div": 1})
			if c == player_club:
				report.user_status = "PROMOTED"
				report.user_new_division = 1

		# Appliquer D2 <-> D3 si D3 existe
		if d3 != null:
			for c in to_relegate_d2_to_d3:
				d2.clubs.erase(c)
				d3.clubs.append(c)
				c.division = 3
				report.relegations.append({"club": c, "country": country, "from_div": 2, "to_div": 3})
				if c == player_club:
					report.user_status = "RELEGATED"
					report.user_new_division = 3

			for c in to_promote_d3_to_d2:
				d3.clubs.erase(c)
				d2.clubs.append(c)
				c.division = 2
				report.promotions.append({"club": c, "country": country, "from_div": 3, "to_div": 2})
				if c == player_club:
					report.user_status = "PROMOTED"
					report.user_new_division = 2

	if report.user_status == "STABLE":
		report.user_new_division = player_club.division

static func _process_retirements(
	all_leagues: Array[League],
	market: TransferMarket,
	player_club: Club,
	report: SeasonTransitionReport
) -> void:
	# Retraites dans les clubs
	for l in all_leagues:
		for c in l.clubs:
			var to_retire: Array[Player] = []
			for p in c.squad:
				var chance: float = 0.0
				if p.age >= 38:
					chance = 1.0
				elif p.age >= 36:
					chance = 0.85
				elif p.age == 35:
					chance = 0.55
				elif p.age == 34:
					chance = 0.30
				elif p.age == 33:
					chance = 0.15

				if chance > 0.0 and randf() < chance:
					to_retire.append(p)

			for p in to_retire:
				c.squad.erase(p)
				c.starting_five.erase(p)
				var is_user = (c == player_club)
				report.retirees.append({
					"player": p,
					"club_name": c.club_name,
					"age": p.age,
					"is_user": is_user
				})
				if is_user:
					report.user_retirees.append(p)

			# Garantir un effectif d'au moins 7 joueurs avec des jeunes du centre de formation
			while c.squad.size() < 7:
				var pos = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD].pick_random()
				var target_lvl = max(6, int(c.get_average_overall() * 0.9))
				var rookie = PlayerGenerator.create_random_player(c.country, pos, target_lvl)
				rookie.age = randi_range(17, 20)
				c.squad.append(rookie)

	# Retraites parmi les agents libres
	if market != null:
		var market_retire: Array[Player] = []
		for fa in market.free_agents:
			if fa.age >= 35 or (fa.age >= 33 and randf() < 0.5):
				market_retire.append(fa)
		for fa in market_retire:
			market.free_agents.erase(fa)

static func _process_aging_and_stats(
	all_leagues: Array[League],
	market: TransferMarket,
	season_num: int
) -> void:
	for l in all_leagues:
		for c in l.clubs:
			for p in c.squad:
				# 1. Évolution physique / technique selon âge et performances
				p.evolve_annual(c.division)
				# 2. Archiver la saison
				p.archive_season(season_num, c.club_name, c.country, c.division)
				# 3. Prendre 1 an
				p.age += 1

	# Agents libres restants
	if market != null:
		for fa in market.free_agents:
			fa.evolve_annual(1)
			fa.archive_season(season_num, "Agent Libre", fa.nationality, 1)
			fa.age += 1

static func _process_market_and_budgets(
	all_leagues: Array[League],
	market: TransferMarket,
	player_club: Club,
	report: SeasonTransitionReport
) -> void:
	# 1. Dotations budgétaires de nouvelle saison
	for l in all_leagues:
		var base_bonus: int = 0
		match l.division:
			1: base_bonus = randi_range(200_000, 320_000)
			2: base_bonus = randi_range(110_000, 170_000)
			_: base_bonus = randi_range(50_000, 85_000)

		for c in l.clubs:
			var bonus = base_bonus
			if c.palmares.has("Champion %s" % l.league_name):
				bonus += 80_000
			c.budget += bonus
			if c == player_club:
				report.user_budget_gain = bonus

	# 2. Rafraîchir le marché des transferts
	if market != null:
		market.pending_offers.clear()
		# Ajouter de nouveaux agents libres
		var count_to_add = max(10, 26 - market.free_agents.size())
		var countries = ["France", "Espagne", "Italie", "Portugal", "Angleterre", "Brésil", "Belgique", "Pays-Bas"]
		var positions = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD]
		for i in count_to_add:
			var nat = countries.pick_random()
			var pos = positions.pick_random()
			var lvl = randi_range(62, 85)
			var new_fa = PlayerGenerator.create_random_player(nat, pos, lvl)
			new_fa.age = randi_range(18, 27)
			market.free_agents.append(new_fa)
		report.new_free_agents_count = count_to_add

static func _process_contracts(
	all_leagues: Array[League],
	market: TransferMarket,
	player_club: Club,
	report: SeasonTransitionReport
) -> void:
	for l in all_leagues:
		for c in l.clubs:
			var is_user: bool = (c == player_club)
			var to_expire: Array[Player] = []
			for p in c.squad:
				p.contract_years -= 1
				if p.contract_years <= 0:
					if not is_user:
						# Club IA : prolonge automatiquement les bons éléments s'il en a les moyens
						var should_renew = (p.get_overall() >= 65 or randf() < 0.60) and (c.budget > 15_000)
						if should_renew:
							p.contract_years = randi_range(1, 3)
						else:
							to_expire.append(p)
					else:
						# Club utilisateur : contrat expiré faute de prolongation
						to_expire.append(p)

			for p in to_expire:
				c.squad.erase(p)
				c.starting_five.erase(p)
				p.contract_years = 1
				p.recalculate_value(1)
				if market != null:
					market.free_agents.append(p)
				if is_user:
					report.user_expired_contracts.append(p)

			# Garantir un effectif d'au moins 7 joueurs
			while c.squad.size() < 7:
				var pos = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD].pick_random()
				var target_lvl = max(6, int(c.get_average_overall() * 0.9))
				var rookie = PlayerGenerator.create_random_player(c.country, pos, target_lvl)
				rookie.age = randi_range(17, 20)
				rookie.contract_years = 3
				c.squad.append(rookie)
