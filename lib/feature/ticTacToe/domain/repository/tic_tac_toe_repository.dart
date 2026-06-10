import 'package:fpdart/fpdart.dart';
import 'package:tictactoe/core/failure/failure.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';
import 'package:tictactoe/feature/ticTacToe/domain/entity/game_enums.dart';


abstract class TicTacToeRepository {
  Future<Either<Failure, GameStatsModel>> getStats(GameMode mode);
  Future<Either<Failure, bool>> saveStats(GameMode mode, GameStatsModel stats);
}
