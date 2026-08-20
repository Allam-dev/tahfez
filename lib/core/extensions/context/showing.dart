import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tahfez/core/error/failure.dart';
import 'package:tahfez/app/widgets/snackbars/error_snack_bar.dart';
import 'package:tahfez/app/widgets/snackbars/success_snack_bar.dart';

extension Showing on BuildContext {
  void showSnackBar({required SnackBar snackBar}) {
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  void showErrorSnakeBar(Failure failure) {
    return showSnackBar(snackBar: ErrorSnackBar(message: tr(failure.message)));
  }

  void showSuccessSnackBar(String message) {
    return showSnackBar(snackBar: SuccessSnackBar(message: message));
  }
}
