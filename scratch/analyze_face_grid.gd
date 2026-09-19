extends SceneTree

func _init() -> void:
	var path1 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774374997.jpg"
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	
	var img1 = Image.new()
	img1.load(path1)
	var bg_color1 = img1.get_pixel(5, 5)
	print("img1 bg_color:", bg_color1.to_html(false))
	
	var img2 = Image.new()
	img2.load(path2)
	var bg_color2 = img2.get_pixel(5, 5)
	print("img2 bg_color:", bg_color2.to_html(false))
	
	# Check dimensions
	# In img1 (1024 x 682), if 14 cols, 1024 / 14 = ~73.14 px per col
	# If 8 rows, 682 / 8 = ~85.25 px per row
	print("img1 estimated cell: ", 1024.0 / 14.0, "x", 682.0 / 8.0)
	
	# In img2 (1024 x 682), if 12 cols, 1024 / 12 = ~85.33 px per col
	# If 7 rows, 682 / 7 = ~97.43 px per row
	print("img2 estimated cell: ", 1024.0 / 12.0, "x", 682.0 / 7.0)
	
	quit(0)
