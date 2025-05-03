import 'package:flutter/material.dart';
import 'package:furia_app/core/services/match_service.dart';
import 'package:furia_app/core/shimmer/match_shimmer.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  int? _selectedGameId;
  bool _showFinished = false;
  late Future<List<Map<String, dynamic>>> _matchesFuture;
  late Future<List<Map<String, dynamic>>> _gamesFuture;
  late Future<Map<int, int>> _furiaTeamsFuture;

  final Map<String, String> _gameLogoMap = {
    'counter-strike': 'counterstrike2.png',
    'counter-strike-2': 'counterstrike2.png',
    'dota-2': 'dota2.png',
    'league-of-legends': 'leagueoflegends.png',
    'overwatch': 'overwatch.png',
    'pubg': 'pubg.png', 
    'rainbow-six': 'rainbowsix.png',
    'valorant': 'valorant.png',
    'rl': 'rocketleague.png',
  };

  @override
  void initState() {
    super.initState();
    _gamesFuture = MatchService.getVideogames();
    _furiaTeamsFuture = MatchService.getFuriaTeams();
    _matchesFuture = Future.value([]);
    _fetchInitialMatches();
  }

  Future<void> _fetchInitialMatches() async {
    try {
      final furiaTeams = await _furiaTeamsFuture;
      if (furiaTeams.isNotEmpty) {
        setState(() {
          _selectedGameId = furiaTeams.keys.first;
        });
        await _fetchMatches();
      }
    } catch (e) {
      debugPrint('Erro ao buscar times iniciais: $e');
    }
  }

  Future<void> _fetchMatches() async {
    if (_selectedGameId == null) return;

    try {
      final furiaTeams = await _furiaTeamsFuture;
      final teamId = furiaTeams[_selectedGameId];
      if (teamId == null) return;

      setState(() {
        _matchesFuture = MatchService.getFuriaMatches(
          teamId: teamId,
          finished: _showFinished,
        );
      });
    } catch (e) {
      debugPrint('Erro ao buscar partidas: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar partidas: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Partidas FURIA'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _furiaTeamsFuture = MatchService.getFuriaTeams();
            _gamesFuture = MatchService.getVideogames();
          });
          await _fetchInitialMatches();
        },
        child: Column(
          children: [
            FutureBuilder(
              future: Future.wait([_gamesFuture, _furiaTeamsFuture]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar jogos',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final games = snapshot.data?[0] as List<Map<String, dynamic>>? ?? [];
                final furiaTeams = snapshot.data?[1] as Map<int, int>? ?? {};

                final availableGames = games.where((game) => furiaTeams.containsKey(game['id'])).toList();

                if (availableGames.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Nenhum jogo com times da FURIA disponível.'),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: availableGames.map((game) {
                      final isSelected = game['id'] == _selectedGameId;
                      final gameSlug = game['slug'];
                      final logoFile = _gameLogoMap[gameSlug] ?? 'counterstrike2.png';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedGameId = game['id'];
                          });
                          _fetchMatches();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                            ),
                          ),
                          child: Image.asset(
                            '/games_logos/$logoFile',
                            width: 48,
                            height: 48,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.videogame_asset, size: 48),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text("Finalizadas"),
                  Switch(
                    value: _showFinished,
                    onChanged: (val) {
                      setState(() {
                        _showFinished = val;
                      });
                      _fetchMatches();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _matchesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 5,
                      itemBuilder: (context, index) => const MatchShimmer(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 40),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar partidas',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchMatches,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_esports, size: 40),
                          SizedBox(height: 16),
                          Text('Nenhuma partida encontrada.'),
                        ],
                      ),
                    );
                  } else {
                    final matches = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return _buildMatchCard(match);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
    );
  }

  Widget _buildTeamLogo(String gameSlug, String teamId, String teamSlug) {
    final normalizedGame = _normalizeGame(gameSlug);
    final logoPath = 'assets/teams_logos/${normalizedGame}_${teamId}_$teamSlug.png';
    
    return Image.asset(
      logoPath,
      width: 64,
      height: 64,
      fit: BoxFit.contain,
      errorBuilder: (context, error, _) =>
          const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }

  String _normalizeGame(String gameSlug) {
    if (gameSlug == 'league-of-legends') return 'lol';
    if (gameSlug == 'rl') return 'Rocket_League';
    return gameSlug.replaceAll('-', '');
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            match['tournament'] ?? 'Campeonato desconhecido',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTeamLogo(
                match['game_slug'] ?? '',
                match['team1_id']?.toString() ?? '',
                match['team1_slug'] ?? '',
              ),
              Column(
                children: [
                  Text(
                    match['score'] ?? '-',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    match['date'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              _buildTeamLogo(
                match['game_slug'] ?? '',
                match['team2_id']?.toString() ?? '',
                match['team2_slug'] ?? '',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${match['team1']} vs ${match['team2']}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}