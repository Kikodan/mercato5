class_name PlayerGenerator
extends RefCounted

static var registered_names: Dictionary = {}

const FIRST_NAMES = {
	"France": [
		"Théo", "Lucas", "Maxime", "Kylian", "Sofiane", "Adrien", "Mathis", "Alexandre", "Valentin", "Romain",
		"Clément", "Antoine", "Dimitri", "Florian", "Hugo", "Yanis", "Rayan", "Bastien", "Enzo", "Gabin",
		"Julien", "Nabil", "Amine", "Bilal", "Loïc", "Thomas", "Nicolas", "Mickaël", "Benoît", "Guillaume",
		"Sébastien", "Arnaud", "Pierre", "Paul", "Louis", "Arthur", "Jules", "Gabriel", "Léo", "Raphaël",
		"Zinédine", "Thierry", "Karim", "Michel", "David", "Franck", "Laurent", "Didier", "Éric", "Robert"
	],
	"Espagne": [
		"Alejandro", "Mateo", "Carlos", "Pablo", "Diego", "Hugo", "Álvaro", "Adrián", "Sergio", "Daniel",
		"Javier", "David", "Marcos", "Mario", "Manuel", "Iván", "Rubén", "Raúl", "Iker", "Gonzalo",
		"Pau", "Pol", "Marc", "Jordi", "Ferran", "Oriol", "Héctor", "Vicente", "Fernando", "Jorge",
		"Miguel", "Jaime", "Andrés", "Joaquín", "Borja", "Ignacio", "Lucas", "Gorka", "Unai", "Ander",
		"Carles", "Xabier", "Gerard", "Cesc", "Santiago", "Emilio", "Guti", "Alfonso", "Gaizka", "Joseba"
	],
	"Italie": [
		"Lorenzo", "Matteo", "Federico", "Nicolo", "Leonardo", "Marco", "Francesco", "Alessandro", "Andrea", "Gabriele",
		"Mattia", "Riccardo", "Tommaso", "Edoardo", "Filippo", "Davide", "Giuseppe", "Antonio", "Giovanni", "Michele",
		"Pietro", "Salvatore", "Vincenzo", "Domenico", "Christian", "Luca", "Fabio", "Simone", "Daniele", "Alessio",
		"Manuel", "Stefano", "Giorgio", "Giacomo", "Luigi", "Claudio", "Paolo", "Gianluca", "Roberto", "Massimo",
		"Gianluigi", "Ciro", "Gennaro", "Dino", "Franco", "Gianfranco", "Fabrizio", "Mario", "Claudio", "Renato"
	],
	"Angleterre": [
		"Jack", "Harry", "Mason", "Callum", "Oliver", "George", "Noah", "Arthur", "Leo", "Charlie",
		"Jacob", "Freddie", "Alfie", "Archie", "Oscar", "Theo", "James", "William", "Thomas", "Henry",
		"Ethan", "Alexander", "Max", "Daniel", "Samuel", "Joseph", "Edward", "Lucas", "Liam", "Benjamin",
		"Luke", "Connor", "Declan", "Lewis", "Finley", "Harrison", "Harvey", "Toby", "Reuben", "Ellis",
		"David", "Steven", "Frank", "Wayne", "Alan", "Paul", "Rio", "John", "Gary", "Ashley"
	],
	"Portugal": [
		"Diogo", "Tiago", "Gonçalo", "Bernardo", "Ruben", "Rafael", "Rodrigo", "Martim", "Afonso", "Tomás",
		"Duarte", "Miguel", "Lourenço", "Gabriel", "Santiago", "Simão", "Vasco", "Lucas", "Mateus", "Guilherme",
		"João", "Pedro", "Manuel", "António", "Francisco", "José", "Luís", "André", "Filipe", "Rui",
		"Nuno", "Bruno", "Ricardo", "Carlos", "Paulo", "Sérgio", "Vítor", "Hélder", "Fábio", "Renato",
		"Cristiano", "Deco", "Luís", "Nani", "Pauleta", "Maniche", "Costinha", "Beto", "Quaresma", "Pepe"
	],
	"Allemagne": [
		"Lukas", "Finn", "Jonas", "Niklas", "Felix", "Maximilian", "Paul", "Leon", "Ben", "Noah",
		"Elias", "Luca", "David", "Tim", "Philipp", "Moritz", "Jan", "Simon", "Fabian", "Julian",
		"Florian", "Tobias", "Sebastian", "Alexander", "Daniel", "Michael", "Christian", "Stefan", "Markus", "Andreas",
		"Thomas", "Kevin", "Marcel", "Dennis", "Patrick", "Nico", "Dominik", "Sven", "Timo", "Marco",
		"Manuel", "Bastian", "Toni", "Mesut", "Mario", "Miroslav", "Jürgen", "Oliver", "Franz", "Lothar"
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
		"Frenkie", "Memphis", "Virgil", "Matthijs", "Cody", "Nathan", "Stefan", "Teun", "Denzel", "Xavi",
		"Robin", "Wesley", "Arjen", "Ruud", "Dennis", "Clarence", "Edgar", "Patrick", "Edwin", "Frank"
	]
}

# Noms de famille réels de joueurs célèbres (passé ou présent), strictement classés par position
const LAST_NAMES_BY_POS = {
	Player.Position.GK: {
		"France": [
			"Barthez", "Lloris", "Maignan", "Coupet", "Mandanda", "Lama", "Bats", "Frey", "Ruffier", "Landreau",
			"Samba", "Areola", "Charbonnier", "Letizi", "Costil", "Lafont", "Bernardoni", "Carrasso", "Ramé", "Porato",
			"Olmeta", "Dropsy", "Castaneda", "Carnus", "Baratelli", "Janot", "Richert", "Riou", "Lecomte", "Larsonneur"
		],
		"Espagne": [
			"Casillas", "De Gea", "Simón", "Raya", "Reina", "Valdés", "Zubizarreta", "Cañizares", "Kepa", "Palop",
			"López", "Asenjo", "Arconada", "Buyo", "Remiro", "Pacheco", "Soria", "Guaita", "Moyà", "Molina",
			"Ochotorena", "Sadurní", "Ramallets", "Abbiati", "Herrerín", "Sergi", "Valles", "Gazzaniga", "Dmitrovic", "Soriano"
		],
		"Italie": [
			"Buffon", "Donnarumma", "Zoff", "Pagliuca", "Toldo", "Peruzzi", "Marchetti", "Sirigu", "Vicario", "Provedel",
			"Meret", "Carnesecchi", "Zenga", "Albertosi", "Marchegiani", "Abbiati", "De Sanctis", "Sorrentino", "Gollini", "Di Gregorio",
			"Falcone", "Silvestri", "Montipò", "Bardi", "Mirante", "Consigli", "Antonioli", "Bordon", "Cudicini", "Galli"
		],
		"Angleterre": [
			"Pickford", "Ramsdale", "Seaman", "Banks", "Shilton", "Hart", "Pope", "Henderson", "Robinson", "James",
			"Martyn", "Green", "Foster", "Carson", "Johnstone", "Butland", "Travers", "Clemence", "Woods", "Flowers",
			"Corrigan", "Bonetti", "Stepney", "Swindin", "Kirkland", "Wright", "Pressman", "Walker", "Steele", "Heaton"
		],
		"Portugal": [
			"Costa", "Patrício", "Sá", "Baía", "Ricardo", "Eduardo", "Beto", "Bento", "Quim", "Lopes",
			"Hilário", "Silva", "Maximiano", "Varela", "Damas", "Silvino", "Costinha", "Moreira", "Kieszek", "Marafona"
		],
		"Allemagne": [
			"Neuer", "Kahn", "ter Stegen", "Maier", "Lehmann", "Trapp", "Leno", "Baumann", "Köpke", "Schumacher",
			"Illgner", "Adler", "Hildebrand", "Nübel", "Rost", "Butt", "Weidenfeller", "Zieler", "Karius", "Enke",
			"Reck", "Immel", "Kleff", "Tilkowski", "Fährmann", "Schwolow", "Zentner", "Blaswich", "Dahmen", "Atubolu"
		],
		"Brésil": [
			"Alisson", "Ederson", "Dida", "César", "Taffarel", "Ceni", "Marcos", "Bento", "Perri", "Neto",
			"Weverton", "Alves", "Helton", "Leão", "Manga", "Gilmar", "Castilho", "Peres", "Carlos", "Zetti",
			"Danrlei", "Velloso", "Doni", "Vasconcelos", "Everson", "Santos", "Grohe", "Jailson", "Cássio", "Fábio"
		],
		"Belgique": [
			"Courtois", "Preud'homme", "Pfaff", "Casteels", "Mignolet", "Sels", "Proto", "Bailly", "De Vlieger", "Vandereycken",
			"Bodart", "Piot", "De Bie", "Kaminski", "Roef", "Coosemans", "Hubert", "Lammens", "Vandevoordt", "Penneteau"
		],
		"Pays-Bas": [
			"Van der Sar", "Cillessen", "Verbruggen", "Flekken", "Bijlow", "Stekelenburg", "Krul", "Van Breukelen", "De Goey", "Waterreus",
			"Noppert", "Jongbloed", "Van Beveren", "Schrijvers", "Menzo", "Hiele", "Westerveld", "Boschker", "Zoet", "Pasveer"
		],
		"Global": [
			"Yashin", "Schmeichel", "Oblak", "Navas", "Chilavert", "Higuita", "Cech", "Sommer", "Bounou", "Martínez",
			"Muslera", "Ochoa", "Handanovic", "Szczesny", "Dudek", "Goycochea", "Romero", "Livakovic", "Onana", "Mendy",
			"Kobel", "Lunin", "Trubin", "Ospina", "Bravo", "Campos", "N'Kono", "Enyeama"
		]
	},
	Player.Position.DEF: {
		"France": [
			"Thuram", "Desailly", "Blanc", "Varane", "Koundé", "Upamecano", "Saliba", "Hernández", "Pavard",
			"Sagnol", "Lizarazu", "Abidal", "Evra", "Umtiti", "Kimpembe", "Konaté", "Mendy", "Digne", "Gallas",
			"Sagna", "Clichy", "Mexès", "Leboeuf", "Amoros", "Bossis", "Trésor", "Battiston", "Sakho", "Zouma",
			"Disasi", "Badiashile", "Todibo", "Kalulu", "Gusto", "Lukeba", "Simakan", "Clauss", "Sidibé", "Debuchy"
		],
		"Espagne": [
			"Ramos", "Puyol", "Piqué", "Hierro", "Carvajal", "Alba", "Laporte", "Le Normand", "Cucurella", "Grimaldo",
			"Azpilicueta", "Nacho", "Arbeloa", "Capdevila", "Salgado", "Marchena", "Albiol", "Juanfran", "Bartra", "Torres",
			"Porro", "Balde", "Gayà", "Martínez", "Vivian", "Camacho", "Gordillo", "Sanchís", "Nadal", "Abelardo"
		],
		"Italie": [
			"Maldini", "Baresi", "Cannavaro", "Nesta", "Chiellini", "Bonucci", "Scirea", "Bergomi", "Costacurta", "Ferrara",
			"Zambrotta", "Panucci", "Materazzi", "Barzagli", "Bastoni", "Dimarco", "Calafiori", "Di Lorenzo", "Acerbi", "Mancini",
			"Darmian", "Spinazzola", "Pessotto", "Tassotti", "Gentile", "Cabrini", "Vierchowod", "Burgnich", "Facchetti", "Grosso"
		],
		"Angleterre": [
			"Ferdinand", "Terry", "Campbell", "Moore", "Walker", "Stones", "Maguire", "Alexander-Arnold", "Shaw", "Trippier",
			"Cole", "Neville", "Adams", "Keown", "Carragher", "Cahill", "Southgate", "King", "Guéhi", "Konsa",
			"Gomez", "James", "Chilwell", "Burn", "Dunk", "Smalling", "Jones", "Jagielka", "Lescott", "Baines"
		],
		"Portugal": [
			"Pepe", "Dias", "Carvalho", "Alves", "Cancelo", "Mendes", "Dalot", "Guerreiro", "Fonte", "Semedo",
			"Pereira", "Inácio", "Silva", "Couto", "Secretário", "Ferreira", "Bosingwa", "Coentrão", "Miguel", "Andrade"
		],
		"Allemagne": [
			"Beckenbauer", "Kohler", "Sammer", "Hummels", "Rüdiger", "Boateng", "Lahm", "Breitner", "Kimmich", "Tah",
			"Schlotterbeck", "Raum", "Gosens", "Mertesacker", "Friedrich", "Metzelder", "Nowotny", "Helmer", "Buchwald", "Augenthaler"
		],
		"Brésil": [
			"Cafu", "Carlos", "Silva", "Marquinhos", "Lúcio", "Juan", "Alves", "Marcelo", "Maicon", "Aldair",
			"Júnior", "Alberto", "Magalhães", "Bremer", "Militão", "Danilo", "Sandro", "Luiz", "Miranda", "Roque"
		],
		"Belgique": [
			"Kompany", "Vertonghen", "Alderweireld", "Van Buyten", "Vermaelen", "Meunier", "Castagne", "Theate", "Faes", "Debast",
			"Albert", "Renquin", "Meeuws", "Gerets", "Boyata", "Kabasele", "Bornauw", "De Winter", "De Cuyper", "Engels"
		],
		"Pays-Bas": [
			"van Dijk", "Koeman", "de Ligt", "Stam", "de Vrij", "Aké", "Dumfries", "Blind", "Van Bronckhorst", "de Boer",
			"Reiziger", "Krol", "van Hecke", "Timber", "Geertruida", "Botman", "van de Ven", "Heitinga", "Mathijsen", "Boulahrouz"
		],
		"Global": [
			"Godín", "Lugano", "Zanetti", "Ayala", "Passarella", "Romero", "Otamendi", "Martínez", "Koulibaly", "Tapsoba",
			"Alaba", "Vidic", "Skriniar", "Gvardiol", "Savic", "Kjaer", "Aguerd", "Hakimi", "Montero", "Sorín"
		]
	},
	Player.Position.MID: {
		"France": [
			"Zidane", "Platini", "Vieira", "Kanté", "Pogba", "Makelele", "Camavinga", "Tchouaméni", "Rabiot", "Matuidi",
			"Deschamps", "Pirès", "Tigana", "Giresse", "Fernandez", "Petit", "Diarra", "Toulalan", "Cabaye", "Sissoko",
			"Fofana", "Zaïre-Emery", "Guendouzi", "Gourcuff", "Nasri", "Payet", "Valbuena", "Rothen", "Micoud", "Pedretti"
		],
		"Espagne": [
			"Xavi", "Iniesta", "Busquets", "Rodri", "Alonso", "Fàbregas", "Silva", "Cazorla", "Pedri", "Gavi",
			"Koke", "Alcântara", "Isco", "Mata", "Guardiola", "Enrique", "Senna", "Arteta", "Merino", "Ruiz",
			"Zubimendi", "Olmo", "Baena", "Soler", "Ceballos", "Míchel", "Bakero", "Guerrero", "Valerón", "de la Peña"
		],
		"Italie": [
			"Pirlo", "Gattuso", "De Rossi", "Barella", "Verratti", "Tardelli", "Ancelotti", "Albertini", "Marchisio", "Jorginho",
			"Pellegrini", "Tonali", "Locatelli", "Frattesi", "Giannini", "Donadoni", "Benetti", "Antognoni", "Tommasi", "Perrotta"
		],
		"Angleterre": [
			"Gerrard", "Lampard", "Scholes", "Beckham", "Bellingham", "Rice", "Foden", "Gascoigne", "Robson", "Hoddle",
			"Henderson", "Carrick", "Barry", "Milner", "Wilshere", "Ince", "Platt", "Waddle", "Mainoo", "Maddison"
		],
		"Portugal": [
			"Deco", "Costa", "Silva", "Fernandes", "Moutinho", "Figo", "Sousa", "Mendes", "Maniche", "Costinha",
			"Vitinha", "Palhinha", "Neves", "Otávio", "Sanches", "Nunes", "Carvalho", "Veloso"
		],
		"Allemagne": [
			"Kroos", "Matthäus", "Schweinsteiger", "Ballack", "Özil", "Gündogan", "Wirtz", "Musiala", "Khedira", "Effenberg",
			"Littbarski", "Overath", "Netzer", "Möller", "Hässler", "Frings", "Hamann", "Goretzka", "Andrich", "Pavlovic"
		],
		"Brésil": [
			"Ronaldinho", "Kaká", "Zico", "Sócrates", "Falcão", "Casemiro", "Dunga", "Rivaldo", "Pernambucano", "Silva",
			"Fernandinho", "Fabinho", "Paquetá", "Guimarães", "Luiz", "Roberto", "Émerson", "Cerezo", "Gérson", "Ribas"
		],
		"Belgique": [
			"De Bruyne", "Hazard", "Tielemans", "Witsel", "Fellaini", "Dembélé", "Scifo", "Van der Elst", "Ceulemans", "Mangala",
			"Onana", "Vermeeren", "Praet", "Defour", "Coeck", "Vandereycken", "Vercauteren", "Nainggolan", "Chadli", "Dendoncker"
		],
		"Pays-Bas": [
			"Cruyff", "Gullit", "Rijkaard", "Sneijder", "de Jong", "Davids", "Seedorf", "van Bommel", "Neeskens", "Koopmeiners",
			"Reijnders", "Schouten", "Wijnaldum", "Strootman", "van de Beek", "Simons", "Gravenberch", "van Hanegem", "Winter", "Cocu"
		],
		"Global": [
			"Modric", "Rakitic", "Boban", "Prosinecki", "Nedved", "Hamsik", "de Arrascaeta", "Valverde", "Bentancur", "Mac Allister",
			"De Paul", "Fernández", "Redondo", "Simeone", "Riquelme", "Verón", "Essien", "Touré", "Partey", "Kudus"
		]
	},
	Player.Position.FWD: {
		"France": [
			"Mbappé", "Henry", "Benzema", "Griezmann", "Cantona", "Papin", "Trezeguet", "Fontaine", "Kopa", "Giroud",
			"Dembélé", "Barcola", "Coman", "Ben Arfa", "Cissé", "Wiltord", "Dugarry", "Anelka", "Govou", "Ginola",
			"Rocheteau", "Lacazette", "Ben Yedder", "Thuram", "Kolo Muani", "Nkunku", "Gignac", "Thauvin", "Martial", "Terrier"
		],
		"Espagne": [
			"González", "Villa", "Torres", "Morata", "Butragueño", "Morientes", "Yamal", "Williams", "Oyarzabal",
			"Aspas", "Rodríguez", "Llorente", "Negredo", "Soldado", "Salinas", "Santillana", "Gento", "Amaro", "Costa",
			"Moreno", "Joselu", "Zarra", "Di Stéfano", "Puskás", "Quini", "Tristán", "Muniain", "Omorodion", "Pérez"
		],
		"Italie": [
			"Baggio", "Del Piero", "Totti", "Rossi", "Riva", "Vieri", "Inzaghi", "Toni", "Vialli", "Mancini",
			"Chiesa", "Immobile", "Scamacca", "Retegui", "Gilardino", "Balotelli", "Di Natale", "Signori", "Zola", "Schillaci",
			"Boninsegna", "Mazzola", "Raspadori", "Kean", "Meazza", "Piola", "Bettega", "Graziani", "Pruzzo", "Altobelli"
		],
		"Angleterre": [
			"Kane", "Shearer", "Rooney", "Owen", "Lineker", "Charlton", "Saka", "Sterling", "Rashford", "Watkins",
			"Toney", "Fowler", "Wright", "Cole", "Sheringham", "Ferdinand", "Defoe", "Heskey", "Crouch", "Sturridge",
			"Vardy", "Greaves", "Hurst", "Palmer", "Gordon", "Dean", "Lofthouse", "Finney", "Keegan", "Solanke"
		],
		"Portugal": [
			"Ronaldo", "Eusébio", "Pauleta", "Nani", "Leão", "Jota", "Félix", "Gomes", "Futre", "Sabrosa",
			"Quaresma", "Ramos", "Neto", "Conceição", "Almeida", "Postiga", "Liédson", "Peyroteo", "Matateu", "Águas",
			"Jordão", "Silva", "Guedes", "Varela", "Éder", "Paciência", "Carvalho", "Bruma"
		],
		"Allemagne": [
			"Müller", "Klose", "Rummenigge", "Klinsmann", "Völler", "Seeler", "Havertz", "Füllkrug", "Gnabry", "Sané",
			"Gomez", "Bierhoff", "Podolski", "Schürrle", "Werner", "Kießling", "Kuranyi", "Neuville", "Fischer", "Heynckes",
			"Walter", "Rahn", "Hölzenbein", "Riedle", "Kirsten", "Bobic", "Asamoah", "Undav", "Beier", "Moukoko"
		],
		"Brésil": [
			"Pelé", "Ronaldo", "Romário", "Neymar", "Vinícius", "Rodrygo", "Rivaldo", "Bebeto", "Careca", "Jairzinho",
			"Garrincha", "Adriano", "Robinho", "Jesus", "Richarlison", "Endrick", "Raphinha", "Hulk", "Fred", "Fabiano",
			"da Silva", "de Menezes", "Vavá", "Zagallo", "Tostão", "Reinaldo", "Edmundo", "Amoroso", "Élber", "Firmino"
		],
		"Belgique": [
			"Lukaku", "Hazard", "Mertens", "Nilis", "Degryse", "Doku", "Openda", "Trossard", "Batshuayi", "Benteke",
			"Origi", "Bakayoko", "Saelemaekers", "Mirallas", "Van Himst", "Lambert", "Vandenbergh", "Claesen", "Weber", "Mpenza"
		],
		"Pays-Bas": [
			"van Basten", "van Nistelrooy", "Bergkamp", "Robben", "van Persie", "Kluivert", "Depay", "Gakpo", "Huntelaar", "Makaay",
			"Hasselbaink", "Malen", "Weghorst", "Zirkzee", "Keizer", "Rensenbrink", "Rep", "van der Kuijlen", "Kieft", "Bosman"
		],
		"Global": [
			"Messi", "Maradona", "Suárez", "Cavani", "Forlán", "Lewandowski", "Haaland", "Ibrahimovic", "Eto'o", "Drogba",
			"Salah", "Mané", "Osimhen", "Shevchenko", "Suker", "Stoichkov", "Weah", "Son", "Álvarez", "Martínez",
			"Crespo", "Batistuta", "Kempes", "Di María", "Tévez", "Agüero", "Higuaín", "Francescoli", "Salas", "Zamorano"
		]
	}
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

static func generate_unique_name(country: String, pos: Player.Position = Player.Position.FWD) -> String:
	var first_list: Array = FIRST_NAMES.get(country, FIRST_NAMES["France"])
	
	# Récupération des noms associés à la position et au pays
	var pos_dict: Dictionary = LAST_NAMES_BY_POS.get(pos, LAST_NAMES_BY_POS[Player.Position.FWD])
	var last_list: Array = pos_dict.get(country, [])
	if last_list.is_empty():
		last_list = pos_dict.get("Global", pos_dict["France"])
	
	# Tentative directe NOM CÉLÈBRE (majuscule) + prénom
	for attempt in 150:
		var last_name = last_list.pick_random()
		var first_name = first_list.pick_random()
		var candidate = "%s %s" % [last_name.to_upper(), first_name]
		if not registered_names.has(candidate):
			registered_names[candidate] = true
			return candidate
	
	# Si saturation sur le pays, puiser dans la liste globale de la même position
	var global_list: Array = pos_dict.get("Global", [])
	if not global_list.is_empty():
		for attempt in 100:
			var last_name = global_list.pick_random()
			var first_name = first_list.pick_random()
			var candidate = "%s %s" % [last_name.to_upper(), first_name]
			if not registered_names.has(candidate):
				registered_names[candidate] = true
				return candidate

	# Variantes avec suffixe pour garantir un nom unique tout en restant cohérent
	var last_picked = last_list.pick_random() if not last_list.is_empty() else "JOUEUR"
	var first_picked = first_list.pick_random()
	var base_candidate = "%s %s" % [last_picked.to_upper(), first_picked]
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

	return "JOUEUR %s" % str(pos)

static func create_random_player(country: String, pos: Player.Position, base_rating: int) -> Player:
	var p = Player.new()
	p.nationality = country
	p.position = pos
	p.full_name = generate_unique_name(country, pos)
	p.age = randi_range(18, 34)

	# Conversion échelle 20-99 : si base_rating est donné sur l'ancienne échelle (1-20), on convertit
	var target_ovr: int = base_rating
	if target_ovr <= 20:
		target_ovr = clampi(int(target_ovr * 3.8 + 24), 48, 92)

	var r = func(offset: int = 0):
		return clampi(target_ovr + offset + randi_range(-6, 6), 25, 99)

	match pos:
		Player.Position.GK:
			p.reflexes = r.call(10)
			p.defending = r.call(2)
			p.passing = r.call(-5)
			p.stamina = r.call(-2)
			p.speed = r.call(-12)
			p.shooting = clampi(r.call(-30), 20, 50)
			p.dribbling = clampi(r.call(-25), 20, 55)
		Player.Position.DEF:
			p.defending = r.call(10)
			p.stamina = r.call(5)
			p.speed = r.call(0)
			p.passing = r.call(-2)
			p.dribbling = r.call(-5)
			p.shooting = clampi(r.call(-18), 20, 65)
			p.reflexes = clampi(r.call(-25), 20, 50)
		Player.Position.MID:
			p.passing = r.call(8)
			p.dribbling = r.call(6)
			p.stamina = r.call(4)
			p.shooting = r.call(2)
			p.speed = r.call(0)
			p.defending = r.call(0)
			p.reflexes = clampi(r.call(-25), 20, 50)
		Player.Position.FWD:
			p.shooting = r.call(10)
			p.speed = r.call(6)
			p.dribbling = r.call(6)
			p.passing = r.call(-2)
			p.stamina = r.call(0)
			p.defending = clampi(r.call(-18), 20, 60)
			p.reflexes = clampi(r.call(-25), 20, 50)

	var actual_ovr = p.get_overall()
	if p.age <= 21:
		p.potential_min = clampi(actual_ovr + randi_range(2, 6), 55, 94)
		p.potential_max = clampi(p.potential_min + randi_range(6, 14), p.potential_min, 99)
	elif p.age <= 25:
		p.potential_min = clampi(actual_ovr - randi_range(1, 3), 50, 92)
		p.potential_max = clampi(actual_ovr + randi_range(3, 8), p.potential_min, 95)
	else:
		p.potential_min = clampi(actual_ovr - randi_range(2, 5), 45, 90)
		p.potential_max = clampi(actual_ovr + randi_range(0, 3), p.potential_min, 90)

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

static func create_youth_prospect(country: String, pos: Player.Position = Player.Position.MID) -> Player:
	var p = Player.new()
	p.nationality = country
	p.position = pos
	p.full_name = generate_unique_name(country, pos)
	p.age = randi_range(15, 18)
	p.is_youth_prospect = true

	# Note de départ de jeune pépite : 54 à 70
	var base_ovr = randi_range(54, 70)
	var r = func(offset: int = 0):
		return clampi(base_ovr + offset + randi_range(-5, 5), 35, 88)

	match pos:
		Player.Position.GK:
			p.reflexes = r.call(8)
			p.defending = r.call(0)
			p.passing = r.call(-6)
			p.stamina = r.call(-3)
			p.speed = r.call(-10)
			p.shooting = clampi(r.call(-25), 20, 45)
			p.dribbling = clampi(r.call(-20), 20, 50)
		Player.Position.DEF:
			p.defending = r.call(8)
			p.stamina = r.call(4)
			p.speed = r.call(0)
			p.passing = r.call(-4)
			p.dribbling = r.call(-5)
			p.shooting = clampi(r.call(-18), 20, 55)
			p.reflexes = clampi(r.call(-20), 20, 45)
		Player.Position.MID:
			p.passing = r.call(6)
			p.dribbling = r.call(6)
			p.stamina = r.call(2)
			p.shooting = r.call(0)
			p.speed = r.call(0)
			p.defending = r.call(-2)
			p.reflexes = clampi(r.call(-20), 20, 45)
		Player.Position.FWD:
			p.shooting = r.call(8)
			p.speed = r.call(6)
			p.dribbling = r.call(5)
			p.passing = r.call(-3)
			p.stamina = r.call(0)
			p.defending = clampi(r.call(-18), 20, 50)
			p.reflexes = clampi(r.call(-20), 20, 45)

	# Haut potentiel pour le centre de formation
	var actual_ovr = p.get_overall()
	p.potential_min = clampi(actual_ovr + randi_range(8, 14), 70, 88)
	p.potential_max = clampi(p.potential_min + randi_range(6, 15), p.potential_min, 99)

	if randf() > 0.4:
		p.trait_positive = POSITIVE_TRAITS.pick_random()
	if randf() > 0.6:
		p.trait_negative = NEGATIVE_TRAITS.pick_random()

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
