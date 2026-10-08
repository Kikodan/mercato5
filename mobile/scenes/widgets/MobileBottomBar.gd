class_name MobileBottomBar
extends PanelContainer

signal advance_requested()
signal save_requested()

var btn_advance: Button
var btn_save: Button

func _init() -> void:
	custom_minimum_size.y = 70.0
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.08, 0.14, 0.98)
	sb.border_color = Color(0.18, 0.24, 0.36, 0.90)
	sb.set_border_width_all(1)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	add_theme_stylebox_override("panel", sb)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	add_child(hbox)

	btn_save = Button.new()
	btn_save.custom_minimum_size = Vector2(56, 52)
	btn_save.text = "💾"
	btn_save.tooltip_text = "Sauvegarder la partie"
	var sb_btn_save = StyleBoxFlat.new()
	sb_btn_save.bg_color = Color(0.12, 0.18, 0.28, 0.90)
	sb_btn_save.border_color = Color(0.28, 0.38, 0.55, 0.80)
	sb_btn_save.set_border_width_all(1)
	sb_btn_save.set_corner_radius_all(8)
	btn_save.add_theme_stylebox_override("normal", sb_btn_save)
	btn_save.pressed.connect(func(): save_requested.emit())
	hbox.add_child(btn_save)

	btn_advance = Button.new()
	btn_advance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_advance.custom_minimum_size.y = 52.0
	btn_advance.text = "Passer au jour suivant ➡️"
	btn_advance.add_theme_font_size_override("font_size", 15)

	var sb_adv = StyleBoxFlat.new()
	sb_adv.bg_color = Color(0.08, 0.50, 0.35, 0.95)
	sb_adv.border_color = Color("34d399")
	sb_adv.set_border_width_all(2)
	sb_adv.set_corner_radius_all(10)
	btn_advance.add_theme_stylebox_override("normal", sb_adv)

	var sb_adv_p = StyleBoxFlat.new()
	sb_adv_p.bg_color = Color(0.06, 0.40, 0.28, 1.0)
	sb_adv_p.border_color = Color("10b981")
	sb_adv_p.set_border_width_all(2)
	sb_adv_p.set_corner_radius_all(10)
	btn_advance.add_theme_stylebox_override("pressed", sb_adv_p)

	btn_advance.pressed.connect(func(): advance_requested.emit())
	hbox.add_child(btn_advance)

func set_advance_text(text: String, is_match_day: bool = false, is_end_week: bool = false) -> void:
	btn_advance.text = text
	var sb = StyleBoxFlat.new()
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)

	if is_match_day:
		sb.bg_color = Color(0.80, 0.25, 0.15, 0.95)
		sb.border_color = Color("f87171")
		btn_advance.add_theme_color_override("font_color", Color.WHITE)
	elif is_end_week:
		sb.bg_color = Color(0.65, 0.45, 0.08, 0.95)
		sb.border_color = Color("facc15")
		btn_advance.add_theme_color_override("font_color", Color("fef08a"))
	else:
		sb.bg_color = Color(0.08, 0.50, 0.35, 0.95)
		sb.border_color = Color("34d399")
		btn_advance.add_theme_color_override("font_color", Color.WHITE)

	btn_advance.add_theme_stylebox_override("normal", sb)
