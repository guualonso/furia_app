import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furia_app/core/widgets/match_section.dart';

class HomeWebScreen extends StatelessWidget {
  const HomeWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildWebAppBar(context),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: MatchSection(),
      ),
    );
  }

  PreferredSizeWidget _buildWebAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: SvgPicture.asset(
                  'assets/images/logo-furia.svg',
                  height: 40,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Image.asset(
                        'icons/icon_pesquisa.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                    StreamBuilder<User?>(
                      stream: FirebaseAuth.instance.authStateChanges(),
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        if (user == null) {
                          return TextButton(
                            onPressed: () => context.goNamed('login'),
                            child: const Text('Login', style: TextStyle(color: Colors.black)),
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
                            child: Row(
                              children: [
                                const Icon(Icons.person_outline, color: Colors.black),
                                const SizedBox(width: 10),
                                Text(
                                  user.displayName ?? 'Usuário',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
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
