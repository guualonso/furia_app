import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class MatchService {
  static Future<List<Map<String, dynamic>>> getFuriaMatches({
    required int teamId,
    required bool finished,
  }) async {
    try {
      final String token = dotenv.env['PANDASCORE_API_KEY']!;
      final String status = finished ? 'finished' : 'upcoming';

      final now = DateTime.now().toUtc().toIso8601String();
      final dateFilter = finished ? '' : '&filter[begin_at_after]=$now';

      final matchesUrl =
        'https://api.pandascore.co/matches?filter[opponent_id]=$teamId'
        '&filter[status]=$status'
        '$dateFilter'
        '&page[size]=50'
        '&sort=${finished ? '-end_at' : 'begin_at'}';
        
      final response = await http.get(
        Uri.parse(matchesUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isEmpty) return [];

        return data.map<Map<String, dynamic>>((match) {
          final dateStr = match['end_at'] ?? match['begin_at'];
          final date = dateStr != null
              ? DateTime.parse(dateStr).toLocal()
              : null;
          final formattedDate = date != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(date)
              : 'Data desconhecida';

          final opponents = (match['opponents'] as List?)
              ?.map((o) => o['opponent'] as Map<String, dynamic>?)
              .where((o) => o != null)
              .cast<Map<String, dynamic>>()
              .toList() ?? [];

          final team1 = opponents.isNotEmpty ? opponents[0] : {'name': 'TBD', 'image_url': null, 'id': null, 'slug': ''};
          final team2 = opponents.length > 1 ? opponents[1] : {'name': 'TBD', 'image_url': null, 'id': null, 'slug': ''};

          final results = match['results'] as List? ?? [];
          final score1 = results.isNotEmpty ? results[0]['score']?.toString() ?? '0' : '0';
          final score2 = results.length > 1 ? results[1]['score']?.toString() ?? '0' : '0';

          return {
            'team1': team1['name'] ?? 'TBD',
            'team1_id': team1['id'],
            'team1_slug': team1['slug'] ?? '',
            'team2': team2['name'] ?? 'TBD',
            'team2_id': team2['id'],
            'team2_slug': team2['slug'] ?? '',
            'date': formattedDate,
            'score': finished ? '$score1 - $score2' : 'A confirmar',
            'game_slug': match['videogame']?['slug'] ?? '',
            'tournament': match['league']?['name'] ?? 'Liga Desconhecida',
          };
        }).toList();
      } else {
        throw Exception('Erro ao buscar partidas: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro no getFuriaMatches: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getVideogames() async {
    try {
      final apiKey = dotenv.env['PANDASCORE_API_KEY']!;
      final url = Uri.parse('https://api.pandascore.co/videogames');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map<Map<String, dynamic>>((item) => {
          'id': item['id'],
          'name': item['name'],
          'slug': item['slug'],
          'image_url': item['image_url'] ?? '',
        }).toList();
      } else {
        throw Exception('Erro ao buscar videogames: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro no getVideogames: $e');
      }
      rethrow;
    }
  }

  static Future<Map<int, int>> getFuriaTeams() async {
    try {
      final apiKey = dotenv.env['PANDASCORE_API_KEY']!;
      final response = await http.get(
        Uri.parse('https://api.pandascore.co/teams?search[name]=furia'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> teams = json.decode(response.body);
        final Map<int, int> result = {};

        for (var team in teams) {
          if (team['current_videogame'] != null) {
            final gameId = team['current_videogame']['id'];
            final teamId = team['id'];
            result[gameId] = teamId;
          }
        }

        return result;
      } else {
        throw Exception('Erro ao buscar times da FURIA: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro no getFuriaTeams: $e');
      }
      rethrow;
    }
  }
}