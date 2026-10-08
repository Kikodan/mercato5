class_name MobileOptionsMenuModal
extends Control

## Modale d'options mobile tactile (roulette d'options comme sur PC)
## Contrôle du volume, de la musique et accès aux réglages globaux.

signal closed()
signal return_to_main_menu_requested()

var panel: PanelContainer
var slider_vol: HSlider
var lbl_vol_val: Label
var lbl_track_title: Label
var btn_mute: Button
var btn_play_pause: Button
var btn_next: Button
var btn_prev: Button
var btn_close: Button
var btn_main_menu: Button

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

	var mm = _get_music_manager()
	if mm != null:
		if mm.has_signal("track_changed") and not mm.track_changed.is_connected(_on_track_changed):
			mm.track_changed.connect(_on_track_changed)
		if mm.has_signal("volume_changed") and not mm.volume_changed.is_connected(_on_volume_changed):
			mm.volume_changed.connect(_on_volume_changed)

func _get_music_manager() -> Node:
	if is_inside_tree() and get_tree() != null and get_tree().root != null:
		return get_tree().root.get_node_or_null("MusicManager")
	return null

func _build_ui() -> void:
	for c in get_children():
		c.queue_free()

	# 1. Overlay assombri tactile
	var overlay = ColorRect.new()
	overlay.color = Color(0.04, 0.06, 0.11, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# 2. Centreur vertical
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	# 3. Boîtier de modale adapté aux smartphones (largeur 600px max sur 720px)
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 480)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.07, 0.11, 0.19, 0.98)
	sb.set_corner_radius_all(16)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color("38bdf8")
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 24
	sb.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	# Titre avec icône roulette ⚙️
	var title = Label.new()
	title.text = "⚙️ OPTIONS & AMBIANCE AUDIO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("facc15"))
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	# Piste en cours
	var track_box = VBoxContainer.new()
	track_box.add_theme_constant_override("separation", 4)

	var lbl_now_playing = Label.new()
	lbl_now_playing.text = "🎵 PISTE MUSICALE EN COURS :"
	lbl_now_playing.add_theme_font_size_override("font_size", 12)
	lbl_now_playing.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	track_box.add_child(lbl_now_playing)

	lbl_track_title = Label.new()
	lbl_track_title.text = "▶ Piste 1"
	lbl_track_title.add_theme_font_size_override("font_size", 15)
	lbl_track_title.add_theme_color_override("font_color", Color("38bdf8"))
	track_box.add_child(lbl_track_title)
	vbox.add_child(track_box)

	# Commandes de lecture (grands boutons tactiles min 48px)
	var ctrl_row = HBoxContainer.new()
	ctrl_row.add_theme_constant_override("separation", 10)
	ctrl_row.alignment = BoxContainer.ALIGNMENT_CENTER

	btn_prev = _create_touch_btn("⏮️ Précédent", Vector2(130, 48))
	btn_prev.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null and mm.has_method("previous_track"):
			mm.previous_track()
	)
	ctrl_row.add_child(btn_prev)

	btn_play_pause = _create_touch_btn("⏯️ Pause", Vector2(130, 48))
	btn_play_pause.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null:
			if mm.player and mm.player.playing:
				mm.pause()
				btn_play_pause.text = "▶️ Lecture"
			else:
				mm.play()
				btn_play_pause.text = "⏸️ Pause"
	)
	ctrl_row.add_child(btn_play_pause)

	btn_next = _create_touch_btn("Suivant ⏭️", Vector2(130, 48))
	btn_next.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null and mm.has_method("next_track"):
			mm.next_track()
	)
	ctrl_row.add_child(btn_next)

	vbox.add_child(ctrl_row)

	# Slider Volume
	var vol_row_lbl = HBoxContainer.new()
	var l_vol = Label.new()
	l_vol.text = "Volume de la musique :"
	l_vol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l_vol.add_theme_font_size_override("font_size", 14)
	vol_row_lbl.add_child(l_vol)

	lbl_vol_val = Label.new()
	lbl_vol_val.text = "50%"
	lbl_vol_val.add_theme_font_size_override("font_size", 16)
	lbl_vol_val.add_theme_color_override("font_color", Color("facc15"))
	vol_row_lbl.add_child(lbl_vol_val)
	vbox.add_child(vol_row_lbl)

	var slider_box = HBoxContainer.new()
	slider_box.add_theme_constant_override("separation", 12)

	slider_vol = HSlider.new()
	slider_vol.min_value = 0.0
	slider_vol.max_value = 1.0
	slider_vol.step = 0.05
	slider_vol.value = 0.50
	slider_vol.custom_minimum_size.y = 40.0
	slider_vol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_vol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider_vol.value_changed.connect(func(v: float):
		var mm = _get_music_manager()
		if mm != null and mm.has_method("set_volume"):
			mm.set_volume(v)
		lbl_vol_val.text = "%d%%" % int(v * 100)
		btn_mute.text = "🔇 Muet" if v <= 0.001 else "🔊 Mute"
	)
	slider_box.add_child(slider_vol)

	btn_mute = _create_touch_btn("🔊 Mute", Vector2(90, 44))
	btn_mute.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null and mm.has_method("toggle_mute"):
			var muted = mm.toggle_mute()
			btn_mute.text = "🔇 Sourdine" if muted else "🔊 Mute"
			if muted:
				lbl_vol_val.text = "0% (Muet)"
			else:
				lbl_vol_val.text = "%d%%" % int(mm.volume_percent * 100)
	)
	slider_box.add_child(btn_mute)
	vbox.add_child(slider_box)

	vbox.add_child(HSeparator.new())

	# Boutons d'action : Menu principal & Fermer
	var actions_box = VBoxContainer.new()
	actions_box.add_theme_constant_override("separation", 10)

	btn_main_menu = Button.new()
	btn_main_menu.text = "🏠 Revenir au Menu Principal"
	btn_main_menu.custom_minimum_size.y = 48.0
	btn_main_menu.add_theme_font_size_override("font_size", 14)
	var mm_style = StyleBoxFlat.new()
	mm_style.bg_color = Color(0.18, 0.24, 0.38, 0.90)
	mm_style.border_color = Color(0.35, 0.45, 0.65)
	mm_style.set_border_width_all(1)
	mm_style.set_corner_radius_all(10)
	btn_main_menu.add_theme_stylebox_override("normal", mm_style)
	btn_main_menu.pressed.connect(func():
		close_modal()
		return_to_main_menu_requested.emit()
	)
	actions_box.add_child(btn_main_menu)

	btn_close = Button.new()
	btn_close.text = "✔ Valider & Fermer"
	btn_close.custom_minimum_size.y = 50.0
	btn_close.add_theme_font_size_override("font_size", 15)
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(0.10, 0.52, 0.34, 0.95)
	c_style.border_color = Color("34d399")
	c_style.set_border_width_all(1)
	c_style.set_corner_radius_all(10)
	btn_close.add_theme_stylebox_override("normal", c_style)
	btn_close.pressed.connect(close_modal)
	actions_box.add_child(btn_close)

	vbox.add_child(actions_box)

func _create_touch_btn(text: String, min_size: Vector2) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size", 13)
	b.focus_mode = Control.FOCUS_NONE

	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.18, 0.28, 0.90)
	sb.border_color = Color(0.28, 0.38, 0.55, 0.80)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(8)
	b.add_theme_stylebox_override("normal", sb)

	var sbp = StyleBoxFlat.new()
	sbp.bg_color = Color(0.18, 0.26, 0.40, 1.0)
	sbp.border_color = Color("38bdf8")
	sbp.set_border_width_all(2)
	sbp.set_corner_radius_all(8)
	b.add_theme_stylebox_override("pressed", sbp)

	return b

func close_modal() -> void:
	visible = false
	closed.emit()

func open_modal(show_main_menu_btn: bool = true) -> void:
	visible = true
	if btn_main_menu:
		btn_main_menu.visible = show_main_menu_btn
	var mm = _get_music_manager()
	if mm != null:
		slider_vol.value = mm.volume_percent
		lbl_vol_val.text = "%d%%" % int(mm.volume_percent * 100)
		btn_mute.text = "🔇 Sourdine" if mm.is_muted else "🔊 Mute"
		if mm.has_method("get_current_track_title"):
			lbl_track_title.text = "▶ %s" % mm.get_current_track_title()
		if mm.player:
			btn_play_pause.text = "⏸️ Pause" if mm.player.playing else "▶️ Lecture"

func _on_track_changed(t_title: String) -> void:
	if lbl_track_title != null:
		lbl_track_title.text = "▶ %s" % t_title

func _on_volume_changed(v: float) -> void:
	if lbl_vol_val != null:
		lbl_vol_val.text = "%d%%" % int(v * 100)
	if slider_vol != null and absf(slider_vol.value - v) > 0.01:
		slider_vol.value = v
