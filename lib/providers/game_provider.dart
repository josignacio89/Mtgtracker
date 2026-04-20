import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../utils/constants.dart';
import 'setup_provider.dart';

class GameState {
  final List<Player> players;
  final String format;
  final bool isGameOver;
  final String? winnerId;

  const GameState({
    required this.players,
    required this.format,
    required this.isGameOver,
    this.winnerId,
  });

  factory GameState.empty() => const GameState(
        players: [],
        format: AppConstants.formatCommander,
        isGameOver: false,
      );

  int get startingLife => format == AppConstants.formatCommander
      ? AppConstants.defaultCommanderLife
      : AppConstants.defaultStandardLife;

  Player? get winner =>
      winnerId == null ? null : players.where((p) => p.id == winnerId).firstOrNull;

  GameState copyWith({
    List<Player>? players,
    String? format,
    bool? isGameOver,
    String? winnerId,
    bool clearWinner = false,
  }) =>
      GameState(
        players: players ?? this.players,
        format: format ?? this.format,
        isGameOver: isGameOver ?? this.isGameOver,
        winnerId: clearWinner ? null : (winnerId ?? this.winnerId),
      );
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(GameState.empty());

  static const _uuid = Uuid();

  void startGame(SetupState setup) {
    final players = List.generate(
      setup.playerCount,
      (i) => Player(
        id: _uuid.v4(),
        name: setup.names[i].trim().isEmpty ? 'Player ${i + 1}' : setup.names[i].trim(),
        deckName: setup.deckNames[i].trim().isEmpty ? 'Unknown Deck' : setup.deckNames[i].trim(),
        lifeTotal: setup.startingLife,
      ),
    );
    state = GameState(
      players: players,
      format: setup.format,
      isGameOver: false,
    );
  }

  void adjustLife(String playerId, int delta) {
    final updated = _updatePlayer(playerId, (p) {
      p.lifeTotal += delta;
    });
    if (updated) _checkElimination(playerId);
  }

  void setLife(String playerId, int value) {
    final updated = _updatePlayer(playerId, (p) {
      p.lifeTotal = value;
    });
    if (updated) _checkElimination(playerId);
  }

  void adjustCommanderDamage(
      String targetPlayerId, String sourcePlayerId, int delta) {
    final updated = _updatePlayer(targetPlayerId, (p) {
      final current = p.commanderDamage[sourcePlayerId] ?? 0;
      final newVal = (current + delta).clamp(0, 999);
      p.commanderDamage = Map.from(p.commanderDamage)..[sourcePlayerId] = newVal;
    });
    if (updated) _checkElimination(targetPlayerId);
  }

  void declareWinner(String playerId) {
    state = state.copyWith(winnerId: playerId, isGameOver: true);
  }

  void resetGame() {
    state = GameState.empty();
  }

  bool _updatePlayer(String playerId, void Function(Player p) mutate) {
    final index = state.players.indexWhere((p) => p.id == playerId);
    if (index == -1) return false;
    final players = state.players.map((p) => p.copyWith()).toList();
    mutate(players[index]);
    state = state.copyWith(players: players);
    return true;
  }

  void _checkElimination(String playerId) {
    final player = state.players.firstWhere((p) => p.id == playerId);
    final shouldBeEliminated =
        player.lifeTotal <= 0 || player.isEliminatedByCommanderDamage;

    if (shouldBeEliminated && !player.isEliminated) {
      final players = state.players.map((p) {
        if (p.id == playerId) return p.copyWith(isEliminated: true);
        return p.copyWith();
      }).toList();
      state = state.copyWith(players: players);
    }

    _checkAutoWin();
  }

  void _checkAutoWin() {
    if (state.isGameOver) return;
    final alive = state.players.where((p) => !p.isEliminated).toList();
    if (alive.length == 1) {
      state = state.copyWith(winnerId: alive.first.id, isGameOver: true);
    }
  }
}

final gameProvider =
    StateNotifierProvider<GameNotifier, GameState>((ref) => GameNotifier());
