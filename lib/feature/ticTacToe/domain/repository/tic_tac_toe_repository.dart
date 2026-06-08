import 'package:fpdart/fpdart.dart';
import 'package:tictactoe/core/failure/failure.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';


abstract class TicTacToeRepository {
  Future<Either<Failure, GameStatsModel>> getStats();
  Future<Either<Failure, bool>> saveStats(GameStatsModel stats);
}
