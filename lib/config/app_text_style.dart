import 'package:flutter/material.dart';
import 'package:tictactoe/config/app_colors.dart';

TextStyle textStyleTitle() => const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: 4,
      color: AppColor.fg,
    );

TextStyle textStyleStatus() => const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColor.fg,
    );

TextStyle textStyleLabel() => TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColor.fg.withOpacity(0.7),
    );

TextStyle textStyleScore() => const TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColor.fg,
    );

TextStyle textStyleButton() => const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
      color: AppColor.fg,
    );
