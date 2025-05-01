import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:furia_app/core/services/home_match_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: SvgPicture.asset(
          'assets/images/logo-furia.svg',
          height: 40,
        ),
        actions: [
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              if (user == null) {
                return TextButton(
                  onPressed: () => context.goNamed('login'),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              } else {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      FirebaseAuth.instance.signOut();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Sair'),
                    ),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          user.displayName ?? 'Usuário',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavigationButton(
                  text: 'Estatísticas',
                  onPressed: () => context.goNamed('statistics'),
                  isActive: true,
                ),
                _NavigationButton(
                  text: 'Partidas',
                  onPressed: () => context.goNamed('matches'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildMatchSection(context),
        ),
      ),
    );
  }

  Widget _buildMatchSection(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: HomeMatchService.getAllFuriaMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Nenhuma partida encontrada.');
        }
        final matches = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Partidas Finalizadas da FURIA',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...matches.take(5).map((match) => _buildMatchCard(match)),
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
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamLogo(
                match['game'], 
                match['team1_id'], 
                match['team1_slug']
              ),
              const SizedBox(width: 8),
              const Icon(Icons.sports_esports, color: Colors.white),
              const SizedBox(width: 8),
              _buildTeamLogo(
                match['game'], 
                match['team2_id'], 
                match['team2_slug']
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            match['tournament'],
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            match['date'],
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Placar: ${match['score']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildGameLogo(match['game'], match['game_logo']),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String game, String teamId, String teamSlug) {
    final safeGame = game.replaceAll(' ', '_'); // evita espaços
    final logoPath = 'teams_logos/${safeGame}_${teamId}_$teamSlug.png';
    return Image.asset(
      logoPath,
      width: 64,
      height: 64,
      fit: BoxFit.contain,
      errorBuilder: (context, error, _) =>
          const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }

  Widget _buildGameLogo(String gameName, String? logoUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        logoUrl != null && logoUrl.isNotEmpty
            ? Image.network(
                logoUrl,
                width: 24,
                height: 24,
                errorBuilder: (context, error, _) =>
                    const Icon(Icons.videogame_asset, size: 24, color: Colors.grey),
              )
            : const Icon(Icons.videogame_asset, size: 24, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          gameName,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActive;

  const _NavigationButton({
    required this.text,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        foregroundColor: isActive ? Colors.black : Colors.grey,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          decoration: isActive ? TextDecoration.underline : null,
        ),
      ),
    );
  }
}
