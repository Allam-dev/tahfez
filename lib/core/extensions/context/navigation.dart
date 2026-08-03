import 'package:flutter/material.dart';

extension Navigation on BuildContext {
  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);

  void popUntil(RoutePredicate predicate) =>
      Navigator.of(this).popUntil(predicate);

  Future<T?> push<T extends Object?>(Widget page) =>
      Navigator.of(this).push(MaterialPageRoute(builder: (context) => page));

  void pushReplacement(Widget page) => Navigator.of(
    this,
  ).pushReplacement(MaterialPageRoute(builder: (context) => page));

  void pushAndRemoveUntil(Widget page, {Function(Route<dynamic>)? predicate}) =>
      Navigator.of(this).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => page),
        (route) => predicate?.call(route) ?? false,
      );
}
