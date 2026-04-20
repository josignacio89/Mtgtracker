class PlayerSnapshot {
  final String id;
  final String name;
  final String deckName;
  final int finalLifeTotal;
  final bool eliminatedByCommanderDamage;

  const PlayerSnapshot({
    required this.id,
    required this.name,
    required this.deckName,
    required this.finalLifeTotal,
    required this.eliminatedByCommanderDamage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'deckName': deckName,
        'finalLifeTotal': finalLifeTotal,
        'eliminatedByCommanderDamage': eliminatedByCommanderDamage,
      };

  factory PlayerSnapshot.fromJson(Map<String, dynamic> json) => PlayerSnapshot(
        id: json['id'] as String,
        name: json['name'] as String,
        deckName: json['deckName'] as String,
        finalLifeTotal: json['finalLifeTotal'] as int,
        eliminatedByCommanderDamage:
            json['eliminatedByCommanderDamage'] as bool? ?? false,
      );
}

class GameRecord {
  final String id;
  final DateTime playedAt;
  final String format;
  final int startingLife;
  final List<PlayerSnapshot> players;
  final String winnerId;
  final String winnerName;
  final String winnerDeckName;

  const GameRecord({
    required this.id,
    required this.playedAt,
    required this.format,
    required this.startingLife,
    required this.players,
    required this.winnerId,
    required this.winnerName,
    required this.winnerDeckName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'playedAt': playedAt.toIso8601String(),
        'format': format,
        'startingLife': startingLife,
        'players': players.map((p) => p.toJson()).toList(),
        'winnerId': winnerId,
        'winnerName': winnerName,
        'winnerDeckName': winnerDeckName,
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        id: json['id'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
        format: json['format'] as String,
        startingLife: json['startingLife'] as int,
        players: (json['players'] as List<dynamic>)
            .map((e) => PlayerSnapshot.fromJson(e as Map<String, dynamic>))
            .toList(),
        winnerId: json['winnerId'] as String,
        winnerName: json['winnerName'] as String,
        winnerDeckName: json['winnerDeckName'] as String,
      );
}
