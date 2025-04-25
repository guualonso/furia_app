import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FURIA Esports'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.goNamed('statistics'),
              child: const Text('Estatísticas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.goNamed('matches'),
              child: const Text('Partidas'),
            ),
          ],
        ),
      ),
    );
  }
}