extends SceneTree

func _init() -> void:
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	var img2 = Image.new()
	img2.load(path2)
	img2.convert(Image.FORMAT_RGBA8)
	
	var col_w2 = 1024.0 / 12.0
	var row_h2 = 682.0 / 7.0
	var sub = img2.get_region(Rect2i(0, 0, int(col_w2), int(row_h2)))
	
	# Background color
	var bg_col = Color(0.05, 0.10, 0.13)
	for y in sub.get_height():
		for x in sub.get_width():
			var p = sub.get_pixel(x, y)
			var dr = absf(p.r - bg_col.r)
			var dg = absf(p.g - bg_col.g)
			var db = absf(p.b - bg_col.b)
			if dr < 0.05 and dg < 0.05 and db < 0.05:
				sub.set_pixel(x, y, Color(0, 0, 0, 0))
	
	sub.save_png("res://scratch/test_faces/trans_test2.png")
	print("Transparent test 2 saved!")
	quit(0)
