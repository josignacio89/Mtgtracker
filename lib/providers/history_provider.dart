import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_stats.dart';
import '../models/game_record.dart';
import '../utils/persistence.dart';

final persistenceHelperProvider = Provider<PersistenceHelper>(
  (ref) => PersistenceHelper(),
);

class HistoryNotifier extends StateNotifier<List<GameRecord>> {
  HistoryNotifier(this._persistence) : super([]) {
    _load();
  }

  final PersistenceHelper _persistence;

  Future<void> _load() async {
    final records = await _persistence.loadHistory();
    state = records;
  }

  Future<void> addRecord(GameRecord record) async {
    state = [...state, record];
    await _persistence.saveHistory(state);
  }

  Future<void> clearHistory() async {
    state = [];
    await _persistence.saveHistory(state);
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<GameRecord>>(
  (ref) => HistoryNotifier(ref.read(persistenceHelperProvider)),
);

final appStatsProvider = Provider<AppStats>(
  (ref) => AppStats.fromRecords(ref.watch(historyProvider)),
);
