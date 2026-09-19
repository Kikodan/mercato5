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



@export_range(1, 20) var speed: int = 10
@export_range(1, 20) var shooting: int = 10
@export_range(1, 20) var passing: int = 10
@export_range(1, 20) var defending: int = 10
@export_range(1, 20) var stamina: int = 10

@export var trait_positive: String = "Aucun"
@export var trait_negative: String = "Aucun"

@export var market_value: int = 50_000
@export var salary: int = 2_000
@export var wage_demand: int = 2_000
@export var contract_years: int = 2
@export var greed: float = 1.0
@export_range(0.0, 1.0) var fitness: float = 1.0

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
			return int(defending * 0.5 + passing * 0.2 + stamina * 0.3)
		Position.DEF:
			return int(defending * 0.45 + speed * 0.25 + passing * 0.15 + stamina * 0.15)
		Position.MID:
			return int(passing * 0.35 + stamina * 0.25 + speed * 0.2 + shooting * 0.2)
		Position.FWD:
			return int(shooting * 0.45 + speed * 0.3 + passing * 0.15 + stamina * 0.1)
	return 10

func get_average_rating() -> float:
	var m: int = stats_current_season.get("matches", 0)
	if m <= 0:
		return 6.0
	return float(stats_current_season.get("rating_sum", 0.0)) / float(m)

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
	var base: float = pow(ovr, 2.75) * 45.0

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
	final_val = max(5_000, final_val)

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
		greed = randf_range(0.85, 1.25)
	salary = max(350, int(market_value * 0.0035))
	wage_demand = int(salary * greed)

