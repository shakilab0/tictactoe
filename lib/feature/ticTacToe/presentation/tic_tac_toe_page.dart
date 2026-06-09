import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'package:tictactoe/config/app_colors.dart';
import 'package:tictactoe/config/app_text_style.dart';
import 'package:tictactoe/feature/ticTacToe/domain/entity/game_enums.dart';
import 'package:tictactoe/feature/ticTacToe/presentation/tic_tac_toe_controller.dart';

class TicTacToePage extends GetView<TicTacToeController> {
  const TicTacToePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bg,
      appBar: AppBar(
        backgroundColor: AppColor.bg,
        elevation: 0,
        centerTitle: false,
        title: Text('TIC-TAC-TOE', style: textStyleTitle()),
        actions: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showStats(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 22, left: 40, bottom: 6, top: 6),
              child: Icon(Icons.bar_chart_rounded, color: AppColor.fg, size: 30),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  _scoreboard(),
                  const SizedBox(height: 6),
                  Obx(() => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      controller.statusMessage.value,
                      key: ValueKey(controller.statusMessage.value),
                      style: textStyleStatus(),
                    ),
                  )),
                  const SizedBox(height: 6),
                  _board(),
                  const SizedBox(height: 16),
                  _modeSelector(),
                  const SizedBox(height: 12),
                  Obx(() => controller.mode.value == GameMode.onePlayer
                      ? _difficultySelector()
                      : const SizedBox.shrink()),
                  const Spacer(),
                  _newGameButton(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Obx(() => controller.showWinAnimation.value
              ? Positioned.fill(child: _winAnimationOverlay())
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _winAnimationOverlay() {
    return IgnorePointer(
      child: Lottie.asset(
        TicTacToeController.winAnimationAsset,
        repeat: false,
        fit: BoxFit.cover,
        onLoaded: (composition) {
          Future.delayed(composition.duration, controller.onWinAnimationComplete);
        },
      ),
    );
  }

  // ── Scoreboard ──────────────────────────────────────────────────────
  Widget _scoreboard() {
    return Obx(() => Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.fg, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: AppColor.cell,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _scoreItem(controller.leftLabel, controller.xScore.value),
          Container(width: 1.5, height: 40, color: AppColor.fg.withOpacity(0.3)),
          _scoreItem('Tie', controller.tieScore.value),
          Container(width: 1.5, height: 40, color: AppColor.fg.withOpacity(0.3)),
          _scoreItem(controller.rightLabel, controller.oScore.value),
        ],
      ),
    ));
  }

  Widget _scoreItem(String label, int value) {
    return Column(
      children: [
        Text(label, style: textStyleLabel()),
        const SizedBox(height: 6),
        Text('$value', style: textStyleScore()),
      ],
    );
  }

  // ── Board ─────────────────────────────────────────────────────────────
  //  Simple, bullet-proof: 9 cells, each draws its OWN inner grid lines
  //  (right border for cols 0–1, bottom border for rows 0–1) → "#" look
  //  with no outer box. No Stack/overlay on top, so taps always register.
  Widget _board() {
    return AspectRatio(
      aspectRatio: 1,
      child: Obx(() => Column(
        children: List.generate(3, (row) {
          return Expanded(
            child: Row(
              children: List.generate(3, (col) {
                final int index = row * 3 + col;
                final String mark = controller.board[index];
                final bool isWinning = controller.winningLine.contains(index);
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      debugPrint('TTT 👉 widget tap reached cell $index');
                      controller.onCellTap(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isWinning
                            ? AppColor.accent.withOpacity(0.18)
                            : Colors.transparent,
                        border: Border(
                          right: col < 2
                              ? const BorderSide(color: AppColor.fg, width: 2)
                              : BorderSide.none,
                          bottom: row < 2
                              ? const BorderSide(color: AppColor.fg, width: 2)
                              : BorderSide.none,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 150),
                        style: TextStyle(
                          fontSize: mark.isEmpty ? 0 : 60,
                          fontWeight: FontWeight.bold,
                          color: mark == 'X' ? AppColor.xColor : AppColor.oColor,
                        ),
                        child: Text(mark),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      )),
    );
  }

  // ── Selectors ───────────────────────────────────────────────────────
  Widget _modeSelector() {
    return Obx(() => Row(
      children: [
        _toggle('1 Player', controller.mode.value == GameMode.onePlayer,
                () => controller.setMode(GameMode.onePlayer)),
        const SizedBox(width: 10),
        _toggle('2 Players', controller.mode.value == GameMode.twoPlayer,
                () => controller.setMode(GameMode.twoPlayer)),
      ],
    ));
  }

  Widget _difficultySelector() {
    return Obx(() => Row(
      children: [
        _toggle('Easy', controller.difficulty.value == Difficulty.easy,
                () => controller.setDifficulty(Difficulty.easy)),
        const SizedBox(width: 8),
        _toggle('Medium', controller.difficulty.value == Difficulty.medium,
                () => controller.setDifficulty(Difficulty.medium)),
        const SizedBox(width: 8),
        _toggle('Hard', controller.difficulty.value == Difficulty.hard,
                () => controller.setDifficulty(Difficulty.hard)),
      ],
    ));
  }

  Widget _toggle(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColor.fg : Colors.transparent,
            border: Border.all(color: AppColor.fg, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: selected ? AppColor.bg : AppColor.fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _newGameButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.rematch,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColor.fg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('↻  NEW GAME', style: textStyleButton()),
        ),
      ),
    );
  }

  void _showStats(BuildContext context) {
    final s = controller.stats.value;
    final width = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (_) => Center(
        child: Material(
          color: AppColor.bg,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: width * 0.9,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 22, right: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: Text('YOUR STATS', style: textStyleTitle()),
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _statRow('Games played', s.gamesPlayed),
                  _statRow('Wins', s.wins),
                  _statRow('Losses', s.losses),
                  _statRow('Ties', s.ties),
                  _statRow('Abandoned', s.abandoned),
                  _statRow('Total time (sec)', s.totalPlaySeconds),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColor.fg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'CLOSE',
                          style: textStyleLabel().copyWith(color: AppColor.bg),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyleLabel()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.fg.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$value', style: textStyleLabel()),
          ),
        ],
      ),
    );
  }
}