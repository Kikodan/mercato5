extends SceneTree

func _init() -> void:
	var path1 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774374997.jpg"
	var img1 = Image.new()
	img1.load(path1)
	img1.convert(Image.FORMAT_RGBA8)
	
	var col_w1 = 1024.0 / 14.0
	var row_h1 = 682.0 / 8.0
	var sub = img1.get_region(Rect2i(0, 0, int(col_w1), int(row_h1)))
	
	var bg_col = Color(0.035, 0.095, 0.135)
	for y in sub.get_height():
		for x in sub.get_width():
			var p = sub.get_pixel(x, y)
			var dr = absf(p.r - bg_col.r)
			var dg = absf(p.g - bg_col.g)
			var db = absf(p.b - bg_col.b)
			if dr < 0.04 and dg < 0.04 and db < 0.04:
				sub.set_pixel(x, y, Color(0, 0, 0, 0))
	
	sub.save_png("res://scratch/test_faces/trans_test.png")
	print("Transparent test saved!")
	quit(0)
