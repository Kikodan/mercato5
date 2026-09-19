extends SceneTree

func _init() -> void:
	var path1 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774374997.jpg"
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	
	DirAccess.make_dir_absolute("res://scratch/test_faces")
	
	var img1 = Image.new()
	img1.load(path1)
	
	var col_w1 = 1024.0 / 14.0
	var row_h1 = 682.0 / 8.0
	
	for r in 2:
		for c in 3:
			var x = int(c * col_w1)
			var y = int(r * row_h1)
			var w = int(col_w1)
			var h = int(row_h1)
			var sub = img1.get_region(Rect2i(x, y, w, h))
			sub.save_png("res://scratch/test_faces/sheet1_r%d_c%d.png" % [r, c])
	
	var img2 = Image.new()
	img2.load(path2)
	var col_w2 = 1024.0 / 12.0
	var row_h2 = 682.0 / 7.0
	for r in 2:
		for c in 3:
			var x = int(c * col_w2)
			var y = int(r * row_h2)
			var w = int(col_w2)
			var h = int(row_h2)
			var sub = img2.get_region(Rect2i(x, y, w, h))
			sub.save_png("res://scratch/test_faces/sheet2_r%d_c%d.png" % [r, c])
			
	print("Test faces saved!")
	quit(0)
