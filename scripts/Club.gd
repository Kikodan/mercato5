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
@export var palmares: Array[String] = []
@export var recent_form: Array[Dictionary] = []

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

func is_lineup_valid() -> bool:
	if starting_five.size() != 5:
		return false
	for p in starting_five:
		if p.position == Player.Position.GK:
			return true
	return false

func auto_pick_lineup() -> void:
	starting_five.clear()
	var sorted_squad: Array[Player] = squad.duplicate()
	sorted_squad.sort_custom(func(a, b): return a.get_overall() > b.get_overall())

	for p in sorted_squad:
		if p.position == Player.Position.GK:
			starting_five.append(p)
			sorted_squad.erase(p)
			break

	for p in sorted_squad:
		if starting_five.size() < 5 and p.position != Player.Position.GK:
			starting_five.append(p)

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

