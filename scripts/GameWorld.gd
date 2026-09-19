class_name GameWorld
extends RefCounted

const ClubFinances = preload("res://scripts/ClubFinances.gd")

static func create_default_world() -> Dictionary:
	PlayerGenerator.reset_registry()
	var all_leagues: Array[League] = []

	var market = TransferMarket.new()
	market.init_free_agents("France", 12, 28)

	# ===================== FRANCE =====================
	all_leagues.append(_create_league("France", "Division 1 Élite", 1, 13, [
		{"name": "Paris RG", "primary": Color("1e3a8a"), "secondary": Color("ef4444"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Massalia", "primary": Color("0284c7"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Lyon Futsal", "primary": Color("b91c1c"), "secondary": Color("eab308"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Lille 5", "primary": Color("dc2626"), "secondary": Color("1e293b"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Nantes Fives", "primary": Color("059669"), "secondary": Color("facc15"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Bordeaux F5", "primary": Color("0f172a"), "secondary": Color("f8fafc"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Rennes Futsal", "primary": Color("b91c1c"), "secondary": Color("18181b"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Strasbourg 5", "primary": Color("2563eb"), "secondary": Color("f1f5f9"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR}
	]))

	all_leagues.append(_create_league("France", "Division 2 Pro", 2, 10, [
		{"name": "Toulouse F5", "primary": Color("7c3aed"), "secondary": Color("f8fafc"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Nice Riviera", "primary": Color("dc2626"), "secondary": Color("0f172a"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Montpellier Futsal", "primary": Color("ea580c"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Lens Artois", "primary": Color("ca8a04"), "secondary": Color("b91c1c"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Reims Futsal", "primary": Color("e11d48"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Metz 5", "primary": Color("831843"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	all_leagues.append(_create_league("France", "Division 3 Régionale", 3, 8, [
		{"name": "AS Brest 5", "primary": Color("1e293b"), "secondary": Color("38bdf8"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Le Havre Futsal", "primary": Color("0284c7"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Nîmes F5", "primary": Color("059669"), "secondary": Color("f8fafc"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Dijon Futsal", "primary": Color("dc2626"), "secondary": Color("0f172a"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Angers SCO 5", "primary": Color("0f172a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Clermont F5", "primary": Color("991b1b"), "secondary": Color("1e293b"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	# ===================== ESPAGNE =====================
	all_leagues.append(_create_league("Espagne", "Primera División", 1, 14, [
		{"name": "Barça Futsal", "primary": Color("1e3a8a"), "secondary": Color("991b1b"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Inter Movistar", "primary": Color("0284c7"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "ElPozo Murcia", "primary": Color("dc2626"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Palma Futsal", "primary": Color("15803d"), "secondary": Color("eab308"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Jaén Paraíso", "primary": Color("eab308"), "secondary": Color("15803d"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Valdepeñas", "primary": Color("2563eb"), "secondary": Color("facc15"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Betis Futsal", "primary": Color("16a34a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Ribera Navarra", "primary": Color("ea580c"), "secondary": Color("0f172a"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	all_leagues.append(_create_league("Espagne", "Segunda División", 2, 11, [
		{"name": "Levante Futsal", "primary": Color("0284c7"), "secondary": Color("b91c1c"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Zaragoza 5", "primary": Color("2563eb"), "secondary": Color("f8fafc"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "O Parrulo Ferrol", "primary": Color("ffffff"), "secondary": Color("0284c7"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Burela FS", "primary": Color("ea580c"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Alzira Futsal", "primary": Color("2563eb"), "secondary": Color("991b1b"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "UMA Antequera", "primary": Color("15803d"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	all_leagues.append(_create_league("Espagne", "Segunda B", 3, 8, [
		{"name": "Ibiza Futsal", "primary": Color("06b6d4"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Melilla 5", "primary": Color("2563eb"), "secondary": Color("eab308"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Ceuta Futsal", "primary": Color("ffffff"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Leganés FS", "primary": Color("1e3a8a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Talavera 5", "primary": Color("f8fafc"), "secondary": Color("1e293b"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Gran Canaria FS", "primary": Color("eab308"), "secondary": Color("2563eb"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	# ===================== ITALIE =====================
	all_leagues.append(_create_league("Italie", "Serie A Futsal", 1, 13, [
		{"name": "Napoli Futsal", "primary": Color("0ea5e9"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Roma 5", "primary": Color("991b1b"), "secondary": Color("eab308"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Feldi Eboli", "primary": Color("b91c1c"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Sandro Abate", "primary": Color("15803d"), "secondary": Color("facc15"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Olimpus Roma", "primary": Color("1e293b"), "secondary": Color("38bdf8"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Came Treviso", "primary": Color("2563eb"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	all_leagues.append(_create_league("Italie", "Serie A2 Élite", 2, 10, [
		{"name": "Milano Futsal", "primary": Color("dc2626"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Lazio 5", "primary": Color("38bdf8"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Pescara Futsal", "primary": Color("0284c7"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Verona 5", "primary": Color("eab308"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Sampdoria 5", "primary": Color("2563eb"), "secondary": Color("dc2626"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Modena 5", "primary": Color("eab308"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR}
	]))

	all_leagues.append(_create_league("Italie", "Serie B Futsal", 3, 8, [
		{"name": "Palermo F5", "primary": Color("f472b6"), "secondary": Color("0f172a"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Bari Futsal", "primary": Color("dc2626"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Catania 5", "primary": Color("dc2626"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Bologna Futsal", "primary": Color("991b1b"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Cagliari 5", "primary": Color("b91c1c"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Parma Futsal", "primary": Color("eab308"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	# ===================== PORTUGAL =====================
	all_leagues.append(_create_league("Portugal", "Liga Placard", 1, 13, [
		{"name": "Sporting CP 5", "primary": Color("16a34a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Benfica Futsal", "primary": Color("dc2626"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Braga Futsal", "primary": Color("b91c1c"), "secondary": Color("f8fafc"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Leões Porto Salvo", "primary": Color("ea580c"), "secondary": Color("1e293b"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Quinta Lombos", "primary": Color("eab308"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Fundão F5", "primary": Color("0284c7"), "secondary": Color("facc15"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	all_leagues.append(_create_league("Portugal", "Segunda Divisão", 2, 10, [
		{"name": "Belenenses 5", "primary": Color("1e3a8a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Rio Ave Futsal", "primary": Color("15803d"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Marítimo 5", "primary": Color("15803d"), "secondary": Color("dc2626"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Portimonense", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Caxinas 5", "primary": Color("0284c7"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Ferreira Zêzere", "primary": Color("eab308"), "secondary": Color("15803d"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	all_leagues.append(_create_league("Portugal", "Terceira Divisão", 3, 8, [
		{"name": "Viseu 2001", "primary": Color("2563eb"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Burinhosa 5", "primary": Color("eab308"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Académica 5", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Olho Marinho", "primary": Color("15803d"), "secondary": Color("eab308"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Nogueiró 5", "primary": Color("dc2626"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Macedense", "primary": Color("1e3a8a"), "secondary": Color("facc15"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	# ===================== ANGLETERRE =====================
	all_leagues.append(_create_league("Angleterre", "National Futsal Series 1", 1, 11, [
		{"name": "London Helvecia", "primary": Color("e11d48"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Manchester Futsal", "primary": Color("0284c7"), "secondary": Color("1e293b"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Birmingham Tigers", "primary": Color("ea580c"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Bloomsbury Futsal", "primary": Color("6366f1"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Bristol City 5", "primary": Color("dc2626"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Oxford Lions", "primary": Color("1e3a8a"), "secondary": Color("facc15"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	all_leagues.append(_create_league("Angleterre", "National Futsal Series 2", 2, 9, [
		{"name": "York Futsal", "primary": Color("1e3a8a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Derby Futsal", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Bolton 5", "primary": Color("1e3a8a"), "secondary": Color("dc2626"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Southampton F5", "primary": Color("dc2626"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Newcastle Futsal", "primary": Color("0f172a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Cambridge 5", "primary": Color("38bdf8"), "secondary": Color("1e3a8a"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR}
	]))

	all_leagues.append(_create_league("Angleterre", "National Futsal Series 3", 3, 7, [
		{"name": "Leeds Futsal", "primary": Color("2563eb"), "secondary": Color("eab308"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Liverpool F5", "primary": Color("dc2626"), "secondary": Color("15803d"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Sheffield 5", "primary": Color("dc2626"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Norwich Futsal", "primary": Color("15803d"), "secondary": Color("eab308"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Plymouth F5", "primary": Color("15803d"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Cardiff Futsal", "primary": Color("2563eb"), "secondary": Color("dc2626"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR}
	]))

	return {
		"all_leagues": all_leagues,
		"market": market
	}

static func _create_league(country: String, league_name: String, div: int, avg_lvl: int, club_configs: Array) -> League:
	var l = League.new()
	l.country = country
	l.league_name = league_name
	l.division = div
	for cfg in club_configs:
		var c = Club.new()
		c.club_name = cfg["name"]
		c.country = country
		c.division = div
		c.primary_color = cfg["primary"]
		c.secondary_color = cfg["secondary"]
		c.badge_shape = cfg["shape"]
		c.badge_symbol = cfg["symbol"]
		match div:
			1: c.budget = randi_range(180_000, 380_000)
			2: c.budget = randi_range(70_000, 140_000)
			_: c.budget = randi_range(25_000, 55_000)
		c.finances = ClubFinances.create_default_for_division(div, c.club_name)
		c.tactical_style = randi_range(0, 2)
		PlayerGenerator.create_default_squad(c, avg_lvl)
		l.clubs.append(c)
	l.initialize_league()
	return l
