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
			"Diego López", "Asenjo", "Arconada", "Buyo", "Remiro", "Pacheco", "Soria", "Guaita", "Moyà", "Molina",
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
			"Diogo Costa", "Patrício", "José Sá", "Vítor Baía", "Ricardo", "Eduardo", "Beto", "Manuel Bento", "Quim", "Anthony Lopes",
			"Hilário", "Rui Silva", "Maximiano", "Bruno Varela", "Damas", "Silvino", "Costinha", "Moreira", "Kieszek", "Marafona"
		],
		"Allemagne": [
			"Neuer", "Kahn", "ter Stegen", "Maier", "Lehmann", "Trapp", "Leno", "Baumann", "Köpke", "Schumacher",
			"Illgner", "Adler", "Hildebrand", "Nübel", "Rost", "Butt", "Weidenfeller", "Zieler", "Karius", "Enke",
			"Reck", "Immel", "Kleff", "Tilkowski", "Fährmann", "Schwolow", "Zentner", "Blaswich", "Dahmen", "Atubolu"
		],
		"Brésil": [
			"Alisson", "Ederson", "Dida", "Júlio César", "Taffarel", "Rogério Ceni", "Marcos", "Bento", "Lucas Perri", "Neto",
			"Weverton", "Diego Alves", "Helton", "Leão", "Manga", "Gilmar", "Castilho", "Waldir Peres", "Carlos", "Zetti",
			"Danrlei", "Velloso", "Doni", "Gabriel Vasconcelos", "Everson", "Santos", "Grohe", "Jailson", "Cássio", "Fábio"
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
			"Yashin", "Schmeichel", "Oblak", "Keylor Navas", "Chilavert", "Higuita", "Cech", "Sommer", "Bounou", "Dibu Martínez",
			"Muslera", "Ochoa", "Handanovic", "Szczesny", "Dudek", "Goycochea", "Sergio Romero", "Livakovic", "Onana", "Édouard Mendy",
			"Kobel", "Lunin", "Trubin", "David Ospina", "Claudio Bravo", "Jorge Campos", "Thomas N'Kono", "Vincent Enyeama"
		]
	},
	Player.Position.DEF: {
		"France": [
			"Thuram", "Desailly", "Blanc", "Varane", "Koundé", "Upamecano", "Saliba", "Theo Hernández", "Lucas Hernández", "Pavard",
			"Sagnol", "Lizarazu", "Abidal", "Evra", "Umtiti", "Kimpembe", "Konaté", "Ferland Mendy", "Digne", "Gallas",
			"Sagna", "Clichy", "Mexès", "Leboeuf", "Amoros", "Bossis", "Trésor", "Battiston", "Sakho", "Zouma",
			"Disasi", "Badiashile", "Todibo", "Kalulu", "Gusto", "Lukeba", "Simakan", "Clauss", "Sidibé", "Debuchy"
		],
		"Espagne": [
			"Sergio Ramos", "Puyol", "Piqué", "Hierro", "Carvajal", "Jordi Alba", "Laporte", "Le Normand", "Cucurella", "Grimaldo",
			"Azpilicueta", "Nacho", "Arbeloa", "Capdevila", "Míchel Salgado", "Marchena", "Albiol", "Juanfran", "Bartra", "Pau Torres",
			"Pedro Porro", "Balde", "Gayà", "Íñigo Martínez", "Vivian", "Camacho", "Gordillo", "Manolo Sanchís", "Miguel Ángel Nadal", "Abelardo"
		],
		"Italie": [
			"Maldini", "Baresi", "Cannavaro", "Nesta", "Chiellini", "Bonucci", "Scirea", "Bergomi", "Costacurta", "Ciro Ferrara",
			"Zambrotta", "Panucci", "Materazzi", "Barzagli", "Bastoni", "Dimarco", "Calafiori", "Di Lorenzo", "Acerbi", "Gianluca Mancini",
			"Darmian", "Spinazzola", "Pessotto", "Mauro Tassotti", "Claudio Gentile", "Cabrini", "Vierchowod", "Burgnich", "Facchetti", "Grosso"
		],
		"Angleterre": [
			"Rio Ferdinand", "John Terry", "Sol Campbell", "Bobby Moore", "Kyle Walker", "John Stones", "Harry Maguire", "Alexander-Arnold", "Luke Shaw", "Trippier",
			"Ashley Cole", "Gary Neville", "Tony Adams", "Martin Keown", "Jamie Carragher", "Gary Cahill", "Gareth Southgate", "Ledley King", "Marc Guéhi", "Ezri Konsa",
			"Joe Gomez", "Reece James", "Ben Chilwell", "Dan Burn", "Lewis Dunk", "Chris Smalling", "Phil Jones", "Phil Jagielka", "Joleon Lescott", "Leighton Baines"
		],
		"Portugal": [
			"Pepe", "Rúben Dias", "Ricardo Carvalho", "Bruno Alves", "Cancelo", "Nuno Mendes", "Dalot", "Raphaël Guerreiro", "José Fonte", "Nélson Semedo",
			"Danilo Pereira", "Gonçalo Inácio", "António Silva", "Fernando Couto", "Secretário", "Paulo Ferreira", "Bosingwa", "Fábio Coentrão", "Miguel", "Jorge Andrade"
		],
		"Allemagne": [
			"Beckenbauer", "Jürgen Kohler", "Matthias Sammer", "Mats Hummels", "Antonio Rüdiger", "Jérôme Boateng", "Philipp Lahm", "Paul Breitner", "Joshua Kimmich", "Jonathan Tah",
			"Nico Schlotterbeck", "David Raum", "Robin Gosens", "Per Mertesacker", "Arne Friedrich", "Christoph Metzelder", "Jens Nowotny", "Thomas Helmer", "Guido Buchwald", "Klaus Augenthaler"
		],
		"Brésil": [
			"Cafu", "Roberto Carlos", "Thiago Silva", "Marquinhos", "Lúcio", "Juan", "Dani Alves", "Marcelo", "Maicon", "Aldair",
			"Léo Júnior", "Carlos Alberto", "Gabriel Magalhães", "Bremer", "Éder Militão", "Danilo", "Alex Sandro", "David Luiz", "Miranda", "Roque Júnior"
		],
		"Belgique": [
			"Vincent Kompany", "Jan Vertonghen", "Toby Alderweireld", "Daniel Van Buyten", "Thomas Vermaelen", "Thomas Meunier", "Timothy Castagne", "Arthur Theate", "Wout Faes", "Zeno Debast",
			"Philippe Albert", "Michel Renquin", "Walter Meeuws", "Eric Gerets", "Dedryck Boyata", "Christian Kabasele", "Sebastiaan Bornauw", "Koni De Winter", "Maxim De Cuyper", "Björn Engels"
		],
		"Pays-Bas": [
			"Virgil van Dijk", "Ronald Koeman", "Matthijs de Ligt", "Jaap Stam", "Stefan de Vrij", "Nathan Aké", "Denzel Dumfries", "Daley Blind", "Van Bronckhorst", "Frank de Boer",
			"Michael Reiziger", "Ruud Krol", "Jan Paul van Hecke", "Jurriën Timber", "Lutsharel Geertruida", "Sven Botman", "Micky van de Ven", "John Heitinga", "Joris Mathijsen", "Khalid Boulahrouz"
		],
		"Global": [
			"Diego Godín", "Diego Lugano", "Javier Zanetti", "Roberto Ayala", "Daniel Passarella", "Cristian Romero", "Nicolás Otamendi", "Lisandro Martínez", "Kalidou Koulibaly", "Edmond Tapsoba",
			"David Alaba", "Nemanja Vidic", "Milan Skriniar", "Josko Gvardiol", "Stefan Savic", "Simon Kjaer", "Nayef Aguerd", "Achraf Hakimi", "Paolo Montero", "Juan Pablo Sorín"
		]
	},
	Player.Position.MID: {
		"France": [
			"Zidane", "Platini", "Vieira", "Kanté", "Pogba", "Makelele", "Camavinga", "Tchouaméni", "Rabiot", "Matuidi",
			"Deschamps", "Pirès", "Tigana", "Giresse", "Luis Fernandez", "Emmanuel Petit", "Alou Diarra", "Toulalan", "Cabaye", "Moussa Sissoko",
			"Youssouf Fofana", "Zaïre-Emery", "Guendouzi", "Gourcuff", "Nasri", "Payet", "Valbuena", "Rothen", "Micoud", "Pedretti"
		],
		"Espagne": [
			"Xavi", "Iniesta", "Busquets", "Rodri", "Xabi Alonso", "Cesc Fàbregas", "David Silva", "Santi Cazorla", "Pedri", "Gavi",
			"Koke", "Thiago Alcântara", "Isco", "Juan Mata", "Pep Guardiola", "Luis Enrique", "Marcos Senna", "Mikel Arteta", "Mikel Merino", "Fabián Ruiz",
			"Martín Zubimendi", "Dani Olmo", "Álex Baena", "Carlos Soler", "Dani Ceballos", "Míchel", "José Mari Bakero", "Julen Guerrero", "Juan Carlos Valerón", "Iván de la Peña"
		],
		"Italie": [
			"Andrea Pirlo", "Gennaro Gattuso", "Daniele De Rossi", "Nicolò Barella", "Marco Verratti", "Marco Tardelli", "Carlo Ancelotti", "Demetrio Albertini", "Claudio Marchisio", "Jorginho",
			"Lorenzo Pellegrini", "Sandro Tonali", "Manuel Locatelli", "Davide Frattesi", "Giuseppe Giannini", "Roberto Donadoni", "Romeo Benetti", "Giancarlo Antognoni", "Damiano Tommasi", "Simone Perrotta"
		],
		"Angleterre": [
			"Steven Gerrard", "Frank Lampard", "Paul Scholes", "David Beckham", "Jude Bellingham", "Declan Rice", "Phil Foden", "Paul Gascoigne", "Bryan Robson", "Glenn Hoddle",
			"Jordan Henderson", "Michael Carrick", "Gareth Barry", "James Milner", "Jack Wilshere", "Paul Ince", "David Platt", "Chris Waddle", "Kobbie Mainoo", "James Maddison"
		],
		"Portugal": [
			"Deco", "Rui Costa", "Bernardo Silva", "Bruno Fernandes", "João Moutinho", "Luís Figo", "Paulo Sousa", "Tiago Mendes", "Maniche", "Costinha",
			"Vitinha", "João Palhinha", "Rúben Neves", "Otávio", "Renato Sanches", "Matheus Nunes", "João Neves", "William Carvalho", "Adrien Silva", "Miguel Veloso"
		],
		"Allemagne": [
			"Toni Kroos", "Lothar Matthäus", "Bastian Schweinsteiger", "Michael Ballack", "Mesut Özil", "Ilkay Gündogan", "Florian Wirtz", "Jamal Musiala", "Sami Khedira", "Stefan Effenberg",
			"Pierre Littbarski", "Wolfgang Overath", "Günter Netzer", "Andreas Möller", "Thomas Hässler", "Torsten Frings", "Dietmar Hamann", "Leon Goretzka", "Robert Andrich", "Aleksandar Pavlovic"
		],
		"Brésil": [
			"Ronaldinho", "Kaká", "Zico", "Sócrates", "Falcão", "Casemiro", "Dunga", "Rivaldo", "Juninho Pernambucano", "Gilberto Silva",
			"Fernandinho", "Fabinho", "Lucas Paquetá", "Bruno Guimarães", "Douglas Luiz", "Zé Roberto", "Émerson", "Toninho Cerezo", "Gérson", "Diego Ribas"
		],
		"Belgique": [
			"Kevin De Bruyne", "Eden Hazard", "Youri Tielemans", "Axel Witsel", "Marouane Fellaini", "Mousa Dembélé", "Enzo Scifo", "Franky Van der Elst", "Jan Ceulemans", "Orel Mangala",
			"Amadou Onana", "Arthur Vermeeren", "Dennis Praet", "Steven Defour", "Ludo Coeck", "René Vandereycken", "Frank Vercauteren", "Radja Nainggolan", "Nacer Chadli", "Leander Dendoncker"
		],
		"Pays-Bas": [
			"Johan Cruyff", "Ruud Gullit", "Frank Rijkaard", "Wesley Sneijder", "Frenkie de Jong", "Edgar Davids", "Clarence Seedorf", "Mark van Bommel", "Johan Neeskens", "Teun Koopmeiners",
			"Tijjani Reijnders", "Jerdy Schouten", "Georginio Wijnaldum", "Kevin Strootman", "Donny van de Beek", "Xavi Simons", "Ryan Gravenberch", "Willem van Hanegem", "Aron Winter", "Philip Cocu"
		],
		"Global": [
			"Luka Modric", "Ivan Rakitic", "Zvonimir Boban", "Robert Prosinecki", "Pavel Nedved", "Marek Hamsik", "Giorgian de Arrascaeta", "Federico Valverde", "Rodrigo Bentancur", "Alexis Mac Allister",
			"Rodrigo De Paul", "Enzo Fernández", "Fernando Redondo", "Diego Simeone", "Juan Román Riquelme", "Juan Sebastián Verón", "Michael Essien", "Yaya Touré", "Thomas Partey", "Mohammed Kudus"
		]
	},
	Player.Position.FWD: {
		"France": [
			"Kylian Mbappé", "Thierry Henry", "Karim Benzema", "Antoine Griezmann", "Éric Cantona", "Jean-Pierre Papin", "David Trezeguet", "Just Fontaine", "Raymond Kopa", "Olivier Giroud",
			"Ousmane Dembélé", "Bradley Barcola", "Kingsley Coman", "Hatem Ben Arfa", "Djibril Cissé", "Sylvain Wiltord", "Christophe Dugarry", "Nicolas Anelka", "Sidney Govou", "David Ginola",
			"Dominique Rocheteau", "Alexandre Lacazette", "Wissam Ben Yedder", "Marcus Thuram", "Randal Kolo Muani", "Christopher Nkunku", "André-Pierre Gignac", "Florian Thauvin", "Anthony Martial", "Martin Terrier"
		],
		"Espagne": [
			"Raúl González", "David Villa", "Fernando Torres", "Álvaro Morata", "Emilio Butragueño", "Fernando Morientes", "Lamine Yamal", "Nico Williams", "Ferran Torres", "Mikel Oyarzabal",
			"Iago Aspas", "Pedro Rodríguez", "Fernando Llorente", "Álvaro Negredo", "Roberto Soldado", "Julio Salinas", "Santillana", "Paco Gento", "Amancio Amaro", "Diego Costa",
			"Gerard Moreno", "Joselu", "Telmo Zarra", "Alfredo Di Stéfano", "Ferenc Puskás", "Quini", "Diego Tristán", "Iker Muniain", "Samu Omorodion", "Ayoze Pérez"
		],
		"Italie": [
			"Roberto Baggio", "Alessandro Del Piero", "Francesco Totti", "Paolo Rossi", "Gigi Riva", "Christian Vieri", "Filippo Inzaghi", "Luca Toni", "Gianluca Vialli", "Roberto Mancini",
			"Federico Chiesa", "Ciro Immobile", "Gianluca Scamacca", "Mateo Retegui", "Alberto Gilardino", "Mario Balotelli", "Antonio Di Natale", "Giuseppe Signori", "Gianfranco Zola", "Salvatore Schillaci",
			"Roberto Boninsegna", "Sandro Mazzola", "Giacomo Raspadori", "Moise Kean", "Giuseppe Meazza", "Silvio Piola", "Roberto Bettega", "Francesco Graziani", "Roberto Pruzzo", "Alessandro Altobelli"
		],
		"Angleterre": [
			"Harry Kane", "Alan Shearer", "Wayne Rooney", "Michael Owen", "Gary Lineker", "Bobby Charlton", "Bukayo Saka", "Raheem Sterling", "Marcus Rashford", "Ollie Watkins",
			"Ivan Toney", "Robbie Fowler", "Ian Wright", "Andy Cole", "Teddy Sheringham", "Les Ferdinand", "Jermain Defoe", "Emile Heskey", "Peter Crouch", "Daniel Sturridge",
			"Jamie Vardy", "Jimmy Greaves", "Geoff Hurst", "Cole Palmer", "Anthony Gordon", "Dixie Dean", "Nat Lofthouse", "Tom Finney", "Kevin Keegan", "Dominic Solanke"
		],
		"Portugal": [
			"Cristiano Ronaldo", "Eusébio", "Pedro Pauleta", "Nani", "Rafael Leão", "Diogo Jota", "João Félix", "Nuno Gomes", "Paulo Futre", "Simão Sabrosa",
			"Ricardo Quaresma", "Gonçalo Ramos", "Pedro Neto", "Francisco Conceição", "Hugo Almeida", "Hélder Postiga", "Liédson", "Fernando Peyroteo", "Matateu", "José Águas",
			"Rui Jordão", "Fernando Gomes", "André Silva", "Gonçalo Guedes", "Fábio Silva", "Silvestre Varela", "Éder", "Domingos Paciência", "Dani Carvalho", "Bruma"
		],
		"Allemagne": [
			"Gerd Müller", "Miroslav Klose", "Karl-Heinz Rummenigge", "Jürgen Klinsmann", "Rudi Völler", "Uwe Seeler", "Kai Havertz", "Niclas Füllkrug", "Serge Gnabry", "Leroy Sané",
			"Mario Gomez", "Oliver Bierhoff", "Lukas Podolski", "André Schürrle", "Timo Werner", "Stefan Kießling", "Kevin Kuranyi", "Oliver Neuville", "Klaus Fischer", "Jupp Heynckes",
			"Fritz Walter", "Helmut Rahn", "Bernd Hölzenbein", "Karl-Heinz Riedle", "Ulf Kirsten", "Fredi Bobic", "Gerald Asamoah", "Deniz Undav", "Maximilian Beier", "Youssoufa Moukoko"
		],
		"Brésil": [
			"Pelé", "Ronaldo Fenômeno", "Romário", "Neymar Jr", "Vinícius Júnior", "Rodrygo", "Rivaldo", "Bebeto", "Careca", "Jairzinho",
			"Garrincha", "Adriano Imperador", "Robinho", "Gabriel Jesus", "Richarlison", "Endrick", "Raphinha", "Hulk", "Fred", "Luís Fabiano",
			"Leônidas da Silva", "Ademir de Menezes", "Vavá", "Mário Zagallo", "Tostão", "Reinaldo", "Edmundo", "Márcio Amoroso", "Giovane Élber", "Roberto Firmino"
		],
		"Belgique": [
			"Romelu Lukaku", "Eden Hazard", "Dries Mertens", "Luc Nilis", "Marc Degryse", "Jérémy Doku", "Loïs Openda", "Leandro Trossard", "Michy Batshuayi", "Christian Benteke",
			"Divock Origi", "Johan Bakayoko", "Alexis Saelemaekers", "Kevin Mirallas", "Paul Van Himst", "Raoul Lambert", "Erwin Vandenbergh", "Nico Claesen", "Josip Weber", "Mbo Mpenza"
		],
		"Pays-Bas": [
			"Marco van Basten", "Ruud van Nistelrooy", "Dennis Bergkamp", "Arjen Robben", "Robin van Persie", "Patrick Kluivert", "Memphis Depay", "Cody Gakpo", "Klaas-Jan Huntelaar", "Roy Makaay",
			"Jimmy Floyd Hasselbaink", "Donyell Malen", "Wout Weghorst", "Joshua Zirkzee", "Piet Keizer", "Rob Rensenbrink", "Johnny Rep", "Willy van der Kuijlen", "Wim Kieft", "John Bosman"
		],
		"Global": [
			"Lionel Messi", "Diego Maradona", "Luis Suárez", "Edinson Cavani", "Diego Forlán", "Robert Lewandowski", "Erling Haaland", "Zlatan Ibrahimovic", "Samuel Eto'o", "Didier Drogba",
			"Mohamed Salah", "Sadio Mané", "Victor Osimhen", "Andriy Shevchenko", "Davor Suker", "Hristo Stoichkov", "George Weah", "Son Heung-min", "Julián Álvarez", "Lautaro Martínez",
			"Hernán Crespo", "Gabriel Batistuta", "Mario Kempes", "Ángel Di María", "Carlos Tévez", "Sergio Agüero", "Gonzalo Higuaín", "Enzo Francescoli", "Marcelo Salas", "Iván Zamorano"
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
	
	# Tentative directe prénom + nom célèbre de cette position
	for attempt in 150:
		var candidate = "%s %s" % [first_list.pick_random(), last_list.pick_random()]
		if not registered_names.has(candidate):
			registered_names[candidate] = true
			return candidate
	
	# Si saturation sur le pays, puiser dans la liste globale de la même position
	var global_list: Array = pos_dict.get("Global", [])
	if not global_list.is_empty():
		for attempt in 100:
			var candidate = "%s %s" % [first_list.pick_random(), global_list.pick_random()]
			if not registered_names.has(candidate):
				registered_names[candidate] = true
				return candidate

	# Variantes avec suffixe pour garantir un nom unique tout en restant cohérent
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

	return "Joueur %s" % str(pos)

static func create_random_player(country: String, pos: Player.Position, base_rating: int) -> Player:
	var p = Player.new()
	p.nationality = country
	p.position = pos
	p.full_name = generate_unique_name(country, pos)
	p.age = randi_range(18, 34)

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
