class_name DayMercato
extends VBoxContainer

const Club = preload("res://scripts/Club.gd")
const Player = preload("res://scripts/Player.gd")
const TransferMarket = preload("res://scripts/TransferMarket.gd")
const TransferOffer = preload("res://scripts/TransferOffer.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")
const MobilePlayerCard = preload("res://scenes/widgets/MobilePlayerCard.gd")

var club: Club = null
var market: TransferMarket = null
var other_clubs: Array[Club] = []

var btn_tab_market: Button
var btn_tab_inbox: Button
var content_container: VBoxContainer
var is_inbox_mode: bool = false
var selected_pos_filter: int = -1

signal data_changed()

func _init() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)

	# Barre d'onglets du Mercato
	var tabs_hbox = HBoxContainer.new()
	tabs_hbox.add_theme_constant_override("separation", 8)
	add_child(tabs_hbox)

	btn_tab_market = Button.new()
	btn_tab_market.text = "🛒 Marché des Joueurs"
	btn_tab_market.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_market.custom_minimum_size.y = 44.0
	btn_tab_market.pressed.connect(func():
		is_inbox_mode = false
		_update_tab_styles()
		refresh_view()
	)
	tabs_hbox.add_child(btn_tab_market)

	btn_tab_inbox = Button.new()
	btn_tab_inbox.text = "📬 Offres Reçues (0)"
	btn_tab_inbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_tab_inbox.custom_minimum_size.y = 44.0
	btn_tab_inbox.pressed.connect(func():
		is_inbox_mode = true
		_update_tab_styles()
		refresh_view()
	)
	tabs_hbox.add_child(btn_tab_inbox)

	# Conteneur scrollable
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)

	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 6)
	scroll.add_child(content_container)

	_update_tab_styles()

func setup(p_club: Club, p_market: TransferMarket, p_other_clubs: Array[Club]) -> void:
	club = p_club
	market = p_market
	other_clubs = p_other_clubs
	refresh_view()

func _update_tab_styles() -> void:
	var sb_active = StyleBoxFlat.new()
	sb_active.bg_color = Color(0.12, 0.22, 0.38, 0.95)
	sb_active.border_color = Color("38bdf8")
	sb_active.set_border_width_all(2)
	sb_active.set_corner_radius_all(6)

	var sb_inactive = StyleBoxFlat.new()
	sb_inactive.bg_color = Color(0.06, 0.09, 0.16, 0.85)
	sb_inactive.border_color = Color(0.18, 0.25, 0.38, 0.5)
	sb_inactive.set_border_width_all(1)
	sb_inactive.set_corner_radius_all(6)

	btn_tab_market.add_theme_stylebox_override("normal", sb_active if not is_inbox_mode else sb_inactive)
	btn_tab_inbox.add_theme_stylebox_override("normal", sb_active if is_inbox_mode else sb_inactive)

func refresh_view() -> void:
	if club == null or market == null:
		return

	btn_tab_inbox.text = "📬 Offres Reçues (%d)" % market.pending_offers.size()

	for child in content_container.get_children():
		child.queue_free()

	if is_inbox_mode:
		_render_inbox()
	else:
		_render_market()

func _render_inbox() -> void:
	if market.pending_offers.is_empty():
		var lbl_empty = Label.new()
		lbl_empty.text = "Aucune offre de transfert reçue pour le moment.\nPlacez des joueurs sur la liste des transferts pour attirer les clubs !"
		lbl_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_empty.add_theme_color_override("font_color", Color("94a3b8"))
		lbl_empty.add_theme_font_size_override("font_size", 13)
		content_container.add_child(lbl_empty)
		return

	for offer in market.pending_offers:
		var panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.12, 0.20, 0.95)
		sb.border_color = Color("c084fc")
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 12
		sb.content_margin_right = 12
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", sb)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)
		panel.add_child(vbox)

		var lbl_offer = Label.new()
		lbl_offer.text = "🏷️ %s propose %s € pour %s (%d OVR)" % [
			offer.sender_club.club_name,
			FormatUtils.format_number(offer.transfer_fee),
			offer.target_player.full_name,
			offer.target_player.get_overall()
		]
		lbl_offer.add_theme_font_size_override("font_size", 13)
		lbl_offer.add_theme_color_override("font_color", Color("f1f5f9"))
		vbox.add_child(lbl_offer)

		var btn_box = HBoxContainer.new()
		btn_box.add_theme_constant_override("separation", 10)
		vbox.add_child(btn_box)

		var btn_accept = Button.new()
		btn_accept.text = "✅ Accepter l'offre"
		btn_accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_accept.custom_minimum_size.y = 38.0
		btn_accept.modulate = Color("34d399")
		btn_accept.pressed.connect(func():
			market.accept_player_sale(offer, club)
			refresh_view()
			data_changed.emit()
		)
		btn_box.add_child(btn_accept)

		var btn_refuse = Button.new()
		btn_refuse.text = "❌ Refuser"
		btn_refuse.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_refuse.custom_minimum_size.y = 38.0
		btn_refuse.modulate = Color("f87171")
		btn_refuse.pressed.connect(func():
			market.reject_offer(offer)
			refresh_view()
		)
		btn_box.add_child(btn_refuse)

		content_container.add_child(panel)

func _render_market() -> void:
	# Filtres par poste
	var filter_hbox = HBoxContainer.new()
	filter_hbox.add_theme_constant_override("separation", 4)
	content_container.add_child(filter_hbox)

	var filter_names = ["Tous", "GK", "DEF", "MID", "FWD"]
	for i in range(filter_names.size()):
		var b = Button.new()
		b.text = filter_names[i]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 32.0
		var pos_id = i - 1
		b.pressed.connect(func():
			selected_pos_filter = pos_id
			refresh_view()
		)
		filter_hbox.add_child(b)

	# Liste des joueurs disponibles (Agents libres + Joueurs listés d'autres clubs)
	var available_candidates: Array[Dictionary] = []
	for fa in market.free_agents:
		if selected_pos_filter == -1 or fa.position == selected_pos_filter:
			available_candidates.append({"player": fa, "seller": null, "is_free": true})

	for oc in other_clubs:
		for p in oc.squad:
			if p.is_transfer_listed:
				if selected_pos_filter == -1 or p.position == selected_pos_filter:
					available_candidates.append({"player": p, "seller": oc, "is_free": false})

	if available_candidates.is_empty():
		var lbl_none = Label.new()
		lbl_none.text = "Aucun joueur disponible correspondant aux critères."
		lbl_none.add_theme_color_override("font_color", Color("94a3b8"))
		content_container.add_child(lbl_none)
		return

	for c in available_candidates:
		var p: Player = c["player"]
		var seller: Club = c["seller"]
		var is_free: bool = c["is_free"]

		var row_panel = PanelContainer.new()
		var sb = StyleBoxFlat.new()
		sb.bg_color = Color(0.06, 0.09, 0.16, 0.90)
		sb.border_color = Color(0.18, 0.25, 0.38, 0.60)
		sb.set_border_width_all(1)
		sb.set_corner_radius_all(6)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 6
		sb.content_margin_bottom = 6
		row_panel.add_theme_stylebox_override("panel", sb)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		row_panel.add_child(hbox)

		var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
		var lbl_pos = Label.new()
		lbl_pos.text = pos_str
		lbl_pos.add_theme_font_size_override("font_size", 11)
		lbl_pos.custom_minimum_size = Vector2(30, 24)
		hbox.add_child(lbl_pos)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var lbl_n = Label.new()
		lbl_n.text = "%s %s (%da)" % [p.get_flag_emoji(), p.full_name, p.age]
		lbl_n.add_theme_font_size_override("font_size", 12)
		lbl_n.add_theme_color_override("font_color", Color("f1f5f9"))
		info_vbox.add_child(lbl_n)

		var lbl_sub = Label.new()
		var origin_txt = "Agent Libre" if is_free else seller.club_name
		lbl_sub.text = "%s  •  Val: %s €  •  Sal: %s €" % [origin_txt, FormatUtils.format_number(p.market_value), FormatUtils.format_number(p.salary)]
		lbl_sub.add_theme_font_size_override("font_size", 10)
		lbl_sub.add_theme_color_override("font_color", Color("94a3b8"))
		info_vbox.add_child(lbl_sub)

		var lbl_ovr = Label.new()
		lbl_ovr.text = "%d" % p.get_overall()
		lbl_ovr.add_theme_font_size_override("font_size", 15)
		lbl_ovr.add_theme_color_override("font_color", Color("facc15"))
		hbox.add_child(lbl_ovr)

		var btn_buy = Button.new()
		btn_buy.text = "Signer" if is_free else "Acheter"
		btn_buy.custom_minimum_size = Vector2(70, 36)
		btn_buy.modulate = Color("34d399")
		btn_buy.pressed.connect(func():
			_open_purchase_dialog(p, seller, is_free)
		)
		hbox.add_child(btn_buy)

		content_container.add_child(row_panel)

func _open_purchase_dialog(p: Player, seller: Club, is_free: bool) -> void:
	if club.squad.size() >= 32:
		_show_popup("Effectif complet", "Votre effectif a atteint le plafond maximal de 32 joueurs.")
		return

	var req_fee = 0 if is_free else int(p.market_value * 1.05)
	var prime = int(p.market_value * 0.10)
	var total_cost = req_fee + prime

	if club.budget < total_cost:
		_show_popup("Budget insuffisant", "Il vous faut au moins %s € pour finaliser cette transaction." % FormatUtils.format_number(total_cost))
		return

	club.budget -= total_cost
	if seller != null:
		seller.budget += req_fee
		seller.squad.erase(p)
		seller.starting_five.erase(p)
	else:
		market.free_agents.erase(p)

	p.is_transfer_listed = false
	p.contract_years = 3
	club.squad.append(p)

	_show_popup("Recrutement réussi !", "Bienvenue à %s dans votre club !\nIndemnité : %s €\nPrime versée : %s €" % [
		p.full_name, FormatUtils.format_number(req_fee), FormatUtils.format_number(prime)
	])
	refresh_view()
	data_changed.emit()

func _show_popup(title: String, body: String) -> void:
	var d = AcceptDialog.new()
	d.title = title
	d.dialog_text = body
	add_child(d)
	d.popup_centered(Vector2i(400, 200))
