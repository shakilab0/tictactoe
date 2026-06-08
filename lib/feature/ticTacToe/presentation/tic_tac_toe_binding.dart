import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:tictactoe/core/analytics/posthog_service.dart';
import 'package:tictactoe/feature/ticTacToe/data/dataSource/game_local_data_source.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';
import 'package:tictactoe/feature/ticTacToe/data/repoImplementation/tic_tac_toe_repository_implementation.dart';
import 'package:tictactoe/feature/ticTacToe/presentation/tic_tac_toe_controller.dart';


class TicTacToeBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<GameLocalDataSourceImpl>(() => GameLocalDataSourceImpl(
        Hive.box<GameStatsModel>(GameStatsModel.boxName),
      ),
    );

    Get.lazyPut<TicTacToeRepositoryImplementation>(() => TicTacToeRepositoryImplementation(
        localDataSource: Get.find<GameLocalDataSourceImpl>(),
      ),
    );

    Get.lazyPut(() => TicTacToeController(
        repository: Get.find<TicTacToeRepositoryImplementation>(),
        analytics: Get.find<PostHogService>(),
      ),
    );
  }
}
