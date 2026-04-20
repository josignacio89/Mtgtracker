import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';

class LifeAdjustmentButtons extends ConsumerWidget {
  final String playerId;
  final bool isEliminated;

  const LifeAdjustmentButtons({
    super.key,
    required this.playerId,
    required this.isEliminated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void adjust(int delta) {
      if (isEliminated) return;
      ref.read(gameProvider.notifier).adjustLife(playerId, delta);
    }

    return Opacity(
      opacity: isEliminated ? 0.35 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AdjustButton(label: '+5', onTap: () => adjust(5)),
          _AdjustButton(label: '+1', onTap: () => adjust(1)),
          const SizedBox(width: 12),
          _AdjustButton(label: '-1', onTap: () => adjust(-1)),
          _AdjustButton(label: '-5', onTap: () => adjust(-5)),
        ],
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AdjustButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPositive = label.startsWith('+');
    final isFive = label.endsWith('5');
    return SizedBox(
      width: 56,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isPositive
              ? Colors.green.shade800
              : Colors.red.shade800,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isFive ? 12 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
