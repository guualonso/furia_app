import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Estatísticas FURIA CS:GO'),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeamOverview(),
            const SizedBox(height: 24),
            _buildPlayerStats(),
            const SizedBox(height: 24),
            _buildRecentMatches(),
            const SizedBox(height: 24),
            _buildMapsPerformance(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamOverview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Visão Geral do Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Ranking Mundial', '#7', Icons.emoji_events),
                _buildStatCard('Vitórias', '24', Icons.check_circle),
                _buildStatCard('Derrotas', '8', Icons.cancel),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.75, 
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 12,
            ),
            const SizedBox(height: 8),
            const Text(
              'Taxa de Vitórias: 75%',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPlayerStats() {
    final players = [
      {'name': 'KSCERATO', 'rating': 1.25, 'kills': 832, 'deaths': 650},
      {'name': 'yuurih', 'rating': 1.18, 'kills': 790, 'deaths': 680},
      {'name': 'FalleN', 'rating': 1.21, 'kills': 720, 'deaths': 710},
      {'name': 'MOLODOY', 'rating': 0.98, 'kills': 650, 'deaths': 670},
      {'name': 'YEKINDAR', 'rating': 1.12, 'kills': 700, 'deaths': 690},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Desempenho dos Jogadores',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...players.map((player) => _buildPlayerRow(
                  player['name'] as String,
                  player['rating'] as double,
                  player['kills'] as int,
                  player['deaths'] as int,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(String name, double rating, int kills, int deaths) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          CircularPercentIndicator(
            radius: 20,
            lineWidth: 4,
            percent: rating / 2,
            center: Text(
              rating.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12),
            ),
            progressColor: rating > 1.1 ? Colors.green : rating > 0.9 ? Colors.orange : Colors.red,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$kills kills'),
                Text('$deaths deaths'),
                Text(
                  'K/D: ${(kills / deaths).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: (kills / deaths) > 1 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatches() {
    final matches = [
      {'opponent': 'Team Liquid', 'result': 'VITÓRIA', 'score': '16-12', 'date': '02/05/2023'},
      {'opponent': 'FaZe Clan', 'result': 'DERROTA', 'score': '10-16', 'date': '28/04/2023'},
      {'opponent': 'Natus Vincere', 'result': 'VITÓRIA', 'score': '19-17', 'date': '25/04/2023'},
      {'opponent': 'G2 Esports', 'result': 'VITÓRIA', 'score': '16-14', 'date': '22/04/2023'},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas Partidas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...matches.map((match) => _buildMatchRow(
                  match['opponent'] as String,
                  match['result'] as String,
                  match['score'] as String,
                  match['date'] as String,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchRow(String opponent, String result, String score, String date) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            opponent.split(' ').map((e) => e[0]).join(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      title: Text(opponent),
      subtitle: Text(date),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            result,
            style: TextStyle(
              color: result == 'VITÓRIA' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            score,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMapsPerformance() {
    final maps = [
      {'name': 'Mirage', 'winRate': 0.85, 'played': 20},
      {'name': 'Inferno', 'winRate': 0.70, 'played': 15},
      {'name': 'Overpass', 'winRate': 0.65, 'played': 12},
      {'name': 'Vertigo', 'winRate': 0.55, 'played': 10},
      {'name': 'Ancient', 'winRate': 0.40, 'played': 8},
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Desempenho por Mapa',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...maps.map((map) => _buildMapRow(
                  map['name'] as String,
                  map['winRate'] as double,
                  map['played'] as int,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMapRow(String name, double winRate, int played) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${(winRate * 100).toStringAsFixed(0)}% ($played jogos)'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: winRate,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              winRate > 0.7 ? Colors.green : winRate > 0.5 ? Colors.orange : Colors.red,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}