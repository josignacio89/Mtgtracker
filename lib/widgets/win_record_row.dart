import 'package:flutter/material.dart';

class WinRecordRow extends StatelessWidget {
  final String name;
  final int wins;
  final int gamesPlayed;
  final int rank;

  const WinRecordRow({
    super.key,
    required this.name,
    required this.wins,
    required this.gamesPlayed,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final winRate = gamesPlayed == 0 ? 0.0 : wins / gamesPlayed;
    final pct = (winRate * 100).toStringAsFixed(0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: _rankColor(rank),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '$wins W / $gamesPlayed G',
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(width: 8),
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: winRate >= 0.5 ? Colors.green.shade400 : Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: winRate,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  winRate >= 0.5 ? Colors.green.shade600 : Colors.blueGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.grey.shade500;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.blueGrey.shade700;
    }
  }
}
