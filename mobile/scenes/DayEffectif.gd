class_name DayEffectif
extends VBoxContainer

const Club = preload("res://scripts/Club.gd")
const Player = preload("res://scripts/Player.gd")
const MobilePlayerCard = preload("res://scenes/widgets/MobilePlayerCard.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")

var club: Club = null
var scroll: ScrollContainer
var list_container: VBoxContainer
var lbl_title: Label

signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 10)

	# Titre & Statistiques d'effectif
	var header_panel = PanelContainer.new()
	var sb_h = StyleBoxFlat.new()
	sb_h.bg_color = Color(0.08, 0.12, 0.20, 0.95)
	sb_h.border_color = Color(0.20, 0.28, 0.42, 0.8)
	sb_h.set_border_width_all(1)
	sb_h.set_corner_radius_all(8)
	sb_h.content_margin_left = 12
	sb_h.content_margin_right = 12
	sb_h.content_margin_top = 8
	sb_h.content_margin_bottom = 8
	header_panel.add_theme_stylebox_override("panel", sb_h)
	add_child(header_panel)

	var hbox_t = HBoxContainer.new()
	header_panel.add_child(hbox_t)

	lbl_title = Label.new()
	lbl_title.text = "📋 EFFECTIF DU CLUB"
	lbl_title.add_theme_font_size_override("font_size", 14)
	lbl_title.add_theme_color_override("font_color", Color("facc15"))
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_t.add_child(lbl_title)

	var lbl_help = Label.new()
	lbl_help.text = "Lundi : Bilan & Contrats"
	lbl_help.add_theme_font_size_override("font_size", 11)
	lbl_help.add_theme_color_override("font_color", Color("94a3b8"))
	hbox_t.add_child(lbl_help)

	# Liste avec défilement
	scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_theme_constant_override("separation", 6)
	scroll.add_child(list_container)

func setup(p_club: Club) -> void:
	club = p_club
	refresh_view()

func refresh_view() -> void:
	if club == null:
		return

	for child in list_container.get_children():
		child.queue_free()

	lbl_title.text = "📋 EFFECTIF DU CLUB (%d/32)" % club.squad.size()

	# Section 1 : Titulaires du 5 majeur
	var header_starters = _create_section_label("🟢 5 DE DÉPART ALIGNÉ", Color("34d399"))
	list_container.add_child(header_starters)

	for p in club.starting_five:
		var card = MobilePlayerCard.new()
		card.setup(p, true, true, true)
		card.transfer_list_toggled.connect(_on_transfer_list_toggled)
		card.renew_requested.connect(_on_renew_requested)
		card.detail_requested.connect(_on_detail_requested)
		list_container.add_child(card)

	# Section 2 : Remplaçants et réserve
	var bench_count = club.squad.size() - club.starting_five.size()
	var header_bench = _create_section_label("🪑 REMPLAÇANTS & RÉSERVE (%d)" % bench_count, Color("94a3b8"))
	list_container.add_child(header_bench)

	for p in club.squad:
		if not club.starting_five.has(p):
			var card = MobilePlayerCard.new()
			card.setup(p, false, true, true)
			card.transfer_list_toggled.connect(_on_transfer_list_toggled)
			card.renew_requested.connect(_on_renew_requested)
			card.detail_requested.connect(_on_detail_requested)
			list_container.add_child(card)

func _create_section_label(text: String, col: Color) -> PanelContainer:
	var pc = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.04, 0.07, 0.12, 0.90)
	sb.content_margin_left = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	pc.add_theme_stylebox_override("panel", sb)

	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", col)
	pc.add_child(l)
	return pc

func _on_transfer_list_toggled(p: Player) -> void:
	p.is_transfer_listed = not p.is_transfer_listed
	refresh_view()
	data_changed.emit()

func _on_renew_requested(p: Player) -> void:
	# Prolongation simplifiée mobile : 2 ans de plus, prime = 10% valeur
	var prime = int(p.market_value * 0.10)
	if club.budget < prime:
		_show_popup("Budget insuffisant", "Il vous faut %s € de prime pour prolonger %s." % [FormatUtils.format_number(prime), p.full_name])
		return

	club.budget -= prime
	p.contract_years += 2
	p.salary = int(p.salary * 1.15)
	_show_popup("Contrat prolongé !", "Contrat de %s prolongé de 2 ans !\nNouveau salaire : %s €/sem.\nPrime versée : %s €." % [
		p.full_name, FormatUtils.format_number(p.salary), FormatUtils.format_number(prime)
	])
	refresh_view()
	data_changed.emit()

func _on_detail_requested(p: Player) -> void:
	var msg = "Position : %s\nÂge : %da  |  Nationalité : %s\nNote : %d OVR  |  Forme : %d%%\nValeur marchande : %s €\nSalaire : %s €/semaine\nContrat restant : %d an(s)" % [
		["Gardien (GK)", "Défenseur (DEF)", "Milieu (MID)", "Attaquant (FWD)"][p.position],
		p.age, p.nationality,
		p.get_overall(), int(p.fitness * 100.0),
		FormatUtils.format_number(p.market_value),
		FormatUtils.format_number(p.salary),
		p.contract_years
	]
	_show_popup("Fiche de %s" % p.full_name, msg)

func _show_popup(title: String, body: String) -> void:
	var d = AcceptDialog.new()
	d.title = title
	d.dialog_text = body
	add_child(d)
	d.popup_centered(Vector2i(420, 220))
