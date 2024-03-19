import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:trellodace/trello_api.dart';

void main() {
  final apiKey = '***';
  final token = '***';
  final trelloApi = TrelloApi(apiKey: apiKey, token: token);
  runApp(MyApp(trelloApi: trelloApi));
}

class MyApp extends StatelessWidget {
  final TrelloApi trelloApi; // Ajouter une référence à TrelloApi

  const MyApp({Key? key, required this.trelloApi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 1, 11, 38)),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'Trellodace', trelloApi: trelloApi),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.trelloApi})
      : super(key: key);
  final TrelloApi trelloApi;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: PhysicalModel(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.transparent,
                shadowColor: Colors.grey.withOpacity(0.5),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fillColor: const Color.fromARGB(255, 217, 217, 217),
                    labelText: 'Email',
                    hintText: 'Entrez votre email',
                    labelStyle: TextStyle(),
                  ),
                ),
              ),
            ),
            // Espacement entre le champ de formulaire et le bouton "Connexion"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: PhysicalModel(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.transparent,
                shadowColor: Colors.grey.withOpacity(0.5),
                child: TextFormField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    fillColor: const Color.fromARGB(255, 217, 217, 217),
                    labelText: 'Mot de passe',
                    hintText: 'Entrez votre mot de passe',
                    labelStyle: TextStyle(),
                  ),
                ),
              ),
            ),
            SizedBox(
                height:
                    20), // Espacement entre le bouton "Connexion" et le bouton "Inscription"
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SecondPage(trelloApi: widget.trelloApi)),
                );
              },
              child: Text('Connexion',
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                final List<Map<String, dynamic>> boards =
                    await widget.trelloApi.fetchBoards();
                List<String> boardNames = [];
                // Parcours des données et extraction des noms des tableaux
                for (var board in boards) {
                  String boardName =
                      board['name']; // Extraction du nom du tableau
                  boardNames
                      .add(boardName); // Ajout du nom du tableau à la liste
                }
                print('Noms des tableaux : $boardNames');
              },
              child: Text('Inscription',
                  style:
                      TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
                height:
                    100), // Espacement entre le bouton "Inscription" et le bouton "Sign up with Google"
            SignInButton(
              Buttons.Google,
              text: "Sign up with Google",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class SecondPage extends StatefulWidget {
  final TrelloApi trelloApi;
  SecondPage({required this.trelloApi});
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  List<String> boardNames = [];

  @override
  void initState() {
    super.initState();
    fetchBoardNames();
  }

  void fetchBoardNames() async {
    final List<Map<String, dynamic>>? boards =
        await widget.trelloApi.fetchBoards();

    if (boards != null) {
      List<String> names = [];
      for (var board in boards) {
        String name = board['name'] ?? '';
        names.add(name);
      }
      setState(() {
        boardNames = names;
      });
    } else {
      print('La liste des tableaux est null.');
    }
  }

  Future<void> showAddBoardDialog() async {
    TextEditingController _textFieldController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un tableau'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Nom du tableau"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                String boardName = _textFieldController.text;
                if (boardName.isNotEmpty) {
                  try {
                    // Création du tableau
                    final String boardId =
                        await widget.trelloApi.createBoard(boardName);
                    // Création des cartes automatiques
                    await widget.trelloApi.createCard(boardId, 'A faire');
                    await widget.trelloApi.createCard(boardId, 'En cours');
                    await widget.trelloApi.createCard(boardId, 'Terminé');
                    // Actualisation de la liste des tableaux après l'ajout du nouveau tableau
                    fetchBoardNames();
                  } catch (e) {
                    print('Erreur lors de la création du tableau : $e');
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vos tableaux'),
      ),
      body: ListView.builder(
        itemCount: boardNames.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(boardNames[index]),
              onTap: () async {
                final List<Map<String, dynamic>>? boards =
                    await widget.trelloApi.fetchBoards();

                if (boards != null) {
                  for (var board in boards) {
                    String boardName = board['name'] ?? '';
                    if (boardName == boardNames[index]) {
                      final String boardId = board['id'];
                      final List<String> cards =
                          await widget.trelloApi.fetchCards(boardId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            boardName: boardName,
                            trelloApi: widget.trelloApi,
                            boardId: boardId, // Ajoutez boardId ici
                            cards: cards,
                          ),
                        ),
                      );
                      return;
                    }
                  }
                  print(
                      'Aucun tableau trouvé avec le nom ${boardNames[index]}');
                } else {
                  print('La liste des tableaux est null.');
                }
              },
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            showAddBoardDialog();
          },
          child: Text('Ajouter un tableau'),
        ),
      ),
    );
  }
}

class Board {
  final String name;
  final List<String> cards;

  Board({required this.name, required this.cards});
}

List<Board> boards = [
  Board(
    name: 'Tableau 1',
    cards: ['Card 1.1', 'Card 1.2', 'Card 1.3'],
  ),
  Board(
    name: 'Tableau 2',
    cards: ['Card 2.1', 'Card 2.2'],
  ),
];

class DetailPage extends StatelessWidget {
  final String boardName;
  final TrelloApi trelloApi;
  final String boardId; // Ajoutez boardId comme paramètre requis
  final List<String> cards;

  DetailPage({
    required this.boardName,
    required this.trelloApi,
    required this.boardId,
    required this.cards, // Définissez cards comme un paramètre requis
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du tableau $boardName'),
      ),
      body: ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(cards[index]),
            ),
          );
        },
      ),
    );
  }
}
