import 'package:hive_ce/hive.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';


abstract class GameLocalDataSource {
  Future<GameStatsModel> getStats();
  Future<void> saveStats(GameStatsModel stats);
}

class GameLocalDataSourceImpl implements GameLocalDataSource {
  final Box<GameStatsModel> statsBox;

  GameLocalDataSourceImpl(this.statsBox);

  @override
  Future<GameStatsModel> getStats() async {
    return statsBox.get(GameStatsModel.recordKey) ?? GameStatsModel();
  }

  @override
  Future<void> saveStats(GameStatsModel stats) async {
    await statsBox.put(GameStatsModel.recordKey, stats);
  }
}