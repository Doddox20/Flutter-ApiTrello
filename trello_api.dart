export 'trello_api.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class TrelloApi {
  final String apiKey;
  final String token;

  TrelloApi({required this.apiKey, required this.token});

  Future<http.Response> fetchBoardDetails(String boardId) {
    return http.get(
      Uri.https(
        'api.trello.com',
        '/1/boards/$boardId',
        {'key': apiKey, 'token': token},
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchBoards() async {
    final response = await http.get(
      Uri.https('api.trello.com', '/1/members/me/boards', {
        'key': apiKey,
        'token': token,
        'idOrganization': 'dorian51882812',
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map<Map<String, dynamic>>((board) => board as Map<String, dynamic>)
          .toList();
    } else {
      throw Exception('Failed to fetch boards');
    }
  }

  Future<String> createBoard(String name) async {
    final response = await http.post(
      Uri.https('api.trello.com', '/1/boards',
          {'key': apiKey, 'token': token, 'name': name}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // Si la création du tableau réussit, vous pouvez extraire l'ID du tableau de la réponse
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final String boardId = responseData['id'];
      return boardId; // Retourne l'ID du tableau créé
    } else {
      // Si la création échoue, lancez une exception avec le message d'erreur
      throw Exception('Failed to create board: ${response.statusCode}');
    }
  }

  Future<List<String>> fetchCards(String boardId) async {
    try {
      final cardsResponse = await http.get(
        Uri.https('api.trello.com', '/1/boards/$boardId/cards', {
          'key': apiKey,
          'token': token,
        }),
      );

      if (cardsResponse.statusCode == 200) {
        final List<dynamic> cardsData = jsonDecode(cardsResponse.body);
        return cardsData.map<String>((card) => card['name'] as String).toList();
      } else {
        throw Exception('Failed to fetch cards for board $boardId');
      }
    } catch (e) {
      throw Exception('Failed to fetch cards for board $boardId: $e');
    }
  }

  Future<List<String>> fetchTasks(String cardId) async {
    try {
      final response = await http.get(
        Uri.https('api.trello.com', '/1/cards/$cardId/checklists', {
          'key': apiKey,
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<String> tasks = [];
        for (var checklist in data) {
          for (var item in checklist['checkItems']) {
            tasks.add(item['name']);
          }
        }
        return tasks;
      } else {
        throw Exception(
            'Failed to fetch tasks for card: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch tasks for card: $e');
    }
  }

  Future<String> createCard(String boardId, String cardName) async {
    final response = await http.post(
      Uri.https('api.trello.com', '/1/cards',
          {'key': apiKey, 'token': token, 'idList': boardId, 'name': cardName}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final String cardId = responseData['id'];
      return cardId;
    } else {
      throw Exception('Failed to create card');
    }
  }

  Future<List<String>> fetchBoardLists(String boardId) async {
    try {
      final response = await http.get(
        Uri.https('api.trello.com', '/1/boards/$boardId/lists', {
          'key': apiKey,
          'token': token,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        List<String> listNames = [];
        for (var list in data) {
          listNames.add(list['name']);
        }
        return listNames;
      } else {
        throw Exception('Failed to fetch board lists');
      }
    } catch (e) {
      throw Exception('Failed to fetch board lists: $e');
    }
  }
}
