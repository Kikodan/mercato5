extends SceneTree

func _init():
	print("--- RENDERING / GUI / FONT SETTINGS ---")
	for prop in ProjectSettings.get_property_list():
		if prop.name.begins_with("gui/theme") or prop.name.begins_with("rendering/2d") or "font" in prop.name or "subpixel" in prop.name or "msdf" in prop.name or "filter" in prop.name:
			print(prop.name, " = ", ProjectSettings.get_setting(prop.name))
	quit(0)
