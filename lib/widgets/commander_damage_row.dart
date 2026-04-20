import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class CommanderDamageRow extends ConsumerWidget {
  final String targetPlayerId;
  final Player sourcePlayer;

  const CommanderDamageRow({
    super.key,
    required this.targetPlayerId,
    required this.sourcePlayer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(gameProvider).players.firstWhere(
          (p) => p.id == targetPlayerId,
          orElse: () => sourcePlayer,
        );
    final damage =
        target.commanderDamage[sourcePlayer.id] ?? 0;
    final isLethal = damage >= AppConstants.commanderDamageThreshold;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'From ${sourcePlayer.name}',
                  style: const TextStyle(
                      fontSize: 13, color: Colors.white70),
                ),
                Text(
                  sourcePlayer.deckName,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.white38,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref
                .read(gameProvider.notifier)
                .adjustCommanderDamage(targetPlayerId, sourcePlayer.id, -1),
            icon: const Icon(Icons.remove_circle_outline, size: 22),
            color: Colors.white70,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$damage',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLethal ? Colors.red.shade400 : Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => ref
                .read(gameProvider.notifier)
                .adjustCommanderDamage(targetPlayerId, sourcePlayer.id, 1),
            icon: const Icon(Icons.add_circle_outline, size: 22),
            color: Colors.white70,
          ),
          if (isLethal)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(Icons.warning_amber_rounded,
                  size: 18, color: Colors.red),
            ),
        ],
      ),
    );
  }
}
