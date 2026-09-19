extends SceneTree

const Club = preload("res://scripts/Club.gd")
const ClubFinances = preload("res://scripts/ClubFinances.gd")
const GameWorld = preload("res://scripts/GameWorld.gd")
const SaveManager = preload("res://scripts/SaveManager.gd")

func _init() -> void:
	print("--- TEST SYSTÈME ÉCONOMIQUE & FINANCES MERCATO 5 ---")
	
	# 1. Test création et division
	var fin_d1 = ClubFinances.create_default_for_division(1, "Paris RG")
	var fin_d3 = ClubFinances.create_default_for_division(3, "Leeds Futsal")
	
	assert(fin_d1.ticket_price == 22, "Prix billet D1 doit être 22")
	assert(fin_d3.ticket_price == 12, "Prix billet D3 doit être 12")
	assert(fin_d1.arena_capacity > fin_d3.arena_capacity, "Capacité D1 > D3")
	print("✓ Finances par division OK (D1: %s places, D3: %s places)" % [fin_d1.arena_capacity, fin_d3.arena_capacity])
	
	# 2. Test élasticité prix billetterie
	var pct_normal = fin_d3.estimate_attendance_percentage(12, 3)
	var pct_expensive = fin_d3.estimate_attendance_percentage(35, 3)
	assert(pct_normal > pct_expensive, "L'affluence doit chuter si le billet est trop cher")
	print("✓ Élasticité prix OK (Prix 12€: %d%% | Prix 35€: %d%%)" % [int(pct_normal * 100), int(pct_expensive * 100)])
	
	# 3. Test Club et cycle hebdomadaire
	var club = Club.new()
	club.club_name = "Brest F5"
	club.division = 3
	club.budget = 40_000
	club.finances = fin_d3
	
	var receipts = fin_d3.process_home_match_receipts(club, null)
	assert(receipts > 0, "Les recettes billetterie doivent être positives")
	assert(club.budget > 40_000, "Le budget doit avoir augmenté après un match à domicile")
	print("✓ Recettes match à domicile OK (+%d €)" % receipts)
	
	var cycle = fin_d3.process_weekly_cycle(club, receipts)
	assert(cycle.has("total_income") and cycle.has("total_expense"), "Cycle doit contenir income et expense")
	print("✓ Cycle financier hebdomadaire OK (Revenus: %d €, Dépenses: %d €, Net: %d €)" % [
		cycle["total_income"], cycle["total_expense"], cycle["net"]
	])
	
	# 4. Test sérialisation / désérialisation
	var serialized = SaveManager._serialize_club(club)
	assert(serialized.has("finances"), "Sérialisation doit inclure finances")
	var restored = SaveManager._deserialize_club(serialized)
	assert(restored.finances != null, "Désérialisation doit restaurer finances")
	assert(restored.finances.ticket_price == fin_d3.ticket_price, "Prix du billet restauré identique")
	assert(restored.finances.arena_capacity == fin_d3.arena_capacity, "Capacité restaurée identique")
	print("✓ Sérialisation & Sauvegarde des finances OK")
	
	print("--- TEST SYSTÈME ÉCONOMIQUE VALIDÉ AVEC SUCCÈS ---")
	quit(0)
