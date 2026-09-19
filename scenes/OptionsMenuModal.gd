class_name OptionsMenuModal
extends Control

signal closed()

var panel: PanelContainer
var slider_vol: HSlider
var lbl_vol_val: Label
var lbl_track_title: Label
var btn_mute: Button
var btn_play_pause: Button
var btn_next: Button
var btn_prev: Button
var btn_close: Button

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	
	if Engine.has_singleton("MusicManager") or get_tree().root.has_node("MusicManager"):
		var mm = _get_music_manager()
		if mm != null:
			mm.track_changed.connect(_on_track_changed)
			mm.volume_changed.connect(_on_volume_changed)

func _get_music_manager() -> Node:
	if is_inside_tree() and get_tree() != null and get_tree().root != null:
		return get_tree().root.get_node_or_null("MusicManager")
	return null

func _build_ui() -> void:
	for c in get_children():
		c.queue_free()
		
	# 1. Overlay sombre
	var overlay = ColorRect.new()
	overlay.color = Color(0.04, 0.06, 0.1, 0.75)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	
	# 2. CenterContainer
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	
	# 3. Panel Container
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 360)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.20, 0.98)
	sb.set_corner_radius_all(14)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.24, 0.35, 0.55)
	sb.content_margin_left = 24
	sb.content_margin_right = 24
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)
	
	# Titre
	var title = Label.new()
	title.text = "⚙️ OPTIONS & VOLUME AUDIO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("facc15"))
	vbox.add_child(title)
	
	vbox.add_child(HSeparator.new())
	
	# Piste en cours
	var track_box = VBoxContainer.new()
	track_box.add_theme_constant_override("separation", 4)
	
	var lbl_now_playing = Label.new()
	lbl_now_playing.text = "🎵 AMBIANCE MUSICALE"
	lbl_now_playing.add_theme_font_size_override("font_size", 13)
	lbl_now_playing.add_theme_color_override("font_color", Color(0.7, 0.78, 0.9))
	track_box.add_child(lbl_now_playing)
	
	lbl_track_title = Label.new()
	lbl_track_title.text = "▶ Piste 1"
	lbl_track_title.add_theme_font_size_override("font_size", 15)
	lbl_track_title.add_theme_color_override("font_color", Color("38bdf8"))
	track_box.add_child(lbl_track_title)
	vbox.add_child(track_box)
	
	# Commandes de lecture
	var ctrl_row = HBoxContainer.new()
	ctrl_row.add_theme_constant_override("separation", 10)
	ctrl_row.alignment = BoxContainer.ALIGNMENT_CENTER
	
	btn_prev = Button.new()
	btn_prev.text = "⏮️ Précédent"
	btn_prev.custom_minimum_size = Vector2(110, 36)
	btn_prev.add_theme_font_size_override("font_size", 13)
	btn_prev.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null: mm.previous_track()
	)
	ctrl_row.add_child(btn_prev)
	
	btn_play_pause = Button.new()
	btn_play_pause.text = "⏯️ Pause"
	btn_play_pause.custom_minimum_size = Vector2(100, 36)
	btn_play_pause.add_theme_font_size_override("font_size", 13)
	btn_play_pause.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null:
			if mm.player.playing:
				mm.pause()
				btn_play_pause.text = "▶️ Lecture"
			else:
				mm.play()
				btn_play_pause.text = "⏸️ Pause"
	)
	ctrl_row.add_child(btn_play_pause)
	
	btn_next = Button.new()
	btn_next.text = "Suivant ⏭️"
	btn_next.custom_minimum_size = Vector2(110, 36)
	btn_next.add_theme_font_size_override("font_size", 13)
	btn_next.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null: mm.next_track()
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
	slider_vol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_vol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider_vol.value_changed.connect(func(v: float):
		var mm = _get_music_manager()
		if mm != null:
			mm.set_volume(v)
		lbl_vol_val.text = "%d%%" % int(v * 100)
		btn_mute.text = "🔇 Muet" if v <= 0.001 else "🔊 Mute"
	)
	slider_box.add_child(slider_vol)
	
	btn_mute = Button.new()
	btn_mute.text = "🔊 Mute"
	btn_mute.custom_minimum_size = Vector2(80, 36)
	btn_mute.add_theme_font_size_override("font_size", 13)
	btn_mute.pressed.connect(func():
		var mm = _get_music_manager()
		if mm != null:
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
	
	# Bouton Fermer
	btn_close = Button.new()
	btn_close.text = "✔ Valider & Fermer"
	btn_close.custom_minimum_size = Vector2(0, 42)
	btn_close.add_theme_font_size_override("font_size", 14)
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(0.12, 0.55, 0.35)
	c_style.set_corner_radius_all(8)
	btn_close.add_theme_stylebox_override("normal", c_style)
	btn_close.pressed.connect(close_modal)
	vbox.add_child(btn_close)

func close_modal() -> void:
	visible = false
	closed.emit()

func open_modal() -> void:
	visible = true
	var mm = _get_music_manager()
	if mm != null:
		slider_vol.value = mm.volume_percent
		lbl_vol_val.text = "%d%%" % int(mm.volume_percent * 100)
		btn_mute.text = "🔇 Sourdine" if mm.is_muted else "🔊 Mute"
		lbl_track_title.text = "▶ %s" % mm.get_current_track_title()
		btn_play_pause.text = "⏸️ Pause" if mm.player.playing else "▶️ Lecture"

func _on_track_changed(t_title: String) -> void:
	if lbl_track_title != null:
		lbl_track_title.text = "▶ %s" % t_title

func _on_volume_changed(v: float) -> void:
	if lbl_vol_val != null:
		lbl_vol_val.text = "%d%%" % int(v * 100)
	if slider_vol != null and absf(slider_vol.value - v) > 0.01:
		slider_vol.value = v
