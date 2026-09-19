extends Node

var loaded_save_data: Dictionary = {}
var new_game_selected_club: Club = null
var new_game_selected_league: League = null
var new_game_all_leagues: Array[League] = []
var new_game_market: TransferMarket = null

func clear_transitions() -> void:
	loaded_save_data.clear()
	new_game_selected_club = null
	new_game_selected_league = null
	new_game_all_leagues.clear()
	new_game_market = null
