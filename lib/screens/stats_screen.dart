import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../widgets/win_record_row.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(appStatsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Stats — ${stats.totalGamesPlayed} game${stats.totalGamesPlayed == 1 ? '' : 's'}',
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Players'),
              Tab(icon: Icon(Icons.style), text: 'Decks'),
            ],
          ),
          actions: [
            if (stats.totalGamesPlayed > 0)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear history',
                onPressed: () => _confirmClear(context, ref),
              ),
          ],
        ),
        body: TabBarView(
          children: [
            _LeaderboardTab(
              items: stats.playerStats
                  .map((s) => _LeaderItem(
                      name: s.playerName,
                      wins: s.wins,
                      gamesPlayed: s.gamesPlayed))
                  .toList(),
              emptyMessage: 'No games played yet.',
              totalGames: stats.totalGamesPlayed,
            ),
            _LeaderboardTab(
              items: stats.deckStats
                  .map((s) => _LeaderItem(
                      name: s.deckName,
                      wins: s.wins,
                      gamesPlayed: s.gamesPlayed))
                  .toList(),
              emptyMessage: 'No deck data yet.',
              totalGames: stats.totalGamesPlayed,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'This will permanently delete all game records. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearHistory();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _LeaderItem {
  final String name;
  final int wins;
  final int gamesPlayed;
  const _LeaderItem(
      {required this.name, required this.wins, required this.gamesPlayed});
}

class _LeaderboardTab extends StatelessWidget {
  final List<_LeaderItem> items;
  final String emptyMessage;
  final int totalGames;

  const _LeaderboardTab({
    required this.items,
    required this.emptyMessage,
    required this.totalGames,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(emptyMessage,
            style: const TextStyle(color: Colors.white54, fontSize: 15)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Card(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${items.length} ${items.length == 1 ? 'entry' : 'entries'} — $totalGames game${totalGames == 1 ? '' : 's'}',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          );
        }
        final item = items[i - 1];
        return WinRecordRow(
          name: item.name,
          wins: item.wins,
          gamesPlayed: item.gamesPlayed,
          rank: i,
        );
      },
    );
  }
}
