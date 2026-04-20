import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/constants.dart';

class SetupState {
  final int playerCount;
  final String format;
  final List<String> names;
  final List<String> deckNames;

  const SetupState({
    required this.playerCount,
    required this.format,
    required this.names,
    required this.deckNames,
  });

  factory SetupState.initial() => SetupState(
        playerCount: AppConstants.minPlayers,
        format: AppConstants.formatCommander,
        names: List.generate(AppConstants.maxPlayers, (i) => 'Player ${i + 1}'),
        deckNames: List.generate(AppConstants.maxPlayers, (_) => ''),
      );

  SetupState copyWith({
    int? playerCount,
    String? format,
    List<String>? names,
    List<String>? deckNames,
  }) =>
      SetupState(
        playerCount: playerCount ?? this.playerCount,
        format: format ?? this.format,
        names: names ?? List.from(this.names),
        deckNames: deckNames ?? List.from(this.deckNames),
      );

  int get startingLife => format == AppConstants.formatCommander
      ? AppConstants.defaultCommanderLife
      : AppConstants.defaultStandardLife;
}

class SetupNotifier extends StateNotifier<SetupState> {
  SetupNotifier() : super(SetupState.initial());

  void setPlayerCount(int count) {
    state = state.copyWith(playerCount: count);
  }

  void setFormat(String format) {
    state = state.copyWith(format: format);
  }

  void setPlayerName(int index, String name) {
    final updated = List<String>.from(state.names);
    updated[index] = name;
    state = state.copyWith(names: updated);
  }

  void setDeckName(int index, String name) {
    final updated = List<String>.from(state.deckNames);
    updated[index] = name;
    state = state.copyWith(deckNames: updated);
  }

  void reset() {
    state = SetupState.initial();
  }
}

final setupProvider =
    StateNotifierProvider<SetupNotifier, SetupState>((ref) => SetupNotifier());
