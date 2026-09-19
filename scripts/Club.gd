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
		var boost: float = 0.15
		if not starting_five.has(p):
			boost += 0.20
		if p.trait_positive == "Poumon":
			boost += 0.05
		if p.trait_negative == "Fragile":
			boost -= 0.05
		if training_focus == 0: # Tactics.TrainingFocus.RECOVERY
			boost += 0.10
		p.fitness = clampf(p.fitness + boost, 0.4, 1.0)

