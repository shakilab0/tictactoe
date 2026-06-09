import 'package:flutter/material.dart';

/// Centralised colour palette — dark navy board with slate cells & teal wins.
class AppColor {
  AppColor._();

  static const Color bg = Color(0xFF1B1B28);
  static const Color fg = Color(0xFFFFFFFF);
  static const Color cell = Color(0xFF434356);
  static const Color accent = Color(0xFF3D8F7A);
  static const Color xColor = Color(0xFFFFFFFF);
  static const Color oColor = Color(0xFFFF4D4D);

  static const List<Color> onePlayerGradient = [Color(0xFFDC2626), Color(0xFFF97316)];
  static const List<Color> twoPlayerGradient = [Color(0xFF8B5CF6), Color(0xFFE689A3)];
  static const List<Color> easyGradient = [Color(0xFF10B981), Color(0xFF6EE7B7)];
  static const List<Color> mediumGradient = [Color(0xFFF59E0B), Color(0xFFFFB86C)];
  static const List<Color> hardGradient = [Color(0xFFEF4444), Color(0xFFE689A3)];
  static const List<Color> statsIconGradient = [Color(0xFF16A34A), Color(0xFFFACC15)];
}
