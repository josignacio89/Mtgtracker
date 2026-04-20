import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/game_record.dart';
import '../providers/game_provider.dart';
import '../providers/history_provider.dart';
import '../providers/setup_provider.dart';

class EndGameScreen extends ConsumerStatefulWidget {
  const EndGameScreen({super.key});

  @override
  ConsumerState<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends ConsumerState<EndGameScreen> {
  String? _selectedWinnerId;
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final game = ref.read(gameProvider);
    _selectedWinnerId = game.winnerId;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final players = game.players;

    return Scaffold(
      appBar: AppBar(
        title: const Text('End Game'),
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Select the winner',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (_, i) {
                final p = players[i];
                return RadioListTile<String>(
                  value: p.id,
                  groupValue: _selectedWinnerId,
                  onChanged: (val) => setState(() => _selectedWinnerId = val),
                  title: Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    p.deckName,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  secondary: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${p.lifeTotal}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text('life', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _selectedWinnerId == null ? null : _confirmAndSave,
                icon: const Icon(Icons.save),
                label: const Text('Confirm & Save Game',
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndSave() async {
    final game = ref.read(gameProvider);
    final winnerId = _selectedWinnerId!;
    final winner =
        game.players.firstWhere((p) => p.id == winnerId);

    final record = GameRecord(
      id: _uuid.v4(),
      playedAt: DateTime.now(),
      format: game.format,
      startingLife: game.startingLife,
      players: game.players
          .map((p) => PlayerSnapshot(
                id: p.id,
                name: p.name,
                deckName: p.deckName,
                finalLifeTotal: p.lifeTotal,
                eliminatedByCommanderDamage: p.isEliminatedByCommanderDamage,
              ))
          .toList(),
      winnerId: winner.id,
      winnerName: winner.name,
      winnerDeckName: winner.deckName,
    );

    await ref.read(historyProvider.notifier).addRecord(record);
    ref.read(gameProvider.notifier).resetGame();
    ref.read(setupProvider.notifier).reset();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }
}
