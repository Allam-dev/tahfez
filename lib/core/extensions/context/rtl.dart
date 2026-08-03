import 'package:flutter/material.dart';

extension Rtl on BuildContext {
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}