class_name MobileTopBar
extends PanelContainer

signal day_selected(day_idx: int)

const Club = preload("res://scripts/Club.gd")
const ClubBadge = preload("res://scripts/ClubBadge.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")

var badge: ClubBadge
var lbl_club_name: Label
var lbl_div: Label
var lbl_budget: Label
var day_buttons: Array[Button] = []

const DAYS_NAMES = ["LUN", "MAR", "MER", "JEU", "VEN", "SAM", "DIM"]
const DAYS_DESC = ["Effectif", "Mercato", "Mercato", "Tactique", "Tactique", "Match", "Économie"]

func _init() -> void:
	custom_minimum_size.y = 110.0
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.09, 0.16, 0.98)
	sb.border_color = Color(0.18, 0.24, 0.36, 0.90)
	sb.set_border_width_all(1)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	add_theme_stylebox_override("panel", sb)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	add_child(main_vbox)

	# Ligne 1 : Info Club & Budget
	var top_hbox = HBoxContainer.new()
	top_hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	main_vbox.add_child(top_hbox)

	badge = ClubBadge.new()
	badge.custom_minimum_size = Vector2(36, 36)
	top_hbox.add_child(badge)

	var name_box = VBoxContainer.new()
	name_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(name_box)

	lbl_club_name = Label.new()
	lbl_club_name.text = "Club"
	lbl_club_name.add_theme_font_size_override("font_size", 16)
	lbl_club_name.add_theme_color_override("font_color", Color("f1f5f9"))
	name_box.add_child(lbl_club_name)

	lbl_div = Label.new()
	lbl_div.text = "Division 1"
	lbl_div.add_theme_font_size_override("font_size", 11)
	lbl_div.add_theme_color_override("font_color", Color("94a3b8"))
	name_box.add_child(lbl_div)

	var budget_box = VBoxContainer.new()
	budget_box.alignment = BoxContainer.ALIGNMENT_END
	top_hbox.add_child(budget_box)

	var lbl_b_title = Label.new()
	lbl_b_title.text = "TRÉSORERIE"
	lbl_b_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_b_title.add_theme_font_size_override("font_size", 9)
	lbl_b_title.add_theme_color_override("font_color", Color("94a3b8"))
	budget_box.add_child(lbl_b_title)

	lbl_budget = Label.new()
	lbl_budget.text = "150 000 €"
	lbl_budget.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_budget.add_theme_font_size_override("font_size", 15)
	lbl_budget.add_theme_color_override("font_color", Color("34d399"))
	budget_box.add_child(lbl_budget)

	# Ligne 2 : Bandeau des 7 Jours de la Semaine
	var days_hbox = HBoxContainer.new()
	days_hbox.add_theme_constant_override("separation", 4)
	days_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(days_hbox)

	for i in range(7):
		var btn = Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size.y = 38.0
		btn.text = "%s\n%s" % [DAYS_NAMES[i], DAYS_DESC[i]]
		btn.add_theme_font_size_override("font_size", 9)
		btn.focus_mode = Control.FOCUS_NONE
		var day_idx = i
		btn.pressed.connect(func(): day_selected.emit(day_idx))
		days_hbox.add_child(btn)
		day_buttons.append(btn)

func setup_club(p_club: Club, p_div_name: String = "") -> void:
	if p_club == null:
		return
	badge.shape = p_club.badge_shape
	badge.symbol = p_club.badge_symbol
	badge.primary_color = p_club.primary_color
	badge.secondary_color = p_club.secondary_color
	badge.queue_redraw()

	lbl_club_name.text = p_club.club_name
	lbl_div.text = ("D%d • %s" % [p_club.division, p_club.country]) if p_div_name.is_empty() else p_div_name
	update_budget(p_club.budget)

func update_budget(amount: int) -> void:
	if lbl_budget:
		lbl_budget.text = "%s €" % FormatUtils.format_number(amount)

func set_active_day(current_day_idx: int) -> void:
	for i in range(day_buttons.size()):
		var b = day_buttons[i]
		var is_active = (i == current_day_idx)
		var is_past = (i < current_day_idx)

		var sb = StyleBoxFlat.new()
		sb.set_corner_radius_all(4)
		if is_active:
			sb.bg_color = Color(0.98, 0.80, 0.08, 0.25)
			sb.border_color = Color("facc15")
			sb.set_border_width_all(2)
			b.add_theme_color_override("font_color", Color("facc15"))
		elif is_past:
			sb.bg_color = Color(0.08, 0.12, 0.20, 0.80)
			sb.border_color = Color(0.20, 0.28, 0.40, 0.40)
			sb.set_border_width_all(1)
			b.add_theme_color_override("font_color", Color("64748b"))
		else:
			sb.bg_color = Color(0.08, 0.12, 0.22, 0.90)
			sb.border_color = Color(0.25, 0.35, 0.50, 0.60)
			sb.set_border_width_all(1)
			b.add_theme_color_override("font_color", Color("e2e8f0"))
		b.add_theme_stylebox_override("normal", sb)

func update_header(p_club: Club, current_day_idx: int) -> void:
	setup_club(p_club)
	set_active_day(current_day_idx)
