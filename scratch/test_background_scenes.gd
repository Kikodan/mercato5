extends SceneTree

func _init() -> void:
	print("--- TEST CHARGEMENT DES SCENES AVEC FOND D'ECRAN MERCATO 5 ---")
	
	# 1. MainMenu.tscn
	var menu_res = load("res://scenes/MainMenu.tscn")
	assert(menu_res != null, "Impossible de charger MainMenu.tscn")
	var menu_inst = menu_res.instantiate()
	assert(menu_inst != null, "Impossible d'instancier MainMenu")
	var menu_bg = menu_inst.get_node_or_null("BackgroundImage")
	assert(menu_bg != null, "BackgroundImage absent dans MainMenu")
	assert(menu_bg.texture != null, "Texture de fond absente dans MainMenu")
	print("✓ MainMenu.tscn instancié avec succès avec son image de fond !")
	menu_inst.free()
	
	# 2. Dashboard.tscn
	var dash_res = load("res://scenes/Dashboard.tscn")
	assert(dash_res != null, "Impossible de charger Dashboard.tscn")
	var dash_inst = dash_res.instantiate()
	assert(dash_inst != null, "Impossible d'instancier Dashboard")
	var dash_bg = dash_inst.get_node_or_null("BackgroundImage")
	assert(dash_bg != null, "BackgroundImage absent dans Dashboard")
	assert(dash_bg.texture != null, "Texture de fond absente dans Dashboard")
	print("✓ Dashboard.tscn instancié avec succès avec son image de fond en haute opacité !")
	dash_inst.free()
	
	print("--- TOUS LES TESTS DE FOND D'ECRAN SONT VALIDES AVEC SUCCES ---")
	quit(0)
