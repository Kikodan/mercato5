extends SceneTree

func _init() -> void:
	var path1 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774374997.jpg"
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	
	var img1 = Image.new()
	img1.load(path1)
	
	# Sample several background points around edges
	print("img1 (0,0):", img1.get_pixel(0, 0))
	print("img1 (512, 0):", img1.get_pixel(512, 0))
	print("img1 (1023, 681):", img1.get_pixel(1023, 681))
	
	var img2 = Image.new()
	img2.load(path2)
	print("img2 (0,0):", img2.get_pixel(0, 0))
	print("img2 (512, 0):", img2.get_pixel(512, 0))
	print("img2 (1023, 681):", img2.get_pixel(1023, 681))
	
	quit(0)
