extends SceneTree

func _init():
	print("--- DISPLAY SETTINGS IN GODOT 4 ---")
	for prop in ProjectSettings.get_property_list():
		if prop.name.begins_with("display/window"):
			print(prop.name, " = ", ProjectSettings.get_setting(prop.name))
		if prop.name.begins_with("rendering/textures"):
			print(prop.name, " = ", ProjectSettings.get_setting(prop.name))
		if "hidpi" in prop.name or "dpi" in prop.name:
			print(prop.name, " = ", ProjectSettings.get_setting(prop.name))
	quit(0)
