extends SceneTree

func _init() -> void:
	print("--- EXTRACTION PARFAITE DES 196 VISAGES ---")
	var path1 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774374997.jpg"
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	
	DirAccess.make_dir_absolute("res://assets/faces")
	
	var img1 = Image.new()
	img1.load(path1)
	img1.convert(Image.FORMAT_RGBA8)
	
	var img2 = Image.new()
	img2.load(path2)
	img2.convert(Image.FORMAT_RGBA8)
	
	var row_splits1 = [0, 93, 172, 253, 333, 411, 493, 573, 682]
	var row_splits2 = [0, 106, 197, 291, 381, 470, 565, 682]
	
	var face_index = 0
	
	# 1. Traitement Sheet 1 (14 cols x 8 rows = 112 visages)
	var bg_col1 = Color(0.035, 0.095, 0.135)
	for r in range(8):
		var y_start = row_splits1[r]
		var y_end = row_splits1[r + 1]
		var h = y_end - y_start
		for c in range(14):
			var x_start = int(c * 1024.0 / 14.0)
			var x_end = int((c + 1) * 1024.0 / 14.0)
			var w = x_end - x_start
			
			var sub = img1.get_region(Rect2i(x_start, y_start, w, h))
			_apply_transparency(sub, bg_col1, 0.055)
			sub.save_png("res://assets/faces/face_%d.png" % face_index)
			face_index += 1
			
	print("Sheet 1 achevée : 112 visages parfaits.")
	
	# 2. Traitement Sheet 2 (12 cols x 7 rows = 84 visages)
	var bg_col2 = Color(0.05, 0.10, 0.13)
	for r in range(7):
		var y_start = row_splits2[r]
		var y_end = row_splits2[r + 1]
		var h = y_end - y_start
		for c in range(12):
			var x_start = int(c * 1024.0 / 12.0)
			var x_end = int((c + 1) * 1024.0 / 12.0)
			var w = x_end - x_start
			
			var sub = img2.get_region(Rect2i(x_start, y_start, w, h))
			_apply_transparency(sub, bg_col2, 0.060)
			sub.save_png("res://assets/faces/face_%d.png" % face_index)
			face_index += 1
			
	print("Sheet 2 achevée : total %d visages générés dans res://assets/faces/" % face_index)
	quit(0)

func _apply_transparency(img: Image, bg_col: Color, tolerance: float) -> void:
	var w = img.get_width()
	var h = img.get_height()
	
	# Flood-fill depuis les 4 bordures
	var visited = []
	visited.resize(w * h)
	visited.fill(false)
	
	var queue: Array[Vector2i] = []
	
	# Enfiler les pixels des 4 bords
	for x in range(w):
		queue.append(Vector2i(x, 0))
		queue.append(Vector2i(x, h - 1))
	for y in range(h):
		queue.append(Vector2i(0, y))
		queue.append(Vector2i(w - 1, y))
		
	var head = 0
	while head < queue.size():
		var pt = queue[head]
		head += 1
		var idx = pt.y * w + pt.x
		if visited[idx]:
			continue
		visited[idx] = true
		
		var p = img.get_pixel(pt.x, pt.y)
		var dr = absf(p.r - bg_col.r)
		var dg = absf(p.g - bg_col.g)
		var db = absf(p.b - bg_col.b)
		var is_bg = (dr < tolerance and dg < tolerance and db < tolerance)
		
		if is_bg:
			img.set_pixel(pt.x, pt.y, Color(0, 0, 0, 0))
			# Voisins 4-connectés
			if pt.x > 0: queue.append(Vector2i(pt.x - 1, pt.y))
			if pt.x < w - 1: queue.append(Vector2i(pt.x + 1, pt.y))
			if pt.y > 0: queue.append(Vector2i(pt.x, pt.y - 1))
			if pt.y < h - 1: queue.append(Vector2i(pt.x, pt.y + 1))
