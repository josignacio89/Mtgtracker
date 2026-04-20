import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_record.dart';

class PersistenceHelper {
  static const _historyKey = 'game_history_v1';

  Future<List<GameRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => GameRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistory(List<GameRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_historyKey, encoded);
  }
}
