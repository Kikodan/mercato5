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
