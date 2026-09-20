class_name GameWorld
extends RefCounted

const ClubFinances = preload("res://scripts/ClubFinances.gd")

static func create_default_world() -> Dictionary:
	PlayerGenerator.reset_registry()
	var all_leagues: Array[League] = []

	var market = TransferMarket.new()
	market.init_free_agents("France", 12, 35)

	# ===================== FRANCE =====================
	# D1 Élite (8 équipes)
	all_leagues.append(_create_league("France", "Ligue 1 Élite", 1, 14, [
		{"name": "Paris Saint-Germain", "primary": Color("004170"), "secondary": Color("da291c"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Olympique de Marseille", "primary": Color("00a3e0"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Olympique Lyonnais", "primary": Color("1d428a"), "secondary": Color("da291c"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "AS Monaco", "primary": Color("da291c"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "LOSC Lille", "primary": Color("da291c"), "secondary": Color("112340"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Stade Rennais", "primary": Color("e30613"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "RC Lens", "primary": Color("ffcc00"), "secondary": Color("da291c"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "OGC Nice", "primary": Color("da291c"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	# D2 Pro (6 équipes)
	all_leagues.append(_create_league("France", "Ligue 2 BKT", 2, 11, [
		{"name": "FC Nantes", "primary": Color("009639"), "secondary": Color("ffd100"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Stade de Reims", "primary": Color("e2001a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "RC Strasbourg", "primary": Color("009fe3"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Toulouse FC", "primary": Color("5b2c82"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Montpellier HSC", "primary": Color("00205b"), "secondary": Color("ff671f"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Stade Brestois", "primary": Color("e20613"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR}
	]))

	# D3 National (6 équipes)
	all_leagues.append(_create_league("France", "National 1", 3, 8, [
		{"name": "Girondins de Bordeaux", "primary": Color("0b1b3d"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "AS Saint-Étienne", "primary": Color("007a3d"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "FC Metz", "primary": Color("8a1538"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "AJ Auxerre", "primary": Color("0055a5"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Angers SCO", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Le Havre AC", "primary": Color("87ceeb"), "secondary": Color("002d62"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	# ===================== ESPAGNE =====================
	# D1 (8 équipes)
	all_leagues.append(_create_league("Espagne", "La Liga EA Sports", 1, 14, [
		{"name": "Real Madrid CF", "primary": Color("ffffff"), "secondary": Color("6c5ce7"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "FC Barcelona", "primary": Color("004d98"), "secondary": Color("a50044"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Atlético de Madrid", "primary": Color("cb3524"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Athletic Club", "primary": Color("ee2524"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Real Sociedad", "primary": Color("0067b1"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Real Betis", "primary": Color("0bb364"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Sevilla FC", "primary": Color("d4001f"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Villarreal CF", "primary": Color("fff000"), "secondary": Color("005bac"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# D2 (6 équipes)
	all_leagues.append(_create_league("Espagne", "La Liga Hypermotion", 2, 11, [
		{"name": "Valencia CF", "primary": Color("ffffff"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Girona FC", "primary": Color("d31127"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Celta de Vigo", "primary": Color("8ac3ee"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "RCD Mallorca", "primary": Color("e20613"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "CA Osasuna", "primary": Color("d31024"), "secondary": Color("0a1c2a"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "RCD Espanyol", "primary": Color("007fc8"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	# D3 (6 équipes)
	all_leagues.append(_create_league("Espagne", "Primera Federación", 3, 8, [
		{"name": "Real Zaragoza", "primary": Color("005daa"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Real Valladolid", "primary": Color("6c2d86"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Deportivo La Coruña", "primary": Color("004c97"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Sporting de Gijón", "primary": Color("e2001a"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Rayo Vallecano", "primary": Color("ffffff"), "secondary": Color("e2001a"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "UD Las Palmas", "primary": Color("f9d616"), "secondary": Color("005ca9"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# ===================== ITALIE =====================
	# D1 (8 équipes)
	all_leagues.append(_create_league("Italie", "Serie A Enilive", 1, 14, [
		{"name": "Juventus FC", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "FC Internazionale", "primary": Color("0068a8"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "AC Milan", "primary": Color("fb090b"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "SSC Napoli", "primary": Color("0080c8"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "AS Roma", "primary": Color("8e1f2f"), "secondary": Color("f0bc42"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "SS Lazio", "primary": Color("87d8f7"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Atalanta BC", "primary": Color("1e569d"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "ACF Fiorentina", "primary": Color("4b2882"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	# D2 (6 équipes)
	all_leagues.append(_create_league("Italie", "Serie BKT", 2, 11, [
		{"name": "Bologna FC", "primary": Color("1b2838"), "secondary": Color("a51c30"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Torino FC", "primary": Color("8b0000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Genoa CFC", "primary": Color("c4122d"), "secondary": Color("0a2240"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Cagliari Calcio", "primary": Color("c4122d"), "secondary": Color("002d62"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Parma Calcio", "primary": Color("ffe000"), "secondary": Color("003882"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Hellas Verona", "primary": Color("002f6c"), "secondary": Color("ffdf00"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# D3 (6 équipes)
	all_leagues.append(_create_league("Italie", "Serie C", 3, 8, [
		{"name": "US Sassuolo", "primary": Color("009640"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "UC Sampdoria", "primary": Color("0055a5"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "US Lecce", "primary": Color("fde100"), "secondary": Color("d31024"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Udinese Calcio", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Palermo FC", "primary": Color("f5a3b7"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Venezia FC", "primary": Color("ff5000"), "secondary": Color("008050"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# ===================== ANGLETERRE =====================
	# D1 (8 équipes)
	all_leagues.append(_create_league("Angleterre", "Premier League", 1, 14, [
		{"name": "Manchester City", "primary": Color("6cabdd"), "secondary": Color("1c2c5b"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Arsenal FC", "primary": Color("ef0107"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Liverpool FC", "primary": Color("c8102e"), "secondary": Color("00b2a9"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Manchester United", "primary": Color("da291c"), "secondary": Color("fbe122"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Chelsea FC", "primary": Color("034694"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Tottenham Hotspur", "primary": Color("132257"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Newcastle United", "primary": Color("241f20"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Aston Villa", "primary": Color("670e36"), "secondary": Color("95bfe5"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# D2 (6 équipes)
	all_leagues.append(_create_league("Angleterre", "EFL Championship", 2, 11, [
		{"name": "West Ham United", "primary": Color("7a263a"), "secondary": Color("1bb1e7"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Brighton & Hove Albion", "primary": Color("0057b8"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Wolverhampton Wanderers", "primary": Color("fdb913"), "secondary": Color("231f20"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Everton FC", "primary": Color("003399"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Crystal Palace", "primary": Color("1b458f"), "secondary": Color("c4122e"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Fulham FC", "primary": Color("ffffff"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	# D3 (6 équipes)
	all_leagues.append(_create_league("Angleterre", "EFL League One", 3, 8, [
		{"name": "Leicester City", "primary": Color("003090"), "secondary": Color("fdbe11"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Leeds United", "primary": Color("ffffff"), "secondary": Color("1d428a"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Southampton FC", "primary": Color("d71920"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Nottingham Forest", "primary": Color("dd0000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "AFC Bournemouth", "primary": Color("da291c"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Sunderland AFC", "primary": Color("eb172b"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS}
	]))

	# ===================== PORTUGAL =====================
	# D1 (8 équipes)
	all_leagues.append(_create_league("Portugal", "Liga Portugal Betclic", 1, 14, [
		{"name": "SL Benfica", "primary": Color("e30613"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "FC Porto", "primary": Color("003b94"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Sporting CP", "primary": Color("008057"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "SC Braga", "primary": Color("da291c"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Vitória Guimarães", "primary": Color("ffffff"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "FC Famalicão", "primary": Color("002d62"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Rio Ave FC", "primary": Color("008057"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Gil Vicente FC", "primary": Color("da291c"), "secondary": Color("003b94"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# D2 (6 équipes)
	all_leagues.append(_create_league("Portugal", "Liga Portugal 2", 2, 11, [
		{"name": "Boavista FC", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Moreirense FC", "primary": Color("008057"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "GD Estoril Praia", "primary": Color("fee12b"), "secondary": Color("005baa"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Casa Pia AC", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "FC Arouca", "primary": Color("fee12b"), "secondary": Color("003b94"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "SC Farense", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.ANCHOR}
	]))

	# D3 (6 équipes)
	all_leagues.append(_create_league("Portugal", "Liga 3", 3, 8, [
		{"name": "Marítimo Funchal", "primary": Color("008057"), "secondary": Color("da291c"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "CD Nacional", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Portimonense SC", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "CF Os Belenenses", "primary": Color("003b94"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "Académica de Coimbra", "primary": Color("000000"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "CD Santa Clara", "primary": Color("da291c"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# ===================== ALLEMAGNE =====================
	# D1 (8 équipes)
	all_leagues.append(_create_league("Allemagne", "Bundesliga", 1, 14, [
		{"name": "FC Bayern München", "primary": Color("dc052d"), "secondary": Color("0066b2"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Borussia Dortmund", "primary": Color("fde100"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Bayer 04 Leverkusen", "primary": Color("e32221"), "secondary": Color("000000"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "RB Leipzig", "primary": Color("e00034"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "VfB Stuttgart", "primary": Color("ffffff"), "secondary": Color("e32219"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "Eintracht Frankfurt", "primary": Color("000000"), "secondary": Color("e1000f"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Borussia M'gladbach", "primary": Color("000000"), "secondary": Color("009e52"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "VfL Wolfsburg", "primary": Color("65b32e"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR}
	]))

	# D2 (6 équipes)
	all_leagues.append(_create_league("Allemagne", "2. Bundesliga", 2, 11, [
		{"name": "SV Werder Bremen", "primary": Color("008040"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "SC Freiburg", "primary": Color("000000"), "secondary": Color("e30613"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "TSG 1899 Hoffenheim", "primary": Color("1961b6"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON},
		{"name": "1. FC Union Berlin", "primary": Color("dc052d"), "secondary": Color("fff000"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "1. FSV Mainz 05", "primary": Color("c70125"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "FC Augsburg", "primary": Color("ba0c2f"), "secondary": Color("005c37"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CHEVRON}
	]))

	# D3 (6 équipes)
	all_leagues.append(_create_league("Allemagne", "3. Liga", 3, 8, [
		{"name": "FC Schalke 04", "primary": Color("004d9d"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Hamburger SV", "primary": Color("003399"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.DIAMOND, "symbol": ClubBadge.SymbolType.CROSS},
		{"name": "1. FC Köln", "primary": Color("e30613"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "Hertha BSC", "primary": Color("005ca9"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.STRIPES, "symbol": ClubBadge.SymbolType.ANCHOR},
		{"name": "Fortuna Düsseldorf", "primary": Color("e30613"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.CIRCLE, "symbol": ClubBadge.SymbolType.STAR},
		{"name": "FC St. Pauli", "primary": Color("653b1f"), "secondary": Color("ffffff"), "shape": ClubBadge.ShieldShape.SHIELD, "symbol": ClubBadge.SymbolType.CROSS}
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
			1: c.budget = randi_range(220_000, 450_000)
			2: c.budget = randi_range(90_000, 160_000)
			_: c.budget = randi_range(30_000, 65_000)
		c.finances = ClubFinances.create_default_for_division(div, c.club_name)
		c.tactical_style = randi_range(0, 2)
		PlayerGenerator.create_default_squad(c, avg_lvl)
		l.clubs.append(c)
	l.initialize_league()
	return l
