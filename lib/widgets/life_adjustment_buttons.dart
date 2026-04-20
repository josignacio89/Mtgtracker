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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AdjustButton(label: '+5', onTap: () => adjust(5)),
        _AdjustButton(label: '+1', onTap: () => adjust(1)),
        _AdjustButton(label: '-1', onTap: () => adjust(-1)),
        _AdjustButton(label: '-5', onTap: () => adjust(-5)),
      ],
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
    return SizedBox(
      width: 56,
      height: 44,
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
