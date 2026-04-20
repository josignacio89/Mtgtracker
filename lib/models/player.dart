import '../utils/constants.dart';

class Player {
  final String id;
  final String name;
  final String deckName;
  int lifeTotal;
  bool isEliminated;
  Map<String, int> commanderDamage;

  Player({
    required this.id,
    required this.name,
    required this.deckName,
    required this.lifeTotal,
    this.isEliminated = false,
    Map<String, int>? commanderDamage,
  }) : commanderDamage = commanderDamage ?? {};

  bool get isEliminatedByCommanderDamage =>
      commanderDamage.values.any((d) => d >= AppConstants.commanderDamageThreshold);

  Player copyWith({
    String? id,
    String? name,
    String? deckName,
    int? lifeTotal,
    bool? isEliminated,
    Map<String, int>? commanderDamage,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      deckName: deckName ?? this.deckName,
      lifeTotal: lifeTotal ?? this.lifeTotal,
      isEliminated: isEliminated ?? this.isEliminated,
      commanderDamage: commanderDamage ?? Map.from(this.commanderDamage),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'deckName': deckName,
        'lifeTotal': lifeTotal,
        'isEliminated': isEliminated,
        'commanderDamage': commanderDamage,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] as String,
        name: json['name'] as String,
        deckName: json['deckName'] as String,
        lifeTotal: json['lifeTotal'] as int,
        isEliminated: json['isEliminated'] as bool? ?? false,
        commanderDamage: (json['commanderDamage'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, v as int)) ??
            {},
      );
}
