import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/setup_provider.dart';
import '../providers/game_provider.dart';
import '../utils/constants.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(setupProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MTG Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Stats',
            onPressed: () => Navigator.pushNamed(context, '/stats'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('Format'),
            const SizedBox(height: 8),
            _FormatToggle(setup: setup, ref: ref),
            const SizedBox(height: 20),
            _SectionLabel('Number of Players'),
            const SizedBox(height: 8),
            _PlayerCountSelector(setup: setup, ref: ref),
            const SizedBox(height: 20),
            _SectionLabel('Players'),
            const SizedBox(height: 8),
            ...List.generate(
              setup.playerCount,
              (i) => _PlayerRow(index: i, setup: setup, ref: ref),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(gameProvider.notifier).startGame(setup);
                  Navigator.pushNamed(context, '/game');
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  'Start Game  (${setup.startingLife} life)',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
            letterSpacing: 1.2),
      );
}

class _FormatToggle extends StatelessWidget {
  final SetupState setup;
  final WidgetRef ref;

  const _FormatToggle({required this.setup, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: AppConstants.formatCommander,
          label: Text('Commander (40 life)'),
          icon: Icon(Icons.shield),
        ),
        ButtonSegment(
          value: AppConstants.formatStandard,
          label: Text('Standard (20 life)'),
          icon: Icon(Icons.star),
        ),
      ],
      selected: {setup.format},
      onSelectionChanged: (val) =>
          ref.read(setupProvider.notifier).setFormat(val.first),
    );
  }
}

class _PlayerCountSelector extends StatelessWidget {
  final SetupState setup;
  final WidgetRef ref;

  const _PlayerCountSelector({required this.setup, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        AppConstants.maxPlayers - AppConstants.minPlayers + 1,
        (i) {
          final count = AppConstants.minPlayers + i;
          final selected = setup.playerCount == count;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$count'),
              selected: selected,
              onSelected: (_) =>
                  ref.read(setupProvider.notifier).setPlayerCount(count),
            ),
          );
        },
      ),
    );
  }
}

class _PlayerRow extends StatefulWidget {
  final int index;
  final SetupState setup;
  final WidgetRef ref;

  const _PlayerRow(
      {required this.index, required this.setup, required this.ref});

  @override
  State<_PlayerRow> createState() => _PlayerRowState();
}

class _PlayerRowState extends State<_PlayerRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _deckCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.setup.names[widget.index]);
    _deckCtrl =
        TextEditingController(text: widget.setup.deckNames[widget.index]);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _deckCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.index;
    final ref = widget.ref;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _playerColor(i),
            child: Text('${i + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Player ${i + 1} Name',
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(setupProvider.notifier).setPlayerName(i, v),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _deckCtrl,
              decoration: const InputDecoration(
                labelText: 'Deck Name',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  ref.read(setupProvider.notifier).setDeckName(i, v),
            ),
          ),
        ],
      ),
    );
  }

  Color _playerColor(int index) {
    const colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
    ];
    return colors[index % colors.length];
  }
}
