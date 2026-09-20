class_name FormatUtils
extends RefCounted

# Formate un entier en espaçant les centaines, milliers, centaines de milliers et millions par un espace
# Ex: 20064000 -> "20 064 000"
# Ex: 1500 -> "1 500"
# Ex: -400000 -> "-400 000"
static func format_number(val: int, sep: String = " ") -> String:
	var is_neg = (val < 0)
	var s = str(absi(val))
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = sep + res
	if is_neg:
		res = "-" + res
	return res

# Formate directement une somme en euros avec espace
# Ex: 1500000 -> "1 500 000 €"
static func format_money(val: int, sep: String = " ") -> String:
	return "%s €" % format_number(val, sep)
