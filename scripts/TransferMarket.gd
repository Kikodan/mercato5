class_name TransferMarket
extends Node

signal inbox_updated
signal transaction_completed(message: String)

var free_agents: Array[Player] = []
var pending_offers: Array[TransferOffer] = []

const MAX_SQUAD_SIZE: int = 32

func init_free_agents(default_country: String = "France", avg_level: int = 68, count: int = 32) -> void:
	free_agents.clear()
	var positions = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD]
	var countries = ["France", "Espagne", "Italie", "Portugal", "Angleterre", "Allemagne", "Brésil", "Belgique", "Pays-Bas"]
	for i in count:
		var c = countries.pick_random() if randf() < 0.7 else default_country
		var target_lvl = avg_level if avg_level > 20 else clampi(int(avg_level * 3.8 + 24), 50, 88)
		free_agents.append(PlayerGenerator.create_random_player(c, positions.pick_random(), target_lvl))

func finalize_signing(buyer: Club, player: Player, agreed_salary: int, signing_bonus: int, contract_years: int, seller: Club = null, transfer_fee: int = 0) -> bool:
	if buyer.squad.size() >= MAX_SQUAD_SIZE:
		transaction_completed.emit("Effectif complet (%d/%d) : la limite maximale est de 32 joueurs." % [buyer.squad.size(), MAX_SQUAD_SIZE])
		return false

	if seller != null and seller.squad.size() <= 5:
		transaction_completed.emit("%s refuse de vendre (effectif minimum de 5 joueurs)." % seller.club_name)
		return false

	var total_cash_cost: int = signing_bonus + transfer_fee
	if buyer.budget < total_cash_cost:
		transaction_completed.emit("Budget insuffisant (%s € requis)." % FormatUtils.format_number(total_cash_cost))
		return false

	buyer.budget -= total_cash_cost

	if seller != null:
		seller.budget += transfer_fee
		seller.squad.erase(player)
		seller.starting_five.erase(player)
	else:
		free_agents.erase(player)

	player.salary = agreed_salary
	player.contract_years = contract_years
	buyer.squad.append(player)

	var club_src = (" (acheté à %s pour %s €)" % [seller.club_name, FormatUtils.format_number(transfer_fee)]) if seller != null else " (libre)"
	transaction_completed.emit("✅ Signature officielle ! %s s'engage pour %d an(s) à %s €/sem%s." % [
		player.full_name, contract_years, FormatUtils.format_number(agreed_salary), club_src
	])
	return true

func renew_contract(club: Club, player: Player, agreed_salary: int, signing_bonus: int, new_contract_years: int) -> bool:
	if not club.squad.has(player):
		transaction_completed.emit("Erreur : le joueur n'appartient pas au club.")
		return false

	if club.budget < signing_bonus:
		transaction_completed.emit("Budget insuffisant pour verser la prime de prolongation (%s € requis)." % FormatUtils.format_number(signing_bonus))
		return false

	club.budget -= signing_bonus
	player.salary = agreed_salary
	player.contract_years = new_contract_years

	transaction_completed.emit("📝 Prolongation officielle ! %s prolonge son contrat pour %d an(s) à %s €/sem (prime : %s €)." % [
		player.full_name, new_contract_years, FormatUtils.format_number(agreed_salary), FormatUtils.format_number(signing_bonus)
	])
	return true

func release_player(club: Club, player: Player) -> bool:
	if club.squad.size() <= 5:
		transaction_completed.emit("Impossible de libérer : effectif minimum atteint (5 joueurs).")
		return false

	var severance: int = player.salary * 4 # 4 semaines d'indemnité
	if club.budget < severance:
		transaction_completed.emit("Budget insuffisant pour payer les indemnités de départ (%s €)." % FormatUtils.format_number(severance))
		return false

	club.budget -= severance
	club.squad.erase(player)
	club.starting_five.erase(player)
	free_agents.append(player)
	transaction_completed.emit("Contrat résilié : %s a été libéré sur le marché (indemnités : %s €)." % [player.full_name, FormatUtils.format_number(severance)])
	return true

func sign_free_agent(buyer: Club, player: Player) -> bool:
	var bonus = int(player.market_value * 0.12)
	return finalize_signing(buyer, player, player.wage_demand, bonus, 2, null, 0)

func buy_player_from_club(buyer: Club, seller: Club, player: Player) -> bool:
	var fee = int(player.market_value * 1.15)
	var bonus = int(player.market_value * 0.10)
	return finalize_signing(buyer, player, int(player.salary * 1.1), bonus, 3, seller, fee)

# Évaluation d'une offre d'achat de club (Phase 1 du transfert en 4 essais)
func evaluate_club_bid(seller: Club, player: Player, offer_amount: int, attempt: int) -> Dictionary:
	var base_asking = int(player.market_value * 1.15)
	var sorted = seller.squad.duplicate()
	sorted.sort_custom(func(a, b): return a.get_overall() > b.get_overall())
	var is_star = sorted.slice(0, mini(3, sorted.size())).has(player)
	if is_star:
		base_asking = int(base_asking * 1.25)

	# Seuil d'acceptation directe (s'assouplit légèrement au fil des tentatives)
	var accept_ratio = 1.02 - (attempt - 1) * 0.04
	var min_acceptable = int(base_asking * accept_ratio)

	if offer_amount >= min_acceptable:
		return {
			"status": "ACCEPTED",
			"counter_offer": offer_amount,
			"message": "Accord trouvé ! %s accepte votre offre de %s €." % [seller.club_name, FormatUtils.format_number(offer_amount)]
		}

	# Si tentative 4 échouée -> rupture
	if attempt >= 4:
		return {
			"status": "BROKEN",
			"counter_offer": 0,
			"message": "Négociations rompues ! Le président de %s refuse définitivement votre offre." % seller.club_name
		}

	# Offre trop basse (< 65%)
	if offer_amount < int(base_asking * 0.65):
		return {
			"status": "REJECTED_LOW",
			"counter_offer": base_asking,
			"message": "Offre jugée dérisoire ! Le président exige au minimum %s €." % FormatUtils.format_number(base_asking)
		}

	# Contre-proposition
	var counter = int((base_asking + offer_amount) / 2)
	counter = maxi(counter, int(base_asking * 0.88))
	return {
		"status": "COUNTER_OFFER",
		"counter_offer": counter,
		"message": "%s refuse cette proposition mais vous soumet une contre-offre à %s €." % [seller.club_name, FormatUtils.format_number(counter)]
	}

func trigger_ai_market_activity(player_club: Club, other_clubs: Array[Club]) -> void:
	pending_offers.clear()
	for p in player_club.squad:
		if randf() < 0.20:
			var buyer: Club = other_clubs.pick_random()
			if buyer and buyer != player_club and buyer.squad.size() < 24:
				var offer = TransferOffer.new()
				offer.offer_type = TransferOffer.Type.PLAYER_PURCHASE
				offer.sender_club = buyer
				offer.target_player = p
				offer.transfer_fee = int(p.market_value * randf_range(0.95, 1.35))
				pending_offers.append(offer)

	if randf() < 0.15:
		var prospective: Club = other_clubs.pick_random()
		if prospective and prospective != player_club:
			var job = TransferOffer.new()
			job.offer_type = TransferOffer.Type.JOB_OFFER
			job.sender_club = prospective
			job.offered_salary = int(prospective.budget * 0.05)
			pending_offers.append(job)

	inbox_updated.emit()

func accept_transfer_offer(offer: TransferOffer, player_club: Club) -> void:
	if offer.offer_type == TransferOffer.Type.PLAYER_PURCHASE:
		var p = offer.target_player
		if player_club.squad.size() <= 5:
			transaction_completed.emit("Effectif minimum atteint (5).")
			return
		player_club.budget += offer.transfer_fee
		offer.sender_club.budget -= offer.transfer_fee
		player_club.squad.erase(p)
		player_club.starting_five.erase(p)
		offer.sender_club.squad.append(p)
		pending_offers.erase(offer)
		transaction_completed.emit("Vente de %s conclue pour %s €." % [p.full_name, FormatUtils.format_number(offer.transfer_fee)])
		inbox_updated.emit()

func reject_offer(offer: TransferOffer) -> void:
	pending_offers.erase(offer)
	transaction_completed.emit("Offre déclinée.")
	inbox_updated.emit()

# Gestion autonome des effectifs par les clubs IA et circulation hebdomadaire du marché
func process_ai_squad_management(all_clubs: Array[Club], user_club: Club = null) -> void:
	for club in all_clubs:
		if club == user_club:
			continue

		# 1. Protection vitale : Garantir au moins 1 gardien de but (urgence absolue)
		var gks: Array[Player] = []
		for p in club.squad:
			if p.position == Player.Position.GK:
				gks.append(p)

		if gks.is_empty():
			var target_gk: Player = null
			for fa in free_agents:
				if fa.position == Player.Position.GK:
					if target_gk == null or fa.get_overall() > target_gk.get_overall():
						target_gk = fa

			if target_gk != null:
				free_agents.erase(target_gk)
				target_gk.salary = target_gk.wage_demand
				club.squad.append(target_gk)
			else:
				var emergency_gk = PlayerGenerator.create_random_player(club.country, Player.Position.GK, clampi(55 + club.division * 5, 50, 85))
				emergency_gk.recalculate_value(club.division)
				club.squad.append(emergency_gk)

			club.auto_pick_lineup()

		# 2. Protection des cadres (Top 5 des meilleurs joueurs du club)
		var sorted_squad = club.squad.duplicate()
		sorted_squad.sort_custom(func(a, b): return a.get_overall() > b.get_overall())
		var star_players = sorted_squad.slice(0, mini(5, sorted_squad.size()))

		# 3. Recrutement actif si effectif < 14 ou renfort opportuniste (< 20)
		if (club.squad.size() < 12 or (club.squad.size() < 20 and randf() < 0.25)) and club.budget > 40_000:
			var def_cnt = 0
			var mid_cnt = 0
			var fwd_cnt = 0
			for p in club.squad:
				match p.position:
					Player.Position.DEF: def_cnt += 1
					Player.Position.MID: mid_cnt += 1
					Player.Position.FWD: fwd_cnt += 1

			var needed_pos = Player.Position.DEF
			if def_cnt <= mid_cnt and def_cnt <= fwd_cnt:
				needed_pos = Player.Position.DEF
			elif mid_cnt <= def_cnt and mid_cnt <= fwd_cnt:
				needed_pos = Player.Position.MID
			else:
				needed_pos = Player.Position.FWD

			if gks.size() < 2 and randf() < 0.6:
				needed_pos = Player.Position.GK

			var best_fa: Player = null
			for fa in free_agents:
				if fa.position == needed_pos:
					if best_fa == null or fa.get_overall() > best_fa.get_overall():
						best_fa = fa

			if best_fa != null:
				var bonus = int(best_fa.market_value * 0.10)
				if club.budget >= bonus:
					club.budget -= bonus
					free_agents.erase(best_fa)
					best_fa.salary = best_fa.wage_demand
					club.squad.append(best_fa)
					club.auto_pick_lineup()

		# 4. Dégraissage des indésirables uniquement si effectif pléthorique (> 24 joueurs)
		if club.squad.size() > 24:
			var candidate_to_release: Player = null
			for p in sorted_squad:
				if star_players.has(p):
					continue
				if p.position == Player.Position.GK and gks.size() <= 1:
					continue
				candidate_to_release = p

			if candidate_to_release != null and club.squad.size() > 5:
				club.squad.erase(candidate_to_release)
				club.starting_five.erase(candidate_to_release)
				free_agents.append(candidate_to_release)
				club.auto_pick_lineup()

	# 5. Renouvellement et circulation hebdomadaire du marché : nouveaux joueurs libres & pépites
	inject_new_market_players(randi_range(4, 7))

# Injection dynamique de nouveaux joueurs sur le marché des transferts
func inject_new_market_players(count: int = 5) -> void:
	var positions = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD]
	var countries = ["France", "Espagne", "Italie", "Portugal", "Angleterre", "Allemagne", "Brésil", "Belgique", "Pays-Bas", "Argentine", "Maroc", "Sénégal"]
	
	for i in range(count):
		var c = countries.pick_random()
		var pos = positions.pick_random()
		var ovr = randi_range(56, 84)
		var p = PlayerGenerator.create_random_player(c, pos, ovr)
		p.market_value = int(pow(float(ovr) / 10.0, 3.8) * 1200.0)
		p.wage_demand = maxi(800, int(p.market_value * 0.0018))
		p.salary = p.wage_demand
		free_agents.push_front(p)
	
	# Conserver une taille raisonnable mais généreuse (jusqu'à 90 joueurs disponibles)
	while free_agents.size() > 90:
		free_agents.pop_back()

