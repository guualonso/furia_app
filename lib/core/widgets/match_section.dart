import 'package:flutter/material.dart';
import 'package:furia_app/core/services/home_match_service.dart';

class MatchSection extends StatelessWidget {
  const MatchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HomeMatchService.getAllFuriaMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}', style: TextStyle(color: Colors.white));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Nenhuma partida encontrada.', style: TextStyle(color: Colors.white));
        }

        final matches = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Últimas Partidas da FURIA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...matches.take(10).map(
              (match) => Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: _buildMatchCard(match),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${match['team1']} vs ${match['team2']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamLogo(match['game'], match['team1_id'], match['team1_slug']),
              const SizedBox(width: 8),
              const Icon(Icons.sports_esports, color: Colors.white),
              const SizedBox(width: 8),
              _buildTeamLogo(match['game'], match['team2_id'], match['team2_slug']),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            match['tournament'],
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            match['date'],
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Placar: ${match['score']}',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildGameLogo(match['game'], match['game_logo']),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String game, String teamId, String teamSlug) {
    final normalizedGame = _normalizeGame(game);
    final logoPath = 'teams_logos/${normalizedGame}_${teamId}_$teamSlug.png';
    return Image.asset(
      logoPath,
      width: 64,
      height: 64,
      fit: BoxFit.contain,
      errorBuilder: (context, error, _) =>
          const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }

  Widget _buildGameLogo(String gameName, String? _) {
    final gameNameCorrections = {
      'LoL': 'League of Legends',
      'Counter-Strike': 'Counter-Strike 2',
    };

    final correctedName = gameNameCorrections[gameName] ?? gameName;
    final normalized = correctedName.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    final logoPath = '/games_logos/$normalized.png';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          logoPath,
          width: 60,
          height: 60,
          errorBuilder: (context, error, _) =>
              const Icon(Icons.videogame_asset, size: 40, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Text(
          correctedName,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _normalizeGame(String game) {
    final map = {
      'csgo': 'counter_strike_2',
      'lol': 'league_of_legends',
      'dota2': 'dota_2',
      'valorant': 'valorant',
      'overwatch2': 'overwatch_2',
      'rainbow6': 'rainbow_6_siege',
      'rocketleague': 'rocket_league',
    };

    final cleaned = game.replaceAll(' ', '').toLowerCase();
    return map[cleaned] ?? cleaned;
  }
}
