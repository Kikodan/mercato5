extends SceneTree

func _init() -> void:
	print("--- DEBUT EXTRACTION DE TOUS LES VISAGES DE JOUEURS ---")
	var path1 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774374997.jpg"
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	
	DirAccess.make_dir_absolute("res://assets/faces")
	
	var img1 = Image.new()
	var err1 = img1.load(path1)
	assert(err1 == OK, "Erreur chargement img1")
	img1.convert(Image.FORMAT_RGBA8)
	
	var img2 = Image.new()
	var err2 = img2.load(path2)
	assert(err2 == OK, "Erreur chargement img2")
	img2.convert(Image.FORMAT_RGBA8)
	
	var face_index = 0
	
	# Sheet 1 : 14 colonnes x 8 lignes = 112 visages
	var col_w1 = 1024.0 / 14.0
	var row_h1 = 682.0 / 8.0
	var bg_col1 = Color(0.035, 0.095, 0.135)
	
	for r in 8:
		for c in 14:
			var x = int(c * col_w1)
			var y = int(r * row_h1)
			var w = int(col_w1)
			var h = int(row_h1)
			var sub = img1.get_region(Rect2i(x, y, w, h))
			
			for py in sub.get_height():
				for px in sub.get_width():
					var p = sub.get_pixel(px, py)
					var dr = absf(p.r - bg_col1.r)
					var dg = absf(p.g - bg_col1.g)
					var db = absf(p.b - bg_col1.b)
					if dr < 0.045 and dg < 0.045 and db < 0.045:
						sub.set_pixel(px, py, Color(0, 0, 0, 0))
						
			sub.save_png("res://assets/faces/face_%d.png" % face_index)
			face_index += 1
	
	print("Sheet 1 terminée : 112 visages extraits.")
	
	# Sheet 2 : 12 colonnes x 7 lignes = 84 visages
	var col_w2 = 1024.0 / 12.0
	var row_h2 = 682.0 / 7.0
	var bg_col2 = Color(0.05, 0.10, 0.13)
	
	for r in 7:
		for c in 12:
			var x = int(c * col_w2)
			var y = int(r * row_h2)
			var w = int(col_w2)
			var h = int(row_h2)
			var sub = img2.get_region(Rect2i(x, y, w, h))
			
			for py in sub.get_height():
				for px in sub.get_width():
					var p = sub.get_pixel(px, py)
					var dr = absf(p.r - bg_col2.r)
					var dg = absf(p.g - bg_col2.g)
					var db = absf(p.b - bg_col2.b)
					if dr < 0.05 and dg < 0.05 and db < 0.05:
						sub.set_pixel(px, py, Color(0, 0, 0, 0))
						
			sub.save_png("res://assets/faces/face_%d.png" % face_index)
			face_index += 1
	
	print("Sheet 2 terminée : total %d visages créés dans res://assets/faces/" % face_index)
	quit(0)
