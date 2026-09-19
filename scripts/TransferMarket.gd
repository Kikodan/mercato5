class_name TransferMarket
extends Node

signal inbox_updated
signal transaction_completed(message: String)

var free_agents: Array[Player] = []
var pending_offers: Array[TransferOffer] = []

const MAX_SQUAD_SIZE: int = 12

func init_free_agents(default_country: String = "France", avg_level: int = 12, count: int = 28) -> void:
	free_agents.clear()
	var positions = [Player.Position.GK, Player.Position.DEF, Player.Position.MID, Player.Position.FWD]
	var countries = ["France", "Espagne", "Italie", "Portugal", "Angleterre", "Brésil", "Belgique", "Pays-Bas"]
	for i in count:
		var c = countries.pick_random() if randf() < 0.7 else default_country
		free_agents.append(PlayerGenerator.create_random_player(c, positions.pick_random(), avg_level))

func finalize_signing(buyer: Club, player: Player, agreed_salary: int, signing_bonus: int, contract_years: int, seller: Club = null, transfer_fee: int = 0) -> bool:
	if buyer.squad.size() >= MAX_SQUAD_SIZE:
		transaction_completed.emit("Effectif complet (%d/%d) : libérez d'abord un joueur." % [buyer.squad.size(), MAX_SQUAD_SIZE])
		return false

	if seller != null and seller.squad.size() <= 5:
		transaction_completed.emit("%s refuse de vendre (effectif minimum de 5 joueurs)." % seller.club_name)
		return false

	var total_cash_cost: int = signing_bonus + transfer_fee
	if buyer.budget < total_cash_cost:
		transaction_completed.emit("Budget insuffisant (%s € requis)." % String.num_int64(total_cash_cost))
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

	var club_src = (" (vendu par %s)" % seller.club_name) if seller != null else " (libre)"
	transaction_completed.emit("✅ Recrutement réussi ! %s s'engage pour %d an(s) à %s €/sem%s." % [
		player.full_name, contract_years, String.num_int64(agreed_salary), club_src
	])
	return true

func release_player(club: Club, player: Player) -> bool:
	if club.squad.size() <= 5:
		transaction_completed.emit("Impossible de libérer : effectif minimum atteint (5 joueurs).")
		return false

	var severance: int = player.salary * 4 # 4 semaines d'indemnité
	if club.budget < severance:
		transaction_completed.emit("Budget insuffisant pour payer les indemnités de départ (%s €)." % String.num_int64(severance))
		return false

	club.budget -= severance
	club.squad.erase(player)
	club.starting_five.erase(player)
	free_agents.append(player)
	transaction_completed.emit("Contrat résilié : %s a été libéré (indemnités: %s €)." % [player.full_name, String.num_int64(severance)])
	return true

func sign_free_agent(buyer: Club, player: Player) -> bool:
	var bonus = int(player.market_value * 0.15)
	return finalize_signing(buyer, player, player.wage_demand, bonus, 2, null, 0)

func buy_player_from_club(buyer: Club, seller: Club, player: Player) -> bool:
	var fee = int(player.market_value * 1.15)
	var bonus = int(player.market_value * 0.10)
	return finalize_signing(buyer, player, int(player.salary * 1.1), bonus, 3, seller, fee)



func trigger_ai_market_activity(player_club: Club, other_clubs: Array[Club]) -> void:
	pending_offers.clear()
	for p in player_club.squad:
		if randf() < 0.25:
			var buyer: Club = other_clubs.pick_random()
			if buyer and buyer != player_club and buyer.squad.size() < 10:
				var offer = TransferOffer.new()
				offer.offer_type = TransferOffer.Type.PLAYER_PURCHASE
				offer.sender_club = buyer
				offer.target_player = p
				offer.transfer_fee = int(p.market_value * randf_range(0.9, 1.3))
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
		transaction_completed.emit("Vente de %s pour %d €." % [p.full_name, offer.transfer_fee])
		inbox_updated.emit()

func reject_offer(offer: TransferOffer) -> void:
	pending_offers.erase(offer)
	transaction_completed.emit("Offre déclinée.")
	inbox_updated.emit()
