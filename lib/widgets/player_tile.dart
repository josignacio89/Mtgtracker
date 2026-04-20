import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../widgets/life_adjustment_buttons.dart';
import '../widgets/commander_damage_row.dart';
import '../utils/constants.dart';

class PlayerTile extends ConsumerWidget {
  final Player player;

  const PlayerTile({super.key, required this.player});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final opponents = gameState.players.where((p) => p.id != player.id).toList();
    final isCommander = gameState.format == AppConstants.formatCommander;

    Color lifeColor;
    if (player.lifeTotal > 15) {
      lifeColor = Colors.green.shade400;
    } else if (player.lifeTotal > 5) {
      lifeColor = Colors.amber.shade400;
    } else {
      lifeColor = Colors.red.shade400;
    }

    return Card(
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  player.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  player.deckName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.white54,
                  ),
                ),
                Text(
                  '${player.lifeTotal}',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: lifeColor,
                    height: 1.1,
                  ),
                ),
                LifeAdjustmentButtons(
                  playerId: player.id,
                  isEliminated: player.isEliminated,
                ),
                if (isCommander && opponents.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _showCommanderDamage(context, opponents),
                    icon: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text('Cmd Damage', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blueGrey.shade300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          if (player.isEliminated) _EliminatedOverlay(player: player),
        ],
      ),
    );
  }

  void _showCommanderDamage(BuildContext context, List<Player> opponents) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Commander damage taken by ${player.name}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70),
              ),
            ),
            const Divider(color: Colors.white12),
            ...opponents.map(
              (opp) => CommanderDamageRow(
                targetPlayerId: player.id,
                sourcePlayer: opp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EliminatedOverlay extends StatelessWidget {
  final Player player;

  const _EliminatedOverlay({required this.player});

  @override
  Widget build(BuildContext context) {
    final reason = player.isEliminatedByCommanderDamage
        ? 'Commander\nDamage'
        : 'Eliminated';

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.72),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.close, size: 48, color: Colors.red),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              player.name,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
