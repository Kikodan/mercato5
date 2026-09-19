extends Node

signal track_changed(track_title: String)
signal volume_changed(new_volume: float)

const TRACK_PATHS = [
	"res://assets/music/track_1.mp3",
	"res://assets/music/track_2.mp3",
	"res://assets/music/track_3.mp3"
]

const TRACK_TITLES = [
	"Mercato Groove (Piste 1)",
	"Urban Futsal (Piste 2)",
	"Matchday Flow (Piste 3)"
]

const SETTINGS_PATH = "user://audio_settings.json"

var player: AudioStreamPlayer
var current_track_index: int = 0
var volume_percent: float = 0.50
var is_muted: bool = false
var has_interacted: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	player = AudioStreamPlayer.new()
	player.bus = "Master"
	add_child(player)
	player.finished.connect(_on_track_finished)
	
	_load_settings()
	_apply_volume()
	
	# Lancer la première piste dès que possible
	_load_and_play_track(current_track_index)

func _input(event: InputEvent) -> void:
	# Déblocage de la politique Audio sur les navigateurs Web (Safari iOS & Chrome)
	if not has_interacted and (event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey):
		if event.is_pressed():
			has_interacted = true
			if not is_muted and not player.playing:
				player.play()

func _load_and_play_track(idx: int) -> void:
	current_track_index = posmod(idx, TRACK_PATHS.size())
	var path = TRACK_PATHS[current_track_index]
	if ResourceLoader.exists(path):
		var stream = load(path)
		if stream is AudioStream:
			player.stream = stream
			if not is_muted:
				player.play()
			track_changed.emit(get_current_track_title())

func _on_track_finished() -> void:
	next_track()

func play() -> void:
	if not player.playing:
		player.play()

func pause() -> void:
	if player.playing:
		player.stop()

func next_track() -> void:
	_load_and_play_track(current_track_index + 1)

func previous_track() -> void:
	_load_and_play_track(current_track_index - 1)

func get_current_track_title() -> String:
	return TRACK_TITLES[current_track_index]

func set_volume(val: float) -> void:
	volume_percent = clampf(val, 0.0, 1.0)
	is_muted = (volume_percent <= 0.001)
	_apply_volume()
	_save_settings()
	volume_changed.emit(volume_percent)

func toggle_mute() -> bool:
	is_muted = not is_muted
	_apply_volume()
	_save_settings()
	return is_muted

func _apply_volume() -> void:
	if is_muted or volume_percent <= 0.001:
		player.volume_db = -80.0
	else:
		player.volume_db = linear_to_db(volume_percent)

func _save_settings() -> void:
	var f = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f != null:
		var d = {
			"volume_percent": volume_percent,
			"is_muted": is_muted
		}
		f.store_string(JSON.stringify(d))
		f.close()

func _load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var f = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if f != null:
			var json = JSON.new()
			if json.parse(f.get_as_text()) == OK and json.data is Dictionary:
				volume_percent = float(json.data.get("volume_percent", 0.50))
				is_muted = bool(json.data.get("is_muted", false))
			f.close()
