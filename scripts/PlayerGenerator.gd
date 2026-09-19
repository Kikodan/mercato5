class_name PlayerGenerator
extends RefCounted

static var registered_names: Dictionary = {}

const FIRST_NAMES = {
	"France": [
		"Théo", "Lucas", "Maxime", "Kylian", "Sofiane", "Adrien", "Mathis", "Alexandre", "Valentin", "Romain",
		"Clément", "Antoine", "Dimitri", "Florian", "Hugo", "Yanis", "Rayan", "Bastien", "Enzo", "Gabin",
		"Julien", "Nabil", "Amine", "Bilal", "Loïc", "Thomas", "Nicolas", "Mickaël", "Benoît", "Guillaume",
		"Sébastien", "Arnaud", "Pierre", "Paul", "Louis", "Arthur", "Jules", "Gabriel", "Léo", "Raphaël"
	],
	"Espagne": [
		"Alejandro", "Mateo", "Carlos", "Pablo", "Diego", "Hugo", "Álvaro", "Adrián", "Sergio", "Daniel",
		"Javier", "David", "Marcos", "Mario", "Manuel", "Iván", "Rubén", "Raúl", "Iker", "Gonzalo",
		"Pau", "Pol", "Marc", "Jordi", "Ferran", "Oriol", "Héctor", "Vicente", "Fernando", "Jorge",
		"Miguel", "Jaime", "Andrés", "Joaquín", "Borja", "Ignacio", "Lucas", "Gorka", "Unai", "Ander"
	],
	"Italie": [
		"Lorenzo", "Matteo", "Federico", "Nicolo", "Leonardo", "Marco", "Francesco", "Alessandro", "Andrea", "Gabriele",
		"Mattia", "Riccardo", "Tommaso", "Edoardo", "Filippo", "Davide", "Giuseppe", "Antonio", "Giovanni", "Michele",
		"Pietro", "Salvatore", "Vincenzo", "Domenico", "Christian", "Luca", "Fabio", "Simone", "Daniele", "Alessio",
		"Manuel", "Stefano", "Giorgio", "Giacomo", "Luigi", "Claudio", "Paolo", "Gianluca", "Roberto", "Massimo"
	],
	"Angleterre": [
		"Jack", "Harry", "Mason", "Callum", "Oliver", "George", "Noah", "Arthur", "Leo", "Charlie",
		"Jacob", "Freddie", "Alfie", "Archie", "Oscar", "Theo", "James", "William", "Thomas", "Henry",
		"Ethan", "Alexander", "Max", "Daniel", "Samuel", "Joseph", "Edward", "Lucas", "Liam", "Benjamin",
		"Luke", "Connor", "Declan", "Lewis", "Finley", "Harrison", "Harvey", "Toby", "Reuben", "Ellis"
	],
	"Portugal": [
		"Diogo", "Tiago", "Gonçalo", "Bernardo", "Ruben", "Rafael", "Rodrigo", "Martim", "Afonso", "Tomás",
		"Duarte", "Miguel", "Lourenço", "Gabriel", "Santiago", "Simão", "Vasco", "Lucas", "Mateus", "Guilherme",
		"João", "Pedro", "Manuel", "António", "Francisco", "José", "Luís", "André", "Filipe", "Rui",
		"Nuno", "Bruno", "Ricardo", "Carlos", "Paulo", "Sérgio", "Vítor", "Hélder", "Fábio", "Renato"
	],
	"Allemagne": [
		"Lukas", "Finn", "Jonas", "Niklas", "Felix", "Maximilian", "Paul", "Leon", "Ben", "Noah",
		"Elias", "Luca", "David", "Tim", "Philipp", "Moritz", "Jan", "Simon", "Fabian", "Julian",
		"Florian", "Tobias", "Sebastian", "Alexander", "Daniel", "Michael", "Christian", "Stefan", "Markus", "Andreas",
		"Thomas", "Kevin", "Marcel", "Dennis", "Patrick", "Nico", "Dominik", "Sven", "Timo", "Marco"
	],
	"Brésil": [
		"Gabriel", "Lucas", "Matheus", "Guilherme", "Gustavo", "Felipe", "Vinícius", "Rafael", "Leonardo", "Rodrigo",
		"Pedro", "Thiago", "Arthur", "Danilo", "Caio", "Diego", "Bruno", "Renan", "Igor", "Murilo",
		"Otávio", "Vitor", "Alexandre", "Leandro", "Marcelo", "Adriano", "Rivaldo", "Ronaldo", "Romário", "Cafu",
		"Kaká", "Neymar", "Ederson", "Alisson", "Casemiro", "Fabinho", "Rodrygo", "Richarlison", "Antony", "Paquetá"
	],
	"Belgique": [
		"Arthur", "Noah", "Louis", "Liam", "Adam", "Jules", "Victor", "Lucas", "Gabriel", "Mohamed",
		"Maxime", "Eden", "Romelu", "Kevin", "Thibaut", "Dries", "Jan", "Toby", "Axel", "Youri",
		"Leandro", "Timothy", "Thomas", "Hans", "Charles", "Zeno", "Amadou", "Jérémy", "Loïs", "Arnaud"
	],
	"Pays-Bas": [
		"Sem", "Lucas", "Levi", "Finn", "Daan", "Milan", "Liam", "Noah", "Luuk", "Bram",
		"Jesse", "Mees", "Sam", "Thijs", "Julian", "Mats", "Thomas", "Lars", "Ruben", "Tim",
		"Frenkie", "Memphis", "Virgil", "Matthijs", "Cody", "Nathan", "Stefan", "Teun", "Denzel", "Xavi"
	]
}

const LAST_NAMES = {
	"France": [
		"Dupont", "Moreau", "Bernard", "Petit", "Roux", "Diallo", "Durand", "Leroy", "Morel", "Simon",
		"Laurent", "Lefebvre", "Michel", "Garcia", "David", "Bertrand", "Roux", "Vincent", "Fournier", "Bonnet",
		"Mercier", "Blanc", "Guerin", "Boyer", "Garnier", "Chevalier", "François", "Legrand", "Gauthier", "Perrin",
		"Robin", "Clement", "Morin", "Nicolas", "Henry", "Roussel", "Mathieu", "Gautier", "Masson", "Marchand"
	],
	"Espagne": [
		"Garcia", "Martinez", "Lopez", "Rodriguez", "Navarro", "Fernandez", "Gonzalez", "Perez", "Sanchez", "Ramirez",
		"Torres", "Flores", "Rivera", "Gomez", "Diaz", "Reyes", "Morales", "Cruz", "Ortiz", "Gutierrez",
		"Chavez", "Ramos", "Castillo", "Vargas", "Mendoza", "Romero", "Herrera", "Medina", "Aguilar", "Vega",
		"Castro", "Soto", "Delgado", "Pena", "Silva", "Guerrero", "Marquez", "Cabrera", "Campos", "Vega"
	],
	"Italie": [
		"Rossi", "Ferrari", "Esposito", "Bianchi", "Romano", "Colombo", "Ricci", "Marino", "Greco", "Bruno",
		"Gallo", "Conti", "De Luca", "Mancini", "Costa", "Giordano", "Rizzo", "Lombardi", "Moretti", "Barbieri",
		"Fontana", "Santoro", "Mariani", "Rinaldi", "Caruso", "Ferrara", "Galli", "Martini", "Leone", "Longo",
		"Gentile", "Martinelli", "Vitale", "Lombardo", "Serra", "Coppola", "De Santis", "D'Angelo", "Marchetti", "Parisi"
	],
	"Angleterre": [
		"Smith", "Taylor", "Brown", "Wilson", "Davies", "Evans", "Thomas", "Johnson", "Roberts", "Walker",
		"Wright", "Robinson", "Thompson", "White", "Hughes", "Edwards", "Green", "Hall", "Wood", "Harris",
		"Martin", "Jackson", "Clarke", "Clark", "Turner", "Hill", "Scott", "Cooper", "Morris", "Ward",
		"Moore", "King", "Watson", "Baker", "Harrison", "Morgan", "Patel", "Young", "Allen", "Anderson"
	],
	"Portugal": [
		"Silva", "Santos", "Ferreira", "Pereira", "Oliveira", "Costa", "Rodrigues", "Martins", "Jesus", "Sousa",
		"Fernandes", "Gonçalves", "Gomes", "Lopes", "Marques", "Alves", "Almeida", "Ribeiro", "Pinto", "Carvalho",
		"Teixeira", "Moreira", "Correia", "Mendes", "Nunes", "Soares", "Vieira", "Monteiro", "Cardoso", "Rocha",
		"Raposo", "Neves", "Coelho", "Cruz", "Pires", "Ramos", "Reis", "Simões", "Antunes", "Matos"
	],
	"Allemagne": [
		"Müller", "Schmidt", "Schneider", "Fischer", "Weber", "Meyer", "Wagner", "Becker", "Schulz", "Hoffmann",
		"Schäfer", "Koch", "Bauer", "Richter", "Klein", "Wolf", "Schröder", "Neumann", "Schwarz", "Zimmermann",
		"Braun", "Krüger", "Hofmann", "Hartmann", "Lange", "Schmitt", "Werner", "Schmitz", "Krause", "Meier",
		"Lehmann", "Schmid", "Herrmann", "Maier", "Köhler", "Walter", "König", "Huber", "Kaiser", "Fuchs"
	],
	"Brésil": [
		"Silva", "Santos", "Oliveira", "Souza", "Rodrigues", "Ferreira", "Alves", "Pereira", "Lima", "Gomes",
		"Costa", "Ribeiro", "Martins", "Carvalho", "Almeida", "Lopes", "Soares", "Fernandes", "Vieira", "Barbosa",
		"Rocha", "Dias", "Nascimento", "Andrade", "Moreira", "Nunes", "Marques", "Machado", "Mendes", "Freitas",
		"Cardoso", "Ramos", "Gonçalves", "Santana", "Teixeira", "Araújo", "Castro", "Neves", "Cavalcanti", "Macedo"
	],
	"Belgique": [
		"Peeters", "Janssens", "Maes", "Jacobs", "Mertens", "Willems", "Claes", "Goossens", "Wouters", "De Smet",
		"Vermeulen", "Pauwels", "Hermans", "Aerts", "Michiels", "Martens", "De Backer", "Lambert", "Dupont", "Dubois",
		"Fontaine", "Renard", "Dumont", "Leclercq", "Laurent", "Denis", "Collet", "Simon", "Gérard", "Boulanger"
	],
	"Pays-Bas": [
		"De Jong", "Jansen", "De Vries", "Van de Berg", "Van Dijk", "Bakker", "Janssen", "Visser", "Smit", "Meijer",
		"De Boer", "Mulder", "De Groot", "Bos", "Vos", "Peters", "Hendriks", "Van Leeuwen", "Dekker", "Brouwer",
		"De Wit", "Dijkstra", "Smits", "De Graaf", "Van der Meer", "Van der Linden", "Kok", "Jacobs", "De Haan", "Vermeulen"
	]
}

const POSITIVE_TRAITS = [
	"Renard des surfaces", "Poumon", "Mur", "Pied soyeux", "Leader",
	"Finition clinique", "Agilité féline", "Maestro du tempo", "Dribbleur fou", "Mental d'acier"
]
const NEGATIVE_TRAITS = [
	"Fumeur", "Individualiste", "Nerfs fragiles", "Paresseux", "Fragile",
	"Irrégulier", "Gourmand en salaire", "Mauvais perdant", "Manque de repli", "Pied faible limité"
]

static func reset_registry() -> void:
	registered_names.clear()

static func generate_unique_name(country: String) -> String:
	var first_list: Array = FIRST_NAMES.get(country, FIRST_NAMES["France"])
	var last_list: Array = LAST_NAMES.get(country, LAST_NAMES["France"])

	for attempt in 150:
		var candidate = "%s %s" % [first_list.pick_random(), last_list.pick_random()]
		if not registered_names.has(candidate):
			registered_names[candidate] = true
			return candidate

	var base_candidate = "%s %s" % [first_list.pick_random(), last_list.pick_random()]
	var suffixes = ["Jr.", "II", "III", "IV", "de Souza", "Filho", "Neto"]
	for s in suffixes:
		var suffixed = "%s %s" % [base_candidate, s]
		if not registered_names.has(suffixed):
			registered_names[suffixed] = true
			return suffixed

	var counter: int = 1
	while true:
		var numbered = "%s (%d)" % [base_candidate, counter]
		if not registered_names.has(numbered):
			registered_names[numbered] = true
			return numbered
		counter += 1

	return "Joueur Inconnu"

static func create_random_player(country: String, pos: Player.Position, base_rating: int) -> Player:
	var p = Player.new()
	p.nationality = country
	p.full_name = generate_unique_name(country)
	p.age = randi_range(18, 34)
	p.position = pos

	var r = func(): return clampi(base_rating + randi_range(-3, 3), 1, 20)
	p.speed = r.call()
	p.shooting = r.call()
	p.passing = r.call()
	p.defending = r.call()
	p.stamina = r.call()

	match pos:
		Player.Position.GK:
			p.defending = clampi(p.defending + 4, 1, 20)
		Player.Position.FWD:
			p.shooting = clampi(p.shooting + 4, 1, 20)
		Player.Position.DEF:
			p.defending = clampi(p.defending + 3, 1, 20)
		Player.Position.MID:
			p.passing = clampi(p.passing + 3, 1, 20)

	if randf() > 0.5:
		p.trait_positive = POSITIVE_TRAITS.pick_random()
	if randf() > 0.5:
		p.trait_negative = NEGATIVE_TRAITS.pick_random()

	# Visage officiel issu des planches de visages
	p.face_data = {
		"face_id": randi_range(0, 195)
	}

	p.recalculate_value(1)
	return p

static func _pick_skin_tone(country: String) -> int:
	match country:
		"France":
			var choices = [1, 2, 3, 4, 5, 6]
			return choices.pick_random()
		"Espagne", "Italie", "Portugal":
			var choices = [1, 2, 2, 3, 3, 4]
			return choices.pick_random()
		"Angleterre", "Allemagne", "Belgique", "Pays-Bas":
			var choices = [0, 1, 1, 1, 2, 4]
			return choices.pick_random()
		"Brésil":
			var choices = [2, 3, 4, 4, 5, 6]
			return choices.pick_random()
		_:
			return randi_range(0, 6)

static func _pick_hair_color(country: String) -> int:
	match country:
		"Angleterre", "Allemagne", "Pays-Bas", "Belgique":
			var choices = [0, 1, 2, 2, 3, 3, 5]
			return choices.pick_random()
		"Espagne", "Italie", "Portugal", "Brésil":
			var choices = [0, 0, 1, 1, 2]
			return choices.pick_random()
		_:
			return randi_range(0, 5)


static func create_default_squad(club: Club, avg_level: int) -> void:
	club.squad.clear()
	var plan = [
		Player.Position.GK, Player.Position.GK,
		Player.Position.DEF, Player.Position.DEF, Player.Position.DEF,
		Player.Position.MID, Player.Position.MID, Player.Position.MID,
		Player.Position.FWD, Player.Position.FWD
	]
	for pos in plan:
		var p = create_random_player(club.country, pos, avg_level)
		p.recalculate_value(club.division)
		club.squad.append(p)
	club.auto_pick_lineup()

