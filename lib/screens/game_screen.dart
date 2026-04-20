import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../providers/setup_provider.dart';
import '../widgets/player_tile.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final players = gameState.players;

    if (players.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (gameState.isGameOver && gameState.winner != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) return;
        Navigator.pushNamed(context, '/end-game');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          gameState.format == 'commander' ? 'Commander' : 'Standard',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Stats',
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'reset') {
                ref.read(gameProvider.notifier).resetGame();
                ref.read(setupProvider.notifier).reset();
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'reset', child: Text('Reset & New Setup')),
            ],
          ),
        ],
      ),
      body: _buildGrid(players),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/end-game'),
        icon: const Icon(Icons.flag),
        label: const Text('End Game'),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  Widget _buildGrid(List<Player> players) {
    if (players.length == 2) {
      return Column(
        children: players
            .map<Widget>((p) => Expanded(child: PlayerTile(player: p)))
            .toList(),
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < players.length; i += 2) {
      final rowPlayers = players.skip(i).take(2).toList();
      rows.add(
        Expanded(
          child: Row(
            children: rowPlayers
                .map<Widget>((p) => Expanded(child: PlayerTile(player: p)))
                .toList(),
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
