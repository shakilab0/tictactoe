import 'package:flutter/material.dart';

/// Centralised colour palette (mirrors the `AppColor` pattern from your
/// production app). Retro black-on-off-white theme.
class AppColor {
  AppColor._();

  static const Color bg = Color(0xFFF5F5F0); // off-white background
  static const Color fg = Color(0xFF1A1A1A); // near-black foreground
  static const Color cell = Color(0xFFFFFFFF); // empty board cell
  static const Color accent = Color(0xFFB8E986); // winning-line highlight
  static const Color xColor = Color(0xFF276EF1); // player X (blue)
  static const Color oColor = Color(0xFFDE1135); // player O (red)
}
