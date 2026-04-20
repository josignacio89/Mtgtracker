import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/setup_provider.dart';
import '../providers/game_provider.dart';
import '../providers/history_provider.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Format'),
                    const SizedBox(height: 8),
                    _FormatToggle(setup: setup, ref: ref),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Number of Players'),
                    const SizedBox(height: 8),
                    _PlayerCountSelector(setup: setup, ref: ref),
                  ],
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Players'),
                    const SizedBox(height: 8),
                    ...List.generate(
                      setup.playerCount,
                      (i) => _PlayerRow(index: i, setup: setup),
                    ),
                  ],
                ),
              ),
            ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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

class _PlayerRow extends ConsumerStatefulWidget {
  final int index;
  final SetupState setup;

  const _PlayerRow({required this.index, required this.setup});

  @override
  ConsumerState<_PlayerRow> createState() => _PlayerRowState();
}

class _PlayerRowState extends ConsumerState<_PlayerRow> {
  late TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.setup.names[widget.index]);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i = widget.index;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
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
              child: _DeckAutocomplete(
                index: i,
                initialValue: widget.setup.deckNames[i],
              ),
            ),
          ],
        ),
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

class _DeckAutocomplete extends ConsumerWidget {
  final int index;
  final String initialValue;

  const _DeckAutocomplete({required this.index, required this.initialValue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckNames = ref.watch(previousDeckNamesProvider);

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: initialValue),
      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return deckNames;
        return deckNames.where((n) => n.toLowerCase().contains(query));
      },
      onSelected: (value) =>
          ref.read(setupProvider.notifier).setDeckName(index, value),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Deck Name',
            isDense: true,
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down, size: 18),
          ),
          onChanged: (v) =>
              ref.read(setupProvider.notifier).setDeckName(index, v),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final option = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
