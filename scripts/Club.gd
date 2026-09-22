class_name Club
extends Resource

const ClubFinances = preload("res://scripts/ClubFinances.gd")

@export var club_name: String = "Club Futsal"
@export var country: String = "France"
@export var division: int = 4
@export var budget: int = 150_000

@export var primary_color: Color = Color("1e293b")
@export var secondary_color: Color = Color("e2e8f0")
@export var badge_shape: int = 0
@export var badge_symbol: int = 1

@export var tactical_style: int = 0
@export var training_focus: int = 0

@export var reputation: int = 50
@export var squad: Array[Player] = []
@export var starting_five: Array[Player] = []
@export var youth_academy: Array[Player] = []
@export var palmares: Array[String] = []
@export var recent_form: Array[Dictionary] = []
@export var is_transfer_banned: bool = false
@export var is_user_controlled: bool = false

func add_match_result(res: String, score_for: int, score_against: int, opponent: String, is_home: bool) -> void:
	recent_form.push_front({
		"result": res,
		"score_for": score_for,
		"score_against": score_against,
		"opponent": opponent,
		"is_home": is_home
	})
	if recent_form.size() > 10:
		recent_form.pop_back()

func get_form_string(max_matches: int = 5) -> String:
	var count = mini(recent_form.size(), max_matches)
	var parts: Array[String] = []
	# Left to right from oldest to newest among the last count matches
	for i in range(count - 1, -1, -1):
		parts.append(recent_form[i].get("result", "-"))
	return " ".join(parts)

var finances = null

func get_finances():
	if finances == null:
		finances = ClubFinances.create_default_for_division(division, club_name)
	return finances

func get_total_wage() -> int:
	var total: int = 0
	for p in squad:
		total += p.salary
	return total

func get_fixed_net_result() -> int:
	var fin = get_finances()
	var fixed_income = fin.get_total_fixed_income()
	var fixed_expense = get_total_wage() + fin.weekly_maintenance
	return fixed_income - fixed_expense

func is_in_financial_fair_play_compliance() -> bool:
	return get_fixed_net_result() >= 0

func get_average_overall() -> int:
	if squad.is_empty():
		return 68
	var sum: int = 0
	for p in squad:
		sum += p.get_overall()
	return int(float(sum) / float(squad.size()))

func is_lineup_valid() -> bool:
	return starting_five.size() == 5

func auto_pick_lineup() -> void:
	starting_five.clear()
	var available: Array[Player] = squad.duplicate()
	var slot_positions = [
		Player.Position.GK,
		Player.Position.DEF,
		Player.Position.MID,
		Player.Position.MID,
		Player.Position.FWD
	]

	# Sélection intelligente par poste en intégrant la forme physique (turnover IA)
	for slot_pos in slot_positions:
		var best_p: Player = null
		var best_score: float = -999.0
		for p in available:
			# Si c'est un poste de champ et que le candidat est un gardien, on l'évite si d'autres joueurs de champ existent
			if slot_pos != Player.Position.GK and p.position == Player.Position.GK:
				var has_outfield = available.any(func(x): return x.position != Player.Position.GK)
				if has_outfield:
					continue

			var eff_ovr = float(p.get_effective_overall(slot_pos))
			# Pondération de la forme physique : un remplaçant frais (100%) surpasse un titulaire fatigué (< 65%)
			var fit_weight = 0.35 + 0.65 * p.fitness
			var score = eff_ovr * fit_weight
			if score > best_score:
				best_score = score
				best_p = p

		if best_p != null:
			starting_five.append(best_p)
			available.erase(best_p)

	# Si moins de 5 joueurs sélectionnés (effectif très réduit), compléter avec les joueurs restants
	for p in available:
		if starting_five.size() < 5:
			starting_five.append(p)

func get_starting_five_average_ovr() -> float:
	if starting_five.is_empty():
		return float(get_average_overall())
	var slot_positions = [
		Player.Position.GK,
		Player.Position.DEF,
		Player.Position.MID,
		Player.Position.MID,
		Player.Position.FWD
	]
	var sum_ovr: float = 0.0
	for i in range(starting_five.size()):
		var p = starting_five[i]
		var slot_pos = slot_positions[i] if i < slot_positions.size() else p.position
		sum_ovr += float(p.get_effective_overall(slot_pos))
	return sum_ovr / float(starting_five.size())

func recover_fitness() -> void:
	for p in squad:
		if starting_five.has(p):
			# Titulaire ayant joué : récupération mesurée (oblige à faire tourner !)
			var boost: float = 0.10
			if training_focus == 0: # Tactics.TrainingFocus.RECOVERY (Cryo)
				boost += 0.06
			if p.trait_positive == "Poumon":
				boost += 0.03
			if p.trait_negative == "Fragile":
				boost -= 0.03
			p.fitness = clampf(p.fitness + boost, 0.35, 1.0)
		else:
			# Remplaçant au repos : récupération rapide pour le prochain match
			var bench_boost: float = 0.35
			if training_focus == 0:
				bench_boost += 0.10
			p.fitness = clampf(p.fitness + bench_boost, 0.35, 1.0)

func init_youth_academy_if_empty() -> void:
	if youth_academy.is_empty():
		var positions = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD]
		for i in range(4):
			var pos = positions[i % positions.size()]
			var prospect = PlayerGenerator.create_youth_prospect(country, pos)
			youth_academy.append(prospect)

func process_weekly_youth_evolution() -> void:
	init_youth_academy_if_empty()
	for p in youth_academy:
		# Le potentiel théorique n'est jamais atteint à 100% en note réelle
		var max_real_achievable = clampi(p.potential_max - 4, 40, p.potential_max - 2)
		if p.get_overall() < max_real_achievable and randf() < 0.60:
			var stat_choice = randi_range(0, 5)
			match stat_choice:
				0: p.speed = mini(99, p.speed + 1)
				1: p.shooting = mini(99, p.shooting + 1)
				2: p.passing = mini(99, p.passing + 1)
				3: p.defending = mini(99, p.defending + 1)
				4: p.dribbling = mini(99, p.dribbling + 1)
				5:
					if p.position == Player.Position.GK:
						p.reflexes = mini(99, p.reflexes + 1)
					else:
						p.stamina = mini(99, p.stamina + 1)

			if p.get_overall() > max_real_achievable:
				match stat_choice:
					0: p.speed = maxi(20, p.speed - 1)
					1: p.shooting = maxi(20, p.shooting - 1)
					2: p.passing = maxi(20, p.passing - 1)
					3: p.defending = maxi(20, p.defending - 1)
					4: p.dribbling = maxi(20, p.dribbling - 1)
					5:
						if p.position == Player.Position.GK:
							p.reflexes = maxi(20, p.reflexes - 1)
						else:
							p.stamina = maxi(20, p.stamina - 1)

			p.potential_min = clampi(p.potential_min + 1, p.get_overall() + 2, p.potential_max)
			p.recalculate_value(division)

func promote_youth_to_senior(p: Player) -> bool:
	if not youth_academy.has(p):
		return false
	if squad.size() >= 32:
		return false
	youth_academy.erase(p)
	p.is_youth_prospect = false
	p.contract_years = 3
	p.salary = 1_500
	p.wage_demand = 1_500
	p.recalculate_value(division)
	squad.append(p)
	return true

func scout_new_youth_prospect(cost: int = 15_000) -> Player:
	if budget < cost:
		return null
	if youth_academy.size() >= 8:
		return null
	budget -= cost
	var rand_pos = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD].pick_random()
	var new_prospect = PlayerGenerator.create_youth_prospect(country, rand_pos)
	youth_academy.append(new_prospect)
	return new_prospect

