import 'package:flutter/material.dart';
import 'package:tahfez/core/extensions/context/theme.dart';

extension MoshafPage on BuildContext {
  String getThemedMoshafPage(String fileName) {
    if (isDarkMode) {
      return 'assets/quran_svg_dark/$fileName';
    } else {
      return 'assets/quran_svg/$fileName';
    }
  }
}
