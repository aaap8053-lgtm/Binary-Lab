import 'package:flutter/widgets.dart';

/// Tiny responsive helpers shared by every screen.
class AppLayout {
  AppLayout._();

  /// Phones < 640dp, tablets/desktop ≥ 640dp.
  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 640;
}
