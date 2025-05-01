import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class HomeMatchService {
  static const List<int> furiaTeamIds = [
    136455, 129384, 128933, 128523, 128477,
    127596, 126886, 126714, 126688, 126093, 124530
  ];

  static Future<List<Map<String, dynamic>>> getAllFuriaMatches() async {
    final String token = dotenv.env['PANDASCORE_API_KEY']!;
    final List<Map<String, dynamic>> allMatches = [];
    final Set<int> seenMatchIds = {}; // evita duplicatas

    for (final teamId in furiaTeamIds) {
      final url =
          'https://api.pandascore.co/matches?filter[opponent_id]=$teamId&filter[status]=finished&page[size]=10';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        for (var match in data) {
          final matchId = match['id'];
          if (seenMatchIds.contains(matchId)) continue;
          seenMatchIds.add(matchId);

          final dateStr = match['end_at'] ?? match['begin_at'];
          final date = dateStr != null
              ? DateTime.parse(dateStr).subtract(const Duration(hours: 3))
              : null;
          final formattedDate = date != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(date)
              : 'Data desconhecida';
          final opponents = (match['opponents'] as List)
              .map((o) => o['opponent'] as Map<String, dynamic>)
              .toList();

          final team1 =
              opponents.isNotEmpty ? opponents[0] : {'name': 'TBD', 'image_url': null};
          final team2 =
              opponents.length > 1 ? opponents[1] : {'name': 'TBD', 'image_url': null};

          final score = match['results'] as List? ?? [];
          final score1 = score.isNotEmpty ? score[0]['score'].toString() : '0';
          final score2 = score.length > 1 ? score[1]['score'].toString() : '0';

          allMatches.add({
            'team1': team1['name'],
            'team1_logo': normalizeImageUrl(team1['image_url']),
            'team1_id': team1['id'].toString(),
            'team1_slug': team1['slug'] ?? 'slug-desconhecido',

            'team2': team2['name'],
            'team2_logo': normalizeImageUrl(team2['image_url']),
            'team2_id': team2['id'].toString(),
            'team2_slug': team2['slug'] ?? 'slug-desconhecido',

            'date': formattedDate,
            'score': '$score1 - $score2',
            'game': match['videogame']?['name'] ?? 'Desconhecido',
            'game_logo': normalizeImageUrl(match['videogame']?['image_url']),
            'tournament':
                '${match['league']?['name'] ?? 'Liga Desconhecida'} - ${match['serie']?['name'] ?? 'Série Desconhecida'} - ${match['tournament']?['name'] ?? 'Estágio Desconhecido'}',
          });
        }
      }
    }

    allMatches.sort((a, b) => b['date'].compareTo(a['date']));
    return allMatches;
  }

  static String normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return 'https://via.placeholder.com/150';
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.length >= 2) {
      return 'http://192.168.15.8:3000/proxy-image?url=$url';
    }
    return url;
  }
}
