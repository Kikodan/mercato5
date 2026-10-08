class_name Player
extends Resource

enum Position { GK, DEF, MID, FWD }

@export var full_name: String = "Joueur"
@export var nationality: String = "France"
@export var age: int = 22
@export var position: Position = Position.MID

func get_country_code() -> String:
	match nationality:
		"France": return "FRA"
		"Espagne": return "ESP"
		"Italie": return "ITA"
		"Angleterre": return "ENG"
		"Portugal": return "POR"
		"Allemagne": return "ALL"
		"Brésil": return "BRE"
		"Belgique": return "BEL"
		"Pays-Bas": return "P-B"
		_: return "INT"

func get_flag_emoji() -> String:
	return "[%s]" % get_country_code()



@export_range(20, 99) var speed: int = 65
@export_range(20, 99) var shooting: int = 60
@export_range(20, 99) var passing: int = 65
@export_range(20, 99) var defending: int = 60
@export_range(20, 99) var dribbling: int = 65
@export_range(20, 99) var stamina: int = 70
@export_range(20, 99) var reflexes: int = 60

# Système de potentiel et centre de formation
@export var potential_min: int = 65
@export var potential_max: int = 80
@export var is_youth_prospect: bool = false

@export var trait_positive: String = "Aucun"
@export var trait_negative: String = "Aucun"

@export var market_value: int = 80_000
@export var salary: int = 2_500
@export var wage_demand: int = 2_500
@export var contract_years: int = 2
@export var greed: float = 1.0
@export var is_transfer_listed: bool = false
@export var sell_on_clause: Dictionary = {}
@export_range(0.0, 1.0) var fitness: float = 1.0
@export var consecutive_starts: int = 0

# Visage officiel issu des planches de portraits
@export var face_data: Dictionary = {
	"face_id": 0
}

# Statistiques détaillées de la saison en cours
@export var stats_current_season: Dictionary = {
	"matches": 0,
	"goals": 0,
	"assists": 0,
	"tackles": 0,
	"saves": 0,
	"clean_sheets": 0,
	"rating_sum": 0.0
}

# Historique des saisons précédentes
@export var stats_history: Array[Dictionary] = []

# Trophées & Palmarès
@export var palmares: Array[String] = []

func get_overall() -> int:
	match position:
		Position.GK:
			return int(reflexes * 0.50 + defending * 0.20 + passing * 0.15 + stamina * 0.15)
		Position.DEF:
			return int(defending * 0.40 + stamina * 0.25 + speed * 0.15 + passing * 0.10 + dribbling * 0.10)
		Position.MID:
			return int(passing * 0.35 + dribbling * 0.25 + stamina * 0.15 + shooting * 0.15 + defending * 0.10)
		Position.FWD:
			return int(shooting * 0.40 + speed * 0.25 + dribbling * 0.20 + passing * 0.10 + stamina * 0.05)
	return 60

func get_position_penalty(slot_position: int) -> int:
	if position == slot_position:
		return 0
	match position:
		Position.FWD:
			# Attaquant : milieu = petit malus (-4), défenseur = moyen (-10), gardien = très gros (-20)
			match slot_position:
				Position.MID: return 4
				Position.DEF: return 10
				Position.GK: return 20
		Position.MID:
			# Milieu : attaquant = petit malus (-4), défenseur = moyen (-5), gardien = gros (-18)
			match slot_position:
				Position.FWD: return 4
				Position.DEF: return 5
				Position.GK: return 18
		Position.DEF:
			# Défenseur : milieu = petit malus (-4), gardien = modéré (-6), attaquant = gros malus (-12)
			match slot_position:
				Position.MID: return 4
				Position.GK: return 6
				Position.FWD: return 12
		Position.GK:
			# Gardien : milieu = modéré (-10), défenseur/attaquant = gros malus (-18 à -20)
			match slot_position:
				Position.MID: return 10
				Position.DEF: return 18
				Position.FWD: return 20
	return 8

func get_effective_overall(slot_position: int) -> int:
	return clampi(get_overall() - get_position_penalty(slot_position), 20, 99)

func get_average_rating() -> float:
	var m: int = stats_current_season.get("matches", 0)
	if m <= 0:
		return 6.0
	return float(stats_current_season.get("rating_sum", 0.0)) / float(m)

func evolve_annual(club_div: int = 1) -> Dictionary:
	var matches_played: int = stats_current_season.get("matches", 0)
	var avg_rating: float = get_average_rating()
	var ovr_before: int = get_overall()

	var primary_attrs: Array[String] = []
	match position:
		Position.GK:
			primary_attrs = ["reflexes", "defending", "passing", "stamina"]
		Position.DEF:
			primary_attrs = ["defending", "stamina", "speed", "passing"]
		Position.MID:
			primary_attrs = ["passing", "dribbling", "stamina", "shooting", "defending"]
		Position.FWD:
			primary_attrs = ["shooting", "speed", "dribbling", "passing"]

	# 1. Jeunes (< 22 ans) : progression naturelle + bonus perfs
	if age < 22:
		var growth_pts = randi_range(1, 2)
		if matches_played >= 6 and avg_rating >= 6.4:
			growth_pts += 1
		for i in growth_pts:
			var attr = primary_attrs.pick_random()
			set(attr, clampi(get(attr) + 1, 20, 99))

	# 2. Développement (22 à 25 ans) : progression modérée
	elif age <= 25:
		if randf() < 0.65:
			var attr = primary_attrs.pick_random()
			set(attr, clampi(get(attr) + 1, 20, 99))
		if matches_played >= 8 and avg_rating >= 7.0:
			var bonus_attr = primary_attrs.pick_random()
			set(bonus_attr, clampi(get(bonus_attr) + 1, 20, 99))

	# 3. Apogée (26 à 29 ans) : stabilité et nuance selon performance
	elif age <= 29:
		if matches_played >= 8 and avg_rating >= 7.2:
			var attr = primary_attrs.pick_random()
			set(attr, clampi(get(attr) + 1, 20, 99))
		elif matches_played == 0 and randf() < 0.35:
			var phys = ["speed", "stamina"].pick_random()
			set(phys, clampi(get(phys) - 1, 20, 99))

	# 4. Vétérans (30 à 33 ans) : léger déclin physique (vitesse, endurance)
	elif age <= 33:
		if randf() < 0.50:
			speed = clampi(speed - 1, 20, 99)
		if randf() < 0.40:
			stamina = clampi(stamina - 1, 20, 99)
		if matches_played >= 8 and avg_rating >= 6.8 and randf() < 0.35:
			var tech = "passing" if position != Position.GK else "reflexes"
			set(tech, clampi(get(tech) + 1, 20, 99))

	# 5. Vétérans avancés (34+ ans) : déclin physique et général
	else:
		speed = clampi(speed - randi_range(1, 2), 20, 99)
		stamina = clampi(stamina - randi_range(1, 2), 20, 99)
		if randf() < 0.45:
			var attr = primary_attrs.pick_random()
			set(attr, clampi(get(attr) - 1, 20, 99))

	recalculate_value(club_div)
	var ovr_after: int = get_overall()
	return {
		"before": ovr_before,
		"after": ovr_after,
		"diff": ovr_after - ovr_before
	}

func archive_season(season_num: int, club_name: String, country: String, div: int) -> void:
	stats_history.append({
		"season": season_num,
		"club_name": club_name,
		"country": country,
		"division": div,
		"matches": stats_current_season.get("matches", 0),
		"goals": stats_current_season.get("goals", 0),
		"assists": stats_current_season.get("assists", 0),
		"tackles": stats_current_season.get("tackles", 0),
		"saves": stats_current_season.get("saves", 0),
		"clean_sheets": stats_current_season.get("clean_sheets", 0),
		"avg_rating": get_average_rating()
	})
	stats_current_season = {
		"matches": 0,
		"goals": 0,
		"assists": 0,
		"tackles": 0,
		"saves": 0,
		"clean_sheets": 0,
		"rating_sum": 0.0
	}

func get_value_breakdown(club_division: int = 1) -> Dictionary:
	var ovr: int = get_overall()
	var ovr_norm: float = maxf(1.0, (float(ovr) - 30.0) / 10.0)
	var base: float = pow(ovr_norm, 3.4) * 6500.0 + 40000.0

	var age_factor: float = 1.0
	if age <= 21:
		age_factor = 1.45
	elif age <= 23:
		age_factor = 1.25
	elif age <= 28:
		age_factor = 1.10
	elif age <= 31:
		age_factor = 0.90
	elif age <= 34:
		age_factor = 0.65
	else:
		age_factor = 0.40

	var div_factor: float = 1.0
	match club_division:
		1: div_factor = 1.35
		2: div_factor = 1.05
		3: div_factor = 0.85
		_: div_factor = 0.75

	var m: int = stats_current_season.get("matches", 0)
	var perf_factor: float = 1.0
	if m >= 1:
		var bonus: float = 0.0
		bonus += minf(0.35, stats_current_season.get("goals", 0) * 0.04)
		bonus += minf(0.20, stats_current_season.get("assists", 0) * 0.03)
		bonus += minf(0.20, stats_current_season.get("tackles", 0) * 0.02)
		bonus += minf(0.20, stats_current_season.get("saves", 0) * 0.02)
		var avg_r = get_average_rating()
		if avg_r > 6.5:
			bonus += (avg_r - 6.5) * 0.15
		perf_factor = clampf(1.0 + bonus, 0.85, 1.65)

	var palmares_factor: float = clampf(1.0 + float(palmares.size()) * 0.08, 1.0, 1.50)

	var final_val: int = int(base * age_factor * div_factor * perf_factor * palmares_factor)
	final_val = max(10_000, final_val)

	return {
		"base": int(base),
		"age_factor": age_factor,
		"div_factor": div_factor,
		"perf_factor": perf_factor,
		"palmares_factor": palmares_factor,
		"final_value": final_val
	}

func recalculate_value(club_division: int = 1) -> void:
	var breakdown = get_value_breakdown(club_division)
	market_value = breakdown["final_value"]
	if greed == 1.0:
		greed = randf_range(0.88, 1.22)
	# Salaire soutenable et proportionnel au niveau sur échelle 100
	var ovr: int = get_overall()
	var base_sal: int = int(market_value * 0.0014) + int(pow(float(ovr) / 10.0, 2.0) * 35.0)
	salary = clampi(base_sal, 450, 22_000)
	wage_demand = int(salary * greed)

