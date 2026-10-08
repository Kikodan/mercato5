class_name DayMercato
extends VBoxContainer

## Mardi & Mercredi : Marché des Transferts & Boîte de réception des offres
## Design tactile épuré avec onglets rétractables (accordéons).

const Club = preload("res://scripts/Club.gd")
const Player = preload("res://scripts/Player.gd")
const TransferMarket = preload("res://scripts/TransferMarket.gd")
const TransferOffer = preload("res://scripts/TransferOffer.gd")
const FormatUtils = preload("res://scripts/FormatUtils.gd")
const MobilePlayerCard = preload("res://scenes/widgets/MobilePlayerCard.gd")
const MobileCollapsibleSection = preload("res://scenes/widgets/MobileCollapsibleSection.gd")

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
	btn_tab_market.focus_mode = Control.FOCUS_NONE
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
	btn_tab_inbox.focus_mode = Control.FOCUS_NONE
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
	content_container.add_theme_constant_override("separation", 8)
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
	sb_active.set_corner_radius_all(8)

	var sb_inactive = StyleBoxFlat.new()
	sb_inactive.bg_color = Color(0.06, 0.09, 0.16, 0.85)
	sb_inactive.border_color = Color(0.18, 0.25, 0.38, 0.5)
	sb_inactive.set_border_width_all(1)
	sb_inactive.set_corner_radius_all(8)

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
		sb.set_corner_radius_all(10)
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		panel.add_theme_stylebox_override("panel", sb)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 8)
		panel.add_child(vbox)

		var lbl_buyer = Label.new()
		lbl_buyer.text = "OFFRE DE : %s" % offer.buyer_club.club_name.to_upper()
		lbl_buyer.add_theme_font_size_override("font_size", 13)
		lbl_buyer.add_theme_color_override("font_color", Color("c084fc"))
		vbox.add_child(lbl_buyer)

		var lbl_details = Label.new()
		lbl_details.text = "Joueur ciblé : %s (%s)\nMontant proposé : %s €" % [
			offer.player.full_name,
			["GK", "DEF", "MID", "FWD"][offer.player.position],
			FormatUtils.format_number(offer.offer_amount)
		]
		lbl_details.add_theme_font_size_override("font_size", 12)
		lbl_details.add_theme_color_override("font_color", Color("f1f5f9"))
		vbox.add_child(lbl_details)

		var btn_hbox = HBoxContainer.new()
		btn_hbox.add_theme_constant_override("separation", 10)
		vbox.add_child(btn_hbox)

		var btn_accept = Button.new()
		btn_accept.text = "✔ Accepter l'offre"
		btn_accept.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_accept.custom_minimum_size.y = 44.0
		var sb_acc = StyleBoxFlat.new()
		sb_acc.bg_color = Color(0.10, 0.52, 0.35, 0.95)
		sb_acc.set_corner_radius_all(6)
		btn_accept.add_theme_stylebox_override("normal", sb_acc)
		var this_offer = offer
		btn_accept.pressed.connect(func(): _accept_offer(this_offer))
		btn_hbox.add_child(btn_accept)

		var btn_reject = Button.new()
		btn_reject.text = "✖ Refuser"
		btn_reject.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_reject.custom_minimum_size.y = 44.0
		var sb_rej = StyleBoxFlat.new()
		sb_rej.bg_color = Color(0.50, 0.12, 0.15, 0.95)
		sb_rej.set_corner_radius_all(6)
		btn_reject.add_theme_stylebox_override("normal", sb_rej)
		btn_reject.pressed.connect(func(): _reject_offer(this_offer))
		btn_hbox.add_child(btn_reject)

		content_container.add_child(panel)

func _render_market() -> void:
	# 1. Section Rétractable : Filtres par Poste
	var filter_section = MobileCollapsibleSection.new("🔍 FILTRER PAR POSTE", false)
	var active_filter_name = ["Tous", "Gardiens (GK)", "Défenseurs (DEF)", "Milieux (MID)", "Attaquants (FWD)"][selected_pos_filter + 1]
	filter_section.set_badge(active_filter_name, Color("38bdf8"))
	content_container.add_child(filter_section)

	var filter_grid = GridContainer.new()
	filter_grid.columns = 3
	filter_grid.add_theme_constant_override("h_separation", 6)
	filter_grid.add_theme_constant_override("v_separation", 6)
	filter_section.add_content(filter_grid)

	var filter_names = ["Tous", "Gardien", "Défenseur", "Milieu", "Attaquant"]
	for i in range(filter_names.size()):
		var b = Button.new()
		b.text = filter_names[i]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 42.0
		b.focus_mode = Control.FOCUS_NONE
		var pos_id = i - 1

		var sb_b = StyleBoxFlat.new()
		sb_b.set_corner_radius_all(6)
		if selected_pos_filter == pos_id:
			sb_b.bg_color = Color(0.12, 0.28, 0.48, 0.95)
			sb_b.border_color = Color("38bdf8")
			sb_b.set_border_width_all(2)
		else:
			sb_b.bg_color = Color(0.08, 0.12, 0.20, 0.85)
			sb_b.border_color = Color(0.20, 0.28, 0.40, 0.50)
			sb_b.set_border_width_all(1)
		b.add_theme_stylebox_override("normal", sb_b)

		b.pressed.connect(func():
			selected_pos_filter = pos_id
			refresh_view()
		)
		filter_grid.add_child(b)

	# 2. Liste des Joueurs Disponibles
	var available_candidates: Array[Dictionary] = []
	for fa in market.free_agents:
		if selected_pos_filter == -1 or fa.position == selected_pos_filter:
			available_candidates.append({"player": fa, "seller": null, "is_free": true})

	for oc in other_clubs:
		for p in oc.squad:
			if p.is_transfer_listed:
				if selected_pos_filter == -1 or p.position == selected_pos_filter:
					available_candidates.append({"player": p, "seller": oc, "is_free": false})

	var list_section = MobileCollapsibleSection.new("📋 JOUEURS DISPONIBLES (%d)" % available_candidates.size(), true)
	content_container.add_child(list_section)

	if available_candidates.is_empty():
		var lbl_none = Label.new()
		lbl_none.text = "Aucun joueur disponible correspondant aux critères."
		lbl_none.add_theme_color_override("font_color", Color("94a3b8"))
		list_section.add_content(lbl_none)
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
		sb.set_corner_radius_all(8)
		sb.content_margin_left = 10
		sb.content_margin_right = 10
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		row_panel.add_theme_stylebox_override("panel", sb)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		row_panel.add_child(hbox)

		var pos_str = ["GK", "DEF", "MID", "FWD"][p.position]
		var lbl_pos = Label.new()
		lbl_pos.text = pos_str
		lbl_pos.add_theme_font_size_override("font_size", 11)
		lbl_pos.custom_minimum_size = Vector2(34, 28)
		lbl_pos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_pos.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var sb_pos = StyleBoxFlat.new()
		sb_pos.set_corner_radius_all(4)
		match p.position:
			Player.Position.GK: sb_pos.bg_color = Color("f59e0b")
			Player.Position.DEF: sb_pos.bg_color = Color("38bdf8")
			Player.Position.MID: sb_pos.bg_color = Color("10b981")
			Player.Position.FWD: sb_pos.bg_color = Color("f43f5e")
		lbl_pos.add_theme_stylebox_override("normal", sb_pos)
		lbl_pos.add_theme_color_override("font_color", Color.WHITE)
		hbox.add_child(lbl_pos)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var lbl_n = Label.new()
		lbl_n.text = "%s %s (%da)" % [p.get_flag_emoji(), p.full_name, p.age]
		lbl_n.add_theme_font_size_override("font_size", 13)
		lbl_n.add_theme_color_override("font_color", Color("f1f5f9"))
		info_vbox.add_child(lbl_n)

		var lbl_sub = Label.new()
		var origin_txt = "Libre" if is_free else seller.club_name
		lbl_sub.text = "%s • Val: %s € • %d OVR" % [origin_txt, FormatUtils.format_number(p.market_value), p.get_overall()]
		lbl_sub.add_theme_font_size_override("font_size", 11)
		lbl_sub.add_theme_color_override("font_color", Color("94a3b8"))
		info_vbox.add_child(lbl_sub)

		var btn_buy = Button.new()
		var cost = int(p.market_value * 1.1) if not is_free else int(p.market_value * 0.15)
		btn_buy.text = "Recruter\n%s €" % FormatUtils.format_number(cost)
		btn_buy.custom_minimum_size = Vector2(100, 44)
		btn_buy.add_theme_font_size_override("font_size", 11)
		btn_buy.focus_mode = Control.FOCUS_NONE

		var sb_buy = StyleBoxFlat.new()
		sb_buy.bg_color = Color(0.08, 0.50, 0.35, 0.95)
		sb_buy.border_color = Color("34d399")
		sb_buy.set_border_width_all(1)
		sb_buy.set_corner_radius_all(6)
		btn_buy.add_theme_stylebox_override("normal", sb_buy)

		var this_p = p
		var this_s = seller
		var this_free = is_free
		var this_cost = cost
		btn_buy.pressed.connect(func(): _buy_player(this_p, this_s, this_free, this_cost))
		hbox.add_child(btn_buy)

		list_section.add_content(row_panel)

func _buy_player(p: Player, seller: Club, is_free: bool, cost: int) -> void:
	if club.budget < cost:
		_show_popup("Fonds insuffisants", "Il vous faut %s € pour signer ce joueur." % FormatUtils.format_number(cost))
		return

	if club.squad.size() >= 32:
		_show_popup("Effectif plein", "Votre club a atteint la limite de 32 joueurs.")
		return

	club.budget -= cost

	if is_free:
		market.free_agents.erase(p)
	else:
		seller.budget += cost
		seller.squad.erase(p)
		if seller.starting_five.has(p):
			seller.starting_five.erase(p)

	club.squad.append(p)
	p.is_transfer_listed = false
	p.contract_years = 2

	_show_popup("Recrutement réussi !", "%s a rejoint votre effectif pour %s € !" % [p.full_name, FormatUtils.format_number(cost)])
	refresh_view()
	data_changed.emit()

func _accept_offer(offer: TransferOffer) -> void:
	market.pending_offers.erase(offer)
	club.budget += offer.offer_amount
	club.squad.erase(offer.player)
	if club.starting_five.has(offer.player):
		club.starting_five.erase(offer.player)

	offer.buyer_club.budget -= offer.offer_amount
	offer.buyer_club.squad.append(offer.player)
	offer.player.is_transfer_listed = false

	_show_popup("Offre acceptée", "%s a été vendu à %s pour %s € !" % [
		offer.player.full_name,
		offer.buyer_club.club_name,
		FormatUtils.format_number(offer.offer_amount)
	])
	refresh_view()
	data_changed.emit()

func _reject_offer(offer: TransferOffer) -> void:
	market.pending_offers.erase(offer)
	refresh_view()
	data_changed.emit()

func _show_popup(title: String, body: String) -> void:
	var d = AcceptDialog.new()
	d.title = title
	d.dialog_text = body
	add_child(d)
	d.popup_centered(Vector2i(420, 220))
