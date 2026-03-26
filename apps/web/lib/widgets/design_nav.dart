import 'package:flutter/material.dart';

enum ScreenType { video, dating, social, market, yoyo }

/// Dispatched by inner nav widgets to request a screen change
class ScreenChangeNotification extends Notification {
  final ScreenType screenType;
  const ScreenChangeNotification(this.screenType);
}
