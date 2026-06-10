import 'package:hive_ce/hive.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';
import 'package:tictactoe/feature/ticTacToe/domain/entity/game_enums.dart';


abstract class GameLocalDataSource {
  Future<GameStatsModel> getStats(GameMode mode);
  Future<void> saveStats(GameMode mode, GameStatsModel stats);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  final Box<GameStatsModel> statsBox;

  GameLocalDataSourceImpl(this.statsBox);

  @override
  Future<GameStatsModel> getStats(GameMode mode) async {
    final key = GameStatsModel.keyForMode(mode);
    final stored = statsBox.get(key);
    if (stored != null) return stored;

    if (mode == GameMode.onePlayer) {
      final legacy = statsBox.get(GameStatsModel.legacyRecordKey);
      if (legacy != null) {
        await statsBox.put(GameStatsModel.onePlayerKey, legacy);
        await statsBox.delete(GameStatsModel.legacyRecordKey);
        return legacy;
      }
    }

    return GameStatsModel();
  }

  @override
  Future<void> saveStats(GameMode mode, GameStatsModel stats) async {
    await statsBox.put(GameStatsModel.keyForMode(mode), stats);
  }
}