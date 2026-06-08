import 'dart:developer';
import 'package:fpdart/fpdart.dart';

import 'package:tictactoe/core/failure/failure.dart';
import 'package:tictactoe/feature/ticTacToe/data/dataSource/game_local_data_source.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';
import 'package:tictactoe/feature/ticTacToe/domain/repository/tic_tac_toe_repository.dart';

class TicTacToeRepositoryImplementation implements TicTacToeRepository {
  final GameLocalDataSource localDataSource;

  TicTacToeRepositoryImplementation({required this.localDataSource});

  @override
  Future<Either<Failure, GameStatsModel>> getStats() async {
    try {
      final stats = await localDataSource.getStats();
      return Right(stats);
    } catch (error, stackTrace) {
      log('getStats failed: $error\n$stackTrace');
      return Left(Failure(
        errorDescription: 'Could not load stats.',
        originalError: error.toString(),
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> saveStats(GameStatsModel stats) async {
    try {
      await localDataSource.saveStats(stats);
      return Right(true);
    } catch (error, stackTrace) {
      log('saveStats failed: $error\n$stackTrace');
      return Left(Failure(
        errorDescription: 'Could not save stats.',
        originalError: error.toString(),
      ));
    }
  }
}
