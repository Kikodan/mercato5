extends SceneTree

func _init() -> void:
	var path1 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774374997.jpg"
	var path2 = "C:/Users/View37/.gemini/antigravity/brain/e0c872b4-d97e-408b-91f2-2fa51579621d/.user_uploaded/media_1789774375040.jpg"
	
	var img1 = Image.new()
	var err1 = img1.load(path1)
	print("img1 load err:", err1, "size:", img1.get_size() if err1 == OK else "N/A")
	
	var img2 = Image.new()
	var err2 = img2.load(path2)
	print("img2 load err:", err2, "size:", img2.get_size() if err2 == OK else "N/A")
	
	quit(0)
