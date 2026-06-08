import 'package:get/get.dart';
import 'package:tictactoe/feature/ticTacToe/presentation/tic_tac_toe_binding.dart';
import 'package:tictactoe/feature/ticTacToe/presentation/tic_tac_toe_page.dart';


final List<GetPage> routes = [
  GetPage(name: AppRoutes.gamePage, page: () => const TicTacToePage(), binding: TicTacToeBinding(),),
];

class AppRoutes {
  AppRoutes._();

  static const String gamePage = "/";
}
