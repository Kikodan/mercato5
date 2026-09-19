class_name ClubFinances
extends RefCounted

var ticket_price: int = 15
var arena_capacity: int = 1200
var arena_name: String = "Futsal Arena"

var primary_sponsor_name: String = "Sponsor Principal"
var primary_sponsor_weekly: int = 2500

var arena_sponsor_name: String = "Partenaire Officiel"
var arena_sponsor_weekly: int = 1200

var weekly_tv_rights: int = 1500
var weekly_maintenance: int = 800

var recent_match_revenue: int = 0
var recent_attendance: int = 0
var last_week_income: int = 0
var last_week_expense: int = 0
var last_week_net: int = 0

static func create_default_for_division(division: int, club_name: String = ""):
	var f = (load("res://scripts/ClubFinances.gd") as GDScript).new()
	f.arena_name = "Palais des Sports %s" % club_name
	
	match division:
		1:
			f.ticket_price = 22
			f.arena_capacity = randi_range(3500, 5200)
			f.primary_sponsor_name = ["Fly Airlines", "CryptoBank", "TechGlobal", "Puma Pro", "Red Bull Energy"].pick_random()
			f.primary_sponsor_weekly = randi_range(9000, 15000)
			f.arena_sponsor_name = ["Orange Connect", "Decathlon Sports", "TotalEnergies"].pick_random()
			f.arena_sponsor_weekly = randi_range(4000, 7500)
			f.weekly_tv_rights = randi_range(7000, 11000)
			f.weekly_maintenance = randi_range(3000, 5000)
		2:
			f.ticket_price = 16
			f.arena_capacity = randi_range(1600, 2600)
			f.primary_sponsor_name = ["Mutuelle Santé", "Brasserie Région", "Transport Express", "Banque Pop"].pick_random()
			f.primary_sponsor_weekly = randi_range(3500, 6000)
			f.arena_sponsor_name = ["Intersport Local", "Optic 2000", "Brico Bâtiment"].pick_random()
			f.arena_sponsor_weekly = randi_range(1800, 3200)
			f.weekly_tv_rights = randi_range(2500, 4500)
			f.weekly_maintenance = randi_range(1200, 2200)
		_: # Division 3
			f.ticket_price = 12
			f.arena_capacity = randi_range(700, 1200)
			f.primary_sponsor_name = ["Garage du Centre", "Boulangerie Artisanale", "Supermarché Express", "Pizzeria Napoli"].pick_random()
			f.primary_sponsor_weekly = randi_range(1400, 2400)
			f.arena_sponsor_name = ["Café des Sports", "Imprimerie Locale", "Pharmacie Centrale"].pick_random()
			f.arena_sponsor_weekly = randi_range(700, 1400)
			f.weekly_tv_rights = randi_range(800, 1500)
			f.weekly_maintenance = randi_range(400, 900)
			
	return f

func estimate_attendance_percentage(price: int, division: int) -> float:
	var ideal_price = 12.0
	match division:
		1: ideal_price = 22.0
		2: ideal_price = 16.0
		_: ideal_price = 12.0
		
	# Elasticité prix : si le prix augmente au-dessus de l'idéal, l'affluence chute
	var ratio = float(price) / maxf(ideal_price, 1.0)
	var base_pct = 0.88
	if ratio <= 1.0:
		base_pct += (1.0 - ratio) * 0.12 # Jusqu'à 100% si pas cher
	else:
		base_pct -= (ratio - 1.0) * 0.55 # Chute rapide si trop cher
		
	return clampf(base_pct, 0.15, 1.0)

func calculate_match_attendance(opponent: Club, is_derby: bool = false, division: int = 1) -> int:
	var pct = estimate_attendance_percentage(ticket_price, division)
	# Bonus d'affiche si l'adversaire est prestigieux ou derby
	if is_derby:
		pct += 0.08
	if opponent != null and opponent.reputation > 70:
		pct += 0.07
		
	pct = clampf(pct + randf_range(-0.04, 0.04), 0.15, 1.0)
	return int(float(arena_capacity) * pct)

func process_home_match_receipts(club: Club, opponent: Club, is_derby: bool = false) -> int:
	var div = club.division if club != null else 1
	var att = calculate_match_attendance(opponent, is_derby, div)
	var receipts = att * ticket_price
	recent_attendance = att
	recent_match_revenue = receipts
	if club != null:
		club.budget += receipts
	return receipts

func process_weekly_cycle(club: Club, home_match_revenue: int = 0) -> Dictionary:
	var wage_bill = club.get_total_wage() if club != null else 0
	var sponsor_total = primary_sponsor_weekly + arena_sponsor_weekly
	var fixed_income = sponsor_total + weekly_tv_rights
	var total_income = fixed_income + home_match_revenue
	
	var total_expense = wage_bill + weekly_maintenance
	var net = total_income - total_expense
	
	last_week_income = total_income
	last_week_expense = total_expense
	last_week_net = net
	
	# Appliquer le solde fixe hebdomadaire (le match à domicile a déjà été ou sera crédité)
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

func to_dict() -> Dictionary:
	return {
		"ticket_price": ticket_price,
		"arena_capacity": arena_capacity,
		"arena_name": arena_name,
		"primary_sponsor_name": primary_sponsor_name,
		"primary_sponsor_weekly": primary_sponsor_weekly,
		"arena_sponsor_name": arena_sponsor_name,
		"arena_sponsor_weekly": arena_sponsor_weekly,
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
	f.arena_sponsor_name = str(d.get("arena_sponsor_name", f.arena_sponsor_name))
	f.arena_sponsor_weekly = int(d.get("arena_sponsor_weekly", f.arena_sponsor_weekly))
	f.weekly_tv_rights = int(d.get("weekly_tv_rights", f.weekly_tv_rights))
	f.weekly_maintenance = int(d.get("weekly_maintenance", f.weekly_maintenance))
	f.recent_match_revenue = int(d.get("recent_match_revenue", 0))
	f.recent_attendance = int(d.get("recent_attendance", 0))
	f.last_week_income = int(d.get("last_week_income", 0))
	f.last_week_expense = int(d.get("last_week_expense", 0))
	f.last_week_net = int(d.get("last_week_net", 0))
	return f
