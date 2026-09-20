class_name ClubTransferModal
extends Control

signal transfer_agreed(player: Player, seller: Club, agreed_fee: int)
signal transfer_cancelled()

const ClubBadge = preload("res://scripts/ClubBadge.gd")
const PlayerFaceWidget = preload("res://scenes/PlayerFaceWidget.gd")

var buyer_club: Club = null
var seller_club: Club = null
var target_player: Player = null
var market_ref: TransferMarket = null

var current_attempt: int = 1
var max_attempts: int = 4
var last_counter_offer: int = 0
var is_agreed: bool = false
var is_broken: bool = false
var agreed_transfer_fee: int = 0

var panel: PanelContainer
var lbl_title: Label
var lbl_attempt: Label
var prog_attempt: ProgressBar
var seller_badge: ClubBadge
var face_widget: PlayerFaceWidget
var lbl_player_name: Label
var lbl_player_details: Label
var lbl_asking_hint: Label

var slider_offer: HSlider
var lbl_offer_val: Label
var lbl_president_dialogue: Label
var president_box: PanelContainer

var btn_submit_bid: Button
var btn_accept_counter: Button
var btn_proceed_player: Button
var btn_cancel: Button

func _ready() -> void:
	visible = false
	z_index = 65
	_build_ui()

func open_modal(buyer: Club, seller: Club, p: Player, market: TransferMarket) -> void:
	buyer_club = buyer
	seller_club = seller
	target_player = p
	market_ref = market
	current_attempt = 1
	last_counter_offer = 0
	is_agreed = false
	is_broken = false
	agreed_transfer_fee = 0

	_refresh_display()
	visible = true
	move_to_front()

func close_modal() -> void:
	visible = false
	transfer_cancelled.emit()

func _build_ui() -> void:
	for c in get_children():
		c.queue_free()

	var overlay = ColorRect.new()
	overlay.color = Color(0.04, 0.06, 0.1, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(680, 530)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.11, 0.19, 0.98)
	sb.set_corner_radius_all(14)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color("38bdf8")
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 18
	sb.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	panel.add_child(main_vbox)

	# En-tête
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 10)

	seller_badge = ClubBadge.new()
	seller_badge.custom_minimum_size = Vector2(36, 36)
	header_hbox.add_child(seller_badge)

	lbl_title = Label.new()
	lbl_title.text = "🏛️ Négociation de Transfert • Club à Club"
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_title.add_theme_font_size_override("font_size", 16)
	lbl_title.add_theme_color_override("font_color", Color("38bdf8"))
	header_hbox.add_child(lbl_title)

	var btn_x = Button.new()
	btn_x.text = "✕"
	btn_x.custom_minimum_size = Vector2(32, 32)
	btn_x.pressed.connect(close_modal)
	header_hbox.add_child(btn_x)
	main_vbox.add_child(header_hbox)

	var sep = HSeparator.new()
	main_vbox.add_child(sep)

	# Fiche du joueur ciblé
	var player_box = PanelContainer.new()
	var pb_style = StyleBoxFlat.new()
	pb_style.bg_color = Color(0.05, 0.08, 0.14, 0.75)
	pb_style.set_corner_radius_all(8)
	pb_style.content_margin_left = 12
	pb_style.content_margin_right = 12
	pb_style.content_margin_top = 10
	pb_style.content_margin_bottom = 10
	player_box.add_theme_stylebox_override("panel", pb_style)

	var p_hbox = HBoxContainer.new()
	p_hbox.add_theme_constant_override("separation", 14)

	face_widget = PlayerFaceWidget.new()
	face_widget.custom_minimum_size = Vector2(56, 56)
	p_hbox.add_child(face_widget)

	var p_vbox = VBoxContainer.new()
	p_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	lbl_player_name = Label.new()
	lbl_player_name.text = "JOUEUR"
	lbl_player_name.add_theme_font_size_override("font_size", 16)
	p_vbox.add_child(lbl_player_name)

	lbl_player_details = Label.new()
	lbl_player_details.text = "Attributs & Club"
	lbl_player_details.modulate = Color("94a3b8")
	lbl_player_details.add_theme_font_size_override("font_size", 12)
	p_vbox.add_child(lbl_player_details)

	lbl_asking_hint = Label.new()
	lbl_asking_hint.text = "Prix indicatif estimé : 0 €"
	lbl_asking_hint.modulate = Color("facc15")
	lbl_asking_hint.add_theme_font_size_override("font_size", 12)
	p_vbox.add_child(lbl_asking_hint)

	p_hbox.add_child(p_vbox)
	player_box.add_child(p_hbox)
	main_vbox.add_child(player_box)

	# Jauge des tentatives
	var attempt_box = HBoxContainer.new()
	attempt_box.add_theme_constant_override("separation", 10)

	lbl_attempt = Label.new()
	lbl_attempt.text = "Tentative 1 / 4 (Patience du club)"
	lbl_attempt.add_theme_font_size_override("font_size", 12)
	attempt_box.add_child(lbl_attempt)

	prog_attempt = ProgressBar.new()
	prog_attempt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prog_attempt.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	prog_attempt.custom_minimum_size = Vector2(0, 10)
	prog_attempt.max_value = 4.0
	prog_attempt.value = 4.0
	prog_attempt.show_percentage = false
	attempt_box.add_child(prog_attempt)

	main_vbox.add_child(attempt_box)

	# Zone de proposition financière
	var fee_card = PanelContainer.new()
	var fc_style = StyleBoxFlat.new()
	fc_style.bg_color = Color(0.06, 0.09, 0.16, 0.9)
	fc_style.set_corner_radius_all(8)
	fc_style.content_margin_left = 14
	fc_style.content_margin_right = 14
	fc_style.content_margin_top = 10
	fc_style.content_margin_bottom = 10
	fee_card.add_theme_stylebox_override("panel", fc_style)

	var fee_vbox = VBoxContainer.new()
	fee_vbox.add_theme_constant_override("separation", 8)

	var fee_header = HBoxContainer.new()
	var lbl_fee_title = Label.new()
	lbl_fee_title.text = "💰 Montant de l'indemnité de transfert proposée :"
	lbl_fee_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_fee_title.add_theme_font_size_override("font_size", 13)
	fee_header.add_child(lbl_fee_title)

	lbl_offer_val = Label.new()
	lbl_offer_val.text = "0 €"
	lbl_offer_val.add_theme_font_size_override("font_size", 16)
	lbl_offer_val.modulate = Color("38bdf8")
	fee_header.add_child(lbl_offer_val)
	fee_vbox.add_child(fee_header)

	slider_offer = HSlider.new()
	slider_offer.min_value = 5_000
	slider_offer.max_value = 500_000
	slider_offer.step = 2_000
	slider_offer.value = 50_000
	slider_offer.value_changed.connect(func(val: float):
		lbl_offer_val.text = "%s €" % String.num_int64(int(val))
	)
	fee_vbox.add_child(slider_offer)

	# Boutons d'ajustement rapide (+5k, +10k, +25k)
	var quick_hbox = HBoxContainer.new()
	quick_hbox.add_theme_constant_override("separation", 8)

	var offsets = [-10_000, -2_000, 2_000, 10_000, 25_000]
	for off in offsets:
		var q_btn = Button.new()
		q_btn.text = ("+%dk" % (off / 1000)) if off > 0 else ("%dk" % (off / 1000))
		q_btn.custom_minimum_size = Vector2(54, 24)
		q_btn.add_theme_font_size_override("font_size", 11)
		q_btn.pressed.connect(func():
			slider_offer.value = clampf(slider_offer.value + off, slider_offer.min_value, slider_offer.max_value)
		)
		quick_hbox.add_child(q_btn)

	fee_vbox.add_child(quick_hbox)
	fee_card.add_child(fee_vbox)
	main_vbox.add_child(fee_card)

	# Réaction / Dialogue du Président
	president_box = PanelContainer.new()
	var pres_style = StyleBoxFlat.new()
	pres_style.bg_color = Color(0.10, 0.14, 0.22, 0.95)
	pres_style.set_corner_radius_all(8)
	pres_style.content_margin_left = 12
	pres_style.content_margin_right = 12
	pres_style.content_margin_top = 10
	pres_style.content_margin_bottom = 10
	president_box.add_theme_stylebox_override("panel", pres_style)

	var pres_hbox = HBoxContainer.new()
	pres_hbox.add_theme_constant_override("separation", 10)

	var lbl_pres_icon = Label.new()
	lbl_pres_icon.text = "👔"
	lbl_pres_icon.add_theme_font_size_override("font_size", 20)
	pres_hbox.add_child(lbl_pres_icon)

	lbl_president_dialogue = Label.new()
	lbl_president_dialogue.text = "Le président du club adverse écoute votre offre..."
	lbl_president_dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_president_dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_president_dialogue.add_theme_font_size_override("font_size", 12)
	pres_hbox.add_child(lbl_president_dialogue)

	president_box.add_child(pres_hbox)
	main_vbox.add_child(president_box)

	# Boutons d'actions
	var act_hbox = HBoxContainer.new()
	act_hbox.add_theme_constant_override("separation", 10)

	btn_submit_bid = Button.new()
	btn_submit_bid.text = "📤 Transmettre l'offre au club (Essai 1/4)"
	btn_submit_bid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_submit_bid.custom_minimum_size = Vector2(0, 36)
	btn_submit_bid.modulate = Color("38bdf8")
	btn_submit_bid.pressed.connect(_on_submit_bid)
	act_hbox.add_child(btn_submit_bid)

	btn_accept_counter = Button.new()
	btn_accept_counter.text = "🤝 Accepter la contre-proposition"
	btn_accept_counter.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_accept_counter.custom_minimum_size = Vector2(0, 36)
	btn_accept_counter.modulate = Color("facc15")
	btn_accept_counter.visible = false
	btn_accept_counter.pressed.connect(_on_accept_counter)
	act_hbox.add_child(btn_accept_counter)

	btn_proceed_player = Button.new()
	btn_proceed_player.text = "➡️ Négocier le contrat du joueur"
	btn_proceed_player.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_proceed_player.custom_minimum_size = Vector2(0, 36)
	btn_proceed_player.modulate = Color("10b981")
	btn_proceed_player.visible = false
	btn_proceed_player.pressed.connect(_on_proceed_to_player)
	act_hbox.add_child(btn_proceed_player)

	btn_cancel = Button.new()
	btn_cancel.text = "Annuler"
	btn_cancel.custom_minimum_size = Vector2(100, 36)
	btn_cancel.pressed.connect(close_modal)
	act_hbox.add_child(btn_cancel)

	main_vbox.add_child(act_hbox)

func _refresh_display() -> void:
	if seller_club != null:
		seller_badge.shape = seller_club.badge_shape
		seller_badge.symbol = seller_club.badge_symbol
		seller_badge.primary_color = seller_club.primary_color
		seller_badge.secondary_color = seller_club.secondary_color
		seller_badge.queue_redraw()
		lbl_title.text = "🏛️ Négociation avec %s" % seller_club.club_name

	if target_player != null:
		face_widget.setup_player(target_player, seller_club.primary_color if seller_club else Color.WHITE, seller_club.secondary_color if seller_club else Color.BLACK)
		var pos_str = ["Gardien (GK)", "Défenseur (DEF)", "Milieu (MID)", "Attaquant (FWD)"][target_player.position]
		lbl_player_name.text = "%s %s" % [target_player.get_flag_emoji(), target_player.full_name]
		lbl_player_details.text = "%s • %d ans • Note %d OVR • Valeur marchande : %s €" % [
			pos_str, target_player.age, target_player.get_overall(), String.num_int64(target_player.market_value)
		]

		var base_asking = int(target_player.market_value * 1.15)
		lbl_asking_hint.text = "Estimation du prix demandé par le club : environ %s €" % String.num_int64(base_asking)

		slider_offer.min_value = max(2_000, int(target_player.market_value * 0.4))
		slider_offer.max_value = max(15_000, int(target_player.market_value * 2.8))
		slider_offer.step = 1_000
		slider_offer.value = target_player.market_value
		lbl_offer_val.text = "%s €" % String.num_int64(int(slider_offer.value))

	_update_attempt_ui()
	lbl_president_dialogue.text = "« Nous vous écoutons. Quel montant proposez-vous pour racheter le contrat de %s ? »" % (target_player.full_name if target_player else "")
	btn_submit_bid.visible = true
	btn_accept_counter.visible = false
	btn_proceed_player.visible = false

func _update_attempt_ui() -> void:
	var remaining = max_attempts - current_attempt + 1
	lbl_attempt.text = "Tentative %d / %d  (Patience restante : %d essai%s)" % [
		current_attempt, max_attempts, remaining, ("s" if remaining > 1 else "")
	]
	prog_attempt.value = remaining
	if remaining >= 3:
		prog_attempt.modulate = Color("34d399")
	elif remaining == 2:
		prog_attempt.modulate = Color("facc15")
	else:
		prog_attempt.modulate = Color("f87171")

	btn_submit_bid.text = "📤 Transmettre l'offre (Tentative %d/%d)" % [current_attempt, max_attempts]

func _on_submit_bid() -> void:
	if is_agreed or is_broken:
		return

	var offer_amount = int(slider_offer.value)
	var res = market_ref.evaluate_club_bid(seller_club, target_player, offer_amount, current_attempt)

	lbl_president_dialogue.text = res.get("message", "")

	match res.get("status"):
		"ACCEPTED":
			is_agreed = true
			agreed_transfer_fee = offer_amount
			btn_submit_bid.visible = false
			btn_accept_counter.visible = false
			btn_proceed_player.visible = true
			lbl_attempt.text = "✅ Accord trouvé !"
			lbl_attempt.modulate = Color("10b981")

		"COUNTER_OFFER":
			last_counter_offer = res.get("counter_offer", 0)
			btn_accept_counter.text = "🤝 Accepter la contre-proposition (%s €)" % String.num_int64(last_counter_offer)
			btn_accept_counter.visible = true
			current_attempt += 1
			if current_attempt > max_attempts:
				_break_negotiations()
			else:
				_update_attempt_ui()

		"REJECTED_LOW":
			btn_accept_counter.visible = false
			current_attempt += 1
			if current_attempt > max_attempts:
				_break_negotiations()
			else:
				_update_attempt_ui()

		"BROKEN":
			_break_negotiations()

func _on_accept_counter() -> void:
	if last_counter_offer <= 0:
		return
	slider_offer.value = last_counter_offer
	is_agreed = true
	agreed_transfer_fee = last_counter_offer
	lbl_president_dialogue.text = "« Parfait ! Nous avons un accord de principe à %s €. Vous pouvez négocier avec le joueur. »" % String.num_int64(last_counter_offer)
	btn_submit_bid.visible = false
	btn_accept_counter.visible = false
	btn_proceed_player.visible = true
	lbl_attempt.text = "✅ Accord trouvé !"
	lbl_attempt.modulate = Color("10b981")

func _break_negotiations() -> void:
	is_broken = true
	lbl_president_dialogue.text = "« Trop d'échecs ! Les discussions sont rompues. %s ne quittera pas notre club cette saison. »" % (target_player.full_name if target_player else "")
	btn_submit_bid.visible = false
	btn_accept_counter.visible = false
	btn_proceed_player.visible = false
	lbl_attempt.text = "❌ Négociations rompues (4 essais épuisés)"
	lbl_attempt.modulate = Color("f87171")

func _on_proceed_to_player() -> void:
	visible = false
	transfer_agreed.emit(target_player, seller_club, agreed_transfer_fee)
