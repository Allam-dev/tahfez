import 'package:flutter/material.dart';
import 'package:tahfez/core/extensions/context/media_query.dart';

extension PaginationLimit on BuildContext {
  int paginationLimit(double itemHeight, double itemWidth) {
    final screenHeight = this.screenHeight;
    final screenWidth = this.screenWidth;

    final itemsPerRow = (screenWidth / itemWidth).floor();

    final itemsPerColumn = (screenHeight / itemHeight).floor();
    final totalItems = itemsPerColumn * itemsPerRow;

    return totalItems;
  }
}
