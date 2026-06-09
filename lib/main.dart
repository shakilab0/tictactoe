import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:tictactoe/app/my_app.dart';
import 'package:tictactoe/core/analytics/posthog_service.dart';
import 'package:tictactoe/feature/ticTacToe/data/model/game_stats_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(GameStatsAdapter());
  await Hive.openBox<GameStatsModel>(GameStatsModel.boxName);

  // ── 2. PostHog (analytics) ──────────────────────────────────────────
  final config = PostHogConfig('phc_wcVYoDKxaEskd2QpRE7vPw4yA2vA6AfUcgvXBBSfh34F');
  config.host = 'https://us.i.posthog.com';
  config.debug = true; // turn off in production
  await Posthog().setup(config);

  // ── 3. Global analytics service ─────────────────────────────────────
  Get.put<PostHogService>(PostHogService(), permanent: true);

  runApp(const MyApp());
}
