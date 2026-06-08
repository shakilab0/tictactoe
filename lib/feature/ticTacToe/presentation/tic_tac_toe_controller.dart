import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'package:tictactoe/core/analytics/posthog_service.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';
import 'package:tictactoe/feature/ticTacToe/domain/entity/game_enums.dart';
import 'package:tictactoe/feature/ticTacToe/domain/repository/tic_tac_toe_repository.dart';

class TicTacToeController extends GetxController with WidgetsBindingObserver {
  final TicTacToeRepository repository;
  final PostHogService analytics;

  TicTacToeController({
    required this.repository,
    required this.analytics,
  });

  // ── Board state ─────────────────────────────────────────────────────
  final RxList<String> board = List.filled(9, '', growable: true).obs;
  final RxString currentPlayer = 'X'.obs;
  final RxBool gameOver = false.obs;
  final RxString statusMessage = ''.obs;
  final RxList<int> winningLine = <int>[].obs;

  // ── Settings ────────────────────────────────────────────────────────
  final Rx<GameMode> mode = GameMode.onePlayer.obs;
  final Rx<Difficulty> difficulty = Difficulty.hard.obs;

  // ── Session scores ──────────────────────────────────────────────────
  final RxInt xScore = 0.obs;
  final RxInt oScore = 0.obs;
  final RxInt tieScore = 0.obs;

  // ── Persisted lifetime stats (Hive) ─────────────────────────────────
  final Rx<GameStatsModel> stats = GameStatsModel().obs;

  // ── Internals ───────────────────────────────────────────────────────
  static const String _you = 'X';
  static const String _cpu = 'O';
  final Random _random = Random();
  int _moveCount = 0;
  bool _gameInProgress = false;
  DateTime _gameStartTime = DateTime.now();
  DateTime _sessionStartTime = DateTime.now();

  static const List<List<int>> _winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  String get leftLabel => mode.value == GameMode.onePlayer ? 'You' : 'Player X';
  String get rightLabel => mode.value == GameMode.onePlayer ? 'CPU' : 'Player O';

  @override
  void onInit() {
    super.onInit();
    debugPrint('TTT 🟢 onInit — controller created');
    WidgetsBinding.instance.addObserver(this);
    _sessionStartTime = DateTime.now();
    _loadStats();
    startNewGame();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  Future<void> _loadStats() async {
    final result = await repository.getStats();
    result.fold(
          (failure) => stats.value = GameStatsModel(),
          (data) => stats.value = data,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final seconds = DateTime.now().difference(_sessionStartTime).inSeconds;
      analytics.sessionEnded(durationSeconds: seconds);
      if (_gameInProgress && !gameOver.value) {
        analytics.gameAbandoned(movesPlayed: _moveCount);
        _persistStats(abandoned: true);
        _gameInProgress = false;
      }
    } else if (state == AppLifecycleState.resumed) {
      _sessionStartTime = DateTime.now();
    }
  }

  // ── Game flow ───────────────────────────────────────────────────────
  void startNewGame() {
    board.assignAll(List.filled(9, ''));
    currentPlayer.value = 'X';
    gameOver.value = false;
    winningLine.clear();
    _moveCount = 0;
    _gameStartTime = DateTime.now();
    _gameInProgress = true;
    statusMessage.value = _turnMessage();
    debugPrint('TTT 🔄 startNewGame — board reset, current=X, gameOver=false');
    analytics.gameStarted(
      mode: mode.value.name,
      difficulty: difficulty.value.name,
    );
  }

  void rematch() {
    debugPrint('TTT ↻ rematch tapped');
    analytics.rematchClicked();
    startNewGame();
  }

  void onCellTap(int index) {
    debugPrint('TTT 👆 onCellTap[$index] | gameOver=${gameOver.value} '
        'cell="${board[index]}" mode=${mode.value.name} '
        'current=${currentPlayer.value}');

    if (gameOver.value || board[index].isNotEmpty) {
      debugPrint('TTT    ⛔ ignored (gameOver=${gameOver.value} or cell not empty)');
      return;
    }
    if (mode.value == GameMode.onePlayer && currentPlayer.value == _cpu) {
      debugPrint("TTT    ⛔ ignored (it's the CPU's turn)");
      return;
    }

    _placeMark(index, currentPlayer.value);
    if (gameOver.value) return;

    if (mode.value == GameMode.onePlayer && currentPlayer.value == _cpu) {
      debugPrint('TTT    🤖 scheduling computer move…');
      Future.delayed(const Duration(milliseconds: 350), _computerMove);
    }
  }

  void _placeMark(int index, String mark) {
    final updated = List<String>.from(board);
    updated[index] = mark;
    board.assignAll(updated);

    _moveCount++;
    debugPrint('TTT    ✏️ placeMark[$index]=$mark | board=$board');
    analytics.moveMade(player: mark, position: index, moveNumber: _moveCount);

    final line = _findWinningLine(board, mark);
    if (line != null) {
      debugPrint('TTT    🏆 winner=$mark line=$line');
      _endGame(winner: mark, line: line);
      return;
    }
    if (_isBoardFull(board)) {
      debugPrint('TTT    🤝 tie');
      _endGame(winner: '', line: null);
      return;
    }
    currentPlayer.value = (mark == 'X') ? 'O' : 'X';
    statusMessage.value = _turnMessage();
  }

  void _computerMove() {
    if (gameOver.value) return;
    final move = _chooseComputerMove();
    debugPrint('TTT    🤖 computer chose $move');
    if (move != -1) _placeMark(move, _cpu);
  }

  // ── AI ──────────────────────────────────────────────────────────────
  int _chooseComputerMove() {
    final empties = _emptyCells(board);
    if (empties.isEmpty) return -1;
    switch (difficulty.value) {
      case Difficulty.easy:
        return empties[_random.nextInt(empties.length)];
      case Difficulty.medium:
        return _random.nextBool()
            ? _bestMove()
            : empties[_random.nextInt(empties.length)];
      case Difficulty.hard:
        return _bestMove();
    }
  }

  int _bestMove() {
    final b = List<String>.from(board);
    int bestScore = -1000;
    int move = -1;
    for (final i in _emptyCells(b)) {
      b[i] = _cpu;
      final score = _minimax(b, 0, false);
      b[i] = '';
      if (score > bestScore) {
        bestScore = score;
        move = i;
      }
    }
    return move;
  }

  int _minimax(List<String> b, int depth, bool isMaximizing) {
    if (_findWinningLine(b, _cpu) != null) return 10 - depth;
    if (_findWinningLine(b, _you) != null) return depth - 10;
    if (_isBoardFull(b)) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (final i in _emptyCells(b)) {
        b[i] = _cpu;
        best = max(best, _minimax(b, depth + 1, false));
        b[i] = '';
      }
      return best;
    } else {
      int best = 1000;
      for (final i in _emptyCells(b)) {
        b[i] = _you;
        best = min(best, _minimax(b, depth + 1, true));
        b[i] = '';
      }
      return best;
    }
  }

  // ── End of game + stats ─────────────────────────────────────────────
  void _endGame({required String winner, List<int>? line}) {
    gameOver.value = true;
    _gameInProgress = false;
    if (line != null) winningLine.assignAll(line);

    final durationSeconds = DateTime.now().difference(_gameStartTime).inSeconds;
    final bool onePlayer = mode.value == GameMode.onePlayer;

    String result;
    if (winner.isEmpty) {
      tieScore.value++;
      result = 'tie';
      statusMessage.value = "It's a tie!";
    } else if (winner == 'X') {
      xScore.value++;
      result = onePlayer ? 'win' : 'x_win';
      statusMessage.value = onePlayer ? 'You win! 🎉' : 'Player X wins! 🎉';
    } else {
      oScore.value++;
      result = onePlayer ? 'lose' : 'o_win';
      statusMessage.value = onePlayer ? 'Computer wins!' : 'Player O wins! 🎉';
    }

    analytics.gameFinished(
      result: result,
      winner: winner.isEmpty ? 'none' : winner,
      totalMoves: _moveCount,
      durationSeconds: durationSeconds,
      mode: mode.value.name,
      difficulty: difficulty.value.name,
    );

    _persistStats(
      win: onePlayer && winner == 'X',
      loss: onePlayer && winner == 'O',
      tie: winner.isEmpty,
      durationSeconds: durationSeconds,
    );
  }

  Future<void> _persistStats({
    bool win = false,
    bool loss = false,
    bool tie = false,
    bool abandoned = false,
    int durationSeconds = 0,
  }) async {
    final s = stats.value;
    if (!abandoned) s.gamesPlayed += 1;
    if (win) s.wins += 1;
    if (loss) s.losses += 1;
    if (tie) s.ties += 1;
    if (abandoned) s.abandoned += 1;
    s.totalPlaySeconds += durationSeconds;
    stats.value = s;
    stats.refresh();
    await repository.saveStats(s);
  }

  // ── Settings changes ────────────────────────────────────────────────
  void setMode(GameMode m) {
    if (mode.value == m) return;
    mode.value = m;
    debugPrint('TTT ⚙️ mode -> ${m.name}');
    analytics.modeChanged(to: m.name);
    startNewGame();
  }

  void setDifficulty(Difficulty d) {
    if (difficulty.value == d) return;
    difficulty.value = d;
    debugPrint('TTT ⚙️ difficulty -> ${d.name}');
    analytics.difficultyChanged(to: d.name);
    startNewGame();
  }

  // ── Helpers ─────────────────────────────────────────────────────────
  String _turnMessage() {
    if (mode.value == GameMode.onePlayer) {
      return currentPlayer.value == 'X' ? 'Your turn (X)' : 'Computer thinking…';
    }
    return "Player ${currentPlayer.value}'s turn";
  }

  List<int> _emptyCells(List<String> b) {
    final cells = <int>[];
    for (int i = 0; i < b.length; i++) {
      if (b[i].isEmpty) cells.add(i);
    }
    return cells;
  }

  bool _isBoardFull(List<String> b) => !b.contains('');

  List<int>? _findWinningLine(List<String> b, String mark) {
    for (final line in _winLines) {
      if (b[line[0]] == mark && b[line[1]] == mark && b[line[2]] == mark) {
        return line;
      }
    }
    return null;
  }
}