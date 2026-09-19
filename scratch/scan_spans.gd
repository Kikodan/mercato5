extends SceneTree

func _init() -> void:
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	var img2 = Image.new()
	img2.load(path2)
	
	var bg_col2 = Color(0.05, 0.10, 0.13)
	var col_center_x = int(1024.0 / 12.0 * 0.5)
	print("Scanning img2 col_center_x = %d" % col_center_x)
	var in_face = false
	var start_y = -1
	for y in img2.get_height():
		var p = img2.get_pixel(col_center_x, y)
		var dr = absf(p.r - bg_col2.r)
		var dg = absf(p.g - bg_col2.g)
		var db = absf(p.b - bg_col2.b)
		var is_bg = (dr < 0.05 and dg < 0.05 and db < 0.05)
		if not is_bg and not in_face:
			in_face = true
			start_y = y
		elif is_bg and in_face:
			in_face = false
			print("Img2 face vertical span: y=%d to %d (height=%d)" % [start_y, y, y - start_y])
			
	quit(0)
