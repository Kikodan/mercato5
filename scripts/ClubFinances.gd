class_name ClubFinances
extends RefCounted

var ticket_price: int = 15
var arena_capacity: int = 1200
var arena_name: String = "Futsal Arena"

# 1. Sponsor Maillot Principal
var primary_sponsor_name: String = "Sponsor Principal"
var primary_sponsor_weekly: int = 24000
var primary_sponsor_bonus_win: int = 4000
var primary_sponsor_weeks_left: int = 14

# 2. Partenaire Naming & Salle
var arena_sponsor_name: String = "Partenaire Salle"
var arena_sponsor_weekly: int = 12000
var arena_sponsor_bonus_win: int = 2000
var arena_sponsor_weeks_left: int = 14

# 3. Équipementier Officiel
var kit_sponsor_name: String = "Équipementier Pro"
var kit_sponsor_weekly: int = 10000
var kit_sponsor_bonus_win: int = 1500
var kit_sponsor_weeks_left: int = 14

# 4. Panneaux Publicitaires & Régie LED
var board_ads_name: String = "Régie Affichage LED"
var board_ads_weekly: int = 8000
var board_ads_bonus_win: int = 1000
var board_ads_weeks_left: int = 14

var weekly_tv_rights: int = 16000
var weekly_maintenance: int = 4000

var recent_match_revenue: int = 0
var recent_attendance: int = 0
var last_week_income: int = 0
var last_week_expense: int = 0
var last_week_net: int = 0

func get_total_sponsor_weekly() -> int:
	return primary_sponsor_weekly + arena_sponsor_weekly + kit_sponsor_weekly + board_ads_weekly

func get_total_win_bonus() -> int:
	return primary_sponsor_bonus_win + arena_sponsor_bonus_win + kit_sponsor_bonus_win + board_ads_bonus_win

func get_total_fixed_income() -> int:
	return get_total_sponsor_weekly() + weekly_tv_rights

static func create_default_for_division(division: int, club_name: String = ""):
	var f = (load("res://scripts/ClubFinances.gd") as GDScript).new()
	f.arena_name = "Palais des Sports %s" % club_name
	
	match division:
		1:
			f.ticket_price = 22
			f.arena_capacity = randi_range(3500, 5500)
			f.primary_sponsor_name = ["Fly Airlines", "CryptoBank", "TechGlobal", "Red Bull Energy", "Rolex Chrono"].pick_random()
			f.primary_sponsor_weekly = randi_range(25000, 36000)
			f.primary_sponsor_bonus_win = randi_range(3500, 6000)
			f.primary_sponsor_weeks_left = 14
			
			f.arena_sponsor_name = ["Orange Connect", "Decathlon Arena", "TotalEnergies Dome", "Groupama Stadium"].pick_random()
			f.arena_sponsor_weekly = randi_range(13000, 19000)
			f.arena_sponsor_bonus_win = randi_range(2000, 3500)
			f.arena_sponsor_weeks_left = 14
			
			f.kit_sponsor_name = ["Nike Football", "Adidas Performance", "Puma King", "Under Armour"].pick_random()
			f.kit_sponsor_weekly = randi_range(11000, 16000)
			f.kit_sponsor_bonus_win = randi_range(1500, 2500)
			f.kit_sponsor_weeks_left = 14
			
			f.board_ads_name = ["Régie Pub LED Europe", "Affichage MediaSport", "JCDecaux Futsal"].pick_random()
			f.board_ads_weekly = randi_range(9000, 13000)
			f.board_ads_bonus_win = randi_range(800, 1500)
			f.board_ads_weeks_left = 14
			
			f.weekly_tv_rights = randi_range(16000, 24000)
			f.weekly_maintenance = randi_range(3500, 5000)

		2:
			f.ticket_price = 16
			f.arena_capacity = randi_range(1800, 2800)
			f.primary_sponsor_name = ["Mutuelle Santé", "Brasserie Région", "Transport Express", "Banque Populaire"].pick_random()
			f.primary_sponsor_weekly = randi_range(10000, 16000)
			f.primary_sponsor_bonus_win = randi_range(1800, 3000)
			f.primary_sponsor_weeks_left = 14
			
			f.arena_sponsor_name = ["Intersport Local", "Optic 2000 Arena", "Brico Bâtiment Hall"].pick_random()
			f.arena_sponsor_weekly = randi_range(5000, 8500)
			f.arena_sponsor_bonus_win = randi_range(1000, 1800)
			f.arena_sponsor_weeks_left = 14
			
			f.kit_sponsor_name = ["Kappa Sport", "Macron Teamwear", "Umbro Pro", "Joma Futsal"].pick_random()
			f.kit_sponsor_weekly = randi_range(4000, 6500)
			f.kit_sponsor_bonus_win = randi_range(800, 1400)
			f.kit_sponsor_weeks_left = 14
			
			f.board_ads_name = ["Régie Panneaux Région", "Affichage Urbain D2"].pick_random()
			f.board_ads_weekly = randi_range(3000, 5000)
			f.board_ads_bonus_win = randi_range(500, 1000)
			f.board_ads_weeks_left = 14
			
			f.weekly_tv_rights = randi_range(6000, 9500)
			f.weekly_maintenance = randi_range(1800, 2800)

		_: # Division 3
			f.ticket_price = 12
			f.arena_capacity = randi_range(900, 1500)
			f.primary_sponsor_name = ["Garage du Centre", "Boulangerie Artisanale", "Supermarché Express", "Pizzeria Napoli"].pick_random()
			f.primary_sponsor_weekly = randi_range(4000, 6500)
			f.primary_sponsor_bonus_win = randi_range(800, 1500)
			f.primary_sponsor_weeks_left = 14
			
			f.arena_sponsor_name = ["Café des Sports", "Imprimerie Locale", "Pharmacie Centrale"].pick_random()
			f.arena_sponsor_weekly = randi_range(2000, 3500)
			f.arena_sponsor_bonus_win = randi_range(400, 800)
			f.arena_sponsor_weeks_left = 14
			
			f.kit_sponsor_name = ["Kipsta Sport", "Uhlsport", "Errea Equipement"].pick_random()
			f.kit_sponsor_weekly = randi_range(1800, 3000)
			f.kit_sponsor_bonus_win = randi_range(300, 600)
			f.kit_sponsor_weeks_left = 14
			
			f.board_ads_name = ["Commerçants Réunis", "Enseignes de Quartier"].pick_random()
			f.board_ads_weekly = randi_range(1400, 2400)
			f.board_ads_bonus_win = randi_range(200, 400)
			f.board_ads_weeks_left = 14
			
			f.weekly_tv_rights = randi_range(2500, 4500)
			f.weekly_maintenance = randi_range(800, 1400)
			
	return f

func estimate_attendance_percentage(price: int, division: int) -> float:
	var ideal_price = 12.0
	match division:
		1: ideal_price = 22.0
		2: ideal_price = 16.0
		_: ideal_price = 12.0
		
	var ratio = float(price) / maxf(ideal_price, 1.0)
	var base_pct = 0.88
	if ratio <= 1.0:
		base_pct += (1.0 - ratio) * 0.12
	else:
		base_pct -= (ratio - 1.0) * 0.55
		
	return clampf(base_pct, 0.15, 1.0)

func calculate_match_attendance(opponent: Club, is_derby: bool = false, division: int = 1) -> int:
	var pct = estimate_attendance_percentage(ticket_price, division)
	if is_derby:
		pct += 0.08
	if opponent != null and opponent.reputation > 70:
		pct += 0.07
		
	pct = clampf(pct + randf_range(-0.04, 0.04), 0.15, 1.0)
	return int(float(arena_capacity) * pct)

func process_home_match_receipts(club: Club, opponent: Club, is_derby: bool = false, is_victory: bool = false) -> int:
	var div = club.division if club != null else 1
	var att = calculate_match_attendance(opponent, is_derby, div)
	var receipts = att * ticket_price
	if is_victory:
		receipts += get_total_win_bonus()
	recent_attendance = att
	recent_match_revenue = receipts
	if club != null:
		club.budget += receipts
	return receipts

func process_weekly_cycle(club: Club, home_match_revenue: int = 0) -> Dictionary:
	var wage_bill = club.get_total_wage() if club != null else 0
	var sponsor_total = get_total_sponsor_weekly()
	var fixed_income = sponsor_total + weekly_tv_rights
	var total_income = fixed_income + home_match_revenue
	
	var total_expense = wage_bill + weekly_maintenance
	var net = total_income - total_expense
	
	last_week_income = total_income
	last_week_expense = total_expense
	last_week_net = net
	
	# Diminuer la durée des contrats
	if primary_sponsor_weeks_left > 0: primary_sponsor_weeks_left -= 1
	if arena_sponsor_weeks_left > 0: arena_sponsor_weeks_left -= 1
	if kit_sponsor_weeks_left > 0: kit_sponsor_weeks_left -= 1
	if board_ads_weeks_left > 0: board_ads_weeks_left -= 1

	if club != null:
		club.budget += (fixed_income - total_expense)
		
	return {
		"fixed_income": fixed_income,
		"sponsor_total": sponsor_total,
		"tv_rights": weekly_tv_rights,
		"match_revenue": home_match_revenue,
		"total_income": total_income,
		"wage_bill": wage_bill,
		"maintenance": weekly_maintenance,
		"total_expense": total_expense,
		"net": net
	}

# Génère 3 offres de sponsors pour négocier un nouveau contrat dans la catégorie choisie
static func generate_sponsor_proposals(category_id: String, division: int, club_reputation: int = 50) -> Array[Dictionary]:
	var proposals: Array[Dictionary] = []
	var mult = 1.0 + (float(club_reputation) - 50.0) * 0.008
	
	match category_id:
		"PRIMARY":
			var brands = [
				{"name": "Emirates Fly Fast", "style": "Prestige mondial", "factor": 1.15},
				{"name": "Red Bull Energy", "style": "Dynamique & Bonus victoire", "factor": 1.05},
				{"name": "CryptoLedger Pro", "style": "Forte prime immédiate", "factor": 1.25},
				{"name": "TechGlobal Solutions", "style": "Partenaire régulier", "factor": 1.00},
				{"name": "Banque Internationale", "style": "Contrat longue durée", "factor": 0.95},
				{"name": "Allianz Finance", "style": "Fiabilité institutionnelle", "factor": 1.08}
			]
			brands.shuffle()
			var base_amt = 24000 if division == 1 else (12000 if division == 2 else 5000)
			for i in 3:
				var b = brands[i]
				var weekly = int(base_amt * b["factor"] * mult * randf_range(0.92, 1.12))
				var win_bonus = int(weekly * 0.20 * randf_range(0.8, 1.4))
				var sign_bonus = int(weekly * randf_range(1.5, 3.5))
				var weeks = [14, 28].pick_random()
				proposals.append({
					"category_id": "PRIMARY",
					"brand_name": b["name"],
					"description": b["style"],
					"weekly_payout": weekly,
					"win_bonus": win_bonus,
					"signing_bonus": sign_bonus,
					"duration_weeks": weeks
				})

		"ARENA":
			var brands = [
				{"name": "Orange Connect Dome", "style": "Télécom & Connectivité", "factor": 1.10},
				{"name": "Decathlon Sports Arena", "style": "Équipements multisports", "factor": 1.00},
				{"name": "TotalEnergies Hall", "style": "Soutien logistique", "factor": 1.15},
				{"name": "Groupama Stadium Park", "style": "Assurance et stabilité", "factor": 1.05}
			]
			brands.shuffle()
			var base_amt = 13000 if division == 1 else (6500 if division == 2 else 2800)
			for i in 3:
				var b = brands[i]
				var weekly = int(base_amt * b["factor"] * mult * randf_range(0.92, 1.12))
				var win_bonus = int(weekly * 0.18)
				var sign_bonus = int(weekly * randf_range(1.2, 2.8))
				var weeks = [14, 28].pick_random()
				proposals.append({
					"category_id": "ARENA",
					"brand_name": b["name"],
					"description": b["style"],
					"weekly_payout": weekly,
					"win_bonus": win_bonus,
					"signing_bonus": sign_bonus,
					"duration_weeks": weeks
				})

		"KIT":
			var brands = [
				{"name": "Nike Football", "style": "Leader mondial", "factor": 1.15},
				{"name": "Adidas Performance", "style": "Précision & Histoire", "factor": 1.12},
				{"name": "Puma Futsal Pro", "style": "Vitesse & Style", "factor": 1.05},
				{"name": "Kappa Sport Classic", "style": "Look vintage réputé", "factor": 0.95},
				{"name": "Joma Futsal Elite", "style": "Spécialiste parquets", "factor": 1.02}
			]
			brands.shuffle()
			var base_amt = 11000 if division == 1 else (5000 if division == 2 else 2200)
			for i in 3:
				var b = brands[i]
				var weekly = int(base_amt * b["factor"] * mult * randf_range(0.92, 1.12))
				var win_bonus = int(weekly * 0.15)
				var sign_bonus = int(weekly * randf_range(1.0, 2.5))
				var weeks = [14, 28].pick_random()
				proposals.append({
					"category_id": "KIT",
					"brand_name": b["name"],
					"description": b["style"],
					"weekly_payout": weekly,
					"win_bonus": win_bonus,
					"signing_bonus": sign_bonus,
					"duration_weeks": weeks
				})

		_: # "BOARD"
			var brands = [
				{"name": "Régie Panneaux LED Europe", "style": "Bord de terrain dynamique", "factor": 1.10},
				{"name": "JCDecaux Sport Vision", "style": "Couverture maximale", "factor": 1.12},
				{"name": "PubliCourt Régie", "style": "Publicité locale ciblée", "factor": 0.95},
				{"name": "MediaFutsal Networks", "style": "Régie internationale", "factor": 1.05}
			]
			brands.shuffle()
			var base_amt = 9000 if division == 1 else (4000 if division == 2 else 1800)
			for i in 3:
				var b = brands[i]
				var weekly = int(base_amt * b["factor"] * mult * randf_range(0.92, 1.12))
				var win_bonus = int(weekly * 0.12)
				var sign_bonus = int(weekly * randf_range(1.0, 2.0))
				var weeks = [14, 28].pick_random()
				proposals.append({
					"category_id": "BOARD",
					"brand_name": b["name"],
					"description": b["style"],
					"weekly_payout": weekly,
					"win_bonus": win_bonus,
					"signing_bonus": sign_bonus,
					"duration_weeks": weeks
				})

	return proposals

func apply_negotiated_sponsor(category_id: String, proposal: Dictionary) -> void:
	match category_id:
		"PRIMARY":
			primary_sponsor_name = proposal.get("brand_name", primary_sponsor_name)
			primary_sponsor_weekly = proposal.get("weekly_payout", primary_sponsor_weekly)
			primary_sponsor_bonus_win = proposal.get("win_bonus", primary_sponsor_bonus_win)
			primary_sponsor_weeks_left = proposal.get("duration_weeks", 14)
		"ARENA":
			arena_sponsor_name = proposal.get("brand_name", arena_sponsor_name)
			arena_sponsor_weekly = proposal.get("weekly_payout", arena_sponsor_weekly)
			arena_sponsor_bonus_win = proposal.get("win_bonus", arena_sponsor_bonus_win)
			arena_sponsor_weeks_left = proposal.get("duration_weeks", 14)
		"KIT":
			kit_sponsor_name = proposal.get("brand_name", kit_sponsor_name)
			kit_sponsor_weekly = proposal.get("weekly_payout", kit_sponsor_weekly)
			kit_sponsor_bonus_win = proposal.get("win_bonus", kit_sponsor_bonus_win)
			kit_sponsor_weeks_left = proposal.get("duration_weeks", 14)
		"BOARD":
			board_ads_name = proposal.get("brand_name", board_ads_name)
			board_ads_weekly = proposal.get("weekly_payout", board_ads_weekly)
			board_ads_bonus_win = proposal.get("win_bonus", board_ads_bonus_win)
			board_ads_weeks_left = proposal.get("duration_weeks", 14)

func to_dict() -> Dictionary:
	return {
		"ticket_price": ticket_price,
		"arena_capacity": arena_capacity,
		"arena_name": arena_name,
		"primary_sponsor_name": primary_sponsor_name,
		"primary_sponsor_weekly": primary_sponsor_weekly,
		"primary_sponsor_bonus_win": primary_sponsor_bonus_win,
		"primary_sponsor_weeks_left": primary_sponsor_weeks_left,
		"arena_sponsor_name": arena_sponsor_name,
		"arena_sponsor_weekly": arena_sponsor_weekly,
		"arena_sponsor_bonus_win": arena_sponsor_bonus_win,
		"arena_sponsor_weeks_left": arena_sponsor_weeks_left,
		"kit_sponsor_name": kit_sponsor_name,
		"kit_sponsor_weekly": kit_sponsor_weekly,
		"kit_sponsor_bonus_win": kit_sponsor_bonus_win,
		"kit_sponsor_weeks_left": kit_sponsor_weeks_left,
		"board_ads_name": board_ads_name,
		"board_ads_weekly": board_ads_weekly,
		"board_ads_bonus_win": board_ads_bonus_win,
		"board_ads_weeks_left": board_ads_weeks_left,
		"weekly_tv_rights": weekly_tv_rights,
		"weekly_maintenance": weekly_maintenance,
		"recent_match_revenue": recent_match_revenue,
		"recent_attendance": recent_attendance,
		"last_week_income": last_week_income,
		"last_week_expense": last_week_expense,
		"last_week_net": last_week_net
	}

static func from_dict(d: Dictionary, division: int = 1, club_name: String = ""):
	var f = create_default_for_division(division, club_name)
	if d.is_empty():
		return f
	f.ticket_price = int(d.get("ticket_price", f.ticket_price))
	f.arena_capacity = int(d.get("arena_capacity", f.arena_capacity))
	f.arena_name = str(d.get("arena_name", f.arena_name))
	f.primary_sponsor_name = str(d.get("primary_sponsor_name", f.primary_sponsor_name))
	f.primary_sponsor_weekly = int(d.get("primary_sponsor_weekly", f.primary_sponsor_weekly))
	f.primary_sponsor_bonus_win = int(d.get("primary_sponsor_bonus_win", f.primary_sponsor_bonus_win))
	f.primary_sponsor_weeks_left = int(d.get("primary_sponsor_weeks_left", f.primary_sponsor_weeks_left))
	f.arena_sponsor_name = str(d.get("arena_sponsor_name", f.arena_sponsor_name))
	f.arena_sponsor_weekly = int(d.get("arena_sponsor_weekly", f.arena_sponsor_weekly))
	f.arena_sponsor_bonus_win = int(d.get("arena_sponsor_bonus_win", f.arena_sponsor_bonus_win))
	f.arena_sponsor_weeks_left = int(d.get("arena_sponsor_weeks_left", f.arena_sponsor_weeks_left))
	f.kit_sponsor_name = str(d.get("kit_sponsor_name", f.kit_sponsor_name))
	f.kit_sponsor_weekly = int(d.get("kit_sponsor_weekly", f.kit_sponsor_weekly))
	f.kit_sponsor_bonus_win = int(d.get("kit_sponsor_bonus_win", f.kit_sponsor_bonus_win))
	f.kit_sponsor_weeks_left = int(d.get("kit_sponsor_weeks_left", f.kit_sponsor_weeks_left))
	f.board_ads_name = str(d.get("board_ads_name", f.board_ads_name))
	f.board_ads_weekly = int(d.get("board_ads_weekly", f.board_ads_weekly))
	f.board_ads_bonus_win = int(d.get("board_ads_bonus_win", f.board_ads_bonus_win))
	f.board_ads_weeks_left = int(d.get("board_ads_weeks_left", f.board_ads_weeks_left))
	f.weekly_tv_rights = int(d.get("weekly_tv_rights", f.weekly_tv_rights))
	f.weekly_maintenance = int(d.get("weekly_maintenance", f.weekly_maintenance))
	f.recent_match_revenue = int(d.get("recent_match_revenue", 0))
	f.recent_attendance = int(d.get("recent_attendance", 0))
	f.last_week_income = int(d.get("last_week_income", 0))
	f.last_week_expense = int(d.get("last_week_expense", 0))
	f.last_week_net = int(d.get("last_week_net", 0))
	return f
