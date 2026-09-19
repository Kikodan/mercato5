class_name TransferOffer
extends RefCounted

enum Type { PLAYER_PURCHASE, JOB_OFFER }

var offer_type: Type = Type.PLAYER_PURCHASE
var sender_club: Club
var target_player: Player = null
var transfer_fee: int = 0
var offered_salary: int = 0
