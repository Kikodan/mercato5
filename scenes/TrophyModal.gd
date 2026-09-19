class_name TrophyModal
extends Control

signal trophy_acknowledged

const ClubBadge = preload("res://scripts/ClubBadge.gd")

var panel_bg: PanelContainer
var lbl_title: Label
var trophy_icon: Label
var badge: ClubBadge
var lbl_champion_name: Label
var lbl_score: Label
var lbl_message: Label
var btn_continue: Button

enum TrophyType { LEAGUE, EUROPEAN }
var current_type: TrophyType = TrophyType.LEAGUE

func _init() -> void:
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index = 60
	_build_ui()

func _ready() -> void:
	if lbl_title == null:
		_build_ui()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.05, 0.08, 0.96)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel_bg = PanelContainer.new()
	panel_bg.custom_minimum_size = Vector2(650, 480)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.10, 0.16, 0.98)
	style.set_corner_radius_all(16)
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.95, 0.78, 0.25, 0.9) # Gold border
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 28
	style.content_margin_bottom = 28
	panel_bg.add_theme_stylebox_override("panel", style)
	center.add_child(panel_bg)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_bg.add_child(vbox)

	trophy_icon = Label.new()
	trophy_icon.text = "🏆"
	trophy_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	trophy_icon.add_theme_font_size_override("font_size", 54)
	vbox.add_child(trophy_icon)

	lbl_title = Label.new()
	lbl_title.text = "👑 SACRE DU CHAMPION 👑"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 22)
	lbl_title.add_theme_color_override("font_color", Color(0.98, 0.85, 0.3))
	vbox.add_child(lbl_title)

	# Badge container
	var badge_center = CenterContainer.new()
	badge = ClubBadge.new()
	badge.custom_minimum_size = Vector2(70, 70)
	badge_center.add_child(badge)
	vbox.add_child(badge_center)

	lbl_champion_name = Label.new()
	lbl_champion_name.text = "NOM DU CLUB"
	lbl_champion_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_champion_name.add_theme_font_size_override("font_size", 26)
	lbl_champion_name.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	vbox.add_child(lbl_champion_name)

	lbl_score = Label.new()
	lbl_score.text = "Score Finale : 7 - 4"
	lbl_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_score.add_theme_font_size_override("font_size", 15)
	lbl_score.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	vbox.add_child(lbl_score)

	lbl_message = Label.new()
	lbl_message.text = "Félicitations au nouveau champion !"
	lbl_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_message.add_theme_font_size_override("font_size", 13)
	lbl_message.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))
	vbox.add_child(lbl_message)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	btn_continue = Button.new()
	btn_continue.text = "Continuer >"
	btn_continue.custom_minimum_size = Vector2(280, 44)
	btn_continue.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var b_style = StyleBoxFlat.new()
	b_style.bg_color = Color(0.12, 0.55, 0.35)
	b_style.set_corner_radius_all(8)
	btn_continue.add_theme_stylebox_override("normal", b_style)
	var b_hov = b_style.duplicate()
	b_hov.bg_color = Color(0.15, 0.68, 0.42)
	btn_continue.add_theme_stylebox_override("hover", b_hov)
	btn_continue.add_theme_font_size_override("font_size", 15)
	btn_continue.pressed.connect(func():
		visible = false
		trophy_acknowledged.emit()
	)
	vbox.add_child(btn_continue)

func show_league_champion(champion: Club, loser: Club, score_h: int, score_a: int, is_user: bool, league_name: String) -> void:
	current_type = TrophyType.LEAGUE
	visible = true

	lbl_title.text = "👑 CHAMPION OFFICIEL • %s 👑" % league_name.to_upper()
	lbl_champion_name.text = champion.club_name.to_upper()

	badge.shape = champion.badge_shape
	badge.symbol = champion.badge_symbol
	badge.primary_color = champion.primary_color
	badge.secondary_color = champion.secondary_color
	badge.queue_redraw()

	lbl_score.text = "Grande Finale des Playoffs : %s %d - %d %s" % [champion.club_name, max(score_h, score_a), min(score_h, score_a), loser.club_name]

	if is_user:
		lbl_message.text = "🏆 GLOIRE ÉTERNELLE ! Votre club monte sur le toit de la ligue !\nPrime de champion attribuée (+100 000 €)."
		lbl_message.add_theme_color_override("font_color", Color(0.98, 0.85, 0.3))
	else:
		lbl_message.text = "%s triomphe lors des playoffs et décroche le bouclier de champion !" % champion.club_name
		lbl_message.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))

	btn_continue.text = "🏆 Accéder à la Coupe d'Europe >"

func show_european_champion(champion: Club, loser: Club, score_text: String, is_user: bool) -> void:
	current_type = TrophyType.EUROPEAN
	visible = true

	lbl_title.text = "🌍 VAINQUEUR DE LA COUPE D'EUROPE 🌍"
	lbl_champion_name.text = champion.club_name.to_upper()

	badge.shape = champion.badge_shape
	badge.symbol = champion.badge_symbol
	badge.primary_color = champion.primary_color
	badge.secondary_color = champion.secondary_color
	badge.queue_redraw()

	lbl_score.text = "Finale Européenne : %s %s %s" % [champion.club_name, score_text, loser.club_name]

	if is_user:
		lbl_message.text = "🌟 HISTORIQUE ! Votre club remporte la plus prestigieuse des compétitions européennes !\nPrime de victoire européenne (+250 000 €)."
		lbl_message.add_theme_color_override("font_color", Color(0.98, 0.85, 0.3))
	else:
		lbl_message.text = "%s soulève la Coupe d'Europe au terme d'une finale épique !" % champion.club_name
		lbl_message.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9))

	btn_continue.text = "🏁 Bilan de Saison & Nouvelle Saison >"
