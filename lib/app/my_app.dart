import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tictactoe/config/app_colors.dart';
import 'package:tictactoe/core/routes/routes.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tic-Tac-Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColor.bg,
        fontFamily: 'monospace',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.fg),
      ),
      getPages: routes,
      initialRoute: AppRoutes.gamePage,
    );
  }
}
