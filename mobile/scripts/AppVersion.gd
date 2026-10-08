class_name AppVersion
extends RefCounted

const VERSION_STRING: String = "v1.2.1"
const FALLBACK_COMMIT: String = "045fcc8"
const RELEASE_DATE: String = "2026-09-22"

enum GitState {
	SYNCED,         # 🟢 Synchronisé avec Git / commit propre
	LOCAL_MODIFIED, # 🟡 Modifications locales non commitées (dev)
	OUTDATED        # 🔴 Version obsolète ou divergente
}

static func get_git_info() -> Dictionary:
	var commit_hash = FALLBACK_COMMIT
	var state = GitState.SYNCED
	var state_label = "Synchronisé"
	var state_color = Color("10b981") # Vert émeraude

	# Tenter une détection dynamique si disponible (Desktop / Éditeur)
	if OS.has_feature("editor") or OS.has_feature("pc"):
		var output: Array = []
		var err_status = OS.execute("git", ["status", "--porcelain"], output, true)
		if err_status == 0:
			var status_str = "".join(output).strip_edges()
			if not status_str.is_empty():
				state = GitState.LOCAL_MODIFIED
				state_label = "Modifié (dev)"
				state_color = Color("f59e0b") # Orange / Ambre

			var commit_output: Array = []
			var err_commit = OS.execute("git", ["rev-parse", "--short", "HEAD"], commit_output, true)
			if err_commit == 0 and not commit_output.is_empty():
				commit_hash = "".join(commit_output).strip_edges()

	return {
		"version": VERSION_STRING,
		"commit": commit_hash,
		"state": state,
		"state_label": state_label,
		"color": state_color,
		"release_date": RELEASE_DATE
	}

static func create_version_badge(compact: bool = false) -> PanelContainer:
	var info = get_git_info()

	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.09, 0.15, 0.85)
	style.set_corner_radius_all(6)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(info["color"].r, info["color"].g, info["color"].b, 0.5)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	panel.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Pastille lumineuse couleur Git
	var dot_lbl = Label.new()
	dot_lbl.text = "●"
	dot_lbl.add_theme_color_override("font_color", info["color"])
	dot_lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(dot_lbl)

	# Texte de version
	var ver_lbl = Label.new()
	if compact:
		ver_lbl.text = "%s [%s]" % [info["version"], info["commit"]]
	else:
		ver_lbl.text = "%s • %s • %s" % [info["version"], info["commit"], info["state_label"]]
	ver_lbl.add_theme_color_override("font_color", Color("cbd5e1"))
	ver_lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(ver_lbl)

	panel.add_child(hbox)
	panel.tooltip_text = "Mercato 5 — Version %s\nCommit Git : %s\nÉtat : %s\nDate : %s" % [
		info["version"], info["commit"], info["state_label"], info["release_date"]
	]
	return panel
