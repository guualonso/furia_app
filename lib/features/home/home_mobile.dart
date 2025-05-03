import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:furia_app/core/widgets/match_section.dart';

class HomeMobileScreen extends StatelessWidget {
  const HomeMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: MatchSection(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavigationButton(
                text: 'Estatísticas',
                onPressed: () => context.goNamed('statistics'),
              ),
              _NavigationButton(
                text: 'Partidas',
                onPressed: () => context.goNamed('matches'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _NavigationButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: Colors.grey),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );
  }
}
