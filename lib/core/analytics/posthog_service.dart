import 'dart:developer';
import 'package:get/get.dart';
import 'package:posthog_flutter/posthog_flutter.dart';


class PostHogService extends GetxService {

  Future<void> _capture(String event, {Map<String, Object>? props}) async {
    try {
      await Posthog().capture(eventName: event, properties: props);
    } catch (e) {
      log('PostHog capture failed for "$event": $e');
    }
  }

  // ── Game events ────────────────────────────────────────────────────
  Future<void> gameStarted({required String mode, required String difficulty,}) {
    return _capture('game_started', props: {'mode': mode, 'difficulty': difficulty});
  }


  Future<void> moveMade({required String player, required int position, required int moveNumber,}) {
   return _capture('move_made', props: {
      'player': player,
      'position': position,
      'move_number': moveNumber,
    });
  }


  Future<void> gameFinished({
    required String result, // win / lose / tie / x_win / o_win
    required String winner, // X / O / none
    required int totalMoves,
    required int durationSeconds,
    required String mode,
    required String difficulty,
  }) {
    return _capture('game_finished', props: {
      'result': result,
      'winner': winner,
      'total_moves': totalMoves,
      'duration_seconds': durationSeconds,
      'mode': mode,
      'difficulty': difficulty,
    });
  }


  /// Fired when the user leaves mid-game (app backgrounded before finish).
  Future<void> gameAbandoned({required int movesPlayed}) {
    return _capture('game_abandoned', props: {'moves_played': movesPlayed});
  }

  Future<void> difficultyChanged({required String to}) {
    return _capture('difficulty_changed', props: {'to': to});
  }

  Future<void> modeChanged({required String to}) {
    return _capture('mode_changed', props: {'to': to});
  }


  Future<void> rematchClicked() => _capture('rematch_clicked');

  /// Total seconds spent in this app session (fired when backgrounded).
  Future<void> sessionEnded({required int durationSeconds}) {
    return _capture('session_ended', props: {'duration_seconds': durationSeconds});
  }





}
