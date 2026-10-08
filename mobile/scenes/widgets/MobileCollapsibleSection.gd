class_name MobileCollapsibleSection
extends VBoxContainer

## Composant mobile accordéon rétractable épuré
## Permet d'afficher/masquer un conteneur d'informations d'un simple toucher tactile.

signal toggled(is_open: bool)

var header_btn: Button
var content_container: VBoxContainer
var chevron_lbl: Label
var title_lbl: Label
var badge_lbl: Label

var is_expanded: bool = true
var section_title: String = ""

func _init(p_title: String = "", p_start_expanded: bool = true) -> void:
	section_title = p_title
	is_expanded = p_start_expanded

	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 4)

	# 1. En-tête tactile (Button cliquable sur toute la largeur)
	header_btn = Button.new()
	header_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_btn.custom_minimum_size.y = 44.0
	header_btn.focus_mode = Control.FOCUS_NONE

	var sb_n = StyleBoxFlat.new()
	sb_n.bg_color = Color(0.08, 0.12, 0.20, 0.95)
	sb_n.border_color = Color(0.22, 0.32, 0.48, 0.70)
	sb_n.set_border_width_all(1)
	sb_n.set_corner_radius_all(8)
	sb_n.content_margin_left = 12
	sb_n.content_margin_right = 12
	sb_n.content_margin_top = 8
	sb_n.content_margin_bottom = 8
	header_btn.add_theme_stylebox_override("normal", sb_n)

	var sb_p = StyleBoxFlat.new()
	sb_p.bg_color = Color(0.12, 0.18, 0.30, 1.0)
	sb_p.border_color = Color("38bdf8")
	sb_p.set_border_width_all(1)
	sb_p.set_corner_radius_all(8)
	sb_p.content_margin_left = 12
	sb_p.content_margin_right = 12
	sb_p.content_margin_top = 8
	sb_p.content_margin_bottom = 8
	header_btn.add_theme_stylebox_override("pressed", sb_p)

	# Contenu visuel dans le bouton
	var hbox = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 8)
	header_btn.add_child(hbox)

	chevron_lbl = Label.new()
	chevron_lbl.text = "▼" if is_expanded else "▶"
	chevron_lbl.add_theme_font_size_override("font_size", 12)
	chevron_lbl.add_theme_color_override("font_color", Color("38bdf8"))
	chevron_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(chevron_lbl)

	title_lbl = Label.new()
	title_lbl.text = section_title
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color("f1f5f9"))
	title_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(title_lbl)

	badge_lbl = Label.new()
	badge_lbl.text = ""
	badge_lbl.add_theme_font_size_override("font_size", 11)
	badge_lbl.add_theme_color_override("font_color", Color("94a3b8"))
	badge_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(badge_lbl)

	header_btn.pressed.connect(toggle)
	add_child(header_btn)

	# 2. Conteneur de contenu rétractable
	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 6)
	content_container.visible = is_expanded
	add_child(content_container)

func set_title(p_title: String) -> void:
	section_title = p_title
	if title_lbl:
		title_lbl.text = p_title

func set_badge(text: String, col: Color = Color("94a3b8")) -> void:
	if badge_lbl:
		badge_lbl.text = text
		badge_lbl.add_theme_color_override("font_color", col)

func add_content(node: Control) -> void:
	content_container.add_child(node)

func clear_content() -> void:
	for c in content_container.get_children():
		c.queue_free()

func toggle() -> void:
	set_expanded(not is_expanded)

func set_expanded(exp: bool) -> void:
	is_expanded = exp
	if content_container:
		content_container.visible = is_expanded
	if chevron_lbl:
		chevron_lbl.text = "▼" if is_expanded else "▶"
	toggled.emit(is_expanded)
