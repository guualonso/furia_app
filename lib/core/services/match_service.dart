import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class MatchService {
  static Future<List<Map<String, dynamic>>> getFuriaMatches() async {
    final String token = dotenv.env['PANDASCORE_API_KEY']!;
    final int furiaId = 124530; // ID da FURIA CS2

    final matchesUrl =
        'https://api.pandascore.co/matches?filter[opponent_id]=$furiaId&filter[status]=finished&page[size]=50';

    final response = await http.get(
      Uri.parse(matchesUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);

      return data.map<Map<String, dynamic>>((match) {
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

        // Prevenção para o caso de vir menos de 2 oponentes
        final team1 = opponents.isNotEmpty ? opponents[0] : {'name': 'TBD', 'image_url': null};
        final team2 = opponents.length > 1 ? opponents[1] : {'name': 'TBD', 'image_url': null};

        // Função para obter a URL da imagem normalizada ou uma imagem padrão
        String getNormalizedImageUrl(String? imageUrl) {
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final uri = Uri.parse(imageUrl);
            final segments = uri.pathSegments;
            if (segments.length >= 2) {
              final id = segments[segments.length - 2];
              final filename = segments.last;
              final normalizedFilename = 'normal_$filename';
              return 'https://cdn.pandascore.co/images/team/image/$id/$normalizedFilename';
            }
          }
          // Imagem padrão caso imageUrl seja null ou inválido
          return 'https://via.placeholder.com/150';
        }

        final logo1 = getNormalizedImageUrl(team1['image_url']);
        final logo2 = getNormalizedImageUrl(team2['image_url']);

        final results = match['results'] as List? ?? [];
        final score1 =
            results.isNotEmpty ? results[0]['score'].toString() : '0';
        final score2 =
            results.length > 1 ? results[1]['score'].toString() : '0';

        return {
          'team1': team1['name'],
          'team1_logo': logo1,
          'team2': team2['name'],
          'team2_logo': logo2,
          'date': formattedDate,
          'score': '$score1 - $score2',
          'game': match['videogame']?['name'] ?? 'Desconhecido',
          'tournament':
              '${match['league']?['name'] ?? 'Liga Desconhecida'} - ${match['serie']?['name'] ?? 'Série Desconhecida'} - ${match['tournament']?['name'] ?? 'Estágio Desconhecido'}',
        };
      }).toList();
    } else {
      throw Exception('Erro ao buscar partidas: ${response.body}');
    }
  }
}
