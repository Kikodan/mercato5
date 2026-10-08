class_name Tactics
extends RefCounted

enum Style {
	BALANCED,
	ALL_OUT_ATTACK,
	COUNTER_ATTACK
}

enum TrainingFocus {
	RECOVERY,
	SHOOTING,
	DEFENDING
}

enum TacticalFormation {
	FORMATION_1_2_1 = 0, # Losange (1 DEF, 2 MID, 1 FWD)
	FORMATION_1_1_2 = 1, # Double Attaque (1 DEF, 1 MID, 2 FWD)
	FORMATION_2_1_1 = 2  # Double Défense (2 DEF, 1 MID, 1 FWD)
}

static func get_formation_name(f: int) -> String:
	match f:
		TacticalFormation.FORMATION_1_2_1:
			return "1-2-1 (Losange)"
		TacticalFormation.FORMATION_1_1_2:
			return "1-1-2 (Double Attaque)"
		TacticalFormation.FORMATION_2_1_1:
			return "2-1-1 (Double Défense)"
		_:
			return "1-2-1 (Losange)"

static func get_formation_desc(f: int) -> String:
	match f:
		TacticalFormation.FORMATION_1_2_1:
			return "Losange équilibré (1 DEF, 2 MID, 1 FWD). Maîtrise du tempo et passes courtes. Bat le 2-1-1 mais craint le 1-1-2."
		TacticalFormation.FORMATION_1_1_2:
			return "Double Attaque (1 DEF, 1 MID, 2 FWD). Pressing haut asphyxiant et double pointe. Bat le 1-2-1 mais s'expose aux contres du 2-1-1."
		TacticalFormation.FORMATION_2_1_1:
			return "Double Défense (2 DEF, 1 MID, 1 FWD). Mur défensif axial et transition rapide. Bat le 1-1-2 mais dominé par le quadrillage du 1-2-1."
		_:
			return ""

static func get_slot_roles(f: int) -> Array:
	match f:
		TacticalFormation.FORMATION_1_2_1:
			return [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.MID, Player.Position.FWD]
		TacticalFormation.FORMATION_1_1_2:
			return [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD, Player.Position.FWD]
		TacticalFormation.FORMATION_2_1_1:
			return [Player.Position.GK, Player.Position.DEF, Player.Position.DEF, Player.Position.MID, Player.Position.FWD]
		_:
			return [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.MID, Player.Position.FWD]

static func get_formation_positions(f: int) -> Array[Vector2]:
	match f:
		TacticalFormation.FORMATION_1_2_1:
			return [
				Vector2(0.50, 0.86), # GK
				Vector2(0.50, 0.66), # DEF
				Vector2(0.24, 0.44), # MID Gauche
				Vector2(0.76, 0.44), # MID Droit
				Vector2(0.50, 0.20)  # FWD
			]
		TacticalFormation.FORMATION_1_1_2:
			return [
				Vector2(0.50, 0.86), # GK
				Vector2(0.50, 0.68), # DEF
				Vector2(0.50, 0.46), # MID Central
				Vector2(0.26, 0.22), # FWD Gauche
				Vector2(0.74, 0.22)  # FWD Droit
			]
		TacticalFormation.FORMATION_2_1_1:
			return [
				Vector2(0.50, 0.86), # GK
				Vector2(0.26, 0.66), # DEF Gauche
				Vector2(0.74, 0.66), # DEF Droit
				Vector2(0.50, 0.44), # MID Central
				Vector2(0.50, 0.20)  # FWD
			]
		_:
			return [
				Vector2(0.50, 0.86),
				Vector2(0.50, 0.66),
				Vector2(0.24, 0.44),
				Vector2(0.76, 0.44),
				Vector2(0.50, 0.20)
			]

# Triangle Pierre-Feuille-Ciseaux :
# 1-1-2 bat 1-2-1 (+15% pour 1-1-2)
# 1-2-1 bat 2-1-1 (+15% pour 1-2-1)
# 2-1-1 bat 1-1-2 (+15% pour 2-1-1)
static func get_formation_matchup(f_home: int, f_away: int) -> Dictionary:
	if f_home == f_away:
		return {
			"advantage": 0.0,
			"winner": 0,
			"label": "Neutralité tactique (Même formation)",
			"desc": "Les deux équipes appliquent la même disposition : aucun bonus tactique."
		}

	# Vérifier si Home a l'avantage
	var home_wins = false
	var reason = ""
	if f_home == TacticalFormation.FORMATION_1_1_2 and f_away == TacticalFormation.FORMATION_1_2_1:
		home_wins = true
		reason = "Le 1-1-2 asphyxie le 1-2-1 par un pressing haut sur ses 2 milieux !"
	elif f_home == TacticalFormation.FORMATION_1_2_1 and f_away == TacticalFormation.FORMATION_2_1_1:
		home_wins = true
		reason = "Le 1-2-1 contourne le bloc bas du 2-1-1 par le quadrillage du milieu !"
	elif f_home == TacticalFormation.FORMATION_2_1_1 and f_away == TacticalFormation.FORMATION_1_1_2:
		home_wins = true
		reason = "Le 2-1-1 neutralise la double pointe du 1-1-2 et sanctionne en contre !"

	if home_wins:
		return {
			"advantage": 0.15,
			"winner": 1,
			"label": "Avantage Domicile (+15%)",
			"desc": reason
		}

	# Sinon Away a l'avantage
	var away_reason = ""
	if f_away == TacticalFormation.FORMATION_1_1_2 and f_home == TacticalFormation.FORMATION_1_2_1:
		away_reason = "Le 1-1-2 adverse asphyxie votre relance en 1-2-1 !"
	elif f_away == TacticalFormation.FORMATION_1_2_1 and f_home == TacticalFormation.FORMATION_2_1_1:
		away_reason = "Le 1-2-1 adverse contourne votre double défense axiale !"
	elif f_away == TacticalFormation.FORMATION_2_1_1 and f_home == TacticalFormation.FORMATION_1_1_2:
		away_reason = "Le 2-1-1 adverse cadenasse votre double attaque et contre à vive allure !"

	return {
		"advantage": -0.15,
		"winner": 2,
		"label": "Avantage Extérieur (+15%)",
		"desc": away_reason
	}

static func get_style_name(style: Style) -> String:
	match style:
		Style.BALANCED:
			return "Équilibré"
		Style.ALL_OUT_ATTACK:
			return "Attaque Totale"
		Style.COUNTER_ATTACK:
			return "Contre-Attaque"
	return "Équilibré"

static func get_style_desc(style: Style) -> String:
	match style:
		Style.BALANCED:
			return "Jeu équilibré. Possession et pressing réguliers."
		Style.ALL_OUT_ATTACK:
			return "Pressing haut et jeu direct (+25% occasions, +30% fatigue)."
		Style.COUNTER_ATTACK:
			return "Bloc bas regroupé (-20% possession, contres tranchants)."
	return ""

static func get_training_name(focus: TrainingFocus) -> String:
	match focus:
		TrainingFocus.RECOVERY:
			return "Cryothérapie & Récupération"
		TrainingFocus.SHOOTING:
			return "Finition & Frappes"
		TrainingFocus.DEFENDING:
			return "Bloc & Duels Défensifs"
	return "Cryothérapie"

static func get_training_desc(focus: TrainingFocus) -> String:
	match focus:
		TrainingFocus.RECOVERY:
			return "Bonus de +20% à la régénération de forme hebdomadaire."
		TrainingFocus.SHOOTING:
			return "Bonus de +2 aux duels de frappe pour le match."
		TrainingFocus.DEFENDING:
			return "Bonus de +2 en défense et arrêts pour le match."
	return ""
