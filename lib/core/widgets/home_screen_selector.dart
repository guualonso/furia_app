import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:furia_app/features/home/home_mobile.dart';
import 'package:furia_app/features/home/home_web.dart';

class HomeScreenSelector extends StatelessWidget {
  const HomeScreenSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const HomeWebScreen();
    } else if (Platform.isAndroid || Platform.isIOS) {
      return const HomeMobileScreen();
    } else {
      return const Scaffold(
        body: Center(child: Text('Plataforma não suportada')),
      );
    }
  }
}
