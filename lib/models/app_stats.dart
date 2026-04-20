import 'game_record.dart';

class PlayerWinStats {
  final String playerName;
  final int wins;
  final int gamesPlayed;

  const PlayerWinStats({
    required this.playerName,
    required this.wins,
    required this.gamesPlayed,
  });

  double get winRate => gamesPlayed == 0 ? 0.0 : wins / gamesPlayed;
}

class DeckWinStats {
  final String deckName;
  final int wins;
  final int gamesPlayed;

  const DeckWinStats({
    required this.deckName,
    required this.wins,
    required this.gamesPlayed,
  });

  double get winRate => gamesPlayed == 0 ? 0.0 : wins / gamesPlayed;
}

class AppStats {
  final List<PlayerWinStats> playerStats;
  final List<DeckWinStats> deckStats;
  final int totalGamesPlayed;

  const AppStats({
    required this.playerStats,
    required this.deckStats,
    required this.totalGamesPlayed,
  });

  factory AppStats.empty() => const AppStats(
        playerStats: [],
        deckStats: [],
        totalGamesPlayed: 0,
      );

  factory AppStats.fromRecords(List<GameRecord> records) {
    final playerWins = <String, int>{};
    final playerGames = <String, int>{};
    final deckWins = <String, int>{};
    final deckGames = <String, int>{};

    for (final record in records) {
      for (final player in record.players) {
        playerGames[player.name] = (playerGames[player.name] ?? 0) + 1;
        deckGames[player.deckName] = (deckGames[player.deckName] ?? 0) + 1;
      }
      playerWins[record.winnerName] = (playerWins[record.winnerName] ?? 0) + 1;
      deckWins[record.winnerDeckName] =
          (deckWins[record.winnerDeckName] ?? 0) + 1;
    }

    final playerStats = playerGames.keys
        .map((name) => PlayerWinStats(
              playerName: name,
              wins: playerWins[name] ?? 0,
              gamesPlayed: playerGames[name]!,
            ))
        .toList()
      ..sort((a, b) => b.wins.compareTo(a.wins));

    final deckStats = deckGames.keys
        .map((name) => DeckWinStats(
              deckName: name,
              wins: deckWins[name] ?? 0,
              gamesPlayed: deckGames[name]!,
            ))
        .toList()
      ..sort((a, b) => b.wins.compareTo(a.wins));

    return AppStats(
      playerStats: playerStats,
      deckStats: deckStats,
      totalGamesPlayed: records.length,
    );
  }
}
