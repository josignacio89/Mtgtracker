import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/setup_screen.dart';
import 'screens/game_screen.dart';
import 'screens/end_game_screen.dart';
import 'screens/stats_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MtgTrackerApp(),
    ),
  );
}

class MtgTrackerApp extends StatelessWidget {
  const MtgTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MTG Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SetupScreen(),
        '/game': (_) => const GameScreen(),
        '/end-game': (_) => const EndGameScreen(),
        '/stats': (_) => const StatsScreen(),
      },
    );
  }
}
